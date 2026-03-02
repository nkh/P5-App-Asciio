# Asciio Debian Packaging - Quick Reference

### Manual Build

```bash
# Clone repository
git clone https://github.com/nkh/P5-App-Asciio.git
cd P5-App-Asciio

# Build package, not signed
./build_debian_package

# Install
sudo apt-get install ./asciio_<version>.deb
```

## Common Commands

### Build with signing
```bash
dpkg-buildpackage -b
```


## File Locations After Installation

| Item          | Location                 |
| ------        | ----------               |
| Binaries      | `/usr/local/bin/`        |
| Perl modules  | `/usr/share/perl5/`      |
| Documentation | `/usr/share/doc/asciio/` |
| Config files  | `/usr/share/asciio/`     |
| User config   | `~/.config/Asciio/`      |

## Binaries Installed

- `asciio` - GUI version (GTK3)
- `tasciio` - TUI version (terminal)
- `asciio_to_text` - Convert .asciio to ASCII
- `text_to_asciio` - Convert text to .asciio

## Package Information

```bash
# Show package info
dpkg -s asciio

# List files in package
dpkg -L asciio

# Verify installation
which asciio tasciio asciio_to_text text_to_asciio
```

## Troubleshooting

### Build fails - missing dependencies

```bash
sudo apt-get install debhelper devscripts build-essential libmodule-build-perl perl cpanminus
```

### Runtime dependency issues

```bash
sudo apt-get install -f
```

### CPAN module not installing

```bash
sudo cpanm --force Data::TreeDumper::Renderer::GTK
```

### Test build in clean environment

```bash
docker run -it --net=host --env="DISPLAY" --volume="$HOME/.Xauthority:/root/.Xauthority:rw" --volume=`pwd`":/asciio" debian:latest bash

# Then follow build instructions
```

## Package Signing

### Setup GPG key

```bash
gpg --gen-key
gpg --list-keys
```

### Sign package

```bash
dpkg-buildpackage -b
# Will prompt for GPG passphrase
```

## Version Updates

### Update changelog

```bash
dch -v 1.90.03-1 "New upstream release"
```

### Build new version

```bash
dpkg-buildpackage -us -uc -b
```

## Uninstallation

```bash
sudo apt-get remove asciio
# or for complete removal including config
sudo apt-get purge asciio
```

## Support

- GitHub Issues: https://github.com/nkh/P5-App-Asciio/issues
- Documentation: https://nkh.github.io/P5-App-Asciio/
