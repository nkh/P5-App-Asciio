# GUI

![GUI](https://github.com/nkh/P5-App-Asciio/blob/main/screencasts/asciio.png)

# TUI

![TUI](https://github.com/nkh/P5-App-Asciio/blob/main/screencasts/tasciio.png)

# SYNOPSIS

         ___                     
        /   |  __________________
       / /| | / ___/ ___/ / / __ \
      / ___ |(__  ) /__/ / / /_/ /
     /_/  |_/____/\___/_/_/\____/

    $> asciio [file.asciio] # GUI application using Gtk3

    $> tasciio [file.asciio] # TUI application

    $> asciio_to_text file.asciio # converts asciio files to ASCII

# DESCRIPTION

Asciio allows you to draw ASCII diagrams in a GUI or TUI. The diagrams
can be saved as ASCII text or in a format that allows you to modify them
later.

Diagrams consist of boxes and text elements connected by arrows. Boxes
stay connected when you move them around.

Both GUI and TUI have vim-like bindings (shortcuts), the GUI has a few extra
bindings that are usually found in GUI applications; bindings can be
customized.

Keyboard bindings are the best way to use Asciio.

To list the bindings: $> perldoc App:Asciio.
 
# DOCUMENTATION

Full documentation, including installation and OCI image, are found at [Online Documentation](https://nkh.github.io/P5-App-Asciio/)

## Interface

          .-------------------------------------------------------------.
          | ........................................................... |
          | ........................................................... |
          | ........................................................... |
          | ..........-------------..------------..--------------...... |
          | .........| stencils  > || asciio   > || box          |..... |
          | .........| Rulers    > || computer > || text         |..... |
          | .........| File      > || people   > || wirl_arrow   |..... |
     grid----->......'-------------'| divers   > || axis         |..... |
          | ..................^.....'------------'| ...          |..... |
          | ..................|...................'--------------'..... |
          | ........................................................... |
          | ........................................................... |
          | ..................|........................................ |
          '-------------------|-----------------------------------------'
                              |
               context menu access some commands
               but most are accessed through the keyboard

## Exporting to ASCII

You can export to a file in ASCII by using a '.txt' file extension.

You can also export the selection, in ASCII, to the Primary clipboard.

## Elements
   
### boxes and text
                    .----------.
                    |  title   |
     .----------.   |----------|   ************
     |          |   | body 1   |   *          *
     '----------'   | body 2   |   ************
                    '----------'
                                          any text
                                (\_/)         |
            text                (O.o)  <------'
                                (> <)

### if-box and process-box

       .--------------.    
      / a == b         \     __________
     (    &&            )    \         \
      \ 'string' ne '' /      ) process )
       '--------------'      /_________/

### rhombus and ellipse

```txt
      ,',              _..---.._
    ,'   ',         .''         ''.
  ,'       ',      /               \
 :  edit me  :    |     edit me     |
  ',       ,'      \               /
    ',   ,'         '..         ..'
      ','              '--...--'
```

### user boxes and exec-boxes

For simple elements, put your design in a box, with or without a frame.

The "exec-box" element lets you put the output of an external application
in a box, in the example below the table is generated, if
you already have text in a file you can use 'cat your_file' as the
command.

      +------------+------------+------------+------------+
      | input_size ‖ algorithmA | algorithmB | algorithmC |
      +============+============+============+============+
      |     1      ‖ 206.4 sec. | 206.4 sec. | 0.02 sec.  |
      +------------+------------+------------+------------+
      |    250     ‖     -      |  80 min.   | 2.27 sec.  |
      +------------+------------+------------+------------+

### wirl-arrow

Rotating the end clockwise or counter-clockwise changes its direction.

          ^            ^          
          |    -----.   \         
          |         |    \           
          '----     |     '------- 
    ------>         |             
                    v             

### multi section wirl-arrow

A set of whirl arrows connected to each other.

     .----------.                     .
     |          |                \   / \
        .-------'           ^     \ /   \
        |   .----------->    \     '     .
        |   '----.            \          /
        |        |             \        /
        '--------'              '------'

### angled-arrow and axis

    -------.       .-------
            \     /
             \   /            ^         
                              |   ^     
             /   \            |  /      
            /     \           | /       
     ------'       '-------    -------->

## Examples

              .---.  .---. .---.  .---.    .---.  .---.
     OS API   '---'  '---' '---'  '---'    '---'  '---'
                |      |     |      |        |      |
                v      v     |      v        |      v
              .------------. | .-----------. |  .-----.
              | Filesystem | | | Scheduler | |  | MMU |
              '------------' | '-----------' |  '-----'
                     |       |      |        |
                     v       |      |        v
                  .----.     |      |    .---------.
                  | IO |<----'      |    | Network |
                  '----'            |    '---------'
                     |              |         |
                     v              v         v
              .---------------------------------------.
              |                  HAL                  |
              '---------------------------------------'


                                 .-Base::Class::Derived_B
                                /
     Something::Else           /
             \                .----Base::Class::Derived_C 
              \              /
               '----Base::Class
                     '       \
                    /         '----Latest::Greatest
      Some::Thing--'                                           

      _____ 
     | ___ |
     ||___|| load
     | ooo |--.------------------.------------------------.
     '_____'  |                  |                        |
              v                  v                        v
      .----------.  .--------------------------.  .----------------.
      | module C |  |         module A         |  |    module B    |
      '----------'  |--------------------------|  | (instrumented) |
           |        |        .-----.           |  '----------------'
           '---------------->| A.o |           |          |
                    |        '-----'           |          |
                    |   .------------------.   |          |
                    |   | A.instrumented.o |<-------------'
                    |   '------------------'   |
                    '--------------------------'

## Unicode example

![Unicode](https://github.com/nkh/P5-App-Asciio/blob/main/screencasts/asciio_unicode.png)

## Export to SVG example

![SVG source](https://github.com/nkh/P5-App-Asciio/blob/main/screencasts/asciio_svg_source.png)

![SVG](https://github.com/nkh/P5-App-Asciio/blob/main/screencasts/asciio_svg.png)

The "goat" project (https://github.com/blampe/goat) must be installed.

# Asciio and Vim

You can call Asciio from vim and insert your diagram.

        map  <leader><leader>a :call TAsciio()<cr>

        function! TAsciio()
            let line = getline('.')

            let tempn = tempname()
            let tempnt = tempn . '.txt'
            let temp = shellescape(tempn)
            let tempt = shellescape(tempnt)

            exec "normal i Asciio_file:" . tempn . "\<Esc>"

            if ! has("gui_running")
            exec "silent !mkdir -p $(dirname " . temp . ")" 
            exec "silent !cp ~/.config/Asciio/templates/empty.asciio ". temp . "; tasciio " . temp . "; asciio_to_text " . temp . " >" . tempt 
            exec "read " . tempnt
            endif

            redraw!
        endfunction

# OTHER PROJECTS

SVG conversion:
![goat](https://github.com/blampe/goat)

Tree generation:
![ascii_tree](https://github.com/yzhong52/ascii_tree)

ASCII Math and other:
![Diagon](https://github.com/ArthurSonzogni/Diagon)

Send me links to your favorites tools (only command line, no libs) and I'll add them if they integrate will in Asciio.

# VIDEO

An old video that shows basic usage, a lot of functionality has bee added since:

![Asciio](https://www.youtube.com/watch?v=0l9W84PhOyI)

# INSTALL

## local build on debian based distribution

The **OCI** directory contains a build file [Containerfile](OCI/Containerfile), you can use the same commands to install locally.

## Container image

Read the [Installation guide](documentation/mdbook_asciio/src/guide/installation.md) for more information.


# AUTHORS

    Khemir Nadim ibn Hamouda
    https://github.com/nkh
    CPAN ID: NKH
    
    Qin Qing
    northisland2017@gmail.com


