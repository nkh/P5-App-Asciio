
use App::Asciio::Actions::Clipboard ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Copy to clipboard'     => [ ['C00-c', 'C00-Insert', 'y'], \&App::Asciio::Actions::Clipboard::copy_to_clipboard    ],
	'Insert from clipboard' => [ ['C00-v', '00S-Insert', 'p'], \&App::Asciio::Actions::Clipboard::insert_from_clipboard],
	) ;

#----------------------------------------------------------------------------------------------

