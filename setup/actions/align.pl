
use App::Asciio::Actions::Align ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'align gui commands' => 
		{
		SHORTCUTS => '000-A',
		
		'Align left'   => ['000-l', \&App::Asciio::Actions::Align::align, 'left'  ],
		'Align center' => ['000-c', \&App::Asciio::Actions::Align::align, 'center'],
		'Align right'  => ['000-r', \&App::Asciio::Actions::Align::align, 'right' ],
		'Align top'    => ['000-t', \&App::Asciio::Actions::Align::align, 'top'   ],
		'Align middle' => ['000-m', \&App::Asciio::Actions::Align::align, 'middle'],
		'Align bottom' => ['000-b', \&App::Asciio::Actions::Align::align, 'bottom'],
		# spread vertically	# spread horizontally # adjacent vert # adjacent hor # stack
		},
	) ;

