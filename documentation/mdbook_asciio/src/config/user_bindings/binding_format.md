# Binding format

A binding contains:

- unique name for your binding
- shortcut, multiple shortcuts are passed as ['shortcut_1', 'shortcut_2', ...]
- action sub reference
- arguments to the action sub reference, optional
- popup-menu sub reference, optional

Example:

```perl

'Edit selected element inline'  => 
    [
    ['C00-2button-press-1','C00-Return'],
    \&App::Asciio::Actions::ElementsManipulation::edit_selected_element,
    1
    ],

```

