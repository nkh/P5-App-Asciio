
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
use App::Asciio::Actions::File ;
use App::Asciio::Actions::Git ;
use App::Asciio::Actions::Mouse ;
use App::Asciio::Actions::Multiwirl ;
use App::Asciio::Actions::Presentation ;
use App::Asciio::Actions::Ruler ;
use App::Asciio::Actions::Shapes ;
use App::Asciio::Actions::Unsorted ;


#----------------------------------------------------------------------------------------------

register_action_handlers
(
'flip cross mode'                        => [ '000-x',                                 sub { $_[0]->{USE_CROSS_MODE} ^= 1 ; $_[0]->update_display ; }                      ],

'Undo'                                   => [['C00-z', '000-u'],                       \&App::Asciio::Actions::Unsorted::undo                                              ],
'Redo'                                   => [['C00-y', 'C00-r'],                       \&App::Asciio::Actions::Unsorted::redo                                              ],
'Zoom in'                                => [['000-plus', 'C00-j', 'C00-scroll-up'],   \&App::Asciio::Actions::Unsorted::zoom, 1                                           ],
'Zoom out'                               => [['000-minus', 'C00-h', 'C00-scroll-down'],\&App::Asciio::Actions::Unsorted::zoom, -1                                          ],
'Copy to clipboard'                      => [['C00-c', 'C00-Insert', 'y'],             \&App::Asciio::Actions::Clipboard::copy_to_clipboard                                ],
'Insert from clipboard'                  => [['C00-v', '00S-Insert', 'p'],             \&App::Asciio::Actions::Clipboard::insert_from_clipboard                            ],
'Export to clipboard & primary as ascii' => [['C00-e', '00S-Y', 'Y'],                  \&App::Asciio::Actions::Clipboard::export_to_clipboard_as_ascii                     ],
'Export to clipboard & primary as markup'=> ['C0S-E',                                  \&App::Asciio::Actions::Clipboard::export_to_clipboard_as_markup                    ],
'Import from primary to box'             => [['C0S-V', '00S-P', 'P'],                  \&App::Asciio::Actions::Clipboard::import_from_primary_to_box                       ],
'Import from primary to text'            => [['0A0-p','A-P'],                          \&App::Asciio::Actions::Clipboard::import_from_primary_to_text                      ],
'Import from clipboard to box'           => [ '0AS-E' ,                                \&App::Asciio::Actions::Clipboard::import_from_clipboard_to_box                     ],
'Import from clipboard to text'          => [ '0AS-T' ,                                \&App::Asciio::Actions::Clipboard::import_from_clipboard_to_text                    ],

'Select next element'                    => [['000-Tab', '000-n'],                     \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [1, 0, 0]   ],
'Select previous element'                => [['00S-ISO_Left_Tab', '00S-N'],            \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [0, 0, 0]   ],
'Select next non arrow'                  => [['C00-Tab', 'C00-n'],                     \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [1, 0, 1]   ],
'Select previous non arrow'              => [['C0S-ISO_Left_Tab', 'C0S-N'],            \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [0, 0, 1]   ],
'Select next arrow'                      => [['CA0-Tab', 'C00-m'],                     \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [1, 0, 2]   ],
'Select previous arrow'                  => [['CAS-ISO_Left_Tab', 'C0S-M'],            \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [0, 0, 2]   ],

'Select element by id'                   => ['0A0-Tab',                                \&App::Asciio::Actions::ElementsManipulation::select_element_by_id                  ],

'Select all elements'                    => [['C00-a', '00S-V'],                       \&App::Asciio::Actions::ElementsManipulation::select_all_elements                   ],
'Deselect all elements'                  => ['000-Escape',                             \&App::Asciio::Actions::ElementsManipulation::deselect_all_elements                 ],
'Select connected elements'              => ['000-v',                                  \&App::Asciio::Actions::ElementsManipulation::select_connected                      ],
'Select elements by word'                => ['C00-f',                                  \&App::Asciio::Actions::ElementsManipulation::select_all_elements_by_words          ],
'Select elements by word no group'       => ['C0S-F',                                  \&App::Asciio::Actions::ElementsManipulation::select_all_elements_by_words_no_group ],

'Delete selected elements'               => [['000-Delete', '000-d'],                  \&App::Asciio::Actions::ElementsManipulation::delete_selected_elements              ],

'Edit selected element'                  => [['000-2button-press-1','000-Return'],     \&App::Asciio::Actions::ElementsManipulation::edit_selected_element, 0              ],
'Edit selected element inline'           => [['C00-2button-press-1','C00-Return'],     \&App::Asciio::Actions::ElementsManipulation::edit_selected_element, 1              ],

'Move selected elements left'            => ['000-Left',                               \&App::Asciio::Actions::ElementsManipulation::move_selection_left                   ],
'Move selected elements right'           => ['000-Right',                              \&App::Asciio::Actions::ElementsManipulation::move_selection_right                  ],
'Move selected elements up'              => ['000-Up',                                 \&App::Asciio::Actions::ElementsManipulation::move_selection_up                     ],
'Move selected elements down'            => ['000-Down',                               \&App::Asciio::Actions::ElementsManipulation::move_selection_down                   ],

'Move selected elements left quick'      => ['0A0-Left',                               \&App::Asciio::Actions::ElementsManipulation::move_selection_left, 10               ],
'Move selected elements right quick'     => ['0A0-Right',                              \&App::Asciio::Actions::ElementsManipulation::move_selection_right, 10              ],
'Move selected elements up quick'        => ['0A0-Up',                                 \&App::Asciio::Actions::ElementsManipulation::move_selection_up, 10                 ],
'Move selected elements down quick'      => ['0A0-Down',                               \&App::Asciio::Actions::ElementsManipulation::move_selection_down, 10               ],

'Move selected elements left 2'          => [['000-h', 'h'],                           \&App::Asciio::Actions::ElementsManipulation::move_selection_left                   ],
'Move selected elements right 2'         => [['000-l', 'l'],                           \&App::Asciio::Actions::ElementsManipulation::move_selection_right                  ],
'Move selected elements up 2'            => [['000-k', 'k'],                           \&App::Asciio::Actions::ElementsManipulation::move_selection_up                     ],
'Move selected elements down 2'          => [['000-j', 'j'],                           \&App::Asciio::Actions::ElementsManipulation::move_selection_down                   ],

'Shrink box'                             => ['000-s',                                  \&App::Asciio::Actions::ElementsManipulation::shrink_box                            ],

'Make element narrower'                  => ['000-1',                                  \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [-1, 0]        ],
'Make element taller'                    => ['000-2',                                  \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [0,  1]        ],
'Make element shorter'                   => ['000-3',                                  \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [0, -1]        ],
'Make element wider'                     => ['000-4',                                  \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [1,  0]        ],

'Make elements Unicode'                  => ['C00-u',                                  \&App::Asciio::Actions::Asciio::make_selection_unicode, 1                           ],
'Make elements not Unicode'              => ['C0S-U',                                  \&App::Asciio::Actions::Asciio::make_selection_unicode, 0                           ],

# mouse
'Mouse right-click'                      => ['000-button-press-3',                     \&App::Asciio::Actions::Mouse::mouse_right_click                                    ],

'Mouse left-click'                       => ['000-button-press-1',                     \&App::Asciio::Actions::Mouse::mouse_left_click                                     ],
'Mouse expand selection'                 => ['00S-button-press-1',                     \&App::Asciio::Actions::Mouse::expand_selection                                     ],
'Mouse selection flip'                   => ['C00-button-press-1',                     \&App::Asciio::Actions::Mouse::mouse_element_selection_flip                         ],

'Mouse quick link'                       => [['0A0-button-press-1', '000-period'],     \&App::Asciio::Actions::Mouse::quick_link                                           ],
'Mouse duplicate elements'               => [['0AS-button-press-1', '000-comma'],      \&App::Asciio::Actions::Mouse::mouse_duplicate_element                              ],
'Mouse quick box'                        => [['C0S-button-press-1'],                   \&App::Asciio::Actions::Elements::add_element, ['Asciio/box', 0]                    ],

'Arrow to mouse'                         => ['CA0-motion_notify',                      \&App::Asciio::Actions::Arrow::interactive_to_mouse                                 ], 
'Arrow mouse change direction'           => ['CA0-2button-press-1',                    \&App::Asciio::Actions::Arrow::change_arrow_direction                               ],      
'Arrow change direction'                 => ['CA0-d',                                  \&App::Asciio::Actions::Arrow::interactive_change_arrow_direction                   ],      
'Wirl arrow add section'                 => ['CA0-button-press-1',                     \&App::Asciio::Actions::Multiwirl::interactive_add_section                          ],
'Wirl arrow insert flex point'           => ['CA0-button-press-2',                     \&App::Asciio::Actions::Multiwirl::insert_wirl_arrow_section                        ],

'Mouse motion'                           => ['000-motion_notify',                      \&App::Asciio::Actions::Mouse::mouse_motion                                         ], 
'Mouse motion 2'                         => ['0AS-motion_notify',                      \&App::Asciio::Actions::Mouse::mouse_motion                                         ],
'Mouse drag canvas'                      => ['C00-motion_notify',                      \&App::Asciio::Actions::Mouse::mouse_drag_canvas                                    ],         

# mouse emulation
'Mouse emulation toggle'                 => [['000-apostrophe', "'"],                  \&App::Asciio::Actions::Mouse::toggle_mouse                                         ],

'Mouse emulation left-click'             => ['000-odiaeresis',                         \&App::Asciio::Actions::Mouse::mouse_left_click                                     ],
'Mouse emulation expand selection'       => ['00S-Odiaeresis',                         \&App::Asciio::Actions::Mouse::expand_selection                                     ],
'Mouse emulation selection flip'         => ['C00-odiaeresis',                         \&App::Asciio::Actions::Mouse::mouse_element_selection_flip                         ],

'Mouse emulation right-click'            => ['000-adiaeresis',                         \&App::Asciio::Actions::Mouse::mouse_right_click                                    ],

'Mouse emulation move left'              => ['C00-Left',                               \&App::Asciio::Actions::Mouse::mouse_move, [-1,  0]                                 ],
'Mouse emulation move right'             => ['C00-Right',                              \&App::Asciio::Actions::Mouse::mouse_move, [ 1,  0]                                 ],
'Mouse emulation move up'                => ['C00-Up',                                 \&App::Asciio::Actions::Mouse::mouse_move, [ 0, -1]                                 ],
'Mouse emulation move down'              => ['C00-Down',                               \&App::Asciio::Actions::Mouse::mouse_move, [ 0,  1]                                 ],

'Mouse emulation drag left'              => ['00S-Left',                               \&App::Asciio::Actions::Mouse::mouse_drag_left                                      ],
'Mouse emulation drag right'             => ['00S-Right',                              \&App::Asciio::Actions::Mouse::mouse_drag_right                                     ],
'Mouse emulation drag up'                => ['00S-Up',                                 \&App::Asciio::Actions::Mouse::mouse_drag_up                                        ],
'Mouse emulation drag down'              => ['00S-Down',                               \&App::Asciio::Actions::Mouse::mouse_drag_down                                      ],

'Mouse on element id'                    => ['000-m',                                  \&App::Asciio::Actions::Mouse::mouse_on_element_id                                  ],

'Asciio context_menu'                    => ['as_context_menu', undef, undef,          \&App::Asciio::Actions::Asciio::context_menu                                        ],
'Box context_menu'                       => ['bo_context_menu', undef, undef,          \&App::Asciio::Actions::Box::context_menu                                           ] ,
'Multi_wirl context_menu'                => ['mw_context_menu', undef, undef,          \&App::Asciio::Actions::Multiwirl::multi_wirl_context_menu                          ],
'Angled arrow context_menu'              => ['aa_ontext menu',  undef, undef,          \&App::Asciio::Actions::Multiwirl::angled_arrow_context_menu                        ],
'Ruler context_menu'                     => ['ru_context_menu', undef, undef,          \&App::Asciio::Actions::Ruler::context_menu                                         ],
'Shapes context_menu'                    => ['sh_context_menu', undef, undef,          \&App::Asciio::Actions::Shapes::context_menu                                        ],

'grouping leader' => 
	{
	SHORTCUTS => '000-g',
	
	'Group selected elements'             => ['000-g', \&App::Asciio::Actions::ElementsManipulation::group_selected_elements                 ],
	'Ungroup selected elements'           => ['000-u', \&App::Asciio::Actions::ElementsManipulation::ungroup_selected_elements               ],
	'Move selected elements to the front' => ['000-f', \&App::Asciio::Actions::ElementsManipulation::move_selected_elements_to_front         ],
	'Move selected elements to the back'  => ['000-b', \&App::Asciio::Actions::ElementsManipulation::move_selected_elements_to_back          ],
	'Temporary move to the front'         => ['00S-F', \&App::Asciio::Actions::ElementsManipulation::temporary_move_selected_element_to_front],
	},

'stripes leader' => 
	{
	SHORTCUTS => '0A0-g',
	
	'create stripes group'                => ['000-g', \&App::Asciio::Actions::ElementsManipulation::create_stripes_group, 0],
	'create one stripe group'             => ['000-1', \&App::Asciio::Actions::ElementsManipulation::create_stripes_group, 1],
	'ungroup stripes group'               => ['000-u', \&App::Asciio::Actions::ElementsManipulation::ungroup_stripes_group  ],
	},

'align leader' => 
	{
	SHORTCUTS => '00S-A',
	
	'Align top'                           => ['000-t', \&App::Asciio::Actions::Align::align, 'top'       ],
	'Align left'                          => ['000-l', \&App::Asciio::Actions::Align::align, 'left'      ],
	'Align bottom'                        => ['000-b', \&App::Asciio::Actions::Align::align, 'bottom'    ],
	'Align right'                         => ['000-r', \&App::Asciio::Actions::Align::align, 'right'     ],
	'Align vertically'                    => ['000-v', \&App::Asciio::Actions::Align::align, 'vertical'  ],
	'Align horizontally'                  => ['000-h', \&App::Asciio::Actions::Align::align, 'horizontal'],
	},

'change color/font leader'=> 
	{
	SHORTCUTS => '000-z',
	
	'Change elements foreground color'    => ['000-c', \&App::Asciio::Actions::Colors::change_elements_colors, 0 ],
	'Change elements background color'    => ['00S-C', \&App::Asciio::Actions::Colors::change_elements_colors, 1 ],

	'Change Asciio background color'      => ['0A0-c', \&App::Asciio::Actions::Colors::change_background_color   ],
	'Change grid color'                   => ['0AS-C', \&App::Asciio::Actions::Colors::change_grid_color         ],
	'Flip color scheme'                   => ['000-s', \&App::Asciio::Actions::Colors::flip_color_scheme         ],
	'Flip transparent element background' => ['000-t', \&App::Asciio::Actions::Unsorted::transparent_elements    ],
	'Flip grid display'                   => ['000-g', \&App::Asciio::Actions::Unsorted::flip_grid_display       ],
	'Remove rulers'                       => ['000-r', \&App::Asciio::Actions::Ruler::remove_ruler               ],
	'Flip hint lines'                     => ['000-h', \&App::Asciio::Actions::Unsorted::flip_hint_lines         ],
	'Change font'                         => ['000-f', \&App::Asciio::Actions::Unsorted::change_font             ],
	'Edit inline'                         => ['000-i', \&App::Asciio::GTK::Asciio::switch_gtk_popup_box_type     ], 
	'show/hide connectors'                => ['000-v', \&App::Asciio::Actions::Unsorted::flip_connector_display  ], 
	},

'arrow leader' => 
	{
	SHORTCUTS => '000-a',
	
	'Change arrow direction'              => ['000-d', \&App::Asciio::Actions::Arrow::change_arrow_direction                          ],
	'Flip arrow start and end'            => ['000-f', \&App::Asciio::Actions::Arrow::flip_arrow_ends                                 ],
	'Append multi_wirl section'           => ['000-s', \&App::Asciio::Actions::Multiwirl::append_section,                             ],
	'Insert multi_wirl section'           => ['000-S', \&App::Asciio::Actions::Multiwirl::insert_wirl_arrow_section                   ],
	'Prepend multi_wirl section'          => ['0A0-s', \&App::Asciio::Actions::Multiwirl::prepend_section                             ],
	'Remove last section from multi_wirl' => ['C00-s', \&App::Asciio::Actions::Multiwirl::remove_last_section_from_section_wirl_arrow ],
	},

'debug leader' => 
	{
	SHORTCUTS => '00S-D',
	
	'Display undo stack statistics'       => ['000-u', \&App::Asciio::Actions::Unsorted::display_undo_stack_statistics ],
	'Dump self'                           => ['000-s', \&App::Asciio::Actions::Debug::dump_self                        ],
	'Dump all elements'                   => ['000-e', \&App::Asciio::Actions::Debug::dump_all_elements                ],
	'Dump selected elements'              => ['000-E', \&App::Asciio::Actions::Debug::dump_selected_elements           ],
	'Display numbered objects'            => ['000-t', sub { $_[0]->{NUMBERED_OBJECTS} ^= 1 ; $_[0]->update_display() }],
	'Test'                                => ['000-o', \&App::Asciio::Actions::Debug::test                             ],
	},

'commands leader'=> 
	{
	SHORTCUTS => '00S-colon',
	
	'Help'                                => ['000-h', \&App::Asciio::Actions::Unsorted::display_help                       ],
	'Display keyboard mapping'            => ['000-k', \&App::Asciio::Actions::Unsorted::display_keyboard_mapping_in_browser],
	'Display commands'                    => ['000-c', \&App::Asciio::Actions::Unsorted::display_commands                   ],
	'Display action files'                => ['000-f', \&App::Asciio::Actions::Unsorted::display_action_files               ],
	'Display manpage'                     => ['000-m', \&App::Asciio::Actions::Unsorted::manpage_in_browser                 ],

	
	'Open'                                => ['000-e', \&App::Asciio::Actions::File::open        ],
	'Save'                                => ['000-w', \&App::Asciio::Actions::File::save, undef ],
	'SaveAs'                              => ['00S-W', \&App::Asciio::Actions::File::save, 'as'  ],
	'Insert'                              => ['000-r', \&App::Asciio::Actions::File::insert      ],
	'Quit'                                => ['000-q', \&App::Asciio::Actions::File::quit        ],
	'Quit no save'                        => ['00S-Q', \&App::Asciio::Actions::File::quit_no_save],
	},

'Insert leader' => 
	{
	SHORTCUTS => '000-i',
	
	# 'Add from file'     => [ 'f' ], ???
	
	'Add box'                             => ['000-b', \&App::Asciio::Actions::Elements::add_element, ['Asciio/box', 0]                      ],
	'Add unicode box'                     => ['0A0-b', \&App::Asciio::Actions::Elements::add_element, ['Asciio/box unicode', 0]              ],
	'Add shrink box'                      => ['00S-B', \&App::Asciio::Actions::Elements::add_element, ['Asciio/shrink_box', 1]               ],
	
	'Add text'                            => ['000-t', \&App::Asciio::Actions::Elements::add_element, ['Asciio/text', 1]                     ],
	
	'Add arrow'                           => ['000-a', \&App::Asciio::Actions::Elements::add_element, ['Asciio/wirl_arrow', 0]               ],
	# 'Add arrow'                           => ['000-a',
	# 						sub
	# 						{
	# 						App::Asciio::Actions::Elements::add_element($_[0], ['Asciio/wirl_arrow', 0]) ;
	# 						$_[0]->use_action_group('0A0-a') ;
	# 						}
	# 					] ,
	
	'Add unicode arrow'                   => ['0A0-a', \&App::Asciio::Actions::Elements::add_element, ['Asciio/wirl_arrow unicode', 0]       ],
	
	'Add angled arrow'                    => ['00S-A', \&App::Asciio::Actions::Elements::add_element, ['Asciio/angled arrow', 0]             ],
	'Add unicode angled arrow'            => ['0AS-A', \&App::Asciio::Actions::Elements::add_element, ['Asciio/angled arrow unicode', 0]     ],
	
	'Add connector'                       => ['000-c', \&App::Asciio::Actions::Elements::add_element, ['Asciio/connector', 0]                ],
	'Add connector type 2'                => ['00S-C', \&App::Asciio::Actions::Elements::add_element, ['Asciio/connector2', 0]               ],
	'Add if'                              => ['000-i', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/if', 1]                 ],
	'Add process'                         => ['000-p', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/process', 1]            ],
	'Add rhombus'                         => ['000-r', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Shape/rhombus', 0]            ],
	'Add ellipse'                         => ['000-e', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Shape/ellipse', 0]            ],
	
	'Add ascii line'                      => ['000-l', \&App::Asciio::Actions::Elements::add_line, 0                                         ], 
	'Add unicode line'                    => ['00S-L', \&App::Asciio::Actions::Elements::add_line, 1                                         ],
	'Add unicode bold line'               => ['0A0-l', \&App::Asciio::Actions::Elements::add_line, 2                                         ],
	'Add unicode double line'             => ['0AS-L', \&App::Asciio::Actions::Elements::add_line, 3                                         ],
	
	'Add ascii no-connect line'           => ['000-k', \&App::Asciio::Actions::Elements::add_non_connecting_line, 0                          ], 
	'Add unicode no-connect line'         => ['00S-K', \&App::Asciio::Actions::Elements::add_non_connecting_line, 1                          ],
	'Add unicode no-connect bold line'    => ['0A0-k', \&App::Asciio::Actions::Elements::add_non_connecting_line, 2                          ],
	'Add unicode no-connect double line'  => ['0AS-K', \&App::Asciio::Actions::Elements::add_non_connecting_line, 3                          ],
	
	'Add multiple texts'                  => ['C00-t', \&App::Asciio::Actions::Unsorted::insert_multiple_boxes_from_text_description, 0      ],
	'Add multiple boxes'                  => ['C00-b', \&App::Asciio::Actions::Unsorted::insert_multiple_boxes_from_text_description, 1      ],
	
	'Add exec box'                        => ['C00-e', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/exec', 1]               ],
	'Add exec box verbatim'               => ['C00-v', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/exec verbatim', 1]      ],
	'Add exec box verbatim once'          => ['C00-o', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/exec verbatim once', 1] ],
	'Add line numbered box'               => ['C00-l', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/exec add lines', 1]     ],
	
	'Add vertical ruler'                  => ['C00-r', \&App::Asciio::Actions::Ruler::add_ruler,      {TYPE => 'VERTICAL'}                   ],
	'Add horizontal ruler'                => ['C0S-R', \&App::Asciio::Actions::Ruler::add_ruler,      {TYPE => 'HORIZONTAL'}                 ],
	'Add help box'                        => ['C00-h', \&App::Asciio::Actions::Elements::add_help_box,                                       ],
	},

'clone' =>
	{
	SHORTCUTS => '000-c',
	ENTER_GROUP => \&App::Asciio::Actions::Clone::clone_enter,
	ESCAPE_KEY => '000-Escape',
	
	'clone escape'                       => [ '000-Escape',          \&App::Asciio::Actions::Clone::clone_escape                                  ],
	'clone motion'                       => [ '000-motion_notify',   \&App::Asciio::Actions::Clone::clone_mouse_motion                            ], 
	
	'clone insert'                       => [ '000-button-press-1',  \&App::Asciio::Actions::Clone::clone_add_element                             ],
	'clone insert2'                      => [ '000-Return',          \&App::Asciio::Actions::Clone::clone_add_element                             ],
	'clone arrow'                        => [ '000-a',               \&App::Asciio::Actions::Clone::clone_set_overlay, ['Asciio/wirl_arrow', 0]   ],
	'clone angled arrow'                 => [ '00S-A',               \&App::Asciio::Actions::Clone::clone_set_overlay, ['Asciio/angled_arrow', 0] ],
	'clone box'                          => [ '000-b',               \&App::Asciio::Actions::Clone::clone_set_overlay, ['Asciio/box', 0]          ],
	'clone text'                         => [ '000-t',               \&App::Asciio::Actions::Clone::clone_set_overlay, ['Asciio/text', 0]         ],
	'clone flip hint lines'              => [ '000-h',               \&App::Asciio::Actions::Unsorted::flip_hint_lines                            ],
	
	'clone left'                         => ['000-Left',             \&App::Asciio::Actions::ElementsManipulation::move_selection_left            ],
	'clone right'                        => ['000-Right',            \&App::Asciio::Actions::ElementsManipulation::move_selection_right           ],
	'clone up'                           => ['000-Up',               \&App::Asciio::Actions::ElementsManipulation::move_selection_up              ],
	'clone down'                         => ['000-Down',             \&App::Asciio::Actions::ElementsManipulation::move_selection_down            ],
	
	'clone emulation left'               => ['C00-Left',             \&App::Asciio::Actions::Mouse::mouse_move, [-1,  0]                          ],
	'clone emulation right'              => ['C00-Right',            \&App::Asciio::Actions::Mouse::mouse_move, [ 1,  0]                          ],
	'clone emulation up'                 => ['C00-Up',               \&App::Asciio::Actions::Mouse::mouse_move, [ 0, -1]                          ],
	'clone emulation down'               => ['C00-Down',             \&App::Asciio::Actions::Mouse::mouse_move, [ 0,  1]                          ],
	},

'git' =>
	{
	SHORTCUTS => '00S-G',
	ESCAPE_KEY => '000-Escape',
	
	'Quick git'                          => [['000-button-press-3', '000-g'],       \&App::Asciio::Actions::Git::quick_link                                ],
	
	'Git add box'                        => [ '000-b',                              \&App::Asciio::Actions::Elements::add_element, ['Asciio/box',  1]      ],
	'Git add text'                       => [ '000-t',                              \&App::Asciio::Actions::Elements::add_element, ['Asciio/text', 1]      ],
	'Git add arrow'                      => [ '000-a',                              \&App::Asciio::Actions::Elements::add_element, ['Asciio/wirl_arrow', 0]],
	'Git edit selected element'          => [['000-2button-press-1', '000-Return'], \&App::Asciio::Actions::Git::edit_selected_element                     ],
	
	'Git mouse left-click'               => [ '000-button-press-1',                 \&App::Asciio::Actions::Mouse::mouse_left_click                        ],
	'Git change arrow direction'         => [ '000-d',                              \&App::Asciio::Actions::Arrow::change_arrow_direction                  ],
	'Git undo'                           => [ '000-u',                              \&App::Asciio::Actions::Unsorted::undo                                 ],
	'Git delete elements'                => [['000-Delete', '000-x'],               \&App::Asciio::Actions::ElementsManipulation::delete_selected_elements ],
	
	'Git mouse motion'                   => [ '000-motion_notify',                  \&App::Asciio::Actions::Mouse::mouse_motion                            ], 
	'Git move elements left'             => [ '000-Left',                           \&App::Asciio::Actions::ElementsManipulation::move_selection_left      ],
	'Git move elements right'            => [ '000-Right',                          \&App::Asciio::Actions::ElementsManipulation::move_selection_right     ],
	'Git move elements up'               => [ '000-Up',                             \&App::Asciio::Actions::ElementsManipulation::move_selection_up        ],
	'Git move elements down'             => [ '000-Down',                           \&App::Asciio::Actions::ElementsManipulation::move_selection_down      ],
	
	'Git mouse right-click'              => [ '0A0-button-press-3',                 \&App::Asciio::Actions::Mouse::mouse_right_click                       ],
	'Git flip hint lines'                => [ '000-h',                              \&App::Asciio::Actions::Unsorted::flip_hint_lines                      ],
	},

'slides leader' => 
	{
	SHORTCUTS => '00S-S',
	
	'Load slides'                        => ['000-l', \&App::Asciio::Actions::Presentation::load_slides   ] ,
	'previous slide'                     => ['00S-N', \&App::Asciio::Actions::Presentation::previous_slide],
	'next slide'                         => ['000-n', \&App::Asciio::Actions::Presentation::next_slide    ],
	'first slide'                        => ['000-g', \&App::Asciio::Actions::Presentation::first_slide   ],
	},

'move arrow ends' =>
	{
	SHORTCUTS => '0A0-a',
	ESCAPE_KEY => '000-Escape',
	
	'arrow start up'                     => [ '000-Up',    \&App::Asciio::Actions::Arrow::move_arrow_start, [ 0, -1] ],
	'arrow start down'                   => [ '000-Down',  \&App::Asciio::Actions::Arrow::move_arrow_start, [ 0,  1] ],
	'arrow start right'                  => [ '000-Right', \&App::Asciio::Actions::Arrow::move_arrow_start, [ 1,  0] ],
	'arrow start left'                   => [ '000-Left',  \&App::Asciio::Actions::Arrow::move_arrow_start, [-1,  0] ],
	'arrow start up2'                    => [ '000-k',     \&App::Asciio::Actions::Arrow::move_arrow_start, [ 0, -1] ],
	'arrow start down2'                  => [ '000-j',     \&App::Asciio::Actions::Arrow::move_arrow_start, [ 0,  1] ],
	'arrow start right2'                 => [ '000-l',     \&App::Asciio::Actions::Arrow::move_arrow_start, [ 1,  0] ],
	'arrow start left2'                  => [ '000-h',     \&App::Asciio::Actions::Arrow::move_arrow_start, [-1,  0] ],
	'arrow end up'                       => [ '00S-Up',    \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 0, -1] ],
	'arrow end down'                     => [ '00S-Down',  \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 0,  1] ],
	'arrow end right'                    => [ '00S-Right', \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 1,  0] ],
	'arrow end left'                     => [ '00S-Left',  \&App::Asciio::Actions::Arrow::move_arrow_end,   [-1,  0] ],
	'arrow end up2'                      => [ '00S-K',     \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 0, -1] ],
	'arrow end down2'                    => [ '00S-J',     \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 0,  1] ],
	'arrow end right2'                   => [ '00S-L',     \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 1,  0] ],
	'arrow end left2'                    => [ '00S-H',     \&App::Asciio::Actions::Arrow::move_arrow_end,   [-1,  0] ],
	},
) ;


