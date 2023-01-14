
use App::Asciio::Actions::File ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Open'           => ['C00-o', \&App::Asciio::Actions::File::open        ],
	'Save'           => ['C00-s', \&App::Asciio::Actions::File::save, undef ],
	'SaveAs'         => ['C0S-S', \&App::Asciio::Actions::File::save, 'as'  ],
	'Insert'         => ['C00-i', \&App::Asciio::Actions::File::insert      ],
	'Quit'           => ['000-q', \&App::Asciio::Actions::File::quit        ],
	'Quit no save'   => ['00S-Q', \&App::Asciio::Actions::File::quit_no_save],
	) ;

#----------------------------------------------------------------------------------------------

