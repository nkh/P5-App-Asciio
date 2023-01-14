
use App::Asciio::Actions::Presentation ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Load slides'    => ['C00-l',     \&App::Asciio::Actions::Presentation::load_slides   ] ,
	'previous slide' => ['C00-Left',  \&App::Asciio::Actions::Presentation::previous_slide],
	'next slide'     => ['C00-Right', \&App::Asciio::Actions::Presentation::next_slide    ],
	'first slide'    => ['C00-Up',    \&App::Asciio::Actions::Presentation::first_slide   ],
	) ;

#----------------------------------------------------------------------------------------------

