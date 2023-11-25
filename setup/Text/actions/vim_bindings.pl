#----------------------------------------------------------------------------------------------

register_action_handlers_remove_old_shortcuts
(
'Undo'                                            => ['u'],
'Redo'                                            => ['C-r'],
'Zoom in'                                         => ['not set Zoom in'],
'Zoom out'                                        => ['not set Zoom out'],

'Select next element'                             => ['Tab',],
'Select previous element'                         => ['S-Tab'],
'Select next non arrow'                           => ['n'],
'Select previous non arrow'                       => ['N'],
'Select next arrow'                               => ['m'],
'Select previous arrow'                           => ['M'],

'Select all elements'                             => ['V'],
'Deselect all elements'                           => ['Escape'],
'Select connected elements'                       => ['v'],
'Select elements by word'                         => ['C-f'],
'Select elements by word no group'                => ['not set'],

'Delete selected elements'                        => [['Delete', 'd']],

'Edit selected element'                           => ['Enter'],
'Edit selected element inline'                    => ['A-Enter'],

'Move selected elements left'                     => ['h'],
'Move selected elements right'                    => ['l'],
'Move selected elements up'                       => ['k'],
'Move selected elements down'                     => ['j'],

'Move selected elements left quick'               => ['A-Left'],
'Move selected elements right quick'              => ['A-Right'],
'Move selected elements up quick'                 => ['A-Up'],
'Move selected elements down quick'               => ['A-Down'],

'Move selected elements left 2'                   => ['Left'],
'Move selected elements right 2'                  => ['Right'],
'Move selected elements up 2'                     => ['Up'],
'Move selected elements down 2'                   => ['Down'],

# mouse
'Mouse right-click'                               => ['000-button-press-3'],

'Mouse left-click'                                => ['000-button-press-1'],
'Start Drag and Drop'                             => ['C00-button-press-1'],

'Mouse left-release'                              => ['000-button-release-1'],
'Mouse left-release2'                             => ['C00-button-release-1'],
'Mouse left-release3'                             => ['00S-button-release-1'],
'Mouse left-release4'                             => ['C0S-button-release-1'],

#'Mouse expand selection'                          => ['not set'], #'00S-button-press-1' shit + button not available
'Mouse selection flip'                            => ['C00-button-press-1'],

'Mouse quick link'                                => [['0A0-button-press-1', '.']],
'Mouse duplicate elements'                        => [['A-ö', '.']],
'Mouse quick box'                                 => ['not set'], # 'C0S-button-press-1' not available

'Arrow to mouse'                                  => ['CA0-motion_notify'], 
'Arrow mouse change direction'                    => ['not set'], # 'CA0-2button-press-1' not available      
'Arrow change direction'                          => ['A-C-d'],      
'Wirl arrow add section'                          => ['CA0-button-press-1'],
'Wirl arrow insert flex point'                    => ['not set'], # 'CA0-button-press-2' not available

'Mouse motion'                                    => ['000-motion_notify'], 
'Mouse motion 2'                                  => ['not set'], # 'CAS-motion_notify' not available
'Mouse drag canvas'                               => ['C00-motion_notify'],         

# mouse emulation
'Mouse emulation toggle'                          => ["'"],

'Mouse emulation left-click'                      => ['ä'],
'Mouse emulation expand selection'                => ['not set'], # '00S-Odiaeresis'
'Mouse emulation selection flip'                  => ['not_set'], # 'C00-odiaeresis'

'Mouse emulation right-click'                     => ['not set'], # crashes in IO::Prompter

'Mouse emulation move left'                       => ['C-Left' ],
'Mouse emulation move right'                      => ['C-Right'],
'Mouse emulation move up'                         => ['C-Up'   ],
'Mouse emulation move down'                       => ['C-Down' ],

'Mouse emulation drag left'                       => ['H'],
'Mouse emulation drag right'                      => ['L'],
'Mouse emulation drag up'                         => ['K'],
'Mouse emulation drag down'                       => ['J'],

'Mouse on element id'                             => ['not set'],




'<< yank leader >>' =>
	{
	SHORTCUTS => 'y',
	
	'Copy to clipboard'                       => ['y'],
	'Export to clipboard & primary as ascii'  => ['Y'],
	'Export to clipboard & primary as markup' => ['m'],
	},

'<< paste leader >>' =>
	{
	SHORTCUTS => 'p',

	'Insert from clipboard'                   => ['p'],
	'Import from clipboard to box'            => ['b'],
	'Import from clipboard to text'           => ['t'],
	'Import from primary to box'              => ['B'],
	'Import from primary to text'             => ['T'],
	},

'<< grouping leader >>' => 
	{
	SHORTCUTS => 'g',
	
	'Group selected elements'                 => ['g'],
	'Ungroup selected elements'               => ['u'],
	'Move selected elements to the front'     => ['f'],
	'Move selected elements to the back'      => ['b'],
	'Temporary move to the front'             => ['F'],
	},

'<< stripes leader >>' => 
	{
	SHORTCUTS => 'A-g',
	
	'create stripes group'                    => ['g'],
	'create one stripe group'                 => ['1'],
	'ungroup stripes group'                   => ['u'],
	},

'<< align leader >>' => 
	{
	SHORTCUTS => 'A',
	
	'Align top'                               => ['t'],
	'Align left'                              => ['l'],
	'Align bottom'                            => ['b'],
	'Align right'                             => ['r'],
	'Align vertically'                        => ['v'],
	'Align horizontally'                      => ['h'],
	},

'<< change color/font leader >>'=> 
	{
	SHORTCUTS => 'z',
	
	'Change font'                             => ['F'],
	'<< Change color >>'                      => ['c'],
	
	'Flip binding completion'                 => ['b'],
	'Flip cross mode'                         => ['x'],
	'Flip color scheme'                       => ['s'],
	'Flip transparent element background'     => ['t'],
	'Flip grid display'                       => ['g'],
	'Flip hint lines'                         => ['h'],
	'Flip edit inline'                        => ['i'], 
	'Flip show/hide connectors'               => ['v'], 
	},

'group_color' => 
	{
	SHORTCUTS => 'group_color',
	
	'Change elements foreground color'        => ['b'],
	'Change elements background color'        => ['f'],

	'Change Asciio background color'          => ['B'],
	'Change grid color'                       => ['g'],
	},

'<< arrow leader >>' => 
	{
	SHORTCUTS => 'a',
	
	'Change arrow direction'                  => ['d'],
	'Flip arrow start and end'                => ['f'],
	'Append multi_wirl section'               => ['s'],
	'Insert multi_wirl section'               => ['S'],
	'Prepend multi_wirl section'              => ['C-s'],
	'Remove last section from multi_wirl'     => ['A-C-s'],
	'Start no disconnect'                     => ['C-d'],
	'End no disconnect'                       => ['A-D'],
	},

'<< debug leader >>' => 
	{
	SHORTCUTS => 'D',
	
	'Display undo stack statistics'           => ['u'],
	'Dump self'                               => ['s'],
	'Dump all elements'                       => ['e'],
	'Dump selected elements'                  => ['E'],
	'Display numbered objects'                => ['t'],
	'Test'                                    => ['o'],
	'ZBuffer Test'                            => ['z'],
	},

'<< commands leader >>'=> 
	{
	SHORTCUTS => ':',
	
	'Help'                                    => ['h'],
	'Add help box'                            => ['H'],
	
	'Display keyboard mapping'                => ['k'],
	'Display commands'                        => ['c'],
	'Display action files'                    => ['f'],
	'Display manpage'                         => ['m'],
	
	'Run external script'                     => ['!'],
	
	'Open'                                    => ['e'],
	'Save'                                    => ['w'],
	'SaveAs'                                  => ['W'],
	'Insert'                                  => ['r'],
	'Quit'                                    => ['q'],
	'Quit no save'                            => ['Q'],
	},

'<< Insert leader >>' => 
	{
	SHORTCUTS => 'i',
	
	'Add connector'                           => ['c'],
	'Add text'                                => ['t'],
	'Add arrow'                               => ['a'],
	
	
	
	
	
	
	
	
	'Add angled arrow'                        => ['A'],
	
	'Add ascii line'                          => ['l'], 
	'Add ascii no-connect line'               => ['k'], 
	
	'From default_stencil'                    => ['s'], 
	'From stencil'                            => ['S'], 
	
	'<< Multiple >>'                          => ['m'] ,
	'<< Unicode >>'                           => ['u'] ,
	'<< Box >>'                               => ['b'] ,
	'<< Elements >>'                          => ['e'] ,
	'<< Ruler >>'                             => ['r'] ,
	},

'group_insert_multiple' => 
	{
	SHORTCUTS => 'group_insert_multiple',
	
	'Add multiple texts'                      => ['t'],
	'Add multiple boxes'                      => ['b'],
	},

'group_insert_ruler' => 
	{
	SHORTCUTS => 'group_insert_ruler',
	
	'Add vertical ruler'                      => ['v'],
	'Add horizontal ruler'                    => ['h'],
	'delete rulers'                           => ['d'],
	},

'group_insert_element' => 
	{
	SHORTCUTS => 'group_insert_element',
	
	'Add connector type 2'                    => ['c'],
	'Add if'                                  => ['i'],
	'Add process'                             => ['p'],
	'Add rhombus'                             => ['r'],
	'Add ellipse'                             => ['e'],
	},

'group_insert_box' => 
	{
	SHORTCUTS => 'group_insert_box',
	
	'Add box'                                 => ['b'],
	'Add shrink box'                          => ['s'],
	
	'Add exec box'                            => ['e'],
	'Add exec box verbatim'                   => ['v'],
	'Add exec box verbatim once'              => ['o'],
	'Add line numbered box'                   => ['l'],
	},

'group_insert_unicode' => 
	{
	SHORTCUTS => 'group_insert_unicode',
	
	'Add unicode box'                         => ['b'],
	'Add unicode arrow'                       => ['a'],
	'Add unicode angled arrow'                => ['A'],
	'Add unicode line'                        => ['l'],
	
	'Add unicode bold line'                   => ['L'],
	'Add unicode double line'                 => ['A-l'],
	
	'Add unicode no-connect line'             => ['k'],
	'Add unicode no-connect bold line'        => ['K'],
	'Add unicode no-connect double line'      => ['A-K'],
	},

'<< element leader >>' => 
	{
	SHORTCUTS => 'e',
	
	'Shrink box'                              => ['s'],
	
	'Make element narrower'                   => ['1'],
	'Make element taller'                     => ['2'],
	'Make element shorter'                    => ['3'],
	'Make element wider'                      => ['4'],
	
	'Make elements Unicode'                   => ['u'],
	'Make elements not Unicode'               => ['U'],
	},

'<< selection leader >>' =>
	{
	SHORTCUTS   => 's',
	ENTER_GROUP => \&App::Asciio::Actions::Selection::selection_enter,
	ESCAPE_KEYS => ['s', 'Escape'],
	
	'Selection escape'               => ['s'],
	'Selection escape2'              => ['Escape'],

	'select flip mode'               => ['e'],
	'select motion'                  => ['000-motion_notify'],
	'Mouse polygon selection'        => ['not_set'],
	},

'<< eraser leader >>' =>
	{
	SHORTCUTS   => '00S-E',
	ENTER_GROUP => \&App::Asciio::Actions::Eraser::eraser_enter,
	ESCAPE_KEYS => '000-Escape',
	
	'Eraser escape'                           => ['Escape'],
	'Eraser motion'                           => ['000-motion_notify'],
	},

'<< clone leader >>' =>
	{
	SHORTCUTS   => 'c',
	ENTER_GROUP => \&App::Asciio::Actions::Clone::clone_enter,
	ESCAPE_KEYS => 'Escape',
	
	# 'clone escape'                            => ['Escape'],
	'clone motion'                            => ['000-motion_notify'], 
	
	'clone insert'                            => ['000-button-press-1'],
	'clone insert2'                           => ['Enter'],
	'clone arrow'                             => ['a'],
	'clone angled arrow'                      => ['A'],
	'clone box'                               => ['b'],
	'clone text'                              => ['t'],
	'clone flip hint lines'                   => ['h'],
	
	'clone left'                              => ['Left'],
	'clone right'                             => ['Right'],
	'clone up'                                => ['Up'],
	'clone down'                              => ['Down'],
	
	'clone emulation left'                    => ['C-Left'],
	'clone emulation right'                   => ['C-Right'],
	'clone emulation up'                      => ['C-Up'],
	'clone emulation down'                    => ['C-Down'],
	},

'<< git leader >>' =>
	{
	SHORTCUTS   => 'G',
	ESCAPE_KEYS => 'Escape',
	
	'Show git bindings'                       => ['?'],
	
	'Quick git'                               => ['c'],
	
	'Git add box'                             => ['b'],
	'Git add text'                            => ['t'],
	'Git add arrow'                           => ['a'],
	'Git edit selected element'               => ['Enter'],
	
	'Git mouse left-click'                    => ['000-button-press-1'],
	'Git change arrow direction'              => ['d'],
	'Git undo'                                => ['u'],
	'Git delete elements'                     => [['delete', 'x']],
	
	'Git mouse motion'                        => ['000-motion_notify'], 
	'Git move elements left'                  => ['Left'],
	'Git move elements right'                 => ['Right'],
	'Git move elements up'                    => ['Up'],
	'Git move elements down'                  => ['Down'],
	
	'Git mouse right-click'                   => ['not set'], # '0A0-button-press-3' not available
	'Git flip hint lines'                     => ['h'],
	},

'<< slides leader >>' => 
	{
	SHORTCUTS => 'S',
	ESCAPE_KEYS => 'Escape',
	
	'Load slides'                             => ['l'],
	'previous slide'                          => ['N'],
	'next slide'                              => ['n'],
	'first slide'                             => ['g'],
	'show previous message'                   => ['m'],
	'show next message'                       => ['M'],
	},

'<< move arrow ends leader >>' =>
	{
	SHORTCUTS  => 'A-a',
	ESCAPE_KEYS => 'Escape',
	
	'arrow start up'                          => ['Up'],
	'arrow start down'                        => ['Dpwn'],
	'arrow start right'                       => ['Right'],
	'arrow start left'                        => ['Left'],
	'arrow start up2'                         => ['k'],
	'arrow start down2'                       => ['j'],
	'arrow start right2'                      => ['l'],
	'arrow start left2'                       => ['h'],
	'arrow end up'                            => ['S-Up'],
	'arrow end down'                          => ['S-Down'],
	'arrow end right'                         => ['S-Right'],
	'arrow end left'                          => ['S-Left'],
	'arrow end up2'                           => ['K'],
	'arrow end down2'                         => ['J'],
	'arrow end right2'                        => ['L'],
	'arrow end left2'                         => ['H'],
	},
) ;

