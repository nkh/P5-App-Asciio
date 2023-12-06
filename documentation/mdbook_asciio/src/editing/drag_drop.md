# Stencils and "Drag And Drop"

## Stencils

You can access Stencils via "Drag and Drop". 

Asciio has bindings to open stencils in a separate instance

**Start Binding:** is

Then uses one of the following keys:

| bindings | action                                                       |
| -------- | ------------------------------------------------------------ |
| s        | select from user stencils in $HOME/.config/Asciio/stencils/  |
| d        | open stencil 'default_stencil.asciio' from current directory |
| a        | select stencil from your computer                            |
| 0        | open 'elements.asciio'  from $HOME/.config/Asciio/stencils/  |
| 1        | open 'computer.asciio'  from $HOME/.config/Asciio/stencils/  |
| 2        | open 'people.asciio'    from $HOME/.config/Asciio/stencils/  |
| 3        | open 'buildings.asciio' from $HOME/.config/Asciio/stencils/  |

## user stencils

User stencils are plain Asciio files.

The distribution contains a few asciio stencils in "setup/Stencils/*.asciio", copy the ones you want to your $HOME/.config/Asciio/stencils.

You can create a new stencil directly from the file picker, just type the name of the new stencil and open it.

## Drag and Drop

***Binding:*** control + left click + drag

| Type              | From              | To                |
| ----------------- | ----------------- | ----------------- |
| Asciio elements   | Asciio            | Asciio            |
| Asciio elements   | Asciio            | text applications |
| Text              | text applications | Asciio            |
| URLs              | URL aplications   | Asciio            |

![Drag And Drop](drag_and_drop.gif)

