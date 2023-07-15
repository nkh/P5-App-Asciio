# Cross Mode

## Introduction

In normal mode, elements boundaries are independent of each.

![normal_elements](normal_elements.png)

In cross mode intersections are merged:

![cross_elements](cross_elements.png)


## Complex graphics

The cross-mode lets you create graphics like this table

```

        ╔═══════╤══════════════════════════════════════════════════════════════╗
        ║       │   test scores                                                ║
        ║       ├──────┬───────┬───────┬────────┬───────┬──────┬────────┬──────╢
        ║  Name │  Math│Physics│       │        │       │      │        │      ║
        ╟───────┼──────┼───────┼───────┼────────┼───────┼──────┼────────┼──────╢
        ║ Jim   │  A+  │  B    │       │        │       │      │        │      ║
        ╟───────┼──────┼───────┼───────┼────────┼───────┼──────┼────────┼──────╢
        ║Stephen│  B   │  A    │       │        │       │      │        │      ║
        ╟───────┼──────┼───────┼───────┼────────┼───────┼──────┼────────┼──────╢
        ║ Kate  │  A   │  C    │       │        │       │      │        │      ║
        ╚═══════╧══════╧═══════╧═══════╧════════╧═══════╧══════╧════════╧══════╝

```

## Enabling cross-mode

### Globally

Add this line in your user configuration.

```perl
USE_CROSS_MODE => 1,
```

### Dynamically

Binding: «x» 'Switch cross mode'

## Line and Box

![cross_lines](cross_lines.gif)

![cross_boxs](cross_boxs.gif)

## Lines and boxes

![cross_box_line](cross_box_line.gif)


## Exported to text

```
        .--------.      ╭────────╮    ┏━━━━━━━━┓    ╔════════╗
        |        |      │        │    ┃        ┃    ║        ║
        |        |      │        │    ┃  ┏━━━━━┻━━┓ ║        ║
        |        |      │        │    ┃  ┃        ┃ ║        ║
        '--------'      ╰────────╯    ┗━━┫        ┃ ╚════════╝
                                         ┃        ┃
                                         ┗━━━━━━━━┛

                |               │            ┃           ║
                |               │            ┃           ║
                |               │            ┃           ║
                |               │       ━━━━━╋━━━━━━     ║
                |               │            ┃           ║
                |               │            ┃           ║
                |               │            ┃           ║
                |               │            ┃           ║
                |               │            ┃           ║





                .--------.
                |        |          ╭─┬────────┬─────╮
                |  .-----'--.       │ │        │     │
                |  |        |       │ │        │     │
                '--.        |       │ │        │     │    ╔══════════════╗
                   |        |       │ ╰────────╯     │    ║              ║
                   '--------'       │                │    ║              ║
                                    │                │    ║              ║
                                    │        ╔═══════╧╗   ║              ║
                                    │        ║        ║   ║              ║
                                    ╰────────╢        ║   ║              ║
                                             ║        ║   ║              ║
                                             ╚════════╝   ╚══════════════╝

```

## Excluded elements

Some elements do not need to cross, such as ellipse, so they can 
be excluded in the configuration file.

```perl
CROSS_MODE_IGNORE =>
    [
    'App::Asciio::stripes::ellipse',
	'App::Asciio::stripes::if_box'
    ],
```

Just write the full path of the element to be excluded.


