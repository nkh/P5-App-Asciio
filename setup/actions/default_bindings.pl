
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

use App::Asciio::Scripting ;

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

# mouse
'Mouse right-click'                  => ['000-button-press-3',                     \&App::Asciio::Actions::Mouse::mouse_right_click                                    ],

'Mouse left-click'                   => ['000-button-press-1',                     \&App::Asciio::Actions::Mouse::mouse_left_click                                     ],
'Start Drag and Drop'                => ['C00-button-press-1',                     sub { $_[0]->{ IN_DRAG_DROP} = 1 ; }                                                ],

'Mouse left-release'                 => ['000-button-release-1',                   \&App::Asciio::Actions::Mouse::mouse_left_release                                   ],
'Mouse left-release2'                => ['C00-button-release-1',                   \&App::Asciio::Actions::Mouse::mouse_left_release                                   ],
'Mouse left-release3'                => ['00S-button-release-1',                   \&App::Asciio::Actions::Mouse::mouse_left_release                                   ],
'Mouse left-release4'                => ['C0S-button-release-1',                   \&App::Asciio::Actions::Mouse::mouse_left_release                                   ],

# 'Mouse expand selection'             => ['',                     \&App::Asciio::Actions::Mouse::expand_selection                                     ],
'Mouse selection flip'               => ['00S-button-press-1',                     \&App::Asciio::Actions::Mouse::mouse_element_selection_flip                         ],

'Mouse quick link'                   => [['0A0-button-press-1', '000-period'],     \&App::Asciio::Actions::Mouse::quick_link                                           ],
'Mouse duplicate elements'           => [['0AS-button-press-1', '000-comma'],      \&App::Asciio::Actions::Mouse::mouse_duplicate_element                              ],
'Mouse quick box'                    => [['C0S-button-press-1'],                   \&App::Asciio::Actions::Elements::add_element, ['Asciio/box', 0]                    ],

'Arrow to mouse'                     => ['CA0-motion_notify',                      \&App::Asciio::Actions::Arrow::interactive_to_mouse                                 ], 
'Arrow mouse change direction'       => ['CA0-2button-press-1',                    \&App::Asciio::Actions::Arrow::change_arrow_direction                               ],      
'Arrow change direction'             => ['CA0-d',                                  \&App::Asciio::Actions::Arrow::interactive_change_arrow_direction                   ],      
'Wirl arrow add section'             => ['CA0-button-press-1',                     \&App::Asciio::Actions::Multiwirl::interactive_add_section                          ],
'Wirl arrow insert flex point'       => ['CA0-button-press-2',                     \&App::Asciio::Actions::Multiwirl::insert_wirl_arrow_section                        ],

'Mouse motion'                       => ['000-motion_notify',                      \&App::Asciio::Actions::Mouse::mouse_motion                                         ], 
'Mouse motion 2'                     => ['0AS-motion_notify',                      \&App::Asciio::Actions::Mouse::mouse_motion                                         ],
#'Mouse drag canvas'                  => ['C00-motion_notify', see drag-and-drop    \&App::Asciio::Actions::Mouse::mouse_drag_canvas                                    ],         

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

'<< yank leader >>' =>
	{
	SHORTCUTS   => '000-y',
	
	'Copy to clipboard'                      => ['000-y', \&App::Asciio::Actions::Clipboard::export_elements_to_system_clipboard],
	'Export to clipboard & primary as ascii' => ['00S-Y', \&App::Asciio::Actions::Clipboard::export_to_clipboard_as_ascii       ],
	'Export to clipboard & primary as markup'=> ['000-m', \&App::Asciio::Actions::Clipboard::export_to_clipboard_as_markup      ],
	},

'<< paste leader >>' =>
	{
	SHORTCUTS   => '000-p',

	'Insert from clipboard'         => ['000-p', \&App::Asciio::Actions::Clipboard::import_elements_from_system_clipboard],
	'Import from primary to box'    => ['00S-P', \&App::Asciio::Actions::Clipboard::import_from_primary_to_box           ],
	'Import from primary to text'   => ['0A0-p', \&App::Asciio::Actions::Clipboard::import_from_primary_to_text          ],
	'Import from clipboard to box'  => ['000-b', \&App::Asciio::Actions::Clipboard::import_from_clipboard_to_box         ],
	'Import from clipboard to text' => ['000-t', \&App::Asciio::Actions::Clipboard::import_from_clipboard_to_text        ],
	},

