
#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	# general
	'Undo'                                                   => [ 'u'  ],
	'Redo'                                                   => [ 'C-r'],
	'Insert from clipboard'                                  => [ 'p' ],
	'Copy to clipboard'                                      => [ 'y' ],
	'Export to clipboard & primary as ascii'                 => [ 'Y' ],
	'Remove rulers'                                          => [ 'A-r' ], 
	
	# elements
	'Quick link'                                             => [ '.' ],
	'Edit selected element'                                  => [ 'Enter' ],
	'Delete selected elements'                               => [ 'd' ],
	'Change elements foreground color'                       => [ 'c' ],
	'Change elements background color'                       => [ 'C' ],
	
	# selection
	'Select all elements'                                    => [ 'V' ],
	'Deselect all elements'                                  => [ 'Escape' ],
	'Select connected elements'                              => [ 'v' ],
	'Select next element'                                    => [ 'n' ],
	'Select previous element'                                => [ 'N' ],
	'Select next element move mouse'                         => [ 'Tab',   \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [1, 1] ],
	'Select previous element move mouse'                     => [ 'S-Tab', \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [0, 1] ],
	
	# sizing
	'Make element narrower'                                  => [ '1' ],
	'Make element taller'                                    => [ '2' ],
	'Make element shorter'                                   => [ '3' ],
	'Make element wider'                                     => [ '4' ],
	'Shrink box'                                             => [ 's' ],
	
	# movement
	'Move selected elements left'                            => [['h', 'Left']],
	'Move selected elements right'                           => [['l', 'Right']],
	'Move selected elements up'                              => [['k', 'Up']],
	'Move selected elements down'                            => [['j', 'Down']],
	
	# mouse
	'Toggle mouse'                                           => [ "'" ],
	
	'Mouse right-click'                                      => [ 'ä' ],
	'Mouse left-click'                                       => [ 'ö' ],
	'Mouse shift-left-click'                                 => [ 'Ö' ],
	'Mouse ctl-left-click'                                   => [ 'ö' ],
	'Mouse alt-left-click'                                   => [ 'ö' ],
	'Mouse on element id'                                    => [ '000' ],
	
	'Mouse drag left'                                        => [ [ 'A-ö', 'H', 'A-Left' ]  ],
	'Mouse drag right'                                       => [ [ 'A-ä', 'L', 'A-Right'] ],
	'Mouse drag up'                                          => [ [ 'A-å', 'K', 'A-Up'  ]  ],
	'Mouse drag down'                                        => [ [ 'A--', 'J', 'A-Down']  ],
	
	'Mouse move left'                                        => [ 'C-Left',  \&App::Asciio::Actions::Mouse::mouse_move, [-1,  0]  ],
	'Mouse move right'                                       => [ 'C-Right', \&App::Asciio::Actions::Mouse::mouse_move, [ 1,  0]  ],
	'Mouse move up'                                          => [ 'C-Up',    \&App::Asciio::Actions::Mouse::mouse_move, [ 0, -1]  ],
	'Mouse move down'                                        => [ 'C-Down',  \&App::Asciio::Actions::Mouse::mouse_move, [ 0,  1]  ],
	
	'command mode'=> 
		{
		SHORTCUTS => ':',
		
		'Help'                                           => [ 'h' ],
		'Display manpage'                                => [ 'm', sub { my ($self) = @_ ; system('perldoc', 'App::Asciio') ; $self->update_display() ; } ],
		'Display keyboard mapping'                       => [ 'k' ],
		'Display commands'                               => [ 'c' ],
		'Display action files'                           => [ 'f' ],
		
		'Open'                                           => [ 'e' ],
		'Insert'                                         => [ 'r' ],
		'Save'                                           => [ 'w' ],
		'SaveAs'                                         => [ 'W' ],
		'Quit'                                           => [ 'q' ],
		'Quit no save'                                   => [ 'Q' ],
		},
	
	'Insert commands' => 
		{
		SHORTCUTS => 'i',
		
		# below need sub that 's not gtk3 dependent
		# 'Import from primary to box'                     => [ 'y' ],
		# 'Import from clipboard to box'                   => [ 'Y' ],
		
		'External command output in a box'               => [ 'x' ],
		'External command output in a box no frame'      => [ 'X' ],
		'Insert from file'                               => [ 'f' ],
		
		'Add box'                                        => [ 'b' ],
		# 'Create multiple box elements from description'  => [ 'M'],
		# 'Create multiple text elements from description' => [ 'T'],
		
		'Add arrow'                                      => [ 'a' ],
		'Add connector'                                  => [ 'c' ],
		'Add help box'                                   => [ 'h' ],
		'Add if'                                         => [ 'i' ],
		'Add process'                                    => [ 'p' ],
		'Add vertical ruler'                             => [ 'r' ],
		'Add horizontal ruler'                           => [ 'R' ],
		'Add text'                                       => [ 't' ],
		'Add angled arrow'                               => [ 'A' ],
		'Add shrink box'                                 => [ 'B' ],
		'Add exec box'                                   => [ 'e' ],
		'Add exec box no border'                         => [ 'E' ],
		},
	
	'arrow commands' => 
		{
		SHORTCUTS => 'a',
		
		'Append multi_wirl section'                      => [ 's' ],
		'Insert multi_wirl section'                      => [ 'S' ],
		'Change arrow direction'                         => [ 'd' ],
		'Flip arrow start and end'                       => [ 'f' ],
		'Prepend multi_wirl section'                     => [ 'p' ],
		'Remove last section from multi_wirl'            => [ 'A-s' ],
		},
	
	'grouping commands' => 
		{
		SHORTCUTS => 'g',
		
		'Group selected elements'                        => [ 'g' ],
		'Ungroup selected elements'                      => [ 'u' ],
		'Ungroup group-object'                           => [ 'u' ],
		'Move selected elements to the back'             => [ 'b' ],
		'Move selected elements to the front'            => [ 'f' ],
		'Temporary move selected element to the front'   => [ 'F' ],
		},
	
	'stripes-group commands' => 
		{
		SHORTCUTS => 'A-g',
		
		'create stripes group'                           => ['0'],
		'create one stripe group'                        => ['0'],
		'ungroup stripes group'                          => ['0'],
		},
	
	'display commands' => 
		{
		SHORTCUTS => 'z',
		
		'Change Asciio background color'                 => [ 'c' ],
		'Change grid color'                              => [ 'C' ],
		'Flip grid display'                              => [ 'g' ],
		'Flip color scheme'                              => [ 's' ],
		'Flip transparent element background'            => [ 't' ],
		},
	
	'align commands' => 
		{
		SHORTCUTS => 'A',
		
		'Align bottom'                                   => [ 'b' ],
		'Align center'                                   => [ 'c' ],
		'Align left'                                     => [ 'l' ],
		'Align middle'                                   => [ 'm' ],
		'Align right'                                    => [ 'r' ],
		'Align top'                                      => [ 't' ],
		},
	
	'slides commands' => 
		{
		SHORTCUTS => 'S',
		
		'Load slides'                                    => [ 'l' ],
		'previous slide'                                 => [ 'N' ],
		'next slide'                                     => [ 'n' ],
		'first slide'                                    => [ 'g' ],
		},
	
	'debug commands' => 
		{
		SHORTCUTS => 'D',
		
		'Display undo stack statistics'                  => [ 'u' ],
		'Dump self'                                      => [ 's' ] ,
		'Dump all elements'                              => [ 'e' ],
		'Dump selected elements'                         => [ 'E' ],
		'Display numbered objects'                       => [ 't' ],
		'Test'                                           => [ 'o' ],
		},
	) ;


#------------------------------------------------------------------------------------------

