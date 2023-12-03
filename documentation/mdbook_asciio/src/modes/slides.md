# slides

You can create a slide show with Asciio ... but it's a work in progress. We write some documentation here but you're better off asking the developers directly.

## Bindings

| binding | action                |
| ------- | ------                |
| S       | enter slides mode     |
| Escape  | escape slides mode    |
| L       | Load slides           |
| n       | next slide            |
| N       | previous slide        |
| g       | first slide           |
| s       | run script            |
| n/a     | show previous message |
| n/a     | show next message     |


## Slides Format

Slides are a very simplified script.

```
use strict ;
use warnings ;

use App::Asciio::Utils::Presentation ;

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

Utilities are defined in *lib/App/Asciio/Utils/Presentation.pm*

