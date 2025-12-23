# Configuration

## Definitions

### Configuration file

A file containing pointers to file where:

- stencils are defines
- actions and bindings are defined 
- asciio options are configured
- routing hooks are defined
- document importers and exporters are defined

### Actions 

Code that is added to **asciio** (a plugin in an other term).

**Asciio** provides many actions but you can write your own and bind it to a keyboard shortcut.

### Bindings

Registered keyboards shortcuts that execute actions.

## Asciio configuration file

The default configuration is defined in :

- setup/setup.ini

### Asciio's default action binding files

- setup/actions/default_bindings.pl
- setup/Text/actions/vim_bindings.pl (which overrides default bindings)

## User configuration file

Your user configuration file is at `$HOME/.config/Asciio/Asciio.ini`.

