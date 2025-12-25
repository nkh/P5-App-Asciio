# Animations

You can create animations with Asciio

[Bindings](../animation_mode.md)

## Animation Format

Animations are simple scripts that are run within a single asciio document.

```
use strict ;
use warnings ;

use App::Asciio::Utils::Animation ;

# the slides definition
[
	# first slide
	[ 
		# text is added to a box at 0, 0
		"0 intro", 
	
		# you can add scritpt with shortcuts per slide
		{
		a => sub
			{
			my ($self) = @_ ;
			App::Asciio::Actions::Elements::add_element($self, ['Asciio/box', 0, 20, 20]) ;
			},
		},
	],
	
	# second slide
	[ 
		# if you have multiple elements in squre bracket, Asciio uses them as steps in your slide
		[ "1.0", ],
		[ "1.1", ],
		
		# a step within a step, thereäs no limit but navigation becomes more intricate
		[ 
			["1.2.0", ]
		],
	],
	
	# third slide
	[
	clear_and_box_at(0, 0, "2"), ], 
	],
	
	# fourth slide
	[ 
		# you can load an asciio file
		load(0, 0, 'path/file.asciio'),
		
		# and add elements to the slide
		box(10, 20, 'title', '3', 0),
	],
	
	# final slide
	[
	clear_all(),
	
	# multiline box
	box(19, 11, '', <<'EOT', 0), 
6.0
(\_/)
(O.o) ASCII world domination is near!
(> <) 
EOT
	],
]
```

Utilities are defined in *lib/App/Asciio/Utils/Animation.pm*

