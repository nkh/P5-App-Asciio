
use App::Asciio::Actions::Colors ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'change gui color'=> 
		{
		SHORTCUTS => '000-z',
		
		'Change Asciio background color'       => ['000-c', \&App::Asciio::Actions::Colors::change_background_color     ],
		'Change grid color'                    => ['000-C', \&App::Asciio::Actions::Colors::change_grid_color           ],
		'Flip color scheme'                    => ['000-s', \&App::Asciio::Actions::Colors::flip_color_scheme           ],

		'Flip transparent element background'  => ['000-t', \&App::Asciio::Actions::Unsorted::transparent_elements      ],
		'Flip grid display'                    => ['000-g', \&App::Asciio::Actions::Unsorted::flip_grid_display         ],
		},

		},
	
	'Change elements foreground color'             => ['000-c', \&App::Asciio::Actions::Colors::change_elements_colors, 0   ],
	'Change elements background color'             => ['000-C', \&App::Asciio::Actions::Colors::change_elements_colors, 1   ],
	) ;
	
