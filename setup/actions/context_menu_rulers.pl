
use App::Asciio::Actions::Ruler ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Remove rulers'        => ['0A0-r', \&App::Asciio::Actions::Ruler::remove_ruler                                                                         ],
	) ;

