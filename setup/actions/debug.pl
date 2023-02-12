
use App::Asciio::Actions::Debug ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'debug gui commands' => 
		{
		SHORTCUTS => 'D',
		
		'Display undo stack statistics' => ['000-u', \&App::Asciio::Actions::Unsorted::display_undo_stack_statistics ],
		'Dump self'                     => ['000-s', \&App::Asciio::Actions::Debug::dump_self                        ],
		'Dump all elements'             => ['000-e', \&App::Asciio::Actions::Debug::dump_all_elements                ],
		'Dump selected elements'        => ['000-E', \&App::Asciio::Actions::Debug::dump_selected_elements           ],
		'Display numbered objects'      => ['000-t', \&display_numbered_objects                                      ],
		'Test'                          => ['000-o', \&App::Asciio::Actions::Debug::test                             ],
		},
	) ;

#----------------------------------------------------------------------------------------------

sub display_numbered_objects
{
my ($self) = @_ ;

$self->{NUMBERED_OBJECTS} ^= 1 ;
$self->update_display() ;
}
