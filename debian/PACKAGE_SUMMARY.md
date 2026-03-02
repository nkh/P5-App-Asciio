# Asciio Debian Package - Complete Package Summary

## Overview

This package contains all necessary files to build a Debian package for Asciio, a Perl GTK3 application for creating interactive ASCII diagrams.

**Repository**:      https://github.com/nkh/P5-App-Asciio
**License**:         Artistic License or GPL-3+
**Package Version**: see *changelog*

## What This Does

Creates a Debian package that installs:

**Four command-line tools** in `/usr/local/bin/`:
- `asciio` - GTK3 GUI for creating ASCII diagrams
- `tasciio` - Terminal UI version
- `asciio_to_text` - Converter from .asciio to ASCII
- `text_to_asciio` - Converter from text to .asciio

**Perl modules** for App::Asciio in vendor directories

**Configuration files** in `/usr/share/asciio/`

**Documentation** in `/usr/share/doc/asciio/`

## Key Features

### Packaging Features

- **Automated dependency handling**:  All Debian-available dependencies listed in control file
- **CPAN fallback**:                  postinst script handles non-Debian dependencies
- **Installation to /usr/local/bin**: As requested by user
- **Comprehensive documentation**:    Multiple guide files included
- **Build automation**:               Script to automate entire build process
- **Clean uninstall**:                Proper package removal support

## Files Description

### debian/control

Package metadata including:
- Package name, section, priority
- Maintainer information
- All build and runtime dependencies
- Package description with feature list

### debian/rules

Build instructions with customizations:
- Uses Module::Build (perl Build.PL)
- Skips tests (require DISPLAY)
- Moves binaries to /usr/local/bin
- Custom clean target

### debian/changelog

Version history in Debian format:
- Current version: 1.90.02-1
- Lists all changes and features
- Proper timestamp and maintainer info

### debian/copyright

License information:
- Upstream license: Artistic or GPL-3+
- Debian packaging license: Same as upstream
- Full license text references

### debian/install

Additional file installation:
- Configuration files
- Templates
- Documentation
- Examples

### debian/postinst

Post-installation script:
- Installs Data::TreeDumper::Renderer::GTK from CPAN
- Only runs if module not already available
- Handles errors gracefully

### debian/docs

Documentation files to include:
- README.md
- Todo.txt
- documentation directory
- examples directory

### debian/watch

Upstream version monitoring:
- Tracks GitHub releases
- Version 4 watch file format
- Automatic tarball detection

## Build Process

The package uses Module::Build (Perl Build.PL system):

**Configure**:    `perl Build.PL --installdirs vendor`
**Build**:        `./Build`
**Test**:         Skipped (requires DISPLAY)
**Install**:      `./Build install` with custom path handling
**Post-install**: CPAN dependency installation

## Installation Layout

```
/usr/local/bin/
├── asciio
├── tasciio
├── asciio_to_text
└── text_to_asciio

/usr/share/perl5/
└── App/
    └── Asciio/
        └── [all modules]

/usr/share/asciio/
├── default_stencil.asciio
└── asciio.magic

/usr/share/doc/asciio/
├── README.md
├── Todo.txt
├── documentation/
├── examples/
└── copyright

~/.config/Asciio/
└── [user configuration]
```

## Customization Options

### Change installation directory

Edit `debian/rules`, modify the `override_dh_auto_install` section

### Add patches

Create `debian/patches/` directory and add patch files

### Change dependencies

Edit `debian/control`, update the Depends field

### Modify build process

Edit `debian/rules`, add or modify override targets

## Known Limitations

**CPAN dependency**: 
- Handled automatically via postinst script
- May require network access during installation

**Tests skipped**: GUI tests need DISPLAY environment
- Documented in debian/rules
- Can be enabled for local testing

**/usr/local/bin location**: Non-standard for Debian packages
- May conflict with local installations

## Maintenance

### Update to new upstream version

```bash
# Update changelog
dch -v 1.90.03-1 "New upstream release"


## Support and Resources

### Documentation
- README.md - Complete guide
- QUICK_REFERENCE.md - Command reference
- TROUBLESHOOTING.md - Problem solving

### External Resources
- Upstream:      https://github.com/nkh/P5-App-Asciio
- Debian         Guide: https://www.debian.org/doc/manuals/maint-guide/
- Module::Build: https://metacpan.org/pod/Module::Build

### Getting Help
- Check TROUBLESHOOTING.md
- Review build logs
- Test in clean environment
- Report issues on GitHub

## License

Both the packaging files and Asciio itself are dual-licensed:
- Artistic License (Perl)
- GNU General Public License v3 or later

## Credits

**Upstream Authors:**
- Khemir Nadim ibn Hamouda (nkh)
- Qin Qing

**Debian Packaging:**
- Customized for /usr/local/bin installation
- Enhanced with comprehensive documentation

## Future Enhancements

Potential improvements:
- extract version from repository
- Desktop file for GUI launcher
- Man pages for commands
- Bash completion scripts
- Systemd integration (if needed)

## Package Verification

### Build reproducibility

The package should build identically from the same source:

```bash
dpkg-buildpackage -us -uc -b
# Compare checksums with previous build
```

### Security considerations

- No network access during build (except CPAN in postinst)
- All dependencies from trusted sources
- GPG signing available for distribution
