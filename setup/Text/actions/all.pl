
#----------------------------------------------------------------------------------------------

# vim like shortcuts

register_action_handlers
	(
	# 'Help'                                           => ':h',
	# 'Display keyboard mapping'                       => ':k',
	# 'Display commands'                               => ':c',
	# 'Display action files'                           => ':f',
	
	# 'Open'                                           => ':e',
	# 'Save'                                           => ':w',
	# 'SaveAs'                                         => ':W',
	# 'Quit'                                           => ':q',
	# 'Quit no save'                                   => ':Q',
	
	# 'Undo'                                           => 'u',
	# 'Redo'                                           => '®',
	
	# 'Import from primary to box'                     => 'iy',
	# 'Import from clipboard to box'                   => 'iY',
	# 'External command output in a box'               => 'ix',
	# 'External command output in a box no frame'      => 'iX',
	# 'Insert from file'                               => 'if',
	
	# 'Append multi_wirl section'                      => 'as',
	# 'Insert multi_wirl section'                      => 'aS',
	# 'Prepend multi_wirl section'                     => 'a?',
	# 'Remove last section from multi_wirl'            => 'a?',
	# 'Change arrow direction'                         => 'ad',
	# 'Flip arrow start and end'                       => 'aa',
	# 'Add group object type 1'                        => 'ig',
	# 'Add group object type 2'                        => 'ig',
	# 'Ungroup group-object'                           => 'lu',
	
	'Add objects'=> 
		{
		SHORTCUTS => '000-i',
		
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

	# 'Group selected elements'                        => 'lg',
	# 'Ungroup selected elements'                      => 'lu',
	# 'Move selected elements to the back'             => 'lb',
	# 'Move selected elements to the front'            => 'lf',
	# 'Temporary move selected element to the front'   => 'lF',
	
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
	
	# 'Insert from clipboard'                          => 'p',
	# 'Copy to clipboard'                              => 'y',
	# 'Export to clipboard & primary as ascii'         => 'Y',
	
	'Move selected elements left'                   => [ '000-h' ],
	'Move selected elements right'                  => [ '000-l' ],
	'Move selected elements up'                     => [ '000-k' ],
	'Move selected elements down'                   => [ '000-j' ],
	
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
	
	
	
	# 'Change AsciiO background color'                 => 'zc',
	# 'Change grid color'                              => 'zC',
	# 'Flip grid display'                              => 'zg',
	# 'Flip color scheme'                              => 'zs',
	# 'Flip transparent element background'            => 'zt',
	# 'Zoom out'                                       => '-',
	# 'Zoom in'                                        => '+',
	
	# 'Align bottom'                                   => 'Ab',
	# 'Align center'                                   => 'Ac',
	# 'Align left'                                     => 'Al',
	# 'Align middle'                                   => 'Am',
	# 'Align right'                                    => 'Ar',
	# 'Align top'                                      => 'At',
	
	# 'Load slides'                                    => 'Sl',
	# 'previous slide'                                 => 'SN',
	# 'next slide'                                     => 'Sn',
	# 'first slide'                                    => 'Sg',
	
	# 'Display undo stack statistics'                  => 'DS',
	# 'Dump self'                                      => 'Ds' ,
	# 'Dump all elements'                              => 'De',
	# 'Dump selected elements'                         => 'DE',
	# 'Display numbered objects'                       => 'Dt',
	# 'Test'                                           => 'Do',
	) ;


#----------------------------------------------------------------------------------------------

