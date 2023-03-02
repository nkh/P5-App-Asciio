
#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	# general
	'Undo'                                                   => [ 'u'  ],
	'Redo'                                                   => [ 'C-r'],
	'Insert from clipboard'                                  => [ 'p' ],
	'Copy to clipboard'                                      => [ 'y' ],
	
	'Export to clipboard & primary as ascii'                 => [ 'Y' ],
	'Import from primary to box'                             => [ 'P' ],
	'Import from primary to text'                            => [ 'A-P' ],
	# 'Import from clipboard to box'                           => [ '' ],
	
	'Remove rulers'                                          => [ 'A-r' ], 
	
	# elements
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
	'Move selected elements left'                            => [ ['h', 'Left'] ],
	'Move selected elements right'                           => [ ['l', 'Right'] ],
	'Move selected elements up'                              => [ ['k', 'Up'] ],
	'Move selected elements down'                            => [ ['j', 'Down'] ],
	
	'Move selected elements left quick'                      => ['A-Left' ],
	'Move selected elements right quick'                     => ['A-Right'],
	'Move selected elements up quick'                        => ['A-Up'   ],
	'Move selected elements down quick'                      => ['A-Down' ],

	# mouse
	'Mouse right-click'                                      => [ 'ä' ],
	'Mouse left-click'                                       => [ 'ö' ],
	
	# 'Mouse emulation selection flip'                         => [ '???' ], # C-ö doesn't work 
	# 'Mouse emulation expand selection'                       => [ '???' ],

	'Mouse quick link'                                       => [ ['A-ö', '.'] ],
	'Mouse quick link git'                                   => [ ['A-ä', ';'], ],
	'Mouse duplicate elements'                               => [ ['A-Ö', ','] ],

	'Mouse on element id'                                    => [ '000' ],
	
	'Mouse emulation drag left'                              => [ [ 'H', 'A-C-Left' ] ],
	'Mouse emulation drag right'                             => [ [ 'L', 'A-C-Right'] ],
	'Mouse emulation drag up'                                => [ [ 'K', 'A-C-Up'  ]  ],
	'Mouse emulation drag down'                              => [ [ 'J', 'A-C-Down']  ],
	
	'Mouse emulation move left'                              => [ 'C-Left' ],
	'Mouse emulation move right'                             => [ 'C-Right' ],
	'Mouse emulation move up'                                => [ 'C-Up' ],
	'Mouse emulation move down'                              => [ 'C-Down' ],
	
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
		
		'External command in a box'                      => [ 'x' ],
		'External command in a box no frame'             => [ 'X' ],
		'Insert from file'                               => [ 'f' ],
		
		'Add box'                                        => [ 'b' ],
		# 'Create multiple box elements'  => [ 'C-b'],
		# 'Create multiple text elements' => [ 'C-t'],
		
		'Add arrow'                                      => [ 'a' ],
		'Add connector'                                  => [ 'c' ],
		'Add help box'                                   => [ 'h' ],
		'Add if'                                         => [ 'i' ],
		'Add process'                                    => [ 'p' ],
		'Add vertical ruler'                             => [ 'r' ],
		'Add horizontal ruler'                           => [ 'R' ],
		'Add text'                                       => [ 't' ],
		'Add angled arrow'                               => [ 'A' ],
		'Add shrink box'                                 => [ 'A-b' ],
		'Add exec box'                                   => [ 'e' ],
		'Add exec box no border'                         => [ 'E' ],
		'Add unicode box'                                => [ 'B' ],
		'Add unicode arrow'                              => [ 'S' ],
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
		'Temporary move to the front'                    => [ 'F' ],
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

