
use App::Asciio::Actions::Mouse ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Quick link' => ['00S-button_press-1', \&App::Asciio::Actions::Mouse::quick_link] ,
	#~ 'C00-button_release' => ['', ] ,
	#~ 'C00-motion_notify' =>['', ] ,
	) ;


#----------------------------------------------------------------------------------------------

