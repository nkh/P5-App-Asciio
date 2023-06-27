# user bindings

The bindings can be changed in your user configuration. File '$HOME/.config/Asciio/Asciio.ini' points at the 


Here's and example of binding:

```perl
'Change elements foreground color' => ['000-c',  \&App::Asciio::Actions::Colors::change_elements_colors, 0 ],
```

Bindings are composed of:

- a command name
- a set of keyboard shortcuts

To change a binding:
- Find the command name for the binding you want to change
- decide a new keyboard shortcuts
- add your binding to your configuration file

Your configuration file has this format:

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

Create '$HOME/.config/Asciio/actions/colors.pl' and add:

```perl
register_action_handlers
	(
	'Change elements foreground color' => ['000-Z'],
	) ;
```

