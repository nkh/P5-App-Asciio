
use App::Asciio::Actions::Debug ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Dump self'             => ['CA0-d', \&App::Asciio::Actions::Debug::dump_self              ],
	'Dump all elements'     => ['C00-d', \&App::Asciio::Actions::Debug::dump_all_elements      ],
	'Dump selected elements'=> ['C0S-D' , \&App::Asciio::Actions::Debug::dump_selected_elements],
	'Test'                  => ['0A0-t',  \&App::Asciio::Actions::Debug::test                  ],
	) ;

#----------------------------------------------------------------------------------------------