'<< grouping leader >>' => 
	{
	SHORTCUTS   => '000-g',
	
	'Group selected elements'             => ['000-g', \&App::Asciio::Actions::ElementsManipulation::group_selected_elements                 ],
	'Ungroup selected elements'           => ['000-u', \&App::Asciio::Actions::ElementsManipulation::ungroup_selected_elements               ],
	'Move selected elements to the front' => ['000-f', \&App::Asciio::Actions::ElementsManipulation::move_selected_elements_to_front         ],
	'Move selected elements to the back'  => ['000-b', \&App::Asciio::Actions::ElementsManipulation::move_selected_elements_to_back          ],
	'Temporary move to the front'         => ['00S-F', \&App::Asciio::Actions::ElementsManipulation::temporary_move_selected_element_to_front],
	},

'<< stripes leader >>' => 
	{
	SHORTCUTS   => '0A0-g',
	
	'create stripes group'                => ['000-g', \&App::Asciio::Actions::ElementsManipulation::create_stripes_group, 0],
	'create one stripe group'             => ['000-1', \&App::Asciio::Actions::ElementsManipulation::create_stripes_group, 1],
	'ungroup stripes group'               => ['000-u', \&App::Asciio::Actions::ElementsManipulation::ungroup_stripes_group  ],
	},

'<< align leader >>' => 
	{
	SHORTCUTS   => '00S-A',
	
	'Align top'                           => ['000-t', \&App::Asciio::Actions::Align::align, 'top'       ],
	'Align left'                          => ['000-l', \&App::Asciio::Actions::Align::align, 'left'      ],
	'Align bottom'                        => ['000-b', \&App::Asciio::Actions::Align::align, 'bottom'    ],
	'Align right'                         => ['000-r', \&App::Asciio::Actions::Align::align, 'right'     ],
	'Align vertically'                    => ['000-v', \&App::Asciio::Actions::Align::align, 'vertical'  ],
	'Align horizontally'                  => ['000-h', \&App::Asciio::Actions::Align::align, 'horizontal'],
	},

'<< change color/font leader >>'=> 
	{
	SHORTCUTS   => '000-z',
	
	'Change font'                         => ['000-f', \&App::Asciio::Actions::Unsorted::change_font                           ],
	'<< Change color >>'                  => ['000-c', sub { $_[0]->use_action_group('group_color') ; }                        ] ,
	
	'Flip binding completion'             => ['000-b', sub { $_[0]->{USE_BINDINGS_COMPLETION} ^= 1 ; $_[0]->update_display() ;}],
	'Flip cross mode'                     => ['000-x', sub { $_[0]->{USE_CROSS_MODE} ^= 1 ; $_[0]->update_display ; }          ],
	'Flip color scheme'                   => ['000-s', \&App::Asciio::Actions::Colors::flip_color_scheme                       ],
	'Flip transparent element background' => ['000-t', \&App::Asciio::Actions::Unsorted::transparent_elements                  ],
	'Flip grid display'                   => ['000-g', \&App::Asciio::Actions::Unsorted::flip_grid_display                     ],
	'Flip hint lines'                     => ['000-h', \&App::Asciio::Actions::Unsorted::flip_hint_lines                       ],
	'Flip edit inline'                    => ['000-i', \&App::Asciio::GTK::Asciio::switch_gtk_popup_box_type                   ], 
	'Flip show/hide connectors'           => ['000-v', \&App::Asciio::Actions::Unsorted::flip_connector_display                ], 
	},

'group_color' => 
	{
	SHORTCUTS   => 'group_color',
	
	'Change elements foreground color'    => ['000-f', \&App::Asciio::Actions::Colors::change_elements_colors, 0       ],
	'Change elements background color'    => ['000-b', \&App::Asciio::Actions::Colors::change_elements_colors, 1       ],

	'Change Asciio background color'      => ['000-B', \&App::Asciio::Actions::Colors::change_background_color         ],
	'Change grid color'                   => ['000-g', \&App::Asciio::Actions::Colors::change_grid_color               ],
	},

