
use App::Asciio::Actions::File ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'command gui mode'=> 
		{
		SHORTCUTS => ':',
		
		# 'Help'                     => [ 'h' ],
		'Display keyboard mapping' => ['000-k', \&App::Asciio::Actions::Unsorted::display_keyboard_mapping],
		'Display commands'         => ['000-c', \&App::Asciio::Actions::Unsorted::display_commands        ],
		'Display action files'     => ['000-f', \&App::Asciio::Actions::Unsorted::display_action_files    ],
		
		'Open'           => ['000-e', \&App::Asciio::Actions::File::open        ],
		'Save'           => ['000-w', \&App::Asciio::Actions::File::save, undef ],
		'SaveAs'         => ['00S-W', \&App::Asciio::Actions::File::save, 'as'  ],
		'Insert'         => ['000-r', \&App::Asciio::Actions::File::insert      ],
		'Quit'           => ['000-q', \&App::Asciio::Actions::File::quit        ],
		'Quit no save'   => ['00S-Q', \&App::Asciio::Actions::File::quit_no_save],
		},
	
	) ;

#----------------------------------------------------------------------------------------------

