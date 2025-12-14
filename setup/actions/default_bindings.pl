
use App::Asciio::Actions ;
use App::Asciio::Actions::Align ;
use App::Asciio::Actions::Arrow ;
use App::Asciio::Actions::Asciio ;
use App::Asciio::Actions::Box ;
use App::Asciio::Actions::Clipboard ;
use App::Asciio::Actions::Clone ;
use App::Asciio::Actions::Colors ;
use App::Asciio::Actions::Debug ;
use App::Asciio::Actions::Elements ;
use App::Asciio::Actions::ElementsManipulation ;
use App::Asciio::Actions::ElementAttributes ;
use App::Asciio::Actions::Eraser ;
use App::Asciio::Actions::File ;
use App::Asciio::Actions::Git ;
use App::Asciio::Actions::Mouse ;
use App::Asciio::Actions::Multiwirl ;
use App::Asciio::Actions::Presentation ;
use App::Asciio::Actions::Ruler ;
use App::Asciio::Actions::Selection ;
use App::Asciio::Actions::Shapes ;
use App::Asciio::Actions::Unsorted ;
use App::Asciio::Actions::ZBuffer ;

use App::Asciio::Utils::Scripting ;

#----------------------------------------------------------------------------------------------

register_action_handlers
(
'Undo'                               => [['C00-z', '000-u'],                       \&App::Asciio::Actions::Unsorted::undo                                              ],
'Redo'                               => [['C00-y', 'C00-r'],                       \&App::Asciio::Actions::Unsorted::redo                                              ],
'Zoom in'                            => [['000-plus', 'C00-j', 'C00-scroll-up'],   \&App::Asciio::Actions::Unsorted::zoom, 1                                           ],
'Zoom out'                           => [['000-minus', 'C00-h', 'C00-scroll-down'],\&App::Asciio::Actions::Unsorted::zoom, -1                                          ],

'Select next element'                => ['000-Tab',                                \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [1, 0, 0]   ],
'Select previous element'            => ['00S-ISO_Left_Tab',                       \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [0, 0, 0]   ],
'Select next non arrow'              => ['000-n',                                  \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [1, 0, 1]   ],
'Select previous non arrow'          => ['00S-N',                                  \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [0, 0, 1]   ],
'Select next arrow'                  => ['000-m',                                  \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [1, 0, 2]   ],
'Select previous arrow'              => ['00S-M',                                  \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [0, 0, 2]   ],

'Select all elements'                => [['C00-a', '00S-V'],                       \&App::Asciio::Actions::ElementsManipulation::select_all_elements                   ],
'Deselect all elements'              => ['000-Escape',                             \&App::Asciio::Actions::ElementsManipulation::deselect_all_elements                 ],
'Select connected elements'          => ['000-v',                                  \&App::Asciio::Actions::ElementsManipulation::select_connected                      ],
'Select elements by word'            => ['C00-f',                                  \&App::Asciio::Actions::ElementsManipulation::select_all_elements_by_words          ],
'Select elements by word no group'   => ['C0S-F',                                  \&App::Asciio::Actions::ElementsManipulation::select_all_elements_by_words_no_group ],

'Delete selected elements'           => [['000-Delete', '000-d'],                  \&App::Asciio::Actions::ElementsManipulation::delete_selected_elements              ],

'Edit selected element'              => [['000-2button-press-1','000-Return'],     \&App::Asciio::Actions::ElementsManipulation::edit_selected_element, 0              ],
'Edit selected element inline'       => [['C00-2button-press-1','0A0-Return'],     \&App::Asciio::Actions::ElementsManipulation::edit_selected_element, 1              ],

'Move selected elements left'        => ['000-Left',                               \&App::Asciio::Actions::ElementsManipulation::move_selection_left                   ],
'Move selected elements right'       => ['000-Right',                              \&App::Asciio::Actions::ElementsManipulation::move_selection_right                  ],
'Move selected elements up'          => ['000-Up',                                 \&App::Asciio::Actions::ElementsManipulation::move_selection_up                     ],
'Move selected elements down'        => ['000-Down',                               \&App::Asciio::Actions::ElementsManipulation::move_selection_down                   ],

'Move selected elements left quick'  => ['0A0-Left',                               \&App::Asciio::Actions::ElementsManipulation::move_selection_left, 10               ],
'Move selected elements right quick' => ['0A0-Right',                              \&App::Asciio::Actions::ElementsManipulation::move_selection_right, 10              ],
'Move selected elements up quick'    => ['0A0-Up',                                 \&App::Asciio::Actions::ElementsManipulation::move_selection_up, 10                 ],
'Move selected elements down quick'  => ['0A0-Down',                               \&App::Asciio::Actions::ElementsManipulation::move_selection_down, 10               ],

'Move selected elements left 2'      => ['000-h',                                  \&App::Asciio::Actions::ElementsManipulation::move_selection_left                   ],
'Move selected elements right 2'     => ['000-l',                                  \&App::Asciio::Actions::ElementsManipulation::move_selection_right                  ],
'Move selected elements up 2'        => ['000-k',                                  \&App::Asciio::Actions::ElementsManipulation::move_selection_up                     ],
'Move selected elements down 2'      => ['000-j',                                  \&App::Asciio::Actions::ElementsManipulation::move_selection_down                   ],

'Make element narrower'              => ['000-1',                                  \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [-1, 0]        ],
'Make element taller'                => ['000-2',                                  \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [0,  1]        ],
'Make element shorter'               => ['000-3',                                  \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [0, -1]        ],
'Make element wider'                 => ['000-4',                                  \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [1,  0]        ],

# mouse
'Mouse right-click'                  => ['000-button-press-3',                     \&App::Asciio::Actions::Mouse::mouse_right_click                                    ],

'Mouse left-click'                   => ['000-button-press-1',                     \&App::Asciio::Actions::Mouse::mouse_left_click                                     ],
'Start Drag and Drop'                => ['C00-button-press-1',                     sub { $_[0]->{ IN_DRAG_DROP} = 1 ; }                                                ],

'Mouse left-release'                 => ['000-button-release-1',                   \&App::Asciio::Actions::Mouse::mouse_left_release                                   ],
'Mouse left-release2'                => ['C00-button-release-1',                   \&App::Asciio::Actions::Mouse::mouse_left_release                                   ],
'Mouse left-release3'                => ['00S-button-release-1',                   \&App::Asciio::Actions::Mouse::mouse_left_release                                   ],
'Mouse left-release4'                => ['C0S-button-release-1',                   \&App::Asciio::Actions::Mouse::mouse_left_release                                   ],

'Mouse selection flip'               => ['00S-button-press-1',                     \&App::Asciio::Actions::Mouse::mouse_element_selection_flip                         ],

'Mouse quick link orthogonal'        => [['0AS-button-press-1'],                   \&App::Asciio::Actions::Mouse::quick_link, 1                                        ],
'Mouse quick link'                   => [['0A0-button-press-1', '000-period'],     \&App::Asciio::Actions::Mouse::quick_link                                           ],
'Mouse duplicate elements'           => [[                      '000-comma'],      \&App::Asciio::Actions::Mouse::mouse_duplicate_element                              ],
'Mouse quick box'                    => [['C0S-button-press-1'],                   \&App::Asciio::Actions::Elements::add_element, ['Asciio/box', 0]                    ],

'Arrow to mouse'                     => ['CA0-motion_notify',                      \&App::Asciio::Actions::Arrow::interactive_to_mouse                                 ], 
'Arrow mouse change direction'       => ['CA0-2button-press-1',                    \&App::Asciio::Actions::Arrow::change_arrow_direction                               ],      
'Arrow change direction'             => ['CA0-d',                                  \&App::Asciio::Actions::Arrow::interactive_change_arrow_direction                   ],      
'Wirl arrow add section'             => ['CA0-button-press-1',                     \&App::Asciio::Actions::Multiwirl::interactive_add_section                          ],
'Wirl arrow insert flex point'       => ['CA0-button-press-2',                     \&App::Asciio::Actions::Multiwirl::insert_wirl_arrow_section                        ],

'Mouse motion'                       => ['000-motion_notify',                      \&App::Asciio::Actions::Mouse::mouse_motion                                         ], 
'Mouse motion 2'                     => ['0AS-motion_notify',                      \&App::Asciio::Actions::Mouse::mouse_motion                                         ],

# mouse emulation
'Mouse emulation toggle'             => [['000-apostrophe', "'"],                  \&App::Asciio::Actions::Mouse::toggle_mouse                                         ],

'Mouse emulation left-click'         => ['000-odiaeresis',                         \&App::Asciio::Actions::Mouse::mouse_left_click                                     ],
'Mouse emulation expand selection'   => ['00S-Odiaeresis',                         \&App::Asciio::Actions::Mouse::expand_selection                                     ],
'Mouse emulation selection flip'     => ['C00-odiaeresis',                         \&App::Asciio::Actions::Mouse::mouse_element_selection_flip                         ],

'Mouse emulation right-click'        => ['000-adiaeresis',                         \&App::Asciio::Actions::Mouse::mouse_right_click                                    ],

'Mouse emulation move left'          => ['C00-Left',                               \&App::Asciio::Actions::Mouse::mouse_move, [-1,  0]                                 ],
'Mouse emulation move right'         => ['C00-Right',                              \&App::Asciio::Actions::Mouse::mouse_move, [ 1,  0]                                 ],
'Mouse emulation move up'            => ['C00-Up',                                 \&App::Asciio::Actions::Mouse::mouse_move, [ 0, -1]                                 ],
'Mouse emulation move down'          => ['C00-Down',                               \&App::Asciio::Actions::Mouse::mouse_move, [ 0,  1]                                 ],

'Mouse emulation drag left'          => ['00S-Left',                               \&App::Asciio::Actions::Mouse::mouse_drag_left                                      ],
'Mouse emulation drag right'         => ['00S-Right',                              \&App::Asciio::Actions::Mouse::mouse_drag_right                                     ],
'Mouse emulation drag up'            => ['00S-Up',                                 \&App::Asciio::Actions::Mouse::mouse_drag_up                                        ],
'Mouse emulation drag down'          => ['00S-Down',                               \&App::Asciio::Actions::Mouse::mouse_drag_down                                      ],

'Mouse on element id'                => ['not set',                                \&App::Asciio::Actions::Mouse::mouse_on_element_id                                  ],

'Copy to clipboard'                  => [['C00-c', 'C00-Insert'],                  \&App::Asciio::Actions::Clipboard::export_elements_to_system_clipboard              ],
'Insert from clipboard'              => [['C00-v', '00S-Insert'],                  \&App::Asciio::Actions::Clipboard::import_elements_from_system_clipboard            ],

'yank ->' =>
	{
	SHORTCUTS   => '000-y',
	
	'Copy to clipboard'                      => ['000-y', \&App::Asciio::Actions::Clipboard::export_elements_to_system_clipboard],
	'Export to clipboard & primary as ascii' => ['00S-Y', \&App::Asciio::Actions::Clipboard::export_to_clipboard_as_ascii       ],
	'Export to clipboard & primary as markup'=> ['000-m', \&App::Asciio::Actions::Clipboard::export_to_clipboard_as_markup      ],
	},

'paste ->' =>
	{
	SHORTCUTS   => '000-p',
	
	'Insert from clipboard'         => ['000-p', \&App::Asciio::Actions::Clipboard::import_elements_from_system_clipboard],
	'Import from primary to box'    => ['00S-P', \&App::Asciio::Actions::Clipboard::import_from_primary_to_box           ],
	'Import from primary to text'   => ['0A0-p', \&App::Asciio::Actions::Clipboard::import_from_primary_to_text          ],
	'Import from clipboard to box'  => ['000-b', \&App::Asciio::Actions::Clipboard::import_from_clipboard_to_box         ],
	'Import from clipboard to text' => ['000-t', \&App::Asciio::Actions::Clipboard::import_from_clipboard_to_text        ],
	},

'grouping ->' => 
	{
	SHORTCUTS   => '000-g',
	
	'Group selected elements'             => ['000-g', \&App::Asciio::Actions::ElementsManipulation::group_selected_elements                 ],
	'Ungroup selected elements'           => ['000-u', \&App::Asciio::Actions::ElementsManipulation::ungroup_selected_elements               ],
	'Move selected elements to the front' => ['000-f', \&App::Asciio::Actions::ElementsManipulation::move_selected_elements_to_front         ],
	'Move selected elements to the back'  => ['000-b', \&App::Asciio::Actions::ElementsManipulation::move_selected_elements_to_back          ],
	'Temporary move to the front'         => ['00S-F', \&App::Asciio::Actions::ElementsManipulation::temporary_move_selected_element_to_front],
	},

'stripes ->' => 
	{
	SHORTCUTS   => '0A0-g',
	
	'create stripes group'                => ['000-g', \&App::Asciio::Actions::ElementsManipulation::create_stripes_group, 0],
	'create one stripe group'             => ['000-1', \&App::Asciio::Actions::ElementsManipulation::create_stripes_group, 1],
	'ungroup stripes group'               => ['000-u', \&App::Asciio::Actions::ElementsManipulation::ungroup_stripes_group  ],
	},

'align ->' => 
	{
	SHORTCUTS   => '00S-A',
	
	'Align top'                           => ['000-t', \&App::Asciio::Actions::Align::align, 'top'       ],
	'Align left'                          => ['000-l', \&App::Asciio::Actions::Align::align, 'left'      ],
	'Align bottom'                        => ['000-b', \&App::Asciio::Actions::Align::align, 'bottom'    ],
	'Align right'                         => ['000-r', \&App::Asciio::Actions::Align::align, 'right'     ],
	'Align vertically'                    => ['000-v', \&App::Asciio::Actions::Align::align, 'vertical'  ],
	'Align horizontally'                  => ['000-h', \&App::Asciio::Actions::Align::align, 'horizontal'],
	},

'display options ->' =>
	{
	SHORTCUTS   => '000-z',
	
	'Change font'                         => ['000-f', \&App::Asciio::Actions::Unsorted::change_font                           ],
	'Change color ->'                  => ['000-c', ACTION_GROUP('color')                                                   ] ,
	
	'Flip binding completion'             => ['000-b', sub { $_[0]->{USE_BINDINGS_COMPLETION} ^= 1 ; $_[0]->update_display() ;}],
	'Flip transparent element background' => ['000-t', \&App::Asciio::Actions::Unsorted::transparent_elements                  ],
	'Flip grid display'                   => ['000-g', \&App::Asciio::Actions::Unsorted::flip_grid_display                     ],
	'Flip rulers display'                 => ['000-r', \&App::Asciio::Actions::Unsorted::flip_rulers_display                   ],
	'Flip hint lines'                     => ['000-h', \&App::Asciio::Actions::Unsorted::flip_hint_lines                       ],
	'Flip edit inline'                    => ['000-i', \&App::Asciio::Actions::Unsorted::toggle_edit_inline                    ], 
	'Flip show/hide connectors'           => ['000-v', \&App::Asciio::Actions::Unsorted::flip_connector_display                ], 
	},

		'group_color' => 
			{
			SHORTCUTS   => 'group_color',
			
			'Flip color scheme'                   => ['000-s', \&App::Asciio::Actions::Colors::flip_color_scheme         ] ,
			
			'Change elements foreground color'    => ['000-f', \&App::Asciio::Actions::Colors::change_elements_colors, 0 ] ,
			'Change elements background color'    => ['000-b', \&App::Asciio::Actions::Colors::change_elements_colors, 1 ] ,
			
			'Change Asciio background color'      => ['00S-B', \&App::Asciio::Actions::Colors::change_background_color   ] ,
			'Change grid color'                   => ['000-g', \&App::Asciio::Actions::Colors::change_grid_color         ] ,
			},

'arrow ->' => 
	{
	SHORTCUTS   => '000-a',
	
	'connectors ->'                    => ['000-c', ACTION_GROUP('connectors')                                                     ] ,

	'Change arrow direction'              => ['000-d', \&App::Asciio::Actions::Arrow::change_arrow_direction                          ],
	'Flip arrow start and end'            => ['000-f', \&App::Asciio::Actions::Arrow::flip_arrow_ends                                 ],
	'Append multi_wirl section'           => ['000-s', \&App::Asciio::Actions::Multiwirl::append_section,                             ],
	'Insert multi_wirl section'           => ['00S-S', \&App::Asciio::Actions::Multiwirl::insert_wirl_arrow_section                   ],
	'Prepend multi_wirl section'          => ['C00-s', \&App::Asciio::Actions::Multiwirl::prepend_section                             ],
	'Remove last section from multi_wirl' => ['CA0-s', \&App::Asciio::Actions::Multiwirl::remove_last_section_from_section_wirl_arrow ],

	'Flip drag selects arrows'            => ['0A0-s', \&App::Asciio::Actions::Arrow::drag_selects_arrows                             ],
	# insert_section
	# remove_last_section
	# remove_first_section
	# change_section_direction
	# change_last_section_direction
	},

		'group_connectors' =>
			{
			SHORTCUTS   => 'group_connectors',
			
			'start enable connection'      => ['000-c', \&App::Asciio::Actions::Arrow::allow_connection, ['start', 1],    ],
			'start disable connection'     => ['00S-C', \&App::Asciio::Actions::Arrow::allow_connection, ['start', 0],    ],
			'end enable connection'        => ['0A0-c', \&App::Asciio::Actions::Arrow::allow_connection, ['end',   1],    ],
			'end disable connection'       => ['0AS-C', \&App::Asciio::Actions::Arrow::allow_connection, ['end',   0],    ],
			
			'enable diagonals'             => ['C00-d', \&App::Asciio::Actions::Arrow::allow_diagonals, 1,                ],
			'disable diagonals'            => ['C0S-D', \&App::Asciio::Actions::Arrow::allow_diagonals, 0,                ],
			
			'Start flip enable connection' => ['CA0-d', \&App::Asciio::Actions::Multiwirl::disable_arrow_connector, 0     ],
			'End flip enable connection'   => ['CAS-D', \&App::Asciio::Actions::Multiwirl::disable_arrow_connector, 1     ],
			
			(
			map { ( "start $_->[0]"        => [ $_->[1], \&App::Asciio::Actions::Multiwirl::change_connector, ['start', $_->[2]] ] ) } 
				(
				['dash', '000-minus',    ['-'] ],
				['dot' , '000-period',   ['.'] ],
				['star', '000-asterisk', ['*'] ],
				['o'   , '000-o',        ['o'] ],
				['O'   , '00S-O',        ['O'] ],
				),
			), 
			(
			map { ( "end $_->[0]"          => [ $_->[1], \&App::Asciio::Actions::Multiwirl::change_connector, ['end', $_->[2]] ] ) } 
				(
				['dynamic dash', '0A0-minus',    ['-', '|', '-', '|'] ],
				
				['dash', '0A0-minus',    ['-'] ],
				['dot' , '0A0-period',   ['.'] ],
				['star', '0A0-asterisk', ['*'] ],
				['o'   , '0A0-o',        ['o'] ],
				['O'   , '0AS-O',        ['O'] ],
				),
			),
			},

'debug ->' => 
	{
	SHORTCUTS   => '00S-D',
	
	'Display undo stack statistics'       => ['000-u', \&App::Asciio::Actions::Unsorted::display_undo_stack_statistics ],
	'Dump self'                           => ['000-s', \&App::Asciio::Actions::Debug::dump_self                        ],
	'Dump all elements'                   => ['000-e', \&App::Asciio::Actions::Debug::dump_all_elements                ],
	'Dump selected elements'              => ['00S-E', \&App::Asciio::Actions::Debug::dump_selected_elements           ],
	'Display numbered objects'            => ['000-t', sub { $_[0]->{NUMBERED_OBJECTS} ^= 1 ; $_[0]->update_display() }],
	'Test'                                => ['000-o', \&App::Asciio::Actions::Debug::test                             ],
	'ZBuffer Test'                        => ['000-z', \&App::Asciio::Actions::ZBuffer::dump_crossings                 ],
	},

'commands ->'=> 
	{
	SHORTCUTS   => '00S-colon',
	
	'Help'                                => ['000-h', \&App::Asciio::Actions::Unsorted::display_help                       ],
	'Add help box'                        => ['00S-H', \&App::Asciio::Actions::Elements::add_help_box,                      ],
	
	'Display keyboard mapping'            => ['000-k', \&App::Asciio::Actions::Unsorted::display_keyboard_mapping_in_browser],
	'Display commands'                    => ['000-c', \&App::Asciio::Actions::Unsorted::display_commands                   ],
	'Display action files'                => ['000-f', \&App::Asciio::Actions::Unsorted::display_action_files               ],
	'Display manpage'                     => ['000-m', \&App::Asciio::Actions::Unsorted::manpage_in_browser                 ],
	
	'Run external script'                 => ['00S-exclam', \&App::Asciio::Utils::Scripting::run_external_script            ],
	
	'Open'                                => ['000-e', \&App::Asciio::Actions::File::open                                   ],
	'Save'                                => ['000-w', \&App::Asciio::Actions::File::save, undef                            ],
	'SaveAs'                              => ['00S-W', \&App::Asciio::Actions::File::save, 'as'                             ],
	'Insert'                              => ['000-r', \&App::Asciio::Actions::File::insert                                 ],
	'Quit'                                => ['000-q', \&App::Asciio::Actions::File::quit                                   ],
	'Quit no save'                        => ['00S-Q', \&App::Asciio::Actions::File::quit_no_save                           ],
	},

'Insert ->' => 
	{
	SHORTCUTS   => '000-i',
	
	'Add connector'                       => ['000-c', \&App::Asciio::Actions::Elements::add_element, ['Asciio/connector', 0]                ],
	'Add text'                            => ['000-t', \&App::Asciio::Actions::Elements::add_element, ['Asciio/text', 1]                     ],
	'Add arrow'                           => ['000-a', \&App::Asciio::Actions::Elements::add_element, ['Asciio/wirl_arrow', 0]               ],
	'Add angled arrow'                    => ['00S-A', \&App::Asciio::Actions::Elements::add_element, ['Asciio/angled arrow', 0]             ],
	
	'Stencil ->'                       => ['000-s', ACTION_GROUP('insert_stencil')                                                        ] ,
	'Multiple ->'                      => ['000-m', ACTION_GROUP('insert_multiple')                                                       ] ,
	'Unicode ->'                       => ['000-u', ACTION_GROUP('insert_unicode')                                                        ] ,
	'Box ->'                           => ['000-b', ACTION_GROUP('insert_box')                                                            ] ,
	'Elements ->'                      => ['000-e', ACTION_GROUP('insert_element')                                                        ] ,
	'Ruler ->'                         => ['000-r', ACTION_GROUP('insert_ruler')                                                          ] ,
	'Line ->'                          => ['000-l', ACTION_GROUP('insert_line')                                                           ] ,
	'Connected ->'                     => ['000-k', ACTION_GROUP('insert_connected')                                                      ] ,
	},

		'group_insert_stencil' => 
			{
			SHORTCUTS   => 'group_insert_stencil',
			
			'From user stencils'                  => ['000-s', \&App::Asciio::Actions::Elements::open_user_stencil                     ], 
			'From default_stencil'                => ['000-d', \&App::Asciio::Actions::Elements::open_stencil, 'default_stencil.asciio'], 
			'From any stencil'                    => ['000-a', \&App::Asciio::Actions::Elements::open_stencil                          ], 
			
			'From user elements'                  => ['000-0', \&App::Asciio::Actions::Elements::open_user_stencil, 'elements.asciio'  ], 
			'From user computer'                  => ['000-1', \&App::Asciio::Actions::Elements::open_user_stencil, 'computer.asciio'  ], 
			'From user people'                    => ['000-2', \&App::Asciio::Actions::Elements::open_user_stencil, 'people.asciio'    ], 
			'From user buildings'                 => ['000-3', \&App::Asciio::Actions::Elements::open_user_stencil, 'buildings.asciio' ], 
			},

		'group_insert_multiple' => 
			{
			SHORTCUTS   => 'group_insert_multiple',
			
			'Add multiple texts'                  => ['000-t', \&App::Asciio::Actions::Elements::add_multiple_elements, 'Asciio/text'  ],
			'Add multiple boxes'                  => ['000-b', \&App::Asciio::Actions::Elements::add_multiple_elements, 'Asciio/box'   ],
			},

		'group_insert_ruler' => 
			{
			SHORTCUTS   => 'group_insert_ruler',
			
			'Add vertical ruler'                  => ['000-v', \&App::Asciio::Actions::Ruler::add_ruler, {TYPE => 'VERTICAL'}          ],
			'Add horizontal ruler'                => ['000-h', \&App::Asciio::Actions::Ruler::add_ruler, {TYPE => 'HORIZONTAL'}        ],
			'delete rulers'                       => ['000-d', \&App::Asciio::Actions::Ruler::remove_ruler                             ],
			},

		'group_insert_line' => 
			{
			SHORTCUTS   => 'group_insert_line',

			'Add ascii line'                      => ['000-l', \&App::Asciio::Actions::Elements::add_line, 0                           ], 
			'Add ascii no-connect line'           => ['000-k', \&App::Asciio::Actions::Elements::add_non_connecting_line, 0            ], 
			},

		'group_insert_connected' => 
			{
			SHORTCUTS   => 'group_insert_connected',

			'Add connected box edit'              => ['000-b', \&App::Asciio::Actions::Elements::add_element_connected, ['Asciio/box', 1]            ], 
			'Add multiple connected box edit'     => ['00S-B', \&App::Asciio::Actions::Elements::add_multiple_element_connected, ['Asciio/box', 1]   ], 
			'Add connected text edit'             => ['000-t', \&App::Asciio::Actions::Elements::add_element_connected, ['Asciio/text', 1]           ], 
			'Add multiple connected text edit'    => ['00S-T', \&App::Asciio::Actions::Elements::add_multiple_element_connected, ['Asciio/text', 1] ], 
			},

		'group_insert_element' => 
			{
			SHORTCUTS   => 'group_insert_element',
			
			'Add connector type 2'                => ['000-c', \&App::Asciio::Actions::Elements::add_element, ['Asciio/connector2', 0]               ],
			'Add connector use top character'     => ['00S-C', \&App::Asciio::Actions::Elements::add_center_connector_use_top_character              ],
			'Add if'                              => ['000-i', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/if', 1]                 ],
			'Add process'                         => ['000-p', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/process', 1]            ],
			'Add rhombus'                         => ['0A0-r', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Shape/rhombus', 0]            ],
			'Add ellipse'                         => ['000-e', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Shape/ellipse', 0]            ],
			},

		'group_insert_box' => 
			{
			SHORTCUTS   => 'group_insert_box',
			
			'Add box'                             => ['000-b', \&App::Asciio::Actions::Elements::add_element, ['Asciio/box', 0]                      ],
			'Add shrink box'                      => ['000-s', \&App::Asciio::Actions::Elements::add_element, ['Asciio/shrink_box', 1]               ],
			
			'Add exec box'                        => ['C00-e', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/exec', 1]               ],
			'Add exec box verbatim'               => ['C00-v', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/exec verbatim', 1]      ],
			'Add exec box verbatim once'          => ['C00-o', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/exec verbatim once', 1] ],
			'Add line numbered box'               => ['C00-l', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/exec add lines', 1]     ],
			},

		'group_insert_unicode' => 
			{
			SHORTCUTS   => 'group_insert_unicode',
			
			'Add unicode box'                     => ['000-b', \&App::Asciio::Actions::Elements::add_element, ['Asciio/box unicode', 0]              ],
			'Add unicode arrow'                   => ['000-a', \&App::Asciio::Actions::Elements::add_element, ['Asciio/wirl_arrow unicode', 0]       ],
			'Add unicode angled arrow'            => ['00S-A', \&App::Asciio::Actions::Elements::add_element, ['Asciio/angled arrow unicode', 0]     ],
			'Add unicode line'                    => ['000-l', \&App::Asciio::Actions::Elements::add_line, 1                                         ],
			
			'Add unicode bold line'               => ['00S-L', \&App::Asciio::Actions::Elements::add_line, 2                                         ],
			'Add unicode double line'             => ['0A0-l', \&App::Asciio::Actions::Elements::add_line, 3                                         ],
			
			'Add unicode no-connect line'         => ['000-k', \&App::Asciio::Actions::Elements::add_non_connecting_line, 1                          ],
			'Add unicode no-connect bold line'    => ['00S-K', \&App::Asciio::Actions::Elements::add_non_connecting_line, 2                          ],
			'Add unicode no-connect double line'  => ['0A0-K', \&App::Asciio::Actions::Elements::add_non_connecting_line, 3                          ],
			},

'element ->' => 
	{
	SHORTCUTS   => '000-e',
	
	'Shrink box'                => ['000-s',  \&App::Asciio::Actions::ElementsManipulation::shrink_box                    ],
	'Make elements Unicode'     => ['C00-u',  \&App::Asciio::Actions::ElementAttributes::make_selection_unicode, 1        ],
	'Make elements not Unicode' => ['C0S-U',  \&App::Asciio::Actions::ElementAttributes::make_selection_unicode, 0        ],
	
	'copy element attributes'   => ['000-c',  \&App::Asciio::Actions::ElementAttributes::copy_attributes                  ],
	'paste element attributes'  => ['000-p',  \&App::Asciio::Actions::ElementAttributes::paste_attributes                 ],
	
	'convert to a big text'     => ['00S-T',  \&App::Asciio::Actions::Elements::convert_selected_elements_to_text_element ], 
	'convert to dots'           => ['00S-D',  \&App::Asciio::Actions::Elements::convert_selected_elements_to_dot_elements ], 
	
	'enable elements cross'     => ['000-x',  \&App::Asciio::Actions::ElementsManipulation::set_elements_crossover, 1     ], 
	'disable elements cross'    => ['00S-X',  \&App::Asciio::Actions::ElementsManipulation::set_elements_crossover, 0     ], 
	
	'Box ->'                 => ['000-b', ACTION_GROUP('box_type_change')                                              ] ,
	'Wirl Arrow ->'          => ['000-w', ACTION_GROUP('wirl_arrow_type_change')                                       ] ,
	'Angled Arrow ->'        => ['000-a', ACTION_GROUP('angled_arrow_type_change')                                     ] ,
	'Ellipse ->'             => ['000-e', ACTION_GROUP('ellipse_type_change')                                          ] ,
	'Rhombus ->'             => ['000-r', ACTION_GROUP('rhombus_type_change')                                          ] ,
	'Triangle Up ->'         => ['000-u', ACTION_GROUP('triangle_up_type_change')                                      ] ,
	'Triangle Down->'        => ['000-d', ACTION_GROUP('triangle_down_type_change')                                    ] ,
	},

		'group_box_type_change' => 
			{
			SHORTCUTS   => 'group_box_type_change',
			
			map { ( "box $_->[0]" => [ $_->[1], \&App::Asciio::Actions::ElementAttributes::change_attributes, ['editable_box2', $_->[0]] ] ) } 
				(
				['dash'                       , '000-d' ],
				['dot'                        , '00S-D' ],
				['star'                       , '000-s' ],
				['math_parantheses'           , '000-m' ],
				['unicode'                    , '000-u' ],
				['unicode_imaginary'          , '000-i' ],
				['unicode_bold'               , '00S-U' ],
				['unicode_bold_imaginary'     , '00S-I' ],
				['unicode_double'             , '000-l' ],
				['unicode_with_filler_type1'  , '000-1' ],
				['unicode_with_filler_type2'  , '000-2' ],
				['unicode_with_filler_type3'  , '000-3' ],
				['unicode_with_filler_type4'  , '000-4' ],
				['unicode_hollow_dot'         , '000-h' ],
				['unicode_math_paranthesesar' , '00S-M' ]
				),
			},
		
		'group_ellipse_type_change' => 
			{
			SHORTCUTS   => 'group_ellipse_type_change',
			
			map { ( "ellipse $_->[0]" => [ $_->[1], \&App::Asciio::Actions::ElementAttributes::change_attributes, ['ellipse', $_->[0]] ] ) } 
				(
				['ellipse_normal'                       , '000-n' ],
				['ellipse_normal_with_filler_star'      , '000-s' ],
				),
			},

		'group_rhombus_type_change' => 
			{
			SHORTCUTS   => 'group_rhombus_type_change',
			
			map { ( "rhombus $_->[0]" => [ $_->[1], \&App::Asciio::Actions::ElementAttributes::change_attributes, ['rhombus', $_->[0]] ] ) } 
				(
				['rhombus_normal'                       , '000-n' ],
				['rhombus_normal_with_filler_star'      , '000-s' ],
				['rhombus_sparseness'                   , '00S-S' ],
				['rhombus_unicode_slash'                , '000-u' ],
				)
			},

		'group_triangle_up_type_change' => 
			{
			SHORTCUTS   => 'group_triangle_up_type_change',
			
			map { ( "triangle $_->[0]" => [ $_->[1], \&App::Asciio::Actions::ElementAttributes::change_attributes, ['triangle_up', $_->[0]] ] ) } 
				(
				['triangle_up_normal'                    , '000-n' ],
				['triangle_up_dot'                       , '000-s' ],
				),
			},

		'group_triangle_down_type_change' => 
			{
			SHORTCUTS   => 'group_triangle_down_type_change',
			
			map { ( "triangle $_->[0]" => [ $_->[1], \&App::Asciio::Actions::ElementAttributes::change_attributes, ['triangle_down', $_->[0]] ] ) } 
				(
				['triangle_down_normal'                    , '000-n' ],
				['triangle_down_dot'                       , '000-s' ],
				),
			},

		'group_wirl_arrow_type_change' => 
			{
			SHORTCUTS   => 'group_wirl_arrow_type_change',
			
			map { ( "wirl arrow $_->[0]" => [ $_->[1], \&App::Asciio::Actions::ElementAttributes::change_attributes, ['section_wirl_arrow', $_->[0]] ] ) } 
				(
				['dash'                   , '000-d'] ,
				['dash_line'              , '00S-D'] ,
				['dot'                    , 'C00-d'] ,
				['dot_no_arrow'           , '0A0-d'] ,
				['star'                   , '000-s'] ,
				['octo'                   , '000-o'] ,
				['unicode'                , '000-1'] ,
				['unicode_line'           , '000-u'] ,
				['unicode_bold'           , '000-2'] ,
				['unicode_bold_line'      , '000-b'] ,
				['unicode_double'         , '000-3'] ,
				['unicode_double_line'    , '00S-B'] ,
				['unicode_imaginary'      , '000-4'] ,
				['unicode_imaginary_line' , '000-i'] ,
				['unicode_hollow_dot'     , '000-h'] ,
				),
			},

		'group_angled_arrow_type_change' => 
			{
			SHORTCUTS   => 'group_angled_arrow_type_change',
			
			map { ( "angled arrow $_->[0]" => [ $_->[1], \&App::Asciio::Actions::ElementAttributes::change_attributes, ['angled_arrow', $_->[0]] ] ) } 
				(
				['angled_arrow_dash'    , '000-d'] ,
				['angled_arrow_unicode' , '000-u'] ,
				),
			},

'selection ->' =>
	{
	SHORTCUTS   => '000-s',
	ENTER_GROUP => \&App::Asciio::Actions::Selection::selection_enter,
	ESCAPE_KEYS => [ '000-s', '000-Escape' ],
	
	'Selection escape'               => [ '000-s',             \&App::Asciio::Actions::Selection::selection_escape                      ],
	'Selection escape2'              => [ '000-Escape',        \&App::Asciio::Actions::Selection::selection_escape                      ],
	
	'select flip mode'               => [ '000-e',             \&App::Asciio::Actions::Selection::selection_mode_flip                   ],
	'select motion'                  => [ '000-motion_notify', \&App::Asciio::Actions::Selection::select_motion                         ],
	'select mouse click'             => [ '000-button-press-1',\&App::Asciio::Actions::Selection::select_elements                       ],
	'polygon selection ->'        => [ '000-x',             ACTION_GROUP('polygon')                                                  ] ,
	},

'group_polygon' =>
	{
	SHORTCUTS => 'group_polygon',
	ENTER_GROUP => \&App::Asciio::GTK::Asciio::polygon_selection_enter,
	ESCAPE_KEYS => [ '000-x', '000-Escape' ],
	
	'Polygon selection escape'               => [ '000-x',               \&App::Asciio::GTK::Asciio::polygon_selection_escape           ],
	'Polygon selection escape2'              => [ '000-Escape',          \&App::Asciio::GTK::Asciio::polygon_selection_escape           ],
	'Polygon select motion'                  => [ '000-motion_notify',   \&App::Asciio::GTK::Asciio::polygon_selection_motion, 1        ],
	'Polygon deselect motion'                => [ 'C00-motion_notify',   \&App::Asciio::GTK::Asciio::polygon_selection_motion, 0        ],
	'Polygon select left-release'            => [ '000-button-release-1',\&App::Asciio::GTK::Asciio::polygon_selection_button_release   ],
	'Polygon select left-release 2'          => [ 'C00-button-release-1',\&App::Asciio::GTK::Asciio::polygon_selection_button_release   ],
	},

'eraser ->' =>
	{
	SHORTCUTS   => '00S-E',
	ENTER_GROUP => \&App::Asciio::Actions::Eraser::eraser_enter,
	ESCAPE_KEYS => '000-Escape',
	
	'Eraser escape'                  => [ '000-Escape',        \&App::Asciio::Actions::Eraser::eraser_escape                            ],
	'Eraser motion'                  => [ '000-motion_notify', \&App::Asciio::Actions::Eraser::erase_elements                           ],
	},

'clone ->' =>
	{
	SHORTCUTS   => '000-c',
	ENTER_GROUP => \&App::Asciio::Actions::Clone::clone_enter,
	ESCAPE_KEYS => '000-Escape',
	
	'clone escape'                   => [ '000-Escape',          \&App::Asciio::Actions::Clone::clone_escape                                  ],
	'clone motion'                   => [ '000-motion_notify',   \&App::Asciio::Actions::Clone::clone_mouse_motion                            ], 
	
	'clone insert'                   => [ '000-button-press-1',  \&App::Asciio::Actions::Clone::clone_add_element                             ],
	'clone insert2'                  => [ '000-Return',          \&App::Asciio::Actions::Clone::clone_add_element                             ],
	'clone arrow'                    => [ '000-a',               \&App::Asciio::Actions::Clone::clone_set_overlay, ['Asciio/wirl_arrow', 0]   ],
	'clone angled arrow'             => [ '00S-A',               \&App::Asciio::Actions::Clone::clone_set_overlay, ['Asciio/angled_arrow', 0] ],
	'clone box'                      => [ '000-b',               \&App::Asciio::Actions::Clone::clone_set_overlay, ['Asciio/box', 0]          ],
	'clone text'                     => [ '000-t',               \&App::Asciio::Actions::Clone::clone_set_overlay, ['Asciio/text', 0]         ],
	'clone flip hint lines'          => [ '000-h',               \&App::Asciio::Actions::Unsorted::flip_hint_lines                            ],
	'clone left'                     => ['000-Left',             \&App::Asciio::Actions::ElementsManipulation::move_selection_left            ],
	'clone right'                    => ['000-Right',            \&App::Asciio::Actions::ElementsManipulation::move_selection_right           ],
	'clone up'                       => ['000-Up',               \&App::Asciio::Actions::ElementsManipulation::move_selection_up              ],
	'clone down'                     => ['000-Down',             \&App::Asciio::Actions::ElementsManipulation::move_selection_down            ],
	
	'clone emulation left'           => ['C00-Left',             \&App::Asciio::Actions::Mouse::mouse_move, [-1,  0]                          ],
	'clone emulation right'          => ['C00-Right',            \&App::Asciio::Actions::Mouse::mouse_move, [ 1,  0]                          ],
	'clone emulation up'             => ['C00-Up',               \&App::Asciio::Actions::Mouse::mouse_move, [ 0, -1]                          ],
	'clone emulation down'           => ['C00-Down',             \&App::Asciio::Actions::Mouse::mouse_move, [ 0,  1]                          ],
	},

'git ->' =>
	{
	SHORTCUTS   => '00S-G',
	ESCAPE_KEYS => '000-Escape',
	
	'Show git bindings'              => ['00S-question',                        sub { $_[0]->show_binding_completions(1) ; }                           ],
	
	'Quick git'                      => [['000-button-press-3', '000-c'],       \&App::Asciio::Actions::Git::quick_link                                ],
	
	'Git add box'                    => [ '000-b',                              \&App::Asciio::Actions::Elements::add_element, ['Asciio/box',  1]      ],
	'Git add text'                   => [ '000-t',                              \&App::Asciio::Actions::Elements::add_element, ['Asciio/text', 1]      ],
	'Git add arrow'                  => [ '000-a',                              \&App::Asciio::Actions::Elements::add_element, ['Asciio/wirl_arrow', 0]],
	'Git edit selected element'      => [['000-2button-press-1', '000-Return'], \&App::Asciio::Actions::Git::edit_selected_element                     ],
	
	'Git mouse left-click'           => [ '000-button-press-1',                 \&App::Asciio::Actions::Mouse::mouse_left_click                        ],
	'Git change arrow direction'     => [ '000-d',                              \&App::Asciio::Actions::Arrow::change_arrow_direction                  ],
	'Git undo'                       => [ '000-u',                              \&App::Asciio::Actions::Unsorted::undo                                 ],
	'Git delete elements'            => [['000-Delete', '000-x'],               \&App::Asciio::Actions::ElementsManipulation::delete_selected_elements ],
	
	'Git mouse motion'               => [ '000-motion_notify',                  \&App::Asciio::Actions::Mouse::mouse_motion                            ], 
	'Git move elements left'         => [ '000-Left',                           \&App::Asciio::Actions::ElementsManipulation::move_selection_left      ],
	'Git move elements right'        => [ '000-Right',                          \&App::Asciio::Actions::ElementsManipulation::move_selection_right     ],
	'Git move elements up'           => [ '000-Up',                             \&App::Asciio::Actions::ElementsManipulation::move_selection_up        ],
	'Git move elements down'         => [ '000-Down',                           \&App::Asciio::Actions::ElementsManipulation::move_selection_down      ],
	
	'Git mouse right-click'          => [ '0A0-button-press-3',                 \&App::Asciio::Actions::Mouse::mouse_right_click                       ],
	'Git flip hint lines'            => [ '000-h',                              \&App::Asciio::Actions::Unsorted::flip_hint_lines                      ],
	},

'slides ->' => 
	{
	SHORTCUTS   => '00S-S',
	ESCAPE_KEYS => '000-Escape',
	
	'Load slides'                    => ['000-l', \&App::Asciio::Actions::Presentation::load_slides          ] ,
	'previous slide'                 => ['00S-N', \&App::Asciio::Actions::Presentation::previous_slide       ],
	'next slide'                     => ['000-n', \&App::Asciio::Actions::Presentation::next_slide           ],
	'first slide'                    => ['000-g', \&App::Asciio::Actions::Presentation::first_slide          ],
	'show previous message'          => ['000-m', \&App::Asciio::Actions::Presentation::show_previous_message],
	'show next message'              => ['00S-M', \&App::Asciio::Actions::Presentation::show_next_message    ],
	'run script ->'               => ['000-s', ACTION_GROUP('slides_script')   ] ,
	},

		'group_slides_script' => 
			{
			SHORTCUTS   => 'group_slides_script',
			ESCAPE_KEYS => '000-Escape',
			
			map { my $name =  "slides script $_" ; $name => ["000-$_", \&App::Asciio::Actions::Presentation::run_script, [$_] ] } ('a'..'z', '0'..'9'),
			},

'move arrow ends ->' =>
	{
	SHORTCUTS   => '0A0-a',
	ESCAPE_KEYS => '000-Escape',
	
	'arrow start up'                 => [ '000-Up',    \&App::Asciio::Actions::Arrow::move_arrow_start, [ 0, -1] ],
	'arrow start down'               => [ '000-Down',  \&App::Asciio::Actions::Arrow::move_arrow_start, [ 0,  1] ],
	'arrow start right'              => [ '000-Right', \&App::Asciio::Actions::Arrow::move_arrow_start, [ 1,  0] ],
	'arrow start left'               => [ '000-Left',  \&App::Asciio::Actions::Arrow::move_arrow_start, [-1,  0] ],
	'arrow start up2'                => [ '000-k',     \&App::Asciio::Actions::Arrow::move_arrow_start, [ 0, -1] ],
	'arrow start down2'              => [ '000-j',     \&App::Asciio::Actions::Arrow::move_arrow_start, [ 0,  1] ],
	'arrow start right2'             => [ '000-l',     \&App::Asciio::Actions::Arrow::move_arrow_start, [ 1,  0] ],
	'arrow start left2'              => [ '000-h',     \&App::Asciio::Actions::Arrow::move_arrow_start, [-1,  0] ],
	'arrow end up'                   => [ '00S-Up',    \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 0, -1] ],
	'arrow end down'                 => [ '00S-Down',  \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 0,  1] ],
	'arrow end right'                => [ '00S-Right', \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 1,  0] ],
	'arrow end left'                 => [ '00S-Left',  \&App::Asciio::Actions::Arrow::move_arrow_end,   [-1,  0] ],
	'arrow end up2'                  => [ '00S-K',     \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 0, -1] ],
	'arrow end down2'                => [ '00S-J',     \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 0,  1] ],
	'arrow end right2'               => [ '00S-L',     \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 1,  0] ],
	'arrow end left2'                => [ '00S-H',     \&App::Asciio::Actions::Arrow::move_arrow_end,   [-1,  0] ],
	},

'pen ->' =>
	{
	SHORTCUTS   => '000-b',
	ENTER_GROUP => \&App::Asciio::GTK::Asciio::Pen::pen_mouse_emulation_enter,
	ESCAPE_KEYS => '000-Escape',
	
	'pen escape'                      => [ '000-Escape',          \&App::Asciio::GTK::Asciio::Pen::pen_mouse_emulation_escape                                    ],
	'pen motion'                      => [ '000-motion_notify',   \&App::Asciio::GTK::Asciio::Pen::pen_mouse_motion, undef, undef, undef, { NO_COMPLETION => 1 } ],
	
	'pen insert or delete'            => [ '000-button-press-1',  \&App::Asciio::GTK::Asciio::Pen::pen_add_or_delete_element, 0                                  ],
	'pen insert2 or delete2'          => [ '000-Return',          \&App::Asciio::GTK::Asciio::Pen::pen_add_or_delete_element, 0                                  ],
	'pen mouse change char'           => [ '000-button-press-3',  \&App::Asciio::GTK::Asciio::Pen::mouse_change_char                                             ],
	'pen eraser switch'               => [ 'C0S-ISO_Left_Tab',    \&App::Asciio::GTK::Asciio::Pen::pen_eraser_switch                                             ],
	
	'pen mouse toggle direction'      => [ 'C00-Tab',              \&App::Asciio::GTK::Asciio::Pen::toggle_mouse_emulation_move_direction                        ],
	'pen mouse move left'             => [['000-Left', 'C00-h'],   \&App::Asciio::GTK::Asciio::Pen::pen_mouse_emulation_move_left                                ],
	'pen mouse move right'            => [['000-Right', 'C00-l'],  \&App::Asciio::GTK::Asciio::Pen::pen_mouse_emulation_move_right                               ],
	'pen mouse move up'               => [['000-Up', 'C00-k'],     \&App::Asciio::GTK::Asciio::Pen::pen_mouse_emulation_move_up                                  ],
	'pen mouse move down'             => [['000-Down', 'C00-j'],   \&App::Asciio::GTK::Asciio::Pen::pen_mouse_emulation_move_down                                ],
	'pen mouse move left quick'       => ['0A0-h',                 \&App::Asciio::GTK::Asciio::Pen::pen_mouse_emulation_move_left_quick                          ],
	'pen mouse move right quick'      => ['0A0-l',                 \&App::Asciio::GTK::Asciio::Pen::pen_mouse_emulation_move_right_quick                         ],
	'pen mouse move up quick'         => ['0A0-k',                 \&App::Asciio::GTK::Asciio::Pen::pen_mouse_emulation_move_up_quick                            ],
	'pen mouse move down quick'       => ['0A0-j',                 \&App::Asciio::GTK::Asciio::Pen::pen_mouse_emulation_move_down_quick                          ],
	'pen mouse move space'            => ['000-space',             \&App::Asciio::GTK::Asciio::Pen::pen_mouse_emulation_move_space                               ],
	'pen mouse move left tab'         => ['00S-ISO_Left_Tab',      \&App::Asciio::GTK::Asciio::Pen::pen_mouse_emulation_move_left_tab                            ],
	'pen mouse move right tab'        => ['000-Tab',               \&App::Asciio::GTK::Asciio::Pen::pen_mouse_emulation_move_right_tab                           ],
	'pen mouse enter'                 => ['00S-Return',            \&App::Asciio::GTK::Asciio::Pen::mouse_emulation_press_enter_key                              ],
	'pen mouse delete dot'            => ['000-Delete',            \&App::Asciio::GTK::Asciio::Pen::pen_delete_element, 1                                        ],
	'pen mouse back delete dot'       => ['000-BackSpace',         \&App::Asciio::GTK::Asciio::Pen::pen_back_delete_element, 1                                   ],
	'pen mouse switch chars next'     => ['C00-Return',            \&App::Asciio::GTK::Asciio::Pen::pen_switch_next_character_sets, 1                            ],
	'pen mouse change help '          => ['C0S-Return',            \&App::Asciio::GTK::Asciio::Pen::pen_switch_show_mapping_help_location,                       ],
	'pen mouse switch chars previous' => ['0A0-Return',            \&App::Asciio::GTK::Asciio::Pen::pen_switch_previous_character_sets, 1                        ],
	
	(map { "pen insert " . $_->[0] => ["00S-" . $_->[0], \&App::Asciio::GTK::Asciio::Pen::pen_enter_then_move_mouse, [$_->[1]], undef, undef, { NO_COMPLETION => 1 }]}(
		['Aring'       , 'Å']  ,
		['Adiaeresis'  , 'Ä']  ,
		['Odiaeresis'  , 'Ö']  ,
		['asterisk'    , '*']  ,
		['parenleft'   , '(']  ,
		['exclam'      , '!']  ,
		['at'          , '@']  ,
		['numbersign'  , '#']  ,
		['dollar'      , '$']  ,
		['percent'     , '%']  ,
		['asciicircum' , '^']  ,
		['ampersand'   , '&']  ,
		['parenright'  , ')']  ,
		['underscore'  , '_']  ,
		['plus'        , '+']  ,
		['braceleft'   , '{']  ,
		['braceright'  , '}']  ,
		['colon'       , ':']  ,
		['quotedbl'    , '"']  ,
		['asciitilde'  , '~']  ,
		['bar'         , '|']  ,
		['question'    , '?']  ,
		['less'        , '<']  ,
		['greater'     , '>']  , )) ,
	(map { "pen insert " . $_->[0] => ["000-" . $_->[0], \&App::Asciio::GTK::Asciio::Pen::pen_enter_then_move_mouse, [$_->[1]], undef, undef, { NO_COMPLETION =>1 }]}(
		['aring'        , 'å']  ,
		['adiaeresis'   , 'ä']  ,
		['odiaeresis'   , 'ö']  ,
		['minus'        , '-']  ,
		['equal'        , '=']  ,
		['bracketleft'  , '[']  ,
		['bracketright' , ']']  ,
		['semicolon'    , ';']  ,
		['apostrophe'   , '\''] ,
		['grave'        , '`']  ,
		['backslash'    , '\\'] ,
		['slash'        , '/']  ,
		['comma'        , ',']  ,
		['period'       , '.']  , )) ,
	(map { "pen insert " . $_ => ["00S-" . $_, \&App::Asciio::GTK::Asciio::Pen::pen_enter_then_move_mouse, [$_], undef, undef, { NO_COMPLETION => 1 }] }('A'..'Z')),
	(map { "pen insert " . $_ => ["000-" . $_, \&App::Asciio::GTK::Asciio::Pen::pen_enter_then_move_mouse, [$_], undef, undef, { NO_COMPLETION => 1 }] }('a'..'z', '0'..'9')),
	},
'find ->' =>
	{
	SHORTCUTS   => '000-f',
	ENTER_GROUP => \&App::Asciio::GTK::Asciio::Find::find_enter,
	ESCAPE_KEYS => ['000-Escape', '000-f'],
	
	'find escape'                  => [ '000-Escape',                            \&App::Asciio::GTK::Asciio::Find::find_escape                  ],
	'find escape2'                 => [ '000-f',                                 \&App::Asciio::GTK::Asciio::Find::find_escape                  ],
	'find next'                    => [ '000-n',                                 \&App::Asciio::GTK::Asciio::Find::find_next                    ],
	'find previous'                => [ '00S-N',                                 \&App::Asciio::GTK::Asciio::Find::find_previous                ],
	'find Zoom in'                 => [['000-plus', 'C0S-J', 'C00-scroll-up'],   \&App::Asciio::GTK::Asciio::Find::find_zoom, 1                 ],
	'find Zoom out'                => [['000-minus', 'C0S-H', 'C00-scroll-down'],\&App::Asciio::GTK::Asciio::Find::find_zoom, -1                ],
	# 'find Mouse drag canvas'       => [ 'C00-motion_notify',                     \&App::Asciio::Actions::Mouse::mouse_drag_canvas               ],
	'find perform new search'      => [ '000-s',                                 \&App::Asciio::GTK::Asciio::Find::find_new_search              ],
	},

'Asciio context_menu'                    => ['as_context_menu', undef, undef,          \&App::Asciio::Actions::Asciio::context_menu                ],
'Box context_menu'                       => ['bo_context_menu', undef, undef,          \&App::Asciio::Actions::Box::context_menu                   ] ,
'Multi_wirl context_menu'                => ['mw_context_menu', undef, undef,          \&App::Asciio::Actions::Multiwirl::multi_wirl_context_menu  ],
'Angled arrow context_menu'              => ['aa_ontext menu',  undef, undef,          \&App::Asciio::Actions::Multiwirl::angled_arrow_context_menu],
'Ruler context_menu'                     => ['ru_context_menu', undef, undef,          \&App::Asciio::Actions::Ruler::context_menu                 ],
'Shapes context_menu'                    => ['sh_context_menu', undef, undef,          \&App::Asciio::Actions::Shapes::context_menu                ],
) ;

register_first_level_group
(
SHORTCUTS => '00S-question',

'Insert ->'          => 1,
'yank ->'            => 1,
'selection ->'       => 1,
'paste ->'           => 1,
'grouping ->'        => 1,
'stripes ->'         => 1,
'align ->'           => 1,
'display options ->'        => 1,
'arrow ->'           => 1,
'debug ->'           => 1,
'commands ->'        => 1,
'Insert ->'          => 1,
'slides ->'          => 1,
'element ->'         => 1,
'clone ->'           => 1,
'git ->'             => 1,
'move arrow ends ->' => 1,
'pen ->'             => 1,

'Select next non arrow'        => 1,
'Select previous non arrow'    => 1,
'Select next arrow'            => 1,
'Select previous arrow'        => 1,
'Select all elements'          => 1,
'Select connected elements'    => 1,

'Edit selected element inline' => 1,

'Mouse quick link'             => 1,
'Mouse quick box'              => 1,

'Arrow to mouse'               => 1,
'Arrow mouse change direction' => 1,
'Arrow change direction'       => 1,
'Wirl arrow add section'       => 1,
'Wirl arrow insert flex point' => 1,
) ;

