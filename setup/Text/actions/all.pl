
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

	# 'Undo'                                           => 'u',
	# 'Redo'                                           => '®',
	
	# elements group
	# --------------
	# 'Insert from clipboard'                          => 'p',
	# 'Copy to clipboard'                              => 'y',
	# 'Export to clipboard & primary as ascii'         => 'Y',
	
	# 'Edit selected element'                          => 'Return',
	# 'Change elements foreground color'               => 'ec',
	# 'Change elements background color'               => 'eC',
	# 'Select all elements'                            => '',
	# 'Select connected elements'                      => '',
	
	'Deselect all elements'                         => [ 'C00-C-l'   ],
	# 'Select next element'                            => 'n',
	'Select next element'                           => [ '000-<Tab>' ],
	
	# 'Select previous element'                        => 'N',
	# 'Delete selected elements'                       => 'dd',
	
	'Move selected elements left'                   => [ '000-h' ],
	'Move selected elements right'                  => [ '000-l' ],
	'Move selected elements up'                     => [ '000-k' ],
	'Move selected elements down'                   => [ '000-j' ],
	
	# mouse group
	# -----------
	'Toggle mouse'                                  => [ "000-'" ] ,
	'Mouse right-click'                             => [ '000-ä' ] ,
	'Mouse left-click'                              => [ '000-ö' ] ,
	'Mouse shift-left-click'                        => [ '000-Ö' ] ,
	'Mouse ctl-left-click'                          => [ 'C00-ö' ] ,
	'Mouse alt-left-click'                          => [ '0A0-ö' ] ,

	# 'Mouse drag down'                                => 'J',
	# 'Mouse drag left'                                => 'H',
	# 'Mouse drag right'                               => 'L',
	# 'Mouse drag up'                                  => 'K',
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

	# 'grouping group' => 
	# 	{
	# 	SHORTCUTS => '000-l',
		
		# 'Group selected elements'                        => 'g',
		# 'Ungroup selected elements'                      => 'u',
		# 'Ungroup group-object'                           => 'u',
		# 'Move selected elements to the back'             => 'b',
		# 'Move selected elements to the front'            => 'f',
		# 'Temporary move selected element to the front'   => 'F',
		# },
	
	# 'display group' => 
	# 	{
	# 	SHORTCUTS => '000-z',
		
		# 'Change AsciiO background color'                 => 'c',
		# 'Change grid color'                              => 'C',
		# 'Flip grid display'                              => 'g',
		# 'Flip color scheme'                              => 's',
		# 'Flip transparent element background'            => 't',
		# 'Zoom out'                                       => '-',
		# 'Zoom in'                                        => '+',
		# },
	
	'align group' => 
		{
		SHORTCUTS => '000-A',
		
		# 'Align bottom'                                   => 'b',
		# 'Align center'                                   => 'c',
		# 'Align left'                                     => 'l',
		# 'Align middle'                                   => 'm',
		# 'Align right'                                    => 'r',
		# 'Align top'                                      => 't',
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

