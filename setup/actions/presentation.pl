
use App::Asciio::Actions::Presentation ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Load slides'    => ['C00-l',     \&App::Asciio::Actions::Presentation::load_slides   ] ,
	'previous slide' => ['C0S-Left',  \&App::Asciio::Actions::Presentation::previous_slide],
	'next slide'     => ['C0S-Right', \&App::Asciio::Actions::Presentation::next_slide    ],
	'first slide'    => ['C0S-Up',    \&App::Asciio::Actions::Presentation::first_slide   ],
	) ;

#----------------------------------------------------------------------------------------------

