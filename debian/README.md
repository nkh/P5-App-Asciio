# Asciio Debian Package Build Instructions

This directory contains the Debian packaging files for Asciio, a Perl GTK3 application for creating ASCII diagrams.

## Package Information

- Package Name: asciio
- Version:      see *changelog*
- Architecture: all
- Section:      graphics
- Priority:     optional

## Prerequisites

```bash
sudo apt-get install debhelper devscripts build-essential libmodule-build-perl perl cpanminus
```

## Directory Structure

The packaging files are in the `debian/` subdirectory of your cloned Asciio repository:

```
P5-App-Asciio/
├── debian/
│   ├── changelog
│   ├── compat
│   ├── control
│   ├── copyright
│   ├── docs
│   ├── install
│   ├── postinst
│   ├── rules
│   ├── watch
│   └── format
├── lib/
├── script/
└── [other source files]
```

## Building the Package

### Clone the Repository

```bash
git clone https://github.com/nkh/P5-App-Asciio.git
cd P5-App-Asciio
```

### Build the package

```bash
./build_debian_package
```

### Install the Package

```bash
apt update
apt install ./asciio_1.97.0-1_all.deb
```

## Package Contents

### Binaries (in /usr/local/bin/)

- `asciio`         - GUI application using GTK3
- `tasciio`        - TUI (Terminal User Interface) application
- `asciio_to_text` - Converts .asciio files to ASCII text
- `text_to_asciio` - Creates .asciio files from text

### Configuration Files (in /usr/share/asciio/)

- `default_stencil.asciio` - Default stencil configuration
- `asciio.magic` - File type magic numbers

### Documentation (in /usr/share/doc/asciio/)

- README.md
- Todo.txt
- documentation/
- examples/

### Perl Modules (in /usr/share/perl5/)

All App::Asciio::* modules will be installed in the vendor Perl directory.

## Dependencies

### Build Dependencies

- debhelper-compat (>= 13)
- perl
- libmodule-build-perl

### Runtime Dependencies

The package depends on numerous Perl modules:

- libdata-compare-perl
- libdirectory-scratch-structured-perl
- libeval-context-perl
- libgtk3-perl
- libio-prompter-perl
- libterm-size-any-perl
- libterm-termkey-perl
- And many more (see debian/control for complete list)

### CPAN Dependencies

One dependency is not available in Debian repositories and will be installed from CPAN automatically during package installation:

- Data::TreeDumper::Renderer::GTK
- and other

This is handled by the `debian/postinst` script.

## Configuration

After installation, you can configure Asciio by creating/editing:

```
~/.config/Asciio/
```

The default configuration from the OCI/Asciio directory will be used as a template.

## Troubleshooting

### Missing Dependencies

If you encounter missing Perl module dependencies during installation:

```bash
sudo apt-get install -f
```

### CPAN Module Installation

If Data::TreeDumper::Renderer::GTK fails to install automatically:

```bash
sudo cpanm --force Data::TreeDumper::Renderer::GTK
```

## Customization

### Changing Installation Directory

The package is configured to install binaries to `/usr/local/bin/`. To change this:

1. Edit `debian/rules` in the `override_dh_auto_install` section
2. Modify the destination path as needed

### Adding Custom Patches

To add patches:

1. Create `debian/patches/` directory
2. Add patch files
3. Create `debian/patches/series` listing the patches
4. Patches will be applied automatically during build

## Package Maintenance

### Updating Version

To update the package version:

```bash
dch -v 1.90.03-1 "New upstream release"
```

This will update `debian/changelog` with proper formatting.


## Files Description

- changelog:     Package version history and changes
- compat:        Debhelper compatibility level
- control:       Package metadata, dependencies, and description
- copyright:     Licensing information
- docs:          List of documentation files to include
- install:       Additional files to install beyond automatic installation
- postinst:      Post-installation script for CPAN dependencies
- rules:         Build instructions and customizations
- watch:         Upstream version tracking
- source/format: Source package format specification

## License

The packaging files are distributed under the same license as Asciio itself (Artistic License or GPL-3+).

## Authors

- Khemir Nadim ibn Hamouda (Upstream author)
- Qin Qing (Contributor)

## Resources

- GitHub Repository:      https://github.com/nkh/P5-App-Asciio
- Documentation:          https://nkh.github.io/P5-App-Asciio/
- Debian Packaging Guide: https://www.debian.org/doc/manuals/maint-guide/
