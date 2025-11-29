# selection

## Introduction

In addition to using rectangular selection boxes or directly clicking on them,
there are other options for selecting elements, which is to use the selection
operation group, which allows us to conveniently select elements in irregular
areas. There are two main forms: mouse-drawn polygon selection or mouse-move
selection (with the left mouse button held down).

## Basic operations

### Entering and exiting selection mode

| action                                      | binding                        |
|---------------------------------------------|--------------------------------|
| Enter selection mode                        | `<<s>>`                        |
| Exit selection mode                         | `<<Escape>>` and `<<<s>>>`     |
| Toggle selection and deselection            | `<<<e>>>`                      |
| Select motion                               | `<<<mouse_motion>>>`           |
| Select mouse click                          | `<<<mouse_left_button>>>`      |
| Enter the polygon selection operation group | `<<<x>>>`                      |

**Polygon selection operation group operation collection**: 

| action                      | binding                      |
|-----------------------------|------------------------------|
| Exit polygon selection mode | `<<<Escape>>>` and `<<<x>>>` |
| Polygon select motion       | `<<<mouse_motion>>>`         |
| Polygon deselect motion     | `<<<Ctrl-mouse_motion>>>`    |


### Operation after entering selection mode

Common selection operation example:

![selection_basic](selection_basic.gif)

### Operation after entering polygon selection mode

1. selection situation.
2. deselection situation.

![selection_polygon](selection_polygon.gif)


