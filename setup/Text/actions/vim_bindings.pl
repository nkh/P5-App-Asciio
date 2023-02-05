
#----------------------------------------------------------------------------------------------

# vim like shortcuts

sub load_test_file
{
my ($self, $file_name) = @_ ;
my $title = $self->load_file($file_name) ;
}

register_action_handlers
	(
	'command group'=> 
		{
		SHORTCUTS => '000-:',
		
		'load test file'                                   => [ '000-t', \&load_test_file, 'test.asciio' ],
		# 'Help'                                           => 'h',
		# 'Display keyboard mapping'                       => 'k',
		# 'Display commands'                               => 'c',
		# 'Display action files'                           => 'f',
		
		# 'Open'                                           => 'e',
		# 'Save'                                           => 'w',
		# 'SaveAs'                                         => 'W',
		# 'Quit'                                           => 'q',
		# 'Quit no save'                                   => 'Q',
		},

	'Undo'                                           => [ '000-u'  ],
	'Redo'                                           => [ 'C00-C-r'],
	
	# elements group
	# --------------
	'Insert from clipboard'                         => [ '000-p' ],
	'Copy to clipboard'                             => [ '000-y' ],
	'Export to clipboard & primary as ascii'        => [ '000-Y' ],
	
	# 'Edit selected element'                          => 'Return',
	# 'Change elements foreground color'               => 'ec',
	# 'Change elements background color'               => 'eC',
	'Select all elements'                           => [ 'C00-C-s'   ],
	'Deselect all elements'                         => [ 'C00-C-l'   ],
	# 'Select connected elements'                      => '',
	'Select next element'                           => [ '000-n' ],
	'Select previous element'                       => [ '000-N' ],
	'Select next element move mouse'                => [ '000-Tab',   \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [1, 1] ],
	'Select previous element move mouse'            => [ '00S-S-Tab', \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [0, 1] ],
	
	# 'Delete selected elements'                       => 'dd',
	
	'Resize element narrower'                       => [ '000-1' ],
	'Resize element taller'                         => [ '000-2' ],
	'Resize element shorter'                        => [ '000-3' ],
	'Resize element wider'                          => [ '000-4' ],
	
	'Move selected elements left'                   => [ '000-h' ],
	'Move selected elements right'                  => [ '000-l' ],
	'Move selected elements up'                     => [ '000-k' ],
	'Move selected elements down'                   => [ '000-j' ],
	
	# mouse group
	# -----------
	'Toggle mouse'                                  => [ "000-'" ],
	'Mouse right-click'                             => [ '000-ä' ],
	'Mouse left-click'                              => [ '000-ö' ],
	'Mouse shift-left-click'                        => [ '000-Ö' ],
	'Mouse ctl-left-click'                          => [ 'C00-ö' ],
	'Mouse alt-left-click'                          => [ '0A0-ö' ],

	# 'Mouse drag down'                               => [ '000-J' ],
	# 'Mouse drag left'                               => [ '000-H' ],
	# 'Mouse drag right'                              => [ '000-L' ],
	# 'Mouse drag up'                                 => [ '000-K' ],
	'Mouse drag left'                               => [ '0A0-A-Left'  ] ,
	'Mouse drag right'                              => [ '0A0-A-Right' ] ,
	'Mouse drag up'                                 => [ '0A0-A-Up'    ] ,
	'Mouse drag down'                               => [ '0A0-A-Down'  ] ,
	# 'Mouse on element id'                            => 'ge',
	# 'Quick link'                                     => 'shift+button_press-1',
	
	'arrow group' => 
		{
		SHORTCUTS => '000-a',
		
		# 'Append multi_wirl section'                      => 's',
		# 'Insert multi_wirl section'                      => 'S',
		# 'Prepend multi_wirl section'                     => '?',
		# 'Remove last section from multi_wirl'            => '?',
		# 'Change arrow direction'                         => 'd',
		# 'Flip arrow start and end'                       => 'a',
		},
	
	'Add objects group' => 
		{
		SHORTCUTS => '000-i',
		
		# 'Add group object type 1'                        => 'ig',
		# 'Add group object type 2'                        => 'ig',
		
		# 'Import from primary to box'                     => 'y',
		# 'Import from clipboard to box'                   => 'Y',
		# 'External command output in a box'               => 'x',
		# 'External command output in a box no frame'      => 'X',
		# 'Insert from file'                               => 'f',
		
		'Add box'                                        => [ '000-b' ],
		# 'Create multiple box elements from description'  => [ '000-M'],
		# 'Create multiple text elements from description' => [ '000-T'],
		
		'Add arrow'                                      => [ '000-a' ],
		'Add connector'                                  => [ '000-c' ],
		'Add if'                                         => [ '000-i' ],
		'Add process'                                    => [ '000-p' ],
		'Add vertical ruler'                             => [ '000-r' ],
		'Add horizontal ruler'                           => [ '000-R' ],
		# 'Delete rulers'                                  => [ '000-r' ],
		'Add text'                                       => [ '000-t' ],
		'Add angled arrow'                               => [ '000-A' ],
		'Add shrink box'                                 => [ '000-B' ],
		},
	
	'grouping group' => 
		{
		SHORTCUTS => '000-g',
		
		'Group selected elements'                        => [ '000-g' ],
		'Ungroup selected elements'                      => [ '000-u' ],
		'Ungroup group-object'                           => [ '000-u' ],
		'Move selected elements to the back'             => [ '000-b' ],
		'Move selected elements to the front'            => [ '000-f' ],
		'Temporary move selected element to the front'   => [ '000-F' ],
		},
	
	'display group' => 
		{
		SHORTCUTS => '000-z',
		
		'Change Asciio background color'                 => [ '000-c' ],
		'Change grid color'                              => [ '000-C' ],
		'Flip grid display'                              => [ '000-g' ],
		'Flip color scheme'                              => [ '000-s' ],
		'Flip transparent element background'            => [ '000-t' ],
		# 'Zoom out'                                       => [ '000--' ],
		# 'Zoom in'                                        => [ '000-+' ],
		},
	
	'align group' => 
		{
		SHORTCUTS => '000-A',
		
		'Align bottom'                                   => [ '000-b' ],
		'Align center'                                   => [ '000-c' ],
		'Align left'                                     => [ '000-l' ],
		'Align middle'                                   => [ '000-m' ],
		'Align right'                                    => [ '000-r' ],
		'Align top'                                      => [ '000-t' ],
		},
	
	'slides group' => 
		{
		SHORTCUTS => '000-S',
		
		# 'Load slides'                                    => 'l',
		# 'previous slide'                                 => 'N',
		# 'next slide'                                     => 'n',
		# 'first slide'                                    => 'g',
		},
	
	'debug group' => 
		{
		SHORTCUTS => '000-D',
		# 'Display undo stack statistics'                  => 'S',
		# 'Dump self'                                      => 's' ,
		# 'Dump all elements'                              => 'e',
		# 'Dump selected elements'                         => 'E',
		# 'Display numbered objects'                       => 't',
		# 'Test'                                           => 'o',
		},
	) ;


#----------------------------------------------------------------------------------------------

