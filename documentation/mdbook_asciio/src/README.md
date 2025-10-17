```
    ___                               .-------.
   /   |  __________________          | Tokyo |
  / /| | / ___/ ___/ / / __ \         '-------'   .-----------.
 / ___ |(__  ) /__/ / / /_/ /             ^       | Tuju-Tuju |
/_/  |_/____/\___/_/_/\____/              |       '-----------'
                                          |             ^
                                      .-------.         |
                           .------.---| Malmö |---------'  .-------.
                           |      |   '-------'            | Korba |
                           v      |       ^                '-------'
                      .--------.  |       |     .-------.      |
                      | Dallas |  |       '-----| Paris |<-----'
                      '--------'  |             '-------'
                                  v
                             .--------.
                             | Moscow |
                             '--------'
```

Asciio allows you to draw ASCII diagrams in a GUI or TUI. The diagrams can be saved as ASCII text or in a format that allows you to modify them later.

Diagrams consist of boxes and text elements connected by arrows. The elements stay connected when you move them around.

Both GUI and TUI have vim-like bindings, the GUI has a few extra bindings that are usually found in GUI applications; bindings can be modified.

ASCII format is easy and universal, many tools exist to manipulate it and even transform it to other formats.

I've used it a lot to draw trees and graphs when my hand drawn pictures were not good enough for presentations. Having the possibility to copy and modify the graphs/diagrams makes it possible to present changes in an attractive way.


## History

Asciio was born ... as a dare; someone coined a cool name at a conference in Oslo and it's been under development for 20 years. It allows you to embed graphs in code, documentation, requirements, ... 


```
                          .------.
              .-----------| root |---------.
              |           '------'         |       other process
              |               .------------|-------------.
              v               |            v             |
            .--.              |          .--.            |
        .---'--'              |      .---'--'---.        |
        |     |               |      |          |        |
        v     |               |      v          v        |
      .--.    |      link     |    .--.       .--.       |
   .--'--'    .--------------------'--'       '--'       |
   |          |               |      |                   |
   v          |               |      v                   |
 .--.         v               |    .--.                  |
 '--'       .--.              |    '--'                  |
            '--'              |                          |
                              '--------------------------'
```

