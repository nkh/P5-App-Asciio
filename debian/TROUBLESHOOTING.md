# Asciio Debian Package - Troubleshooting Guide

## Build Issues

### Issue: Missing build dependencies

**Symptoms:**
```
dpkg-buildpackage: error: cannot find debhelper
```

**Solution:**
```bash
sudo apt-get update
sudo apt-get install debhelper devscripts build-essential libmodule-build-perl perl cpanminus
```

### Issue: Module::Build errors

**Symptoms:**
```
Can't locate Module/Build.pm
```

**Solution:**
```bash
sudo apt-get install libmodule-build-perl
```

### Issue: Tests fail during build

**Symptoms:**
```
Test failures during dpkg-buildpackage
```

**Solution:**
Tests are skipped in `debian/rules`, but if you modified it:
```bash
# Edit debian/rules and ensure override_dh_auto_test is present
override_dh_auto_test:
	# Skip tests during package build
```

## Installation Issues

### Issue: Unmet dependencies

**Symptoms:**
```
dpkg: dependency problems prevent configuration of asciio
```

**Solution:**
```bash
sudo apt-get install -f
```

### Issue: Data::TreeDumper::Renderer::GTK not installing

**Symptoms:**
```
Can't locate Data/TreeDumper/Renderer/GTK.pm
```

**Solution:**
```bash
# Manual installation
sudo cpanm --force Data::TreeDumper::Renderer::GTK

# Or with verbose output to see what's failing
sudo cpanm --verbose Data::TreeDumper::Renderer::GTK
```

### Issue: GTK3 Perl bindings missing

**Symptoms:**
```
Can't locate Gtk3.pm
```

**Solution:**
```bash
sudo apt-get install libgtk3-perl
```

### Issue: Term::TermKey not found

**Symptoms:**
```
Can't locate Term/TermKey.pm
```

**Solution:**
```bash
sudo apt-get install libterm-termkey-perl libtermkey-dev
```

## Runtime Issues

### Issue: asciio command not found

**Symptoms:**
```bash
$ asciio
bash: asciio: command not found
```

**Solution:**
```bash
# Check if installed
which asciio

# Check installation location
dpkg -L asciio | grep bin

# Add to PATH if in /usr/local/bin
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Issue: GUI doesn't start - DISPLAY error

**Symptoms:**
```
Can't open display
```

**Solution:**
```bash
# Make sure you're in a graphical environment
echo $DISPLAY  # Should show something like :0

# If using SSH
ssh -X user@host

# Or use the TUI version instead
tasciio
```

### Issue: Missing configuration directory

**Symptoms:**
```
Can't find configuration files
```

**Solution:**
```bash
# Create user config directory
mkdir -p ~/.config/Asciio

# Copy default configuration
cp -r /usr/share/asciio/* ~/.config/Asciio/
```

### Issue: Permission denied for binaries

**Symptoms:**
```
Permission denied: /usr/local/bin/asciio
```

**Solution:**
```bash
# Check permissions
ls -l /usr/local/bin/asciio

# Fix if needed
sudo chmod +x /usr/local/bin/asciio
sudo chmod +x /usr/local/bin/tasciio
sudo chmod +x /usr/local/bin/asciio_to_text
sudo chmod +x /usr/local/bin/text_to_asciio
```

## Package Quality Issues

### Issue: Lintian warnings

**Check package quality:**
```bash
lintian ../asciio_*.deb
```

**Common warnings and solutions:**

1. **W: asciio: binary-in-usr-local**
   - This is by design for this package
   - Can be suppressed with lintian override if needed

2. **W: asciio: hardening-no-fortify-functions**
   - Perl scripts don't need fortification
   - Can be ignored

3. **E: asciio: debian-changelog-file-is-missing**
   - Make sure debian/changelog exists and is properly formatted

## Dependency-Specific Issues

### Issue: Sereal errors

**Symptoms:**
```
Can't locate Sereal.pm
```

**Solution:**
```bash
sudo apt-get install libsereal-perl
```

### Issue: IO::Prompter not working

**Symptoms:**
```
Can't locate IO/Prompter.pm
```

**Solution:**
```bash
sudo apt-get install libio-prompter-perl
```

### Issue: Compress::Bzip2 errors

**Symptoms:**
```
Can't locate Compress/Bzip2.pm
```

**Solution:**
```bash
sudo apt-get install libcompress-bzip2-perl
```

## Debugging Tips

### Enable verbose output during build

```bash
DH_VERBOSE=1 dpkg-buildpackage -us -uc -b
```

### Check what files are installed

```bash
dpkg -L asciio
```

### Verify dependencies

```bash
dpkg -s asciio | grep Depends
```

### Test in clean environment

```bash
# Using Docker
docker run -it --net=host --env="DISPLAY" --volume="$HOME/.Xauthority:/root/.Xauthority:rw" --volume=`pwd`":/asciio" debian:latest bash

# Then install and test

# Or using chroot/systemd-nspawn
sudo debootstrap stable /var/lib/machines/debian-test
sudo systemd-nspawn -D /var/lib/machines/debian-test
```

### Check build logs

```bash
# Build logs are in parent directory
cat ../*.build
cat ../*.changes
```

## Platform-Specific Issues

### Debian Stable (Bookworm)

May need to adjust debhelper compatibility:
```bash
# Edit debian/compat
echo "12" > debian/compat

# Edit debian/control
# Change: debhelper-compat (= 13)
# To: debhelper-compat (= 12)
```

### Ubuntu

Generally compatible with Debian packaging, but:
```bash
# May need universe repository enabled
sudo add-apt-repository universe
sudo apt-get update
```

### Older Debian versions

```bash
# Install backports if needed
sudo apt-get install -t bullseye-backports debhelper
```

## CPAN Installation Debugging

### Enable CPAN verbose mode

```bash
# Create CPAN config
mkdir -p ~/.cpan/CPAN
cat > ~/.cpan/CPAN/MyConfig.pm <<EOF
\$CPAN::Config = {
  'build_requires_install_policy' => 'yes',
  'mbuildpl_arg' => '--verbose',
};
1;
EOF
```

### Force install CPAN modules

```bash
sudo cpanm --force --verbose Data::TreeDumper::Renderer::GTK
```

### Use local::lib for user installation

```bash
cpanm --local-lib=~/perl5 Data::TreeDumper::Renderer::GTK
echo 'eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)"' >> ~/.bashrc
```

## Getting Help

### Collect diagnostic information

```bash
# System info
uname -a
lsb_release -a

# Perl info
perl -V

# Package info
dpkg -l | grep asciio
dpkg -s asciio

# Dependency check
apt-cache policy libgtk3-perl
```

### Report issues

When reporting issues, include:
1. Operating system and version
2. Perl version (`perl -v`)
3. Full error messages
4. Build log
5. Steps to reproduce

### Resources

- GitHub Issues:          https://github.com/nkh/P5-App-Asciio/issues
- Debian packaging guide: https://www.debian.org/doc/manuals/maint-guide/
- Module::Build docs:     https://metacpan.org/pod/Module::Build

## Clean Reinstall

If all else fails, try a clean reinstall:

```bash
# Remove package
sudo apt-get purge asciio

# Clean CPAN cache
rm -rf ~/.cpan

# Reinstall
sudo dpkg -i asciio_*.deb
sudo apt-get install -f

# Install CPAN dependencies manually
sudo cpanm Data::TreeDumper::Renderer::GTK
```

