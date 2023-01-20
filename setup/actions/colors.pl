
use App::Asciio::Actions::Colors ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Change elements background color' => ['000-c', \&App::Asciio::Actions::Colors::change_elements_colors, 1     ],
	'Change elements foreground color' => ['00S-C', \&App::Asciio::Actions::Colors::change_elements_colors, 0     ],
	'Change AsciiO background color'   => ['0A0-c', \&App::Asciio::Actions::Colors::change_background_color       ],
	'Change grid color'                => ['0AS-C', \&App::Asciio::Actions::Colors::change_grid_color             ],
	'Flip color scheme'                => ['CA0-c', \&App::Asciio::Actions::Colors::flip_color_scheme           ],
	) ;
	
