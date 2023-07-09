# Installation

Asciio is normally packaged for distributions, if you are reading this we are
working on the  GTK3 port and you'll need to install manually.

```bash
    sudo apt install libeval-context-perl libdirectory-scratch-structured-perl libfile-homedir-perl libgtk3-perl
    sudo apt install libterm-size-any-perl libio-prompter-perl libterm-termkey-perl
    
    git clone https://github.com/nkh/P5-Data-TreeDumper-Renderer-GTK
    cd P5-Data-TreeDumper-Renderer-GTK
    perl Makefile.pl
    make
    
    git clone https://github.com/nkh/P5-App-Asciio
    cd P5-App-Asciio
    perl Build.PL
    ./Build installdeps 
    ./Build install
```

In the windows environment, you can use asciio through WSL or cygwin.

## WSL

The use of WSL is not much different from the Linux environment.

## Cygwin

- First install [Cygwin](https://www.cygwin.com/).
- Make sure the following components are installed correctly
   - x11
   - perl
   - Gnome
   - gun-make
   - gcc-g++
- Search for "cygpt" in all the packages to be installed, and install all 
  the packages that appear.
- Install all dependent modules of asciio

Pay attention when installing perl modules, some may be installed through 
cpan, but some cannot, and can only be installed manually.

>When compiling, the Makefile of several modules has an unrecognized option 
`-lnsl`. removed it when install it manually.

Start asciio by the following method:

```bash
startxwin >/dev/null 2>&1 &
export DISPLAY=:0.0
asciio
```




# Running asciio

    $> asciio [file.asciio] # GUI application using Gtk3

    $> tasciio [file.asciio] # TUI application

    $> asciio_to_text file.asciio # converts asciio files to ASCII

# Previous version docker image

    There are docker images made by third parties, use a search engine for
    the latest.

    https://hub.docker.com/r/rodolfoap/asciio

    example images:

    https://gist.github.com/BruceWind/32920cf74ba5b7172b31b06fec38aabb

    https://github.com/rodolfoap

# Platforms

Asciio is developed on both Linux and Windows (cygwin).
