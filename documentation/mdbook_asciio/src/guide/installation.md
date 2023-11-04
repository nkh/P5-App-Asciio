# Installation

Asciio is normally packaged for distributions, if you are reading this we are
working on the GTK3 port and you'll need to install manually.

## Alternative *1*

```bash
    sudo apt install libdata-compare-perl libdata-compare-perl libdirectory-scratch-structured-perl libeval-context-perl libextutils-pkgconfig-perl libfile-homedir-perl libgtk3-perl libio-prompter-perl libterm-size-any-perl libterm-termkey-perl libtest-block-perl libtermkey-dev libmodule-build-perl

    cpan install Data::TreeDumper Data::TreeDumper::Renderer::GTK App::Asciio

```

## Alternative *2*

```bash
    sudo apt install libdata-compare-perl libdata-compare-perl libdirectory-scratch-structured-perl libeval-context-perl libextutils-pkgconfig-perl libfile-homedir-perl libgtk3-perl libio-prompter-perl libterm-size-any-perl libterm-termkey-perl libtest-block-perl libtermkey-dev libmodule-build-perl

    sudo sudo apt install make gcc

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

The use of WSL is not much different from the Linux environment.However, there are some things that need attention. This link talks about how to connect to the WSL environment and execute GUI programs through remote connections under Windows.

[remote_wsl_use_gui_app](https://github.com/qindapao/linux_app_use_in_windows/blob/main/remote_wsl_use_gui_app.md)

## Cygwin

- First install [Cygwin](https://www.cygwin.com/).
- Make sure the following components are installed correctly
   - x11
   - perl
   - Gnome
   - gun-make
   - gcc-g++
- Search for "gcrypt" in all the packages to be installed, and install all 
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
