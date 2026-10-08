# ==============================================================================
# oofsck: Sovereign Filesystem Consistency Verifier & Superblock/Inode Auditor
# Verification and Lifecycle Makefile
# ==============================================================================

SHELL := /bin/bash
BIN := dist/oofsck
SRC := $(shell find . -name "*.oo" -o -name "*.oot" 2>/dev/null)
VERSION := $(shell cat VERSION 2>/dev/null || echo "0.2.0")
OODA_COMPILER ?= /home/ubermetroid/.openooda/bin/oodac
OODACODEX ?= /home/ubermetroid/.openooda/northstar.oot
OO_LIST_AMBIENT_QUOTA ?= 8589934592

.PHONY: all verify build test package clean check line-cap file-law academy density package-deb package-rpm package-arch

all: verify build test

$(BIN): $(SRC)
	@mkdir -p dist
	OO_LIST_AMBIENT_QUOTA=$(OO_LIST_AMBIENT_QUOTA) \
	OODACODEX=$(OODACODEX) \
	OODA_COMPILER=$(OODA_COMPILER) \
	OODA_NO_JAIL=1 \
	$(OODA_COMPILER) build main.oo -o $(BIN)
	@cp $(BIN) dist/oofsck-linux-x86_64
	@cd dist && sha256sum oofsck-linux-x86_64 > oofsck-linux-x86_64.sha256
	@echo "built $(BIN) (and dist/oofsck-linux-x86_64)"

build: $(BIN)

line-cap:
	@violations=0; \
	for f in $$(find . -name "*.oo" -o -name "*.oot" | grep -v '\.git' | grep -v 'dist/'); do \
		lines=$$(wc -l < "$$f"); \
		if grep -q '^// # ' "$$f" && [ $$lines -lt 16 ]; then \
			echo "VIOLATION: $$f has $$lines lines (< 16 floor)"; violations=$$((violations+1)); \
		fi; \
		if [ $$lines -gt 256 ]; then \
			echo "VIOLATION: $$f has $$lines lines (> 256 cap)"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: $$violations files violate line bounds"; exit 1; fi; \
	echo "PASS: Page Rule sizing (16-256 lines, shims exempt from floor) holds"

file-law:
	@bad=$$(find . -name "*.oo" | grep -E '(utils?|helpers?|common|misc|shared|base)\.oo$$' | grep -v 'dist/' || true); \
	if [ -n "$$bad" ]; then \
		echo "VIOLATION: Generic drawer filenames detected:"; echo "$$bad"; exit 1; \
	fi; \
	echo "PASS: file law holds"

academy:
	@missing=0; \
	for f in $$(find . -name "*.oo" -not -path "./dist/*"); do \
		hdr=$$(head -n 7 "$$f"); \
		for elem in "// # " "// Logline:" "// Setup:" "// Beats:"; do \
			if ! echo "$$hdr" | grep -qF "$$elem"; then \
				echo "VIOLATION: $$f missing '$$elem' in first 7 lines"; missing=$$((missing+1)); \
			fi; \
		done; \
	done; \
	if [ $$missing -gt 0 ]; then echo "FAIL: $$missing missing Academy header elements"; exit 1; fi; \
	echo "PASS: academy headers hold (all 4 elements present in first 7 lines)"

