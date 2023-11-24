# Cross Mode

## 1 Introduction

In normal mode, elements boundaries are independent of each.

![normal_elements](normal_elements.png)

In cross mode intersections are merged:

![cross_elements](cross_elements.png)


## 2 Complex graphics

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

## 3 Enabling cross-mode

### 3.1 Globally

Add this line in your user configuration.

```perl
USE_CROSS_MODE => 1,
```

### 3.2 Dynamically

Binding: «z-x» 'Switch cross mode'

## 4 Line and Box

![cross_lines](cross_lines.gif)

![cross_boxs](cross_boxs.gif)

## 5 Lines and boxes

![cross_box_line](cross_box_line.gif)


## 6 Exported to text

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