'<< arrow leader >>' => 
	{
	SHORTCUTS   => '000-a',
	
	'Change arrow direction'              => ['000-d', \&App::Asciio::Actions::Arrow::change_arrow_direction                          ],
	'Flip arrow start and end'            => ['000-f', \&App::Asciio::Actions::Arrow::flip_arrow_ends                                 ],
	'Append multi_wirl section'           => ['000-s', \&App::Asciio::Actions::Multiwirl::append_section,                             ],
	'Insert multi_wirl section'           => ['00S-S', \&App::Asciio::Actions::Multiwirl::insert_wirl_arrow_section                   ],
	'Prepend multi_wirl section'          => ['C00-s', \&App::Asciio::Actions::Multiwirl::prepend_section                             ],
	'Remove last section from multi_wirl' => ['CA0-s', \&App::Asciio::Actions::Multiwirl::remove_last_section_from_section_wirl_arrow ],
	'Start no disconnect'                 => ['C00-d', \&App::Asciio::Actions::Multiwirl::disable_arrow_connector, 0                  ],
	'End no disconnect'                   => ['0A0-d', \&App::Asciio::Actions::Multiwirl::disable_arrow_connector, 1                  ],
	},

'<< debug leader >>' => 
	{
	SHORTCUTS   => '00S-D',
	
	'Display undo stack statistics'       => ['000-u', \&App::Asciio::Actions::Unsorted::display_undo_stack_statistics ],
	'Dump self'                           => ['000-s', \&App::Asciio::Actions::Debug::dump_self                        ],
	'Dump all elements'                   => ['000-e', \&App::Asciio::Actions::Debug::dump_all_elements                ],
	'Dump selected elements'              => ['000-E', \&App::Asciio::Actions::Debug::dump_selected_elements           ],
	'Display numbered objects'            => ['000-t', sub { $_[0]->{NUMBERED_OBJECTS} ^= 1 ; $_[0]->update_display() }],
	'Test'                                => ['000-o', \&App::Asciio::Actions::Debug::test                             ],
	'ZBuffer Test'                        => ['000-z', \&App::Asciio::Actions::ZBuffer::dump_crossings                 ],
	},

'<< commands leader >>'=> 
	{
	SHORTCUTS   => '00S-colon',
	
	'Help'                                => ['000-h', \&App::Asciio::Actions::Unsorted::display_help                       ],
	'Add help box'                        => ['00S-H', \&App::Asciio::Actions::Elements::add_help_box,                                       ],
	
	'Display keyboard mapping'            => ['000-k', \&App::Asciio::Actions::Unsorted::display_keyboard_mapping_in_browser],
	'Display commands'                    => ['000-c', \&App::Asciio::Actions::Unsorted::display_commands                   ],
	'Display action files'                => ['000-f', \&App::Asciio::Actions::Unsorted::display_action_files               ],
	'Display manpage'                     => ['000-m', \&App::Asciio::Actions::Unsorted::manpage_in_browser                 ],
	
	'Run external script'                 => ['00S-exclam', \&App::Asciio::Scripting::run_external_script                   ],
	
	'Open'                                => ['000-e', \&App::Asciio::Actions::File::open                                   ],
	'Save'                                => ['000-w', \&App::Asciio::Actions::File::save, undef                            ],
	'SaveAs'                              => ['00S-W', \&App::Asciio::Actions::File::save, 'as'                             ],
	'Insert'                              => ['000-r', \&App::Asciio::Actions::File::insert                                 ],
	'Quit'                                => ['000-q', \&App::Asciio::Actions::File::quit                                   ],
	'Quit no save'                        => ['00S-Q', \&App::Asciio::Actions::File::quit_no_save                           ],
	},

'<< Insert leader >>' => 
	{
	SHORTCUTS   => '000-i',
	
	'Add connector'                       => ['000-c', \&App::Asciio::Actions::Elements::add_element, ['Asciio/connector', 0]                ],
	'Add text'                            => ['000-t', \&App::Asciio::Actions::Elements::add_element, ['Asciio/text', 1]                     ],
	'Add arrow'                           => ['000-a', \&App::Asciio::Actions::Elements::add_element, ['Asciio/wirl_arrow', 0]               ],
	# 'Add arrow'                           => ['000-a',
	# 						sub
	# 						{
	# 						App::Asciio::Actions::Elements::add_element($_[0], ['Asciio/wirl_arrow', 0]) ;
	# 						$_[0]->use_action_group('0A0-a') ;
	# 						}
	# 					] ,
	
	'Add angled arrow'                    => ['00S-A', \&App::Asciio::Actions::Elements::add_element, ['Asciio/angled arrow', 0]             ],
	
	'Add ascii line'                      => ['000-l', \&App::Asciio::Actions::Elements::add_line, 0                                         ], 
	'Add ascii no-connect line'           => ['000-k', \&App::Asciio::Actions::Elements::add_non_connecting_line, 0                          ], 
	
	'From default_stencil'                => ['000-s', \&App::Asciio::Actions::Elements::open_stencil, 'default_stencil.asciio'              ], 
	'From stencil'                        => ['00S-S', \&App::Asciio::Actions::Elements::open_stencil                                        ], 
	
	'<< Multiple >>'                      => ['000-m', sub { $_[0]->use_action_group('group_insert_multiple') ; }                            ] ,
	'<< Unicode >>'                       => ['000-u', sub { $_[0]->use_action_group('group_insert_unicode') ; }                             ] ,
	'<< Box >>'                           => ['000-b', sub { $_[0]->use_action_group('group_insert_box') ; }                                 ] ,
	'<< Elements >>'                      => ['000-e', sub { $_[0]->use_action_group('group_insert_element') ; }                             ] ,
	'<< Ruler >>'                         => ['000-r', sub { $_[0]->use_action_group('group_insert_ruler') ; }                               ] ,
	},