density:
	@violations=0; \
	for d in $$(find . -maxdepth 3 -type d -not -path '*/.*' -not -path './dist*' -not -path './packaging*'); do \
		n=$$(ls "$$d"/*.oo "$$d"/*.oot 2>/dev/null | grep -v '\*' | wc -l); \
		if [ $$n -gt 8 ]; then \
			echo "VIOLATION: $$d holds $$n pages (exceeds 8)"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: $$violations directories exceed the density bound"; exit 1; fi; \
	echo "PASS: directory density (<= 8 pages per directory) holds"

check:
	@for f in $$(find . -name "*.oo" -not -path "./dist/*"); do \
		OO_LIST_AMBIENT_QUOTA=$(OO_LIST_AMBIENT_QUOTA) OODACODEX=$(OODACODEX) OODA_COMPILER=$(OODA_COMPILER) OODA_NO_JAIL=1 $(OODA_COMPILER) check "$$f" > /dev/null || exit 1; \
	done; \
	echo "PASS: oodac check holds on all .oo files"

verify: line-cap file-law academy density check

test: $(BIN)
	@echo "=== testing --help ==="
	@./$(BIN) --help | grep -q "oofsck" && echo "PASS: --help"
	@echo "=== testing --version ==="
	@./$(BIN) -V | grep -q "oofsck" && echo "PASS: --version"
	@echo "=== testing internal anchors ==="
	@./$(BIN) --test | grep -q "PASSED" && echo "PASS: internal anchors"
	@echo "=== testing default report ==="
	@./$(BIN) | grep -q "Phase 1:" && echo "PASS: default report"
	@echo "=== testing verbose report -v ==="
	@./$(BIN) -v | grep -q "Root inode" && echo "PASS: verbose report -v"
	@echo "=== testing JSON mode -j ==="
	@./$(BIN) -j | grep -q '"integrity_score":' && echo "PASS: JSON mode -j"
	@echo "=== testing showcase --demo -D ==="
	@./$(BIN) -D | grep -q "Showcase" && echo "PASS: --demo"
	@echo "=== testing MCP initialize ==="
	@printf '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}\n' | ./$(BIN) --mcp | grep -q "protocolVersion" && echo "PASS: MCP initialize"
	@echo "=== testing MCP tools/list ==="
	@printf '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}\n' | ./$(BIN) --mcp | grep -q "fsck_inspect_superblock" && echo "PASS: MCP tools/list"
	@echo "=== testing MCP tools/call fsck_inspect_superblock ==="
	@printf '{"jsonrpc":"2.0","id":3,"method":"tools/call","name":"fsck_inspect_superblock","device":"/dev/sda1"}\n' | ./$(BIN) --mcp | grep -q "total_blocks" && echo "PASS: MCP fsck_inspect_superblock"
	@echo "=== testing MCP tools/call fsck_verify_inodes ==="
	@printf '{"jsonrpc":"2.0","id":4,"method":"tools/call","name":"fsck_verify_inodes","device":"/dev/sda1"}\n' | ./$(BIN) --mcp | grep -q "inodes_checked" && echo "PASS: MCP fsck_verify_inodes"
	@echo "=== testing MCP tools/call fsck_audit_partition ==="
	@printf '{"jsonrpc":"2.0","id":5,"method":"tools/call","name":"fsck_audit_partition","device":"/dev/sda1"}\n' | ./$(BIN) --mcp | grep -q "Phase 1:" && echo "PASS: MCP fsck_audit_partition"
	@echo "=== testing MCP tools/call fsck_check_integrity ==="
	@printf '{"jsonrpc":"2.0","id":6,"method":"tools/call","name":"fsck_check_integrity","device":"/dev/sda1"}\n' | ./$(BIN) --mcp | grep -q "integrity_score" && echo "PASS: MCP fsck_check_integrity"
	@echo "=== testing MCP tools/call fsck_demo ==="
	@printf '{"jsonrpc":"2.0","id":7,"method":"tools/call","name":"fsck_demo"}\n' | ./$(BIN) --mcp | grep -q "Showcase" && echo "PASS: MCP fsck_demo"
	@echo "ALL TESTS PASSED"

package-deb: $(BIN)
	@mkdir -p dist/deb-root/DEBIAN dist/deb-root/usr/bin
	@sed "s/^Version:.*/Version: $(VERSION)-1/" packaging/debian/control.binary > dist/deb-root/DEBIAN/control
	@cp $(BIN) dist/deb-root/usr/bin/oofsck
	@chmod 0755 dist/deb-root/usr/bin/oofsck
	@cp uninstall.sh dist/deb-root/usr/bin/oofsck-uninstall
	@chmod 0755 dist/deb-root/usr/bin/oofsck-uninstall
	@dpkg-deb --build --root-owner-group dist/deb-root dist/oofsck_$(VERSION)-1_amd64.deb
	@rm -rf dist/deb-root
	@echo "built dist/oofsck_$(VERSION)-1_amd64.deb"

package-rpm: $(BIN)
	@mkdir -p ~/rpmbuild/SOURCES ~/rpmbuild/SPECS ~/rpmbuild/RPMS
	@cp $(BIN) ~/rpmbuild/SOURCES/oofsck-linux-x86_64
	@cp uninstall.sh ~/rpmbuild/SOURCES/uninstall.sh
	@sed "s/^Version:.*/Version: $(VERSION)/" packaging/oofsck.spec > ~/rpmbuild/SPECS/oofsck.spec
	@rpmbuild -bb ~/rpmbuild/SPECS/oofsck.spec
	@cp ~/rpmbuild/RPMS/x86_64/oofsck-$(VERSION)*.rpm dist/
	@echo "built dist RPM package"

package-arch: $(BIN)
	@mkdir -p dist/arch-pkg/usr/bin
	@cp $(BIN) dist/arch-pkg/usr/bin/oofsck
	@chmod 0755 dist/arch-pkg/usr/bin/oofsck
	@cp uninstall.sh dist/arch-pkg/usr/bin/oofsck-uninstall
	@chmod 0755 dist/arch-pkg/usr/bin/oofsck-uninstall
	@printf "pkgname = oofsck\npkgbase = oofsck\npkgver = $(VERSION)-1\npkgdesc = Sovereign filesystem consistency verifier and superblock/inode integrity auditor in pure openOODA.\nurl = https://github.com/openOODA-tools/oofsck\nbuilddate = $$(date +%s)\npackager = openOODA-tools <ops@openooda.org>\nsize = $$(stat -c %s $(BIN))\narch = x86_64\nlicense = Apache-2.0\ndepend = glibc\nprovides = oofsck\n" > dist/arch-pkg/.PKGINFO
	@tar --zstd -cf dist/oofsck-$(VERSION)-1-x86_64.pkg.tar.zst -C dist/arch-pkg .PKGINFO usr
	@rm -rf dist/arch-pkg
	@bash -n packaging/arch/PKGBUILD
	@cp packaging/arch/PKGBUILD packaging/PKGBUILD
	@echo "built dist/oofsck-$(VERSION)-1-x86_64.pkg.tar.zst and validated PKGBUILD"

package: package-deb package-rpm package-arch
	@cd dist && sha256sum oofsck* > checksums.txt 2>/dev/null || true
	@echo "built all packages and dist/checksums.txt"

clean:
	@rm -rf dist .ooda-cache
	@echo "cleaned"
