# Asciio Keyboard Bindings Reference

## Understanding the Binding System

Asciio uses a hierarchical keyboard binding system where many operations are organized into groups accessed through prefix keys.

It's faster and easier to work with keyboard shortcuts than the mouse plus the number of combination of mouse buttons * control-keys is limited.

*Asciio* bindings are vim-like, they initially take a little time to get used to and often take multiple key presses but they are much more logical as families of commands are accessed with shortcuts that start with the same letter.

Both GUI and TUI have vim-like bindings, the GUI has a few extra bindings that are usually found in GUI applications; bindings can be user modified. See configuration/user_bindings 

## Actions 

Code that is added to **asciio** (a plugin is another term).

**Asciio** provides many actions but you can write your own and bind it to a shortcut.

## Bindings

Registration of shortcuts that execute actions.

The default Bindings are setup by the **register_action_handlers** in the following files:

- setup/actions/default_bindings.pl
- setup/Text/actions/vim_bindings.pl (which overrides default bindings)

## User defined bindings

The bindings can be changed in your user configuration. 

Set the **ACTION_FILES** section of file '$HOME/.config/Asciio/Asciio.ini' to point at one 
or more files that will be loaded by **asciio**.

The files contain bindings override but can also contain actions code.

## Show Bindings Completion

***Binding:*** «zb»

![bindings_help](bindings_help.gif)

Makes Asciio show the current bindings iwhile you type.

You can add it in your config:

```
USE_BINDINGS_COMPLETION => 1,
```

## Embedded bindings

Extra bindings can be embedded in an asciio document with command line options

| option                    |                                            |
| -                         | -                                          |
| add_binding=s             | file containing bindings to embedd         |
| reset_bindings            | remove all embedded bindings from document |
| dump_bindings             | write the embedded bindings to files       |
| dump_binding_names        | display name of embbeded bindings          |

# Binding Notation

Bindings are shown using the notation `«key»` where:
- `«key»` means press that key directly
- `«Shift+Key»` means hold Shift and press the key
- `«Ctrl+Key»` means hold Control and press the key
- `«Alt+Key»` means hold Alt and press the key

## Prefix System

Many operations require a prefix key followed by an operation key:
- Press the prefix key (e.g., `«t»` for tab operations)
- Then press the operation key (e.g., `«n»` for new tab)
- Result: `«t»` + `«n»` creates a new tab

## Escaping Groups

When in a binding group, press `«Escape»` to return to root level bindings.

