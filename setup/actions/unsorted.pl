
use App::Asciio::Actions::Unsorted ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Undo'                                                  => [['C00-z', '000-u'], \&App::Asciio::Actions::Unsorted::undo    ],
	'Redo'                                                  => [['C00-y', 'C00-r'], \&App::Asciio::Actions::Unsorted::redo    ],
	'Zoom in'                                               => ['000-plus',         \&App::Asciio::Actions::Unsorted::zoom, 1 ],
	'Zoom out'                                              => ['000-minus',        \&App::Asciio::Actions::Unsorted::zoom, -1],
	) ;

#----------------------------------------------------------------------------------------------

