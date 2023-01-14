
use App::Asciio::Actions::Box ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'box_context_menu' => ['box_context_menu', undef, undef, \&App::Asciio::Actions::Box::box_context_menu],
	) ;


#----------------------------------------------------------------------------------------------