'group_insert_multiple' => 
	{
	SHORTCUTS   => 'group_insert_multiple',
	
	'Add multiple texts'                  => ['000-t', \&App::Asciio::Actions::Unsorted::insert_multiple_boxes_from_text_description, 0      ],
	'Add multiple boxes'                  => ['000-b', \&App::Asciio::Actions::Unsorted::insert_multiple_boxes_from_text_description, 1      ],
	},

'group_insert_ruler' => 
	{
	SHORTCUTS   => 'group_insert_ruler',
	
	'Add vertical ruler'                  => ['000-v', \&App::Asciio::Actions::Ruler::add_ruler, {TYPE => 'VERTICAL'}                        ],
	'Add horizontal ruler'                => ['000-h', \&App::Asciio::Actions::Ruler::add_ruler, {TYPE => 'HORIZONTAL'}                      ],
	'delete rulers'                       => ['000-d', \&App::Asciio::Actions::Ruler::remove_ruler                                           ],
	},

'group_insert_element' => 
	{
	SHORTCUTS   => 'group_insert_element',
	
	'Add connector type 2'                => ['000-c', \&App::Asciio::Actions::Elements::add_element, ['Asciio/connector2', 0]               ],
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

'<< element leader >>' => 
	{
	SHORTCUTS   => '000-e',
	
	'Shrink box'                     => ['000-s', \&App::Asciio::Actions::ElementsManipulation::shrink_box                              ],
	
	'Make element narrower'          => ['000-1',  \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [-1, 0]         ],
	'Make element taller'            => ['000-2',  \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [0,  1]         ],
	'Make element shorter'           => ['000-3',  \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [0, -1]         ],
	'Make element wider'             => ['000-4',  \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [1,  0]         ],
	
	'Make elements Unicode'          => ['C00-u',  \&App::Asciio::Actions::Asciio::make_selection_unicode, 1                            ],
	'Make elements not Unicode'      => ['C0S-U',  \&App::Asciio::Actions::Asciio::make_selection_unicode, 0                            ],
	},

'<< selection leader >>' =>
	{
	SHORTCUTS   => '000-s',
	ENTER_GROUP => \&App::Asciio::Actions::Selection::selection_enter,
	ESCAPE_KEYS => [ '000-s', '000-Escape' ],
	
	'Selection escape'               => [ '000-s',             \&App::Asciio::Actions::Selection::selection_escape                      ],
	'Selection escape2'              => [ '000-Escape',        \&App::Asciio::Actions::Selection::selection_escape                      ],

	'select flip mode'               => [ '000-e',             \&App::Asciio::Actions::Selection::selection_mode_flip                   ],
	'select motion'                  => [ '000-motion_notify', \&App::Asciio::Actions::Selection::select_elements                       ],
	'<< polygon selection >>'        => [ '000-x',             sub { $_[0]->use_action_group('group_polygon') ; }                       ] ,
	},

'group_polygon' =>
	{
	SHORTCUTS => 'group_polygon',
	ENTER_GROUP => \&App::Asciio::GTK::Asciio::polygon_selection_enter,
	ESCAPE_KEYS => [ '000-x', '000-Escape' ],

	'Polygon selection escape'               => [ '000-x',               \&App::Asciio::GTK::Asciio::polygon_selection_escape             ],
	'Polygon selection escape2'              => [ '000-Escape',          \&App::Asciio::GTK::Asciio::polygon_selection_escape             ],
	'Polygon select motion'                  => [ '000-motion_notify',   \&App::Asciio::GTK::Asciio::polygon_selection_motion, 1          ],
	'Polygon deselect motion'                => [ 'C00-motion_notify',   \&App::Asciio::GTK::Asciio::polygon_selection_motion, 0          ],
	'Polygon select left-release'            => [ '000-button-release-1',\&App::Asciio::GTK::Asciio::polygon_selection_button_release     ],
	'Polygon select left-release 2'          => [ 'C00-button-release-1',\&App::Asciio::GTK::Asciio::polygon_selection_button_release     ],
	},

'<< eraser leader >>' =>
	{
	SHORTCUTS   => '00S-E',
	ENTER_GROUP => \&App::Asciio::Actions::Eraser::eraser_enter,
	ESCAPE_KEYS => '000-Escape',
	
	'Eraser escape'                  => [ '000-Escape',        \&App::Asciio::Actions::Eraser::eraser_escape                            ],
	'Eraser motion'                  => [ '000-motion_notify', \&App::Asciio::Actions::Eraser::erase_elements                           ],
	},

'<< clone leader >>' =>
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

'<< git leader >>' =>
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

'<< slides leader >>' => 
	{
	SHORTCUTS   => '00S-S',
	ESCAPE_KEYS => '000-Escape',
	
	'Load slides'                    => ['000-l', \&App::Asciio::Actions::Presentation::load_slides          ] ,
	'previous slide'                 => ['00S-N', \&App::Asciio::Actions::Presentation::previous_slide       ],
	'next slide'                     => ['000-n', \&App::Asciio::Actions::Presentation::next_slide           ],
	'first slide'                    => ['000-g', \&App::Asciio::Actions::Presentation::first_slide          ],
	'show previous message'          => ['000-m', \&App::Asciio::Actions::Presentation::show_previous_message],
	'show next message'              => ['00S-M', \&App::Asciio::Actions::Presentation::show_next_message    ],
	'<< run script >>'               => ['000-s', sub { $_[0]->use_action_group('group_slides_script') ; }   ] ,
	},

'group_slides_script' => 
	{
	SHORTCUTS   => 'group_slides_script',
	ESCAPE_KEYS => '000-Escape',
	
	map { my $name =  "slides script $_" ; $name => ["000-$_", \&App::Asciio::Actions::Presentation::run_script, [$_] ] } ('a'..'z', '0'..'9'),
	},

'<< move arrow ends leader >>' =>
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

'Asciio context_menu'                    => ['as_context_menu', undef, undef,          \&App::Asciio::Actions::Asciio::context_menu                                        ],
'Box context_menu'                       => ['bo_context_menu', undef, undef,          \&App::Asciio::Actions::Box::context_menu                                           ] ,
'Multi_wirl context_menu'                => ['mw_context_menu', undef, undef,          \&App::Asciio::Actions::Multiwirl::multi_wirl_context_menu                          ],
'Angled arrow context_menu'              => ['aa_ontext menu',  undef, undef,          \&App::Asciio::Actions::Multiwirl::angled_arrow_context_menu                        ],
'Ruler context_menu'                     => ['ru_context_menu', undef, undef,          \&App::Asciio::Actions::Ruler::context_menu                                         ],
'Shapes context_menu'                    => ['sh_context_menu', undef, undef,          \&App::Asciio::Actions::Shapes::context_menu                                        ],
) ;

