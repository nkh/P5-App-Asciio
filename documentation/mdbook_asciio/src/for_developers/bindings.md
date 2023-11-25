# Bindings

Bindings consists of 

- a descriptive but short name

- one or more key to assign the binding

- a reference to a handler

- possible arguments for the handler

```perl
'Mouse quick link git' => [['0A0-button-press-3', '00S-semicolon'],  \&App::Asciio::Actions::Git::quick_link]
```

Goals when adding bindings:

- keep code separate from other bindings code if the new bindings are not very general, ie: code them in their own module

- align the structures

- avoid long or generic or numbered name

- if possible the bindings should be the same as the vim-bindings
	- some GUI standards may require different bindings, IE: C00-A to select everything

- create an equivalent binding set in the vim bindings file

- documents the bindings
	- name, keep them logical, start with an uppercase
	- key
	- what they do, preferably with some screenshot

- don't use control, shift and alt if possible (logical)

- split groups if they become too large

- sort by name or key if possible

## Binding Groups

```perl
'<< selection leader >>' =>
	{
	SHORTCUTS   => '000-r',                                               # also accepts multiple entries in an array ref
	ENTER_GROUP => \&App::Asciio::Actions::Selection::selection_enter,
	ESCAPE_KEYS => [ '000-r', '000-Escape' ],                             # also accepts single entry

	# ESCAPE_KEYS need to be define of group will catch input untill an action is selected 
	
	# same keys as the ESCAPE_KEYS, will be called on exit
	'Selection escape'               => [ '000-r',             \&App::Asciio::Actions::Selection::selection_escape                      ],
	'Selection escape2'              => [ '000-Escape',        \&App::Asciio::Actions::Selection::selection_escape                      ],

	# simple action 
	'select flip mode'               => [ '000-f',             \&App::Asciio::Actions::Selection::selection_mode_flip                   ],

	# handle mouse movement
	'select motion'                  => [ '000-motion_notify', \&App::Asciio::Actions::Selection::select_elements                       ],
	},
```


