
use App::Asciio::Actions::Presentation ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'slides gui commands' => 
		{
		SHORTCUTS => 'S',
		
		'Load slides'    => ['000-l',     \&App::Asciio::Actions::Presentation::load_slides   ] ,
		'previous slide' => ['00S-N',  \&App::Asciio::Actions::Presentation::previous_slide],
		'next slide'     => ['000-n', \&App::Asciio::Actions::Presentation::next_slide    ],
		'first slide'    => ['000-g',    \&App::Asciio::Actions::Presentation::first_slide   ],
		},
	
	) ;

#----------------------------------------------------------------------------------------------

