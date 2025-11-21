use strict ;
use warnings ;

use App::Asciio::Utils::Presentation ;

[
	[ 
		"0 intro", 
		{
		a => sub
			{
			my ($self) = @_ ;
			App::Asciio::Actions::Elements::add_element($self, ['Asciio/box', 0, 20, 20]) ;
			},
		},
	],
	
	[ 
		[ "1.0", ],
		[ "1.1", ],
		[ 
			["1.2.0", ]
		],
	],
	
	[ clear_and_box_at(0, 0, "2"), ], 
	
	[ 
		load(0, 0, './default_stencil.asciio'),
		box(10, 20, 'title', '3', 0),
	],
	
	[ 
		clear_all(),
		box(0, 0, '', "4 -", 0),
		box(10, 20, 'title', '4 --', 0),
	],
	
	# multi element slide
	[ 
		[ clear_and_box_at(0, 0, "5.0"), ],
		
		[
		box(10, 20, 'title', '5.1 -', 0), 
		box(10, 30, 'title', '5.1 --', 0), 
		], 
	],
	
	# final slide
	[
	clear_all(),
	box(19, 11, '', <<'EOT', 0), 
6.0
(\_/)
(O.o) ASCII world domination is near!
(> <) 
EOT
	],
]
