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


```perl

'Cross element Insert leader' => 
	{
	SHORTCUTS => '000-x',
	
	'Add cross angled arrow'              => ['A'],
	'Add cross arrow'                     => ['a'],
	'Add cross box'                       => ['b'],
	'Add cross exec box'                  => ['e'],

	'Select cross elements'               => ['c'],
	'Select cross filler elements'        => ['f'],
	'Select normal elements'              => ['C'],
	'Select normal filler elements'       => ['F'],

	'Add cross unicode line 2'            => ['i'],
	'Add cross unicode line 3'            => ['I'],
	'Change to cross elements'            => ['s'],
	'Change to normal elements'           => ['S'],
	},
```


