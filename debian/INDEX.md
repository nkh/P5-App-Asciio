# Asciio Debian Packaging Files - Index

## Documentation Files (Read These First)

**PACKAGE_SUMMARY.md** - Complete overview of the package
- What it does
- Structure
- Features
- All details in one place

**README.md** - Comprehensive build and installation guide
- Prerequisites
- Step-by-step instructions
- Configuration details
- Package contents

**QUICK_REFERENCE.md** - Command cheat sheet
- Common commands
- File locations
- Quick troubleshooting
- One-page reference

**TROUBLESHOOTING.md** - Problem solving guide
- Build issues
- Installation problems
- Runtime errors
- Debugging tips

## Packaging Files (debian/ directory)

### Essential Files

- **debian/control** - Package metadata and dependencies
  - Package name: asciio
  - Version: see *changelog*
  - Dependencies: 20+ Perl modules
  - Architecture: all

- **debian/rules** - Build instructions
  - Uses Module::Build
  - Installs to /usr/local/bin
  - Skips tests (GUI requirement)
  - Executable file

- **debian/changelog** - Version history

- **debian/copyright** - License information
  - Artistic License or GPL-3+
  - Upstream and packaging

### Supporting Files

- **compat** -   Debhelper version (13)
- **install** -  Additional files to install
- **docs** -     Documentation list
- **postinst** - Post-installation script (CPAN handling)
- **watch** -    Upstream version tracking
- **format** -   Package format (3.0 quilt)

## Build Automation

- **build-package.sh** - Automated build script
  - Clones repository
  - Copies debian files
  - Builds package
  - Optional installation

## Files

- Documentation
- Debian packaging
- Build automation

## Recommended Reading Order

### For First-Time Users:

1. PACKAGE_SUMMARY.md (overview)
2. README.md (detailed guide)
3. build-package.sh --help (automation)
4. Build the package!

### For Quick Setup:

1. QUICK_REFERENCE.md
2. Run: `./build-package.sh --clean --install`

### When Problems Occur:

1. TROUBLESHOOTING.md
2. Check build logs
3. GitHub issues

### For Package Maintainers:

1. PACKAGE_SUMMARY.md
2. debian/control (dependencies)
3. debian/rules (build process)
4. debian/changelog (versioning)

## What Gets Built

**Package**: asciio_<VERSION>.deb

**Installs**:
- 4 binaries in /usr/local/bin/
  - asciio (GUI)
  - tasciio (TUI)
  - asciio_to_text (converter)
  - text_to_asciio (converter)

- Perl modules in /usr/share/perl5/
- Config files in /usr/share/asciio/
- Documentation in /usr/share/doc/asciio/

## Dependencies Required

### To Build:

```bash
sudo apt-get install debhelper devscripts build-essential libmodule-build-perl perl cpanminus
```

### Runtime (installed automatically):

- 20+ Perl modules from Debian
- Perl modules from CPAN (automatic via postinst)

## Usage After Installation

```bash
# GUI mode
asciio diagram.asciio

# TUI mode
tasciio diagram.asciio

# Convert to ASCII
asciio_to_text diagram.asciio > output.txt

# Create from text
text_to_asciio < input.txt
```

## Package Features

- Complete dependency management
- Automated CPAN handling
- Installation to /usr/local/bin
- Comprehensive documentation
- Build automation script

- Troubleshooting guide
- Clean uninstall support
- Standards compliant
- GTK3 GUI interface
- Terminal TUI interface

## License

Artistic License or GPL-3+
(Same as Perl itself)

## Support

- Upstream:      https://github.com/nkh/P5-App-Asciio
- Documentation: https://nkh.github.io/P5-App-Asciio/
- Issues:        https://github.com/nkh/P5-App-Asciio/issues

## Credits

**Upstream Authors:**
- Khemir Nadim ibn Hamouda
- Qin Qing

**Package Maintainer:**
- Khemir Nadim ibn Hamouda <nkh@cpan.org>

## Version

Package Version:  see *chagelog*
Packaging Date:   February 2025
Debian Standards: 4.6.0
Debhelper Compat: 13

