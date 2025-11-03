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

## binding override in your user configuration

- Find the command name for the binding you want to change
- decide a new keyboard shortcuts
- add your binding to your configuration file

### example

Change the shortcut for setting element color.

Create '$HOME/.config/Asciio/actions/colors.pl' and add:

```perl
register_action_handlers
	(
	'Change elements foreground color' => ['000-Z'],
	) ;
```

Add it to yout **'$HOME/.config/Asciio/Asciio.ini'**

```perl
{
...
ACTION_FILES =>
	[
	'actions/colors.pl', # new configuration file where you want to put your color bindings
	],
...
}

```


