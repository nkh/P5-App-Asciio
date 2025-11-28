# Cross Mode

## 1 Introduction

Previously, crossover was a separate mode. But not anymore, crossover is just an
attribute of the element. By default, the following shortcut keys are used to
switch the cross attribute of the element. By default, the element has no cross
attribute. The intersection of the boundaries of elements with the cross
attribute will present special visual effects.

***Binding:*** 

    - «e»     enters the element operation group

| action                 | binding       |
|------------------------|---------------|
| Enable elements cross  | `<<x>>`       |
| Disable elements cross | `<<Shift-X>>` |

![cross_effect](cross_effect.gif)

## 2 Complex graphics

The element cross attribute allows you to draw complex tables like the following:

![cross_complex](cross_complex.gif)


```

           ╔═══════╤═══════════════════════════════════════════════╗
           ║       │     test scores                               ║
           ║ Name  ├───────┬────────┬───────┬───────┬──────┬───────╢
           ║       │   Math│ Physics│       │       │      │       ║
           ╟───────┼───────┼────────┼───────┼───────┼──────┼───────╢
           ║ Jim   │    A+ │  B     │       │       │      │       ║
           ╟───────┼───────┼────────┼───────┼───────┼──────┼───────╢
           ║Stephen│    B  │  A     │       │       │      │       ║
           ╟───────┼───────┼────────┼───────┼───────┼──────┼───────╢
           ║ Kate  │    A  │  C     │       │       │      │       ║
           ╚═══════╧═══════╧════════╧═══════╧═══════╧══════╧═══════╝
```


## Stripe group situation

When we merge elements into a strip group, if the merged elements themself has
a cross attribute, the merged strip group will also presents the visual effect
of intersection, but the strip group element itself has no cross attribute.

![cross_stripes](cross_stripes.gif)

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


