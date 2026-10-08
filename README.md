# oofsck: Sovereign FS INTEGRITY

<div align="center">

```
================================================================================
                                oofsck
               Sovereign openOODA FS INTEGRITY
================================================================================
```

**Sovereign FS INTEGRITY**  
*Sovereign filesystem consistency verifier and superblock/inode integrity auditor in pure openOODA.*  
*Two Faces, One Engine:* Modern terminal ergonomics for humans • Zero-leakage MCP for AI agents  
Written in 100% pure [openOODA](https://github.com/openOODA).

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![openOODA](https://img.shields.io/badge/openOODA-1.0-emerald.svg)](https://openooda.org)
[![Architecture: x86_64 | aarch64](https://img.shields.io/badge/Arch-x86__64%20%7C%20aarch64-lightgrey.svg)]()

</div>

---

## 1. Quick Install

### Automated Installer (Linux x86_64 & aarch64)
```bash
curl -fsSL https://openooda-tools.github.io/oofsck/install.sh | bash
```

### Native Package Managers
```bash
# Arch Linux (AUR / PKGBUILD)
yay -S oofsck-bin
# Or manual PKGBUILD:
cd packaging/arch && makepkg -si

# Debian / Ubuntu (.deb)
curl -fsSL https://openooda-tools.github.io/oofsck/install.sh | bash -s -- --deb

# Fedora / RHEL (.rpm)
curl -fsSL https://openooda-tools.github.io/oofsck/install.sh | bash -s -- --rpm
```

### Uninstallation
```bash
oofsck-uninstall
# or: curl -fsSL https://openooda-tools.github.io/oofsck/uninstall.sh | bash
```

---

## 2. CLI Usage

```
oofsck 0.2.0 (openOODA sovereign filesystem integrity)
usage: oofsck [options] [DEVICE|IMAGE]

Sovereign filesystem consistency verifier and superblock/inode integrity auditor.

Audit & Verification Options:
  -n, --read-only     open filesystem read-only (non-destructive audit default)
  -f, --force         force checking even if filesystem is marked clean
  -v, --verbose       display detailed inode, block group, and extent diagnostics
  -p, --preen         evaluate non-interactive safe preen status
  -j, --json          output structured metrics formatted as JSON
  -D, --demo          interactive multi-filesystem integrity showcase
      --test          execute internal subsystem verification suite
      --mcp           run as Model Context Protocol JSON-RPC stdio server
  -V, --version       output version information and exit
  -h, --help          display this help and exit
```

---

## 3. Theming Integration (`oote`)

`oofsck` synchronizes visual styles and status colors with [oote](https://github.com/openOODA-tools/oote):
* **Configuration:** Reads active palette from `~/.openooda/theme.oot`.
* **Environment Overrides:** Respects `$OODA_THEME` and `$NO_COLOR`.

---

## 4. Model Context Protocol (MCP)

When invoked with `--mcp`, `oofsck` runs a streaming JSON-RPC 2.0 stdio server exposing 5 tools for AI coding agents:
* `fsck_inspect_superblock`: Parse and inspect filesystem superblock headers, UUID, and volume geometry.
* `fsck_verify_inodes`: Audit inode allocation table, extent tree bounds, and pointer integrity.
* `fsck_audit_partition`: Perform complete non-destructive consistency audit on a partition or device image.
* `fsck_check_integrity`: Rapid integrity check returning boolean clean status, error count, and health score.
* `fsck_demo`: Run multi-filesystem interactive superblock and inode integrity verification showcase.

```bash
oofsck --mcp
```

---

## 5. Security & Zero Ambient Authority

* **Pure Capability Bounded:** Operates strictly with explicit tokens (`&FsReadCap`, `&ProcessCap`, `&EnvCap`, `&McpCap`). Physical absence of ambient disk writes or network leakage.
* **Negative-Trust Architecture:** Strict input validation and non-destructive audit semantics.
* **Hermetic Binary:** Standalone zero-dependency executable.

---

## 6. License

Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
