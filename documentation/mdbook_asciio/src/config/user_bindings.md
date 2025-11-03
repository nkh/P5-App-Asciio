# Bindings

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


