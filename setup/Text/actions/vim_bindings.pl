
#----------------------------------------------------------------------------------------------

register_action_handlers_remove_old_shortcuts
	(
	# general
	'Undo'                                                   => [ 'u'  ],
	'Redo'                                                   => [ 'C-r'],
	'Zoom in'                                                => [ '~Zoom in' ],
	'Zoom out'                                               => [ '~Zoom out' ],
	'Insert from clipboard'                                  => [ 'p' ],
	'Copy to clipboard'                                      => [ 'y' ],
	
	'Export to clipboard & primary as ascii'                 => [ 'Y' ],
	'Import from primary to box'                             => [ 'P' ],
	'Import from primary to text'                            => [ 'A-P' ],
	'Import from clipboard to box'                           => [ '~import from clipboard to box' ],
	'Import from clipboard to text'                          => [ '~import from clipboard to text' ],
	
	'Remove rulers'                                          => [ 'A-r' ], 
	
	# elements
	'Edit selected element'                                  => [ 'Enter' ],
	'Delete selected elements'                               => [ 'd' ],
	'Change elements foreground color'                       => [ 'c' ],
	'Change elements background color'                       => [ 'C' ],
	
	'Insert flex point'                                      => [ 'not set-Insert flex point' ],
	
	# selection
	'Select all elements'                                    => [ 'V' ],
	'Deselect all elements'                                  => [ 'Escape' ],
	'Select connected elements'                              => [ 'v' ],
	'Switch cross mode'                                      => ['A-x'],
	'Select next element'                                    => [ 'n' ],
	'Select previous element'                                => [ 'N' ],
	'Select next element move mouse'                         => [ 'Tab',   \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [1, 1, 0] ],
	'Select previous element move mouse'                     => [ 'S-Tab', \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [0, 1, 0] ],
	'Select element by id'                                   => [ 'not_set-Select element by id' ],
	'Select next non arrow'                                  => [ 'C-n' ],
	'Select previous non arrow'                              => [ '~Select previous non arrow' ],
	'Select next arrow'                                      => [ '~Select next non arrow' ],
	'Select previous arrow'                                  => [ '~Select previous arrow' ],
	
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
	'Mouse emulation toggle'                                 => [ "'" ],
	'Mouse emulation right-click'                            => [ 'ä' ],
	'Mouse emulation left-click'                             => [ 'ö' ],
	
	'Mouse emulation selection flip'                         => [ '~Mouse emulation selection flip' ], # C-ö doesn't work 
	'Mouse emulation expand selection'                       => [ '~Mouse emulation exapand selection' ],
	# 'Mouse left-click'                                       => [ '~Mouse left-click' ],
	# 'Mouse motion'                                           => [ '~Mouse motion' ],
	# 'Mouse motion 2'                                         => [ '~Mouse motion 2' ],
	# 'Mouse right-click'                                      => [ '~Mouse right-click' ],
	# 'Mouse expand selection'                                 => [ '~Mouse expand selection' ],
	# 'Mouse selection flip'                                   => [ '~Mouse selection flip' ],

	# 'Mouse quick link'                                       => [ ['A-ö', '.'] ],
	'Mouse quick link git'                                   => [ ['A-ä', ';'] ],
	'Mouse duplicate elements'                               => [ ['A-Ö', ','] ],

	'Mouse on element id'                                    => [ '~Mouse on element id' ],
	
	'Mouse emulation drag left'                              => [ [ 'H', 'A-C-Left' ] ],
	'Mouse emulation drag right'                             => [ [ 'L', 'A-C-Right'] ],
	'Mouse emulation drag up'                                => [ [ 'K', 'A-C-Up'  ]  ],
	'Mouse emulation drag down'                              => [ [ 'J', 'A-C-Down']  ],
	
	'Mouse emulation move left'                              => [ 'C-Left' ],
	'Mouse emulation move right'                             => [ 'C-Right' ],
	'Mouse emulation move up'                                => [ 'C-Up' ],
	'Mouse emulation move down'                              => [ 'C-Down' ],
	
	'command leader'=> 
		{
		SHORTCUTS => ':',
		
		'Help'                                           => [ 'h' ],
		'Display manpage'                                => [ 'm', sub { my ($self) = @_ ; system('perldoc', 'App::Asciio') ; $self->update_display() ; } ],
		'Display keyboard mapping'                       => [ 'k', sub 
										{
										my ($self) = @_ ;
										my $mapping_file = App::Asciio::Actions::Unsorted::get_keyboard_mapping_file($self) ;
										system "cat '$mapping_file' | fzf --cycle --layout=reverse-list" ;
										$self->update_display() ;
										}
									],
		'Display commands'                               => [ 'c' ],
		'Display action files'                           => [ 'f' ],
		
		'Open'                                           => [ 'e' ],
		'Insert'                                         => [ 'r' ],
		'Save'                                           => [ 'w' ],
		'SaveAs'                                         => [ 'W' ],
		'Quit'                                           => [ 'q' ],
		'Quit no save'                                   => [ 'Q' ],
		},
	
	'Insert leader' => 
		{
		SHORTCUTS => 'i',
		
		'Add from file'                                  => [ 'f' ],
		'Add fron stencil'                               => [ 's' ],
		'Add multiple boxes'                             => [ 'C-b'],
		'Add multiple texts'                             => [ 'C-t'],
		
		'From default_stencil'                           => ['000-s'], 
		'From stencil'                                   => ['000-S'], 
		
		'Add angled arrow'                               => [ 'A' ],
		'Add arrow'                                      => [ 'a' ],
		'Add box'                                        => [ 'b' ],
		'Add connector type 2'                           => [ 'C' ],
		'Add connector'                                  => [ 'c' ],
		'Add exec box no border'                         => [ 'E' ],
		'Add exec box'                                   => [ 'e' ],
		'Add external command box no frame'              => [ 'X' ],
		'Add external command box'                       => [ 'x' ],
		'Add help box'                                   => [ 'h' ],
		'Add horizontal ruler'                           => [ 'R' ],
		'Add if'                                         => [ 'i' ],
		'Add process'                                    => [ 'p' ],
		'Add shrink box'                                 => [ 'A-b' ],
		'Add text'                                       => [ 't' ],
		'Add unicode arrow'                              => [ 'S' ],
		'Add unicode box'                                => [ 'B' ],
		'Add vertical ruler'                             => [ 'r' ],
		'Add rhombus'                                    => [ 'A-r' ],
		'Add ellipse'                                    => [ 'A-e' ],
		},
	
	'arrow leader' => 
		{
		SHORTCUTS => 'a',
		
		'Append multi_wirl section'                      => [ 's' ],
		'Insert multi_wirl section'                      => [ 'S' ],
		'Change arrow direction'                         => [ 'd' ],
		'Flip arrow start and end'                       => [ 'f' ],
		'Prepend multi_wirl section'                     => [ 'p' ],
		'Remove last section from multi_wirl'            => [ 'A-s' ],
		},
	
	'grouping leader' => 
		{
		SHORTCUTS => 'g',
		
		'Group selected elements'                        => [ 'g' ],
		'Ungroup selected elements'                      => [ 'u' ],
		'Ungroup group-object'                           => [ 'u' ],
		'Move selected elements to the back'             => [ 'b' ],
		'Move selected elements to the front'            => [ 'f' ],
		'Temporary move to the front'                    => [ 'F' ],
		'Make Unicode             '                      => [ '~Make Unicode' ],
		},
	
	'stripes-group leader' => 
		{
		SHORTCUTS => 'A-g',
		
		'create stripes group'                           => ['g'],
		'create one stripe group'                        => ['1'],
		'ungroup stripes group'                          => ['u'],
		},
	
	'display leader' => 
		{
		SHORTCUTS => 'z',
		
		'Change Asciio background color'                 => [ 'c' ],
		'Change grid color'                              => [ 'C' ],
		'Flip grid display'                              => [ 'g' ],
		'Flip color scheme'                              => [ 's' ],
		'Flip transparent element background'            => [ 't' ],
		'Change font'                                    => [ '~Change font' ],
		},
	
	'align leader' => 
		{
		SHORTCUTS => 'A',
		
		'Align bottom'                                   => [ 'b' ],
		'Align center'                                   => [ 'c' ],
		'Align left'                                     => [ 'l' ],
		'Align middle'                                   => [ 'm' ],
		'Align right'                                    => [ 'r' ],
		'Align top'                                      => [ 't' ],
		},
	
	'slides leader' => 
		{
		SHORTCUTS => 'S',
		
		'Load slides'                                    => [ 'l' ],
		'previous slide'                                 => [ 'N' ],
		'next slide'                                     => [ 'n' ],
		'first slide'                                    => [ 'g' ],
		},
	
	'debug leader' => 
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

