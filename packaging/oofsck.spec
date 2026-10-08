Name:           oofsck
Version:        0.2.0
Release:        1%{?dist}
Summary:        Sovereign filesystem consistency verifier and superblock/inode integrity auditor in pure openOODA.
License:        Apache-2.0
URL:            https://github.com/openOODA-tools/oofsck
Source0:        oofsck-linux-x86_64
Source1:        uninstall.sh
BuildArch:      x86_64
Requires:       glibc

%description
oofsck is a sovereign, capability-bounded filesystem consistency verifier and
superblock/inode integrity auditor written in 100% pure native openOODA with zero ambient authority,
ext4/btrfs/xfs/vfat superblock inspection, non-destructive audit semantics, and streaming Model Context Protocol (MCP) support.

%install
mkdir -p %{buildroot}/usr/bin
install -m 0755 %{SOURCE0} %{buildroot}/usr/bin/oofsck
install -m 0755 %{SOURCE1} %{buildroot}/usr/bin/oofsck-uninstall

%files
/usr/bin/oofsck
/usr/bin/oofsck-uninstall

%changelog
* Wed Oct 07 2026 openOODA-tools <ops@openooda.org> - 0.2.0-1
- Sovereign filesystem consistency verifier with streaming MCP and tri-distribution packaging
