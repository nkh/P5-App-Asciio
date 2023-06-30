
use App::Asciio::Actions::Align ;
use App::Asciio::Actions::Clipboard ;
use App::Asciio::Actions::Colors ;
use App::Asciio::Actions::Multiwirl ;
use App::Asciio::Actions::Box ;
use App::Asciio::Actions::Debug ;
use App::Asciio::Actions::File ;
use App::Asciio::Actions::Mouse ;
use App::Asciio::Actions::Elements ;
use App::Asciio::Actions::Presentation ;
use App::Asciio::Actions::Unsorted ;
use App::Asciio::Actions::Ruler ;
use App::Asciio::Actions::ElementsManipulation ;
use App::Asciio::Actions::Git ;
use App::Asciio::Toolfunc ;

#----------------------------------------------------------------------------------------------

register_action_handlers
(
'Undo'                                        => [['C00-z', '000-u'],                       \&App::Asciio::Actions::Unsorted::undo                                            ],
'Redo'                                        => [['C00-y', 'C00-r'],                       \&App::Asciio::Actions::Unsorted::redo                                            ],
'Zoom in'                                     => [['000-plus', 'C00-j'],                    \&App::Asciio::Actions::Unsorted::zoom, 1                                         ],
'Zoom out'                                    => [['000-minus', 'C00-h'],                   \&App::Asciio::Actions::Unsorted::zoom, -1                                        ],
'Copy to clipboard'                           => [['C00-c', 'C00-Insert', 'y'],             \&App::Asciio::Actions::Clipboard::copy_to_clipboard                              ],
'Insert from clipboard'                       => [['C00-v', '00S-Insert', 'p'],             \&App::Asciio::Actions::Clipboard::insert_from_clipboard                          ],
'Export to clipboard & primary as ascii'      => [['C00-e', '00S-Y', 'Y'],                  \&App::Asciio::Actions::Clipboard::export_to_clipboard_as_ascii                   ],
'Export to clipboard & primary as wiki'       => ['C0S-E',                                  \&App::Asciio::Actions::Clipboard::export_to_clipboard_as_wiki                    ],
'Import from primary to box'                  => [['C0S-V', '00S-P', 'P'],                  \&App::Asciio::Actions::Clipboard::import_from_primary_to_box                     ],
'Import from primary to text'                 => [['0A0-p','A-P'],                          \&App::Asciio::Actions::Clipboard::import_from_primary_to_text                    ],
'Import from clipboard to box'                => [ '0AS-E' ,                                \&App::Asciio::Actions::Clipboard::import_from_clipboard_to_box                   ],
'Import from clipboard to text'               => [ '0AS-T' ,                                \&App::Asciio::Actions::Clipboard::import_from_clipboard_to_text                  ],

'Change elements foreground color'            => ['000-c',                                  \&App::Asciio::Actions::Colors::change_elements_colors, 0                         ],
'Change elements background color'            => ['00S-C',                                  \&App::Asciio::Actions::Colors::change_elements_colors, 1                         ],
'Remove rulers'                               => ['0A0-r',                                  \&App::Asciio::Actions::Ruler::remove_ruler                                       ],

'Select next element'                         => [['000-Tab', '000-n'],                     \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [1, 0]    ],
'Select previous element'                     => [['00S-ISO_Left_Tab', '00S-N'],            \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [0, 0]    ],
'Select next non arrow'                       => [['C00-Tab', 'C00-n'],                     \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [1, 0, 1] ],
'Select previous non arrow'                   => [['C0S-ISO_Left_Tab', 'C0S-N'],            \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [0, 0, 1] ],
'Select next arrow'                           => [['CA0-Tab', 'C00-m'],                     \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [1, 0, 2] ],
'Select previous arrow'                       => [['CAS-ISO_Left_Tab', 'C0S-M'],            \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [0, 0, 2] ],

'Select element by id'                        => ['0A0-Tab',                                \&App::Asciio::Actions::ElementsManipulation::select_element_by_id                ],

'Select all elements'                         => [['C00-a', '00S-V'],                       \&App::Asciio::Actions::ElementsManipulation::select_all_elements                 ],
'Deselect all elements'                       => ['000-Escape',                             \&App::Asciio::Actions::ElementsManipulation::deselect_all_elements               ],
'Select connected elements'                   => ['000-v',                                  \&App::Asciio::Actions::ElementsManipulation::select_connected                    ],
'Select elements by search words'             => ['C00-f',                                  \&App::Asciio::Actions::ElementsManipulation::select_all_elements_by_search_words ],
'Switch cross mode'                           => ['0A0-x',                                  \&App::Asciio::Actions::ElementsManipulation::switch_cross_mode            ],
'Select elements by search words ignore group'=> ['C0S-F',                                  \&App::Asciio::Actions::ElementsManipulation::select_all_elements_by_search_words_ignore_group ],

'Delete selected elements'                    => [['000-Delete', '000-d'],                  \&App::Asciio::Actions::ElementsManipulation::delete_selected_elements            ],

'Edit selected element'                       => [['000-2button-press-1','000-Return'],     \&App::Asciio::Actions::ElementsManipulation::edit_selected_element, 0            ],
'Edit selected element inline'                => [['C00-2button-press-1','C00-Return'],     \&App::Asciio::Actions::ElementsManipulation::edit_selected_element, 1            ],

'Move selected elements left'                 => ['000-Left',                               \&App::Asciio::Actions::ElementsManipulation::move_selection_left                 ],
'Move selected elements right'                => ['000-Right',                              \&App::Asciio::Actions::ElementsManipulation::move_selection_right                ],
'Move selected elements up'                   => ['000-Up',                                 \&App::Asciio::Actions::ElementsManipulation::move_selection_up                   ],
'Move selected elements down'                 => ['000-Down',                               \&App::Asciio::Actions::ElementsManipulation::move_selection_down                 ],

'Move selected elements left quick'           => ['0A0-Left',                               \&App::Asciio::Actions::ElementsManipulation::move_selection_left, 10             ],
'Move selected elements right quick'          => ['0A0-Right',                              \&App::Asciio::Actions::ElementsManipulation::move_selection_right, 10            ],
'Move selected elements up quick'             => ['0A0-Up',                                 \&App::Asciio::Actions::ElementsManipulation::move_selection_up, 10               ],
'Move selected elements down quick'           => ['0A0-Down',                               \&App::Asciio::Actions::ElementsManipulation::move_selection_down, 10             ],

'Move selected elements left 2'               => [['000-h', 'h'],                           \&App::Asciio::Actions::ElementsManipulation::move_selection_left                 ],
'Move selected elements right 2'              => [['000-l', 'l'],                           \&App::Asciio::Actions::ElementsManipulation::move_selection_right                ],
'Move selected elements up 2'                 => [['000-k', 'k'],                           \&App::Asciio::Actions::ElementsManipulation::move_selection_up                   ],
'Move selected elements down 2'               => [['000-j', 'j'],                           \&App::Asciio::Actions::ElementsManipulation::move_selection_down                 ],

'Shrink box'                                  => ['000-s',                                  \&App::Asciio::Actions::ElementsManipulation::shrink_box                          ],

'Make element narrower'                       => ['000-1',                                  \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [-1, 0]      ],
'Make element taller'                         => ['000-2',                                  \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [0,  1]      ],
'Make element shorter'                        => ['000-3',                                  \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [0, -1]      ],
'Make element wider'                          => ['000-4',                                  \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [1,  0]      ],

# mouse
'Mouse right-click'                           => ['000-button-press-3',                     \&App::Asciio::Actions::Mouse::mouse_right_click                                  ],

'Mouse left-click'                            => ['000-button-press-1',                     \&App::Asciio::Actions::Mouse::mouse_left_click                                   ],
'Mouse expand selection'                      => ['00S-button-press-1',                     \&App::Asciio::Actions::Mouse::expand_selection                                   ],
'Mouse selection flip'                        => ['C00-button-press-1',                     \&App::Asciio::Actions::Mouse::mouse_element_selection_flip                       ],

'Mouse quick link'                            => [['0A0-button-press-1', '000-period'],     \&App::Asciio::Actions::Mouse::quick_link                                         ],
'Mouse quick link git'                        => [['0A0-button-press-3', '00S-semicolon'],  \&App::Asciio::Actions::Git::quick_link                                           ],
'Mouse duplicate elements'                    => [['0AS-button-press-1', '000-comma'],      \&App::Asciio::Actions::Mouse::mouse_duplicate_element                            ],

'Insert flex point'                           => ['CA0-button-press-1',                     \&App::Asciio::Actions::Multiwirl::insert_wirl_arrow_section                      ],

'Mouse motion'                                => ['000-motion_notify',                      \&App::Asciio::Actions::Mouse::mouse_motion                                       ], 
'Mouse motion 2'                              => ['0AS-motion_notify',                      \&App::Asciio::Actions::Mouse::mouse_motion                                       ],
'Mouse drag canvas'                           => ['C00-motion_notify',                      \&App::Asciio::Actions::Mouse::mouse_drag_canvas                                  ],         

# mouse emulation
'Mouse emulation toggle'                      => [['000-apostrophe', "'"],                  \&App::Asciio::Actions::Mouse::toggle_mouse                                       ],

'Mouse emulation left-click'                  => ['000-odiaeresis',                         \&App::Asciio::Actions::Mouse::mouse_left_click                                   ],
'Mouse emulation expand selection'            => ['00S-Odiaeresis',                         \&App::Asciio::Actions::Mouse::expand_selection                                   ],
'Mouse emulation selection flip'              => ['C00-odiaeresis',                         \&App::Asciio::Actions::Mouse::mouse_element_selection_flip                       ],

'Mouse emulation right-click'                 => ['000-adiaeresis',                         \&App::Asciio::Actions::Mouse::mouse_right_click                                  ],

'Mouse emulation move left'                   => ['C00-Left',                               \&App::Asciio::Actions::Mouse::mouse_move, [-1,  0]                               ],
'Mouse emulation move right'                  => ['C00-Right',                              \&App::Asciio::Actions::Mouse::mouse_move, [ 1,  0]                               ],
'Mouse emulation move up'                     => ['C00-Up',                                 \&App::Asciio::Actions::Mouse::mouse_move, [ 0, -1]                               ],
'Mouse emulation move down'                   => ['C00-Down',                               \&App::Asciio::Actions::Mouse::mouse_move, [ 0,  1]                               ],

'Mouse emulation drag left'                   => ['00S-Left',                               \&App::Asciio::Actions::Mouse::mouse_drag_left                                    ],
'Mouse emulation drag right'                  => ['00S-Right',                              \&App::Asciio::Actions::Mouse::mouse_drag_right                                   ],
'Mouse emulation drag up'                     => ['00S-Up',                                 \&App::Asciio::Actions::Mouse::mouse_drag_up                                      ],
'Mouse emulation drag down'                   => ['00S-Down',                               \&App::Asciio::Actions::Mouse::mouse_drag_down                                    ],

'Mouse on element id'                         => ['000-m',                                  \&App::Asciio::Actions::Mouse::mouse_on_element_id                                ],

# context menus 
'Box context_menu'                            => ['bo_context_menu', undef, undef,          \&App::Asciio::Actions::Box::box_context_menu                                     ],
'Multi_wirl context_menu'                     => ['mw_context_menu', undef, undef,          \&App::Asciio::Actions::Multiwirl::multi_wirl_context_menu                        ],
'Angled arrow context_menu'                   => ['aa_ontext menu',  undef, undef,          \&App::Asciio::Actions::Multiwirl::angled_arrow_context_menu                      ],
'Ruler context_menu'                          => ['ru_context_menu', undef, undef,          \&App::Asciio::Actions::Ruler::rulers_context_menu                                ],

'grouping leader' => 
	{
	SHORTCUTS => '000-g',
	
	'Group selected elements'             => ['000-g', \&App::Asciio::Actions::ElementsManipulation::group_selected_elements                 ],
	'Ungroup selected elements'           => ['000-u', \&App::Asciio::Actions::ElementsManipulation::ungroup_selected_elements               ],
	'Move selected elements to the front' => ['000-f', \&App::Asciio::Actions::ElementsManipulation::move_selected_elements_to_front         ],
	'Move selected elements to the back'  => ['000-b', \&App::Asciio::Actions::ElementsManipulation::move_selected_elements_to_back          ],
	'Temporary move to the front'         => ['00S-F', \&App::Asciio::Actions::ElementsManipulation::temporary_move_selected_element_to_front],
	'Make Unicode             '           => ['00S-U', \&App::Asciio::Actions::Elements::make_unicode                                        ],
	'Make Ascii default'                  => ['00S-A', \&App::Asciio::Actions::Elements::make_ascii                                          ],
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
	
	'Align left'                          => ['000-l', \&App::Asciio::Actions::Align::align, 'left'  ],
	'Align center'                        => ['000-c', \&App::Asciio::Actions::Align::align, 'center'],
	'Align right'                         => ['000-r', \&App::Asciio::Actions::Align::align, 'right' ],
	'Align top'                           => ['000-t', \&App::Asciio::Actions::Align::align, 'top'   ],
	'Align middle'                        => ['000-m', \&App::Asciio::Actions::Align::align, 'middle'],
	'Align bottom'                        => ['000-b', \&App::Asciio::Actions::Align::align, 'bottom'],
	# spread vertically	# spread horizontally # adjacent vert # adjacent hor # stack
	},

'change color/font leader'=> 
	{
	SHORTCUTS => '000-z',
	
	'Change Asciio background color'      => ['000-c', \&App::Asciio::Actions::Colors::change_background_color ],
	'Change grid color'                   => ['000-C', \&App::Asciio::Actions::Colors::change_grid_color       ],
	'Flip color scheme'                   => ['000-s', \&App::Asciio::Actions::Colors::flip_color_scheme       ],
	'Flip transparent element background' => ['000-t', \&App::Asciio::Actions::Unsorted::transparent_elements  ],
	'Flip grid display'                   => ['000-g', \&App::Asciio::Actions::Unsorted::flip_grid_display     ],
	'Change font'                         => ['000-f', \&App::Asciio::Actions::Unsorted::change_font           ],
	'Edit inline'                         => ['000-i', \&App::Asciio::GTK::Asciio::switch_gtk_popup_box_type,  ], 
	},

'arrow leader' => 
	{
	SHORTCUTS => '000-a',
	
	'Change arrow direction'              => ['000-d', \&App::Asciio::Actions::ElementsManipulation::change_arrow_direction           ],
	'Flip arrow start and end'            => ['000-f', \&App::Asciio::Actions::ElementsManipulation::flip_arrow_ends                  ],
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
	'Add multiple boxes'                  => ['C00-b', \&App::Asciio::Actions::Unsorted::insert_multiple_boxes_from_text_description, 1      ],
	'Add unicode box'                     => ['0A0-b', \&App::Asciio::Actions::Elements::add_element, ['Asciio/box unicode', 0]              ],
	'Add shrink box'                      => ['00S-B', \&App::Asciio::Actions::Elements::add_element, ['Asciio/shrink_box', 1]               ],

	'Add exec box'                        => ['000-e', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/exec', 1]               ],
	'Add exec box verbatim'               => ['000-v', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/exec verbatim', 1]      ],
	'Add exec box verbatim once'          => ['000-o', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/exec verbatim once', 1] ],
	'Add line numbered box'               => ['C00-l', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/exec add lines', 1]     ],
	
	'Add text'                            => ['000-t', \&App::Asciio::Actions::Elements::add_element, ['Asciio/text', 1]                     ],
	'Add multiple texts'                  => ['C00-t', \&App::Asciio::Actions::Unsorted::insert_multiple_boxes_from_text_description, 0      ],
	
	'Add arrow'                           => ['000-a', \&App::Asciio::Actions::Elements::add_element, ['Asciio/wirl_arrow', 0]               ],
	'Add unicode arrow'                   => ['0A0-a', \&App::Asciio::Actions::Elements::add_element, ['Asciio/wirl_arrow unicode', 0]       ],
	'Add angled arrow'                    => ['00S-A', \&App::Asciio::Actions::Elements::add_element, ['Asciio/angled_arrow', 0]             ],
	'Add unicode angled arrow'            => ['C00-a', \&App::Asciio::Actions::Elements::add_element, ['Asciio/angled_arrow unicode', 0]     ],
	
	'Add connector'                       => ['000-c', \&App::Asciio::Actions::Elements::add_element, ['Asciio/connector', 0]                ],
	'Add connector type 2'                => ['00S-C', \&App::Asciio::Actions::Elements::add_element, ['Asciio/connector2', 0]               ],
	'Add vertical ruler'                  => ['000-r', \&App::Asciio::Actions::Ruler::add_ruler,      {TYPE => 'VERTICAL'}                   ],
	'Add horizontal ruler'                => ['00S-R', \&App::Asciio::Actions::Ruler::add_ruler,      {TYPE => 'HORIZONTAL'}                 ],
	'Add if'                              => ['000-i', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/if', 1]                 ],
	'Add process'                         => ['000-p', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/process', 1]            ],
	'Add rhombus'                         => ['C00-r', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Shape/rhombus', 0]            ],
	'Add ellipse'                         => ['C00-e', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Shape/ellipse', 0]            ],
	
	'Add help box'                        => ['000-h', \&App::Asciio::Actions::Elements::add_help_box,                                       ],
	'Add ascii line'                      => ['000-w', \&App::Asciio::Actions::Elements::create_line, [0, 0]                                 ], 
	'Add unicode line'                    => ['00S-W', \&App::Asciio::Actions::Elements::create_line, [1, 0]                                 ],
	'Add unicode bold line'               => ['C00-w', \&App::Asciio::Actions::Elements::create_line, [2, 0]                                 ],
	'Add unicode double line'             => ['0A0-w', \&App::Asciio::Actions::Elements::create_line, [3, 0]                                 ],
	},

'Cross element Insert leader' => 
	{
	SHORTCUTS => '000-x',
	
	'Add cross box'                       => ['000-b', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Cross/box', 0]                 ],
	'Add cross exec box'                  => ['000-e', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Cross/exec box', 1]            ],
	'Add cross arrow'                     => ['000-a', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Cross/wirl_arrow', 0]          ],
	'Add cross angled arrow'              => ['00S-A', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Cross/angled_arrow', 0]        ],
	
	'add cross ascii line'                => ['000-w', \&App::Asciio::Actions::Elements::create_line, [0, 1]                                  ], 
	'add cross unicode line'              => ['00S-W', \&App::Asciio::Actions::Elements::create_line, [1, 1]                                  ],
	'Add cross unicode bold line'         => ['C00-w', \&App::Asciio::Actions::Elements::create_line, [2, 1]                                  ],
	'Add cross unicode double line'       => ['0A0-w', \&App::Asciio::Actions::Elements::create_line, [3, 1]                                  ],
	
	'Select cross elements'               => ['000-c', \&App::Asciio::Actions::ElementsManipulation::select_cross_elements_from_selected_elements               ],
	'Select cross fillers'                => ['000-f', \&App::Asciio::Actions::ElementsManipulation::select_cross_filler_elements_from_selected_elements        ],
	'Select normal elements'              => ['000-n', \&App::Asciio::Actions::ElementsManipulation::select_normal_elements_from_selected_elements              ],
	'Select normal fillers'               => ['0A0-f', \&App::Asciio::Actions::ElementsManipulation::select_normal_filler_elements_from_selected_elements       ],
	
	'change to cross elements'            => ['C00-c', \&App::Asciio::Actions::ElementsManipulation::switch_to_cross_elements_from_selected_elements            ],
	'change to normal elements'           => ['C00-n', \&App::Asciio::Actions::ElementsManipulation::switch_to_normal_elements_from_selected_elements           ],
	},

'slides leader' => 
	{
	SHORTCUTS => '00S-S',
	
	'Load slides'                         => ['000-l', \&App::Asciio::Actions::Presentation::load_slides   ] ,
	'previous slide'                      => ['00S-N', \&App::Asciio::Actions::Presentation::previous_slide],
	'next slide'                          => ['000-n', \&App::Asciio::Actions::Presentation::next_slide    ],
	'first slide'                         => ['000-g', \&App::Asciio::Actions::Presentation::first_slide   ],
	},
) ;

#----------------------------------------------------------------------------------------------

