
use App::Asciio::Actions::Colors ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'change color'=> 
		{
		SHORTCUTS => '0A0-c',
		
		'Change elements background color' => ['000-b', \&App::Asciio::Actions::Colors::change_elements_colors, 1     ],
		'Change elements foreground color' => ['000-f', \&App::Asciio::Actions::Colors::change_elements_colors, 0     ],
		'Change AsciiO background color'   => ['00S-B', \&App::Asciio::Actions::Colors::change_background_color       ],
		'Change grid color'                => ['00S-F', \&App::Asciio::Actions::Colors::change_grid_color             ],
		'Flip color scheme'                => ['000-s', \&App::Asciio::Actions::Colors::flip_color_scheme           ],
		},

	) ;
	
