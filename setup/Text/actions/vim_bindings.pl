
#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	# general
	'Undo'                                                   => [ '000-u'  ],
	'Redo'                                                   => [ 'C00-C-r'],
	'Insert from clipboard'                                  => [ '000-p' ],
	'Copy to clipboard'                                      => [ '000-y' ],
	'Export to clipboard & primary as ascii'                 => [ '000-Y' ],
	
	# elements
	'Edit selected element'                                  => [ '000-Enter' ],
	'Delete selected elements'                               => [ '000-d' ],
	'Change elements foreground color'                       => [ '000-c' ],
	'Change elements background color'                       => [ '000-C' ],
	
	# selection
	'Select all elements'                                    => [ '000-V' ],
	'Deselect all elements'                                  => [ '000-Escape' ],
	'Select connected elements'                              => [ '000-v' ],
	'Select next element'                                    => [ '000-n' ],
	'Select previous element'                                => [ '000-N' ],
	'Select next element move mouse'                         => [ '000-Tab',   \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [1, 1] ],
	'Select previous element move mouse'                     => [ '00S-S-Tab', \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [0, 1] ],
	
	# sizing
	# 'Make element narrower'                                  => [ '000-1' ],
	# 'Make element taller'                                    => [ '000-2' ],
	# 'Make element shorter'                                   => [ '000-3' ],
	# 'Make element wider'                                     => [ '000-4' ],
	'Shrink box'                                             => [ '000-s' ],
	
	# movement
	'Move selected elements left'                            => [ '000-h' ],
	'Move selected elements right'                           => [ '000-l' ],
	'Move selected elements up'                              => [ '000-k' ],
	'Move selected elements down'                            => [ '000-j' ],
	
	# mouse
	'Toggle mouse'                                           => [ "000-'" ],
	'Quick link'                                             => [ '000-.' ],
	
	'Mouse right-click'                                      => [ '000-ä' ],
	'Mouse left-click'                                       => [ '000-ö' ],
	'Mouse shift-left-click'                                 => [ '000-Ö' ],
	'Mouse ctl-left-click'                                   => [ 'C00-ö' ],
	'Mouse alt-left-click'                                   => [ '0A0-ö' ],
	'Mouse on element id'                                    => [ '000-000' ],
	
	'Mouse drag left'                                        => [ '0A0-A-Left'  ],
	'Mouse drag right'                                       => [ '0A0-A-Right' ],
	'Mouse drag up'                                          => [ '0A0-A-Up'    ],
	'Mouse drag down'                                        => [ '0A0-A-Down'  ],
	
	'Mouse drag left 2'                                      => [ '0A0-A-ö', \&App::Asciio::Actions::Mouse::mouse_drag_left  ],
	'Mouse drag right 2'                                     => [ '0A0-A-ä', \&App::Asciio::Actions::Mouse::mouse_drag_right ],
	'Mouse drag up 2'                                        => [ '0A0-A-å', \&App::Asciio::Actions::Mouse::mouse_drag_up    ],
	'Mouse drag down 2'                                      => [ '0A0-A--', \&App::Asciio::Actions::Mouse::mouse_drag_down  ],
	
	'Mouse drag left 3'                                      => [ '000-H', \&App::Asciio::Actions::Mouse::mouse_drag_left  ],
	'Mouse drag right 3'                                     => [ '000-L', \&App::Asciio::Actions::Mouse::mouse_drag_right ],
	'Mouse drag up 3'                                        => [ '000-K', \&App::Asciio::Actions::Mouse::mouse_drag_up    ],
	'Mouse drag down 3'                                      => [ '000-J', \&App::Asciio::Actions::Mouse::mouse_drag_down  ],
	
	'Mouse move left'                                        => [ 'C00-C-Left',  \&App::Asciio::Actions::Mouse::mouse_move, [-1,  0]  ],
	'Mouse move right'                                       => [ 'C00-C-Right', \&App::Asciio::Actions::Mouse::mouse_move, [ 1,  0]  ],
	'Mouse move up'                                          => [ 'C00-C-Up',    \&App::Asciio::Actions::Mouse::mouse_move, [ 0, -1]  ],
	'Mouse move down'                                        => [ 'C00-C-Down',  \&App::Asciio::Actions::Mouse::mouse_move, [ 0,  1]  ],
	
	'command mode'=> 
		{
		SHORTCUTS => '000-:',
		
		'Help'                                           => [ '000-h' ],
		'Display manpage'                                => [ '000-m', sub { my ($self) = @_ ; system('perldoc', 'App::Asciio') ; $self->update_display() ; } ],
		'Display keyboard mapping'                       => [ '000-k' ],
		'Display commands'                               => [ '000-c' ],
		'Display action files'                           => [ '000-f' ],
		
		'Open'                                           => [ '000-e' ],
		'Insert'                                         => [ '000-r' ],
		'Save'                                           => [ '000-w' ],
		'SaveAs'                                         => [ '000-W' ],
		'Quit'                                           => [ '000-q' ],
		'Quit no save'                                   => [ '000-Q' ],
		},
	
	'arrow commands' => 
		{
		SHORTCUTS => '000-a',
		
		'Append multi_wirl section'                      => [ '000-s' ],
		'Insert multi_wirl section'                      => [ '000-S' ],
		'Change arrow direction'                         => [ '000-d' ],
		'Flip arrow start and end'                       => [ '000-f' ],
		# 'Prepend multi_wirl section'                     => [ '000-?' ],
		'Remove last section from multi_wirl'            => [ '000-A-s' ],
		},
	
	'Insert commands' => 
		{
		SHORTCUTS => '000-i',
		
		'Import from primary to box'                     => [ '000-y' ],
		'Import from clipboard to box'                   => [ '000-Y' ],
		'External command output in a box'               => [ '000-x' ],
		'External command output in a box no frame'      => [ '000-X' ],
		'Insert from file'                               => [ '000-f' ],
		
		'Add box'                                        => [ '000-b' ],
		# 'Create multiple box elements from description'  => [ '000-M'],
		# 'Create multiple text elements from description' => [ '000-T'],
		
		'Add arrow'                                      => [ '000-a' ],
		'Add connector'                                  => [ '000-c' ],
		'Add help box'                                   => [ '000-h' ],
		'Add if'                                         => [ '000-i' ],
		'Add process'                                    => [ '000-p' ],
		'Add vertical ruler'                             => [ '000-r' ],
		'Add horizontal ruler'                           => [ '000-R' ],
		'Add text'                                       => [ '000-t' ],
		'Add angled arrow'                               => [ '000-A' ],
		'Add shrink box'                                 => [ '000-B' ],
		'Add exec box'                                   => [ '000-e' ],
		'Add exec box no border'                         => [ '000-E' ],
		},
	
	'Delete rulers'                                          => [ '000-A-r' ], 
	
	'grouping commands' => 
		{
		SHORTCUTS => '000-g',
		
		'Group selected elements'                        => [ '000-g' ],
		'Add group object type 1'                        => [ '000-1' ],
		'Add group object type 2'                        => [ '000-2' ],
		'Ungroup selected elements'                      => [ '000-u' ],
		'Ungroup group-object'                           => [ '000-u' ],
		'Move selected elements to the back'             => [ '000-b' ],
		'Move selected elements to the front'            => [ '000-f' ],
		'Temporary move selected element to the front'   => [ '000-F' ],
		},
	
	'stripes-group commands' => 
		{
		SHORTCUTS => '000-A-g',
		
		'create stripes group'                           => ['000-g'],
		'create one stripe group'                        => ['000-1'],
		'ungroup stripes group'                          => ['000-u'],
		},
	
	'display commands' => 
		{
		SHORTCUTS => '000-z',
		
		'Change Asciio background color'                 => [ '000-c' ],
		'Change grid color'                              => [ '000-C' ],
		'Flip grid display'                              => [ '000-g' ],
		'Flip color scheme'                              => [ '000-s' ],
		'Flip transparent element background'            => [ '000-t' ],
		},
	
	'align commands' => 
		{
		SHORTCUTS => '000-A',
		
		'Align bottom'                                   => [ '000-b' ],
		'Align center'                                   => [ '000-c' ],
		'Align left'                                     => [ '000-l' ],
		'Align middle'                                   => [ '000-m' ],
		'Align right'                                    => [ '000-r' ],
		'Align top'                                      => [ '000-t' ],
		},
	
	'slides commands' => 
		{
		SHORTCUTS => '000-S',
		
		'Load slides'                                    => [ '000-l' ],
		'previous slide'                                 => [ '000-N' ],
		'next slide'                                     => [ '000-n' ],
		'first slide'                                    => [ '000-g' ],
		},
	
	'debug commands' => 
		{
		SHORTCUTS => '000-D',
		
		'Display undo stack statistics'                  => [ '000-S' ],
		'Dump self'                                      => [ '000-s' ] ,
		'Dump all elements'                              => [ '000-e' ],
		'Dump selected elements'                         => [ '000-E' ],
		'Display numbered objects'                       => [ '000-t' ],
		'Test'                                           => [ '000-o' ],
		},
	) ;


#----------------------------------------------------------------------------------------------

