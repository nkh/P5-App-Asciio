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

# Running asciio

    $> asciio [file.asciio] # GUI application using Gtk3

    $> tasciio [file.asciio] # TUI application

    $> asciio_to_text file.asciio # converts asciio files to ASCII

# Previous version docker image

    There are docker images made by third parties, use a search engine for
    the latest.

    example image:
    https://gist.github.com/BruceWind/32920cf74ba5b7172b31b06fec38aabb


