
use App::Asciio::Actions::Ruler ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Add vertical ruler'   => ['000-r', \&App::Asciio::Actions::Ruler::add_ruler, {TYPE => 'VERTICAL'},  \&App::Asciio::Actions::Ruler::rulers_context_menu ],
	'Add horizontal ruler' => ['0A0-r', \&App::Asciio::Actions::Ruler::add_ruler, {TYPE => 'HORIZONTAL'}                                                    ],
	'Remove rulers'        => ['00S-R', \&App::Asciio::Actions::Ruler::remove_ruler                                                                         ],
	) ;