register_first_level_group
(
SHORTCUTS => '00S-question',

'<< Insert leader >>'            => 1,
'<< yank leader >>'              => 1,
'<< selection leader >>'         => 1,
'<< paste leader >>'             => 1,
'<< grouping leader >>'          => 1,
'<< stripes leader >>'           => 1,
'<< align leader >>'             => 1,
'<< change color/font leader >>' => 1,
'<< arrow leader >>'             => 1,
'<< debug leader >>'             => 1,
'<< commands leader >>'          => 1,
'<< Insert leader >>'            => 1,
'<< slides leader >>'            => 1,
'<< element leader >>'           => 1,
'<< clone leader >>'             => 1,
'<< git leader >>'               => 1,
'<< move arrow ends leader >>'   => 1,

'Select next non arrow'          => 1,
'Select previous non arrow'      => 1,
'Select next arrow'              => 1,
'Select previous arrow'          => 1,
'Select all elements'            => 1,
'Select connected elements'      => 1,

'Edit selected element inline'   => 1,

'Mouse quick link'               => 1,
'Mouse duplicate elements'       => 1,
'Mouse quick box'                => 1,

'Arrow to mouse'                 => 1,
'Arrow mouse change direction'   => 1,
'Arrow change direction'         => 1,
'Wirl arrow add section'         => 1,
'Wirl arrow insert flex point'   => 1,
) ;

