
register_action_handlers
(

PROXY_GROUP
	(
	{ SHORTCUTS => '00S-question', NAME => 'help', DESCRIPTION => 'Root groups' } ,
	
	'commands ->'       ,
	' '                 ,
	'Insert ->'         ,
	'element ->'        ,
	'clone ->'          ,
	'arrow ->'          ,
	'move arrow ends ->',
	'graph selection ->',
	'selection ->'      ,
	'yank ->'           ,
	'paste ->'          ,
	'align ->'          ,
	'grouping ->'       ,
	'find ->'       ,
	'stripes ->'        ,
	' '                 ,
	'debug ->'          ,
	'display options ->',
	'slides ->'         ,
	'git ->'            ,
	'pen ->'            ,
	'find ->'           ,
	),

PROXY_GROUP
	(
	# bindings will not be shown
	{ SHORTCUTS => '000-space', NAME => 'leader', DESCRIPTION => 'Shortcuts to bindings', HIDE => 1} ,
	
	# will use 'Add box' shortcut (b), instead of typing i + i + b, we can type 'space' + b
	'Add box',
	
	# you can override the  shortcut too, note that we now have 3 bindings to 'add box', i + b +b, space + b, space + space 
	['Add box' => '000-space'],
	['find and run animation' => '000-space'],
	
	# we can run macros using their shortcut
	'Add diagonal arrow',
	
	['take snapshot' => '000-s'],
	),

ROOT_GROUP
	(
	{ NAME => 'edit', DESCRIPTION => 'Edit elements'},
	
	'Edit selected element'        => [['000-2button-press-1','000-Return'], \&App::Asciio::Actions::ElementsManipulation::edit_selected_element, 0],
	'Edit selected element inline' => [['C00-2button-press-1','0A0-Return'], \&App::Asciio::Actions::ElementsManipulation::edit_selected_element, 1],
	'Delete selected elements'     => [['000-Delete', '000-d'],              \&App::Asciio::Actions::ElementsManipulation::delete_selected_elements],
	'Undo'                         => [['C00-z', '000-u'],                   \&App::Asciio::Actions::Unsorted::undo                                ],
	'Redo'                         => [['C00-y', 'C00-r'],                   \&App::Asciio::Actions::Unsorted::redo                                ],
	),

ROOT_GROUP
	(
	{ NAME => 'clipboard', DESCRIPTION => 'Clipboard functions' },
	
	'Copy to clipboard'     => [['C00-c', 'C00-Insert'], \&App::Asciio::Actions::Clipboard::export_elements_to_system_clipboard  ],
	'Insert from clipboard' => [['C00-v', '00S-Insert'], \&App::Asciio::Actions::Clipboard::import_elements_from_system_clipboard],
	),

ROOT_GROUP
	(
	{ NAME => 'zoom', DESCRIPTION => 'Zoom functions'},
	
	'Zoom in'      => [['000-plus', 'C00-j', 'C00-scroll-up'],    \&App::Asciio::Actions::Unsorted::zoom, 1     ],
	'Zoom out'     => [['000-minus', 'C00-h', 'C00-scroll-down'], \&App::Asciio::Actions::Unsorted::zoom, -1    ],
	'Zoom extents' => ['C00-minus',                               \&App::Asciio::Actions::Unsorted::zoom_extents],
	),

ROOT_GROUP
	(
	{ NAME => 'find', DESCRIPTION => 'Search and replace function'},
	
	'find clear'    => ['C00-l',        \&App::Asciio::Actions::FindAndReplace::clear     ],
	'find search'   => ['00S-asterisk', \&App::Asciio::Actions::FindAndReplace::new_search],
	'find next'     => ['000-n',        \&App::Asciio::Actions::FindAndReplace::next      ],
	'find previous' => ['00S-N',        \&App::Asciio::Actions::FindAndReplace::previous  ],
	),

ROOT_GROUP
	(
	{ NAME => 'element_selection', DESCRIPTION => 'Selection functions'},
	
	'Deselect all elements'            => ['000-Escape',       \&App::Asciio::Actions::ElementSelection::deselect_all_elements                ],
	'Mouse selection flip'             => ['00S-button-press-1',                 \&App::Asciio::Actions::Mouse::mouse_element_selection_flip  ],
	
	'Select next element'              => ['000-Tab',          \&App::Asciio::Actions::ElementSelection::select_element_direction, [1, 0, 0]  ],
	'Select previous element'          => ['00S-ISO_Left_Tab', \&App::Asciio::Actions::ElementSelection::select_element_direction, [0, 0, 0]  ],
	'Select next arrow'                => ['000-m',            \&App::Asciio::Actions::ElementSelection::select_element_direction, [1, 0, 2]  ],
	'Select previous arrow'            => ['00S-M',            \&App::Asciio::Actions::ElementSelection::select_element_direction, [0, 0, 2]  ],
	# 'Select next non arrow'            => ['000-n',            \&App::Asciio::Actions::ElementSelection::select_element_direction, [1, 0, 1]  ],
	# 'Select previous non arrow'        => ['00S-N',            \&App::Asciio::Actions::ElementSelection::select_element_direction, [0, 0, 1]  ],
	'Select all elements'              => [['C00-a', '00S-V'], \&App::Asciio::Actions::ElementSelection::select_all_elements                  ],
	'Select elements by word'          => ['C00-f',            \&App::Asciio::Actions::ElementSelection::select_all_elements_by_words         ],
	'Select elements by word no group' => ['C0S-F',            \&App::Asciio::Actions::ElementSelection::select_all_elements_by_words_no_group],
	
	),

ROOT_GROUP
	(
	{ NAME => 'movements', DESCRIPTION => 'Move elements functions'},
	
	'Move selected elements left'        => ['000-Left',  \&App::Asciio::Actions::ElementsManipulation::move_selection_left           ],
	'Move selected elements right'       => ['000-Right', \&App::Asciio::Actions::ElementsManipulation::move_selection_right          ],
	'Move selected elements up'          => ['000-Up',    \&App::Asciio::Actions::ElementsManipulation::move_selection_up             ],
	'Move selected elements down'        => ['000-Down',  \&App::Asciio::Actions::ElementsManipulation::move_selection_down           ],
	
	'Move selected elements left quick'  => ['0A0-Left',  \&App::Asciio::Actions::ElementsManipulation::move_selection_left, 10       ],
	'Move selected elements right quick' => ['0A0-Right', \&App::Asciio::Actions::ElementsManipulation::move_selection_right, 10      ],
	'Move selected elements up quick'    => ['0A0-Up',    \&App::Asciio::Actions::ElementsManipulation::move_selection_up, 10         ],
	'Move selected elements down quick'  => ['0A0-Down',  \&App::Asciio::Actions::ElementsManipulation::move_selection_down, 10       ],
	
	'Move selected elements left 2'      => ['000-h',     \&App::Asciio::Actions::ElementsManipulation::move_selection_left           ],
	'Move selected elements right 2'     => ['000-l',     \&App::Asciio::Actions::ElementsManipulation::move_selection_right          ],
	'Move selected elements up 2'        => ['000-k',     \&App::Asciio::Actions::ElementsManipulation::move_selection_up             ],
	'Move selected elements down 2'      => ['000-j',     \&App::Asciio::Actions::ElementsManipulation::move_selection_down           ],
	
	'Make element narrower'              => ['000-1',     \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [-1, 0]],
	'Make element taller'                => ['000-2',     \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [0,  1]],
	'Make element shorter'               => ['000-3',     \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [0, -1]],
	'Make element wider'                 => ['000-4',     \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [1,  0]],
	),

ROOT_GROUP
	(
	{ NAME => 'mouse', DESCRIPTION => 'Mouse event handler'},
	
	'Mouse right-click'            => ['000-button-press-3',                 \&App::Asciio::Actions::Mouse::mouse_right_click                        ],
	
	'Mouse left-click'             => ['000-button-press-1',                 \&App::Asciio::Actions::Mouse::mouse_left_click                         ],
	'Start Drag and Drop'          => ['C00-button-press-1',                 sub { $_[0]->{ IN_DRAG_DROP} = 1 ; }                                    ],
	
	'Mouse left-release'           => ['000-button-release-1',               \&App::Asciio::Actions::Mouse::mouse_left_release                       ],
	'Mouse left-release2'          => ['C00-button-release-1',               \&App::Asciio::Actions::Mouse::mouse_left_release                       ],
	'Mouse left-release3'          => ['00S-button-release-1',               \&App::Asciio::Actions::Mouse::mouse_left_release                       ],
	'Mouse left-release4'          => ['C0S-button-release-1',               \&App::Asciio::Actions::Mouse::mouse_left_release                       ],
	
	),

ROOT_GROUP
	(
	{ NAME => 'mouse motion', DESCRIPTION => 'Mouse motion events'},
	
	'Mouse motion'                 => ['000-motion_notify',                  \&App::Asciio::Actions::Mouse::mouse_motion, undef, { HIDE => 1}        ],
	'Mouse motion 2'               => ['0AS-motion_notify',                  \&App::Asciio::Actions::Mouse::mouse_motion, undef, { HIDE => 1}        ],
	'Mouse drag canvas'            => ['C00-motion_notify',                  \&App::Asciio::Actions::Mouse::mouse_drag_canvas                        ],
	),

ROOT_GROUP
	(
	{ NAME => 'mouse emulation', DESCRIPTION => 'Move mouse with keyboard'},
	
	'Mouse emulation toggle'           => [['000-apostrophe', "'"], \&App::Asciio::Actions::Mouse::toggle_mouse                ],
	
	'Mouse emulation left-click'       => ['000-odiaeresis',        \&App::Asciio::Actions::Mouse::mouse_left_click            ],
	'Mouse emulation expand selection' => ['00S-Odiaeresis',        \&App::Asciio::Actions::Mouse::expand_selection            ],
	'Mouse emulation selection flip'   => ['C00-odiaeresis',        \&App::Asciio::Actions::Mouse::mouse_element_selection_flip],
	
	'Mouse emulation right-click'      => ['000-adiaeresis',        \&App::Asciio::Actions::Mouse::mouse_right_click           ],
	
	'Mouse emulation move left'        => ['C00-Left',              \&App::Asciio::Actions::Mouse::mouse_move, [-1,  0]        ],
	'Mouse emulation move right'       => ['C00-Right',             \&App::Asciio::Actions::Mouse::mouse_move, [ 1,  0]        ],
	'Mouse emulation move up'          => ['C00-Up',                \&App::Asciio::Actions::Mouse::mouse_move, [ 0, -1]        ],
	'Mouse emulation move down'        => ['C00-Down',              \&App::Asciio::Actions::Mouse::mouse_move, [ 0,  1]        ],
	
	'Mouse emulation drag left'        => ['00S-Left',              \&App::Asciio::Actions::Mouse::mouse_drag_left             ],
	'Mouse emulation drag right'       => ['00S-Right',             \&App::Asciio::Actions::Mouse::mouse_drag_right            ],
	'Mouse emulation drag up'          => ['00S-Up',                \&App::Asciio::Actions::Mouse::mouse_drag_up               ],
	'Mouse emulation drag down'        => ['00S-Down',              \&App::Asciio::Actions::Mouse::mouse_drag_down             ],
	
	#'Mouse on element id'              => ['',               \&App::Asciio::Actions::Mouse::mouse_on_element_id         ],
	),

ROOT_GROUP
	(
	{ NAME => 'Working efficiently', DESCRIPTION => 'Bindings to quickly create a diagram'},
	
	'Mouse quick link orthogonal'  => [['0AS-button-press-1'],               \&App::Asciio::Actions::Mouse::quick_link, 1                            ],
	'Mouse quick link'             => [['0A0-button-press-1', '000-period'], \&App::Asciio::Actions::Mouse::quick_link                               ],
	'Mouse duplicate elements'     => [[                      '000-comma'],  \&App::Asciio::Actions::Mouse::mouse_duplicate_element                  ],
	'Mouse quick box'              => [['C0S-button-press-1'],               \&App::Asciio::Actions::Elements::add_element, ['Asciio/box', 0]        ],
	
	'Arrow to mouse'               => ['CA0-motion_notify',                  \&App::Asciio::Actions::Arrow::interactive_to_mouse, undef, { HIDE => 1}],
	'Arrow mouse change direction' => ['CA0-2button-press-1',                \&App::Asciio::Actions::Arrow::change_arrow_direction                   ],
	'Arrow change direction'       => ['CA0-d',                              \&App::Asciio::Actions::Arrow::interactive_change_arrow_direction       ],
	'Wirl arrow add section'       => ['CA0-button-press-1',                 \&App::Asciio::Actions::Multiwirl::interactive_add_section              ],
	'Wirl arrow insert flex point' => ['CA0-button-press-2',                 \&App::Asciio::Actions::Multiwirl::insert_wirl_arrow_section            ],
	),

'commands ->' => GROUP
	(
	SHORTCUTS   => '00S-colon',
	DESCRIPTION => 'Application bindings',
	
	'Open'                     => ['000-e', \&App::Asciio::Actions::File::open                                   ],
	'Save'                     => ['000-w', \&App::Asciio::Actions::File::save, undef                            ],
	'SaveAs'                   => ['00S-W', \&App::Asciio::Actions::File::save, 'as'                             ],
	'Insert'                   => ['000-r', \&App::Asciio::Actions::File::insert                                 ],
	'Quit'                     => ['000-q', \&App::Asciio::Actions::File::quit                                   ],
	'Quit no save'             => ['00S-Q', \&App::Asciio::Actions::File::quit_no_save                           ],
	
	'Run external script'      => ['00S-exclam', \&App::Asciio::Utils::Scripting::run_external_script            ],
	
	'Help'                     => ['000-h', \&App::Asciio::Actions::Unsorted::display_help                       ],
	'Add help box'             => ['00S-H', \&App::Asciio::Actions::Elements::add_help_box,                      ],
	
	'Display keyboard mapping' => ['000-k', \&App::Asciio::Actions::Unsorted::display_keyboard_mapping_in_browser],
	'Display commands'         => ['000-c', \&App::Asciio::Actions::Unsorted::display_commands                   ],
	'Display action files'     => ['000-f', \&App::Asciio::Actions::Unsorted::display_action_files               ],
	'Display manpage'          => ['000-m', \&App::Asciio::Actions::Unsorted::manpage_in_browser                 ],
	),

'tabs ->' => GROUP
	(
	SHORTCUTS   => '000-t',
	DESCRIPTION => 'Create and manipulate tabs',
	
	'clone tab'              => ['000-c',      \ &App::Asciio::Actions::Tabs::copy_tab, 1           ],
	'new tab'                => ['000-n',      \ &App::Asciio::Actions::Tabs::new_tab               ],
	'next tab'               => ['000-t',      \ &App::Asciio::Actions::Tabs::next_tab              ],
	'previous tab'           => ['00S-T',      \ &App::Asciio::Actions::Tabs::previous_tab          ],
	'move tab left'          => ['000-h',      \ &App::Asciio::Actions::Tabs::move_tab_left         ],
	'move tab right'         => ['000-l',      \ &App::Asciio::Actions::Tabs::move_tab_right        ],
	'close tab'              => ['000-x',      \ &App::Asciio::Actions::Tabs::close_tab             ],
	'close tab no save'      => ['00S-X',      \ &App::Asciio::Actions::Tabs::close_tab_no_save     ],
	'rename'                 => ['000-r',      \ &App::Asciio::Actions::Tabs::rename_tab            ],
	'toggle tab labels'      => ['00S-L',      \ &App::Asciio::Actions::Tabs::toggle_tab_labels     ],
	'hide all bindings help' => ['00S-H',      \ &App::Asciio::Actions::Tabs::hide_all_bindings_help],
	'show all bindings help' => ['00S-S',      \ &App::Asciio::Actions::Tabs::show_all_bindings_help],
	'open project'           => ['000-e',      \ &App::Asciio::Actions::Tabs::open_project          ],
	'read'                   => ['00S-R',      \ &App::Asciio::Actions::Tabs::read, undef           ],
	'save'                   => ['000-w',      \ &App::Asciio::Actions::Tabs::save_project, undef   ],
	'save as'                => ['00S-W',      \ &App::Asciio::Actions::Tabs::save_project, ''      ],
	'quit app'               => ['000-q',      \ &App::Asciio::Actions::Tabs::quit_app              ],
	'quit app no save'       => ['00S-Q',      \ &App::Asciio::Actions::Tabs::quit_app_no_save      ],
	
	'last tab'               => ['000-dollar', \ &App::Asciio::Actions::Tabs::last_tab, undef, { HIDE => 1 } ],
	map { ("tab $_"          => ["000-$_",     \ &App::Asciio::Actions::Tabs::focus_tab, $_, {  HIDE  => 1 } ] ) } (0..9),
	),

'yank ->' => GROUP
	(
	SHORTCUTS   => '000-y',
	DESCRIPTION => 'Yank elements to the clipboard',
	
	'Copy to clipboard'                      => ['000-y', \&App::Asciio::Actions::Clipboard::export_elements_to_system_clipboard],
	'Export to clipboard & primary as ascii' => ['00S-Y', \&App::Asciio::Actions::Clipboard::export_to_clipboard_as_ascii       ],
	'Export to clipboard & primary as markup'=> ['000-m', \&App::Asciio::Actions::Clipboard::export_to_clipboard_as_markup      ],
	),

'paste ->' => GROUP
	(
	SHORTCUTS   => '000-p',
	DESCRIPTION => 'Paste elements from the clipboard',
	
	'Insert from clipboard'         => ['000-p', \&App::Asciio::Actions::Clipboard::import_elements_from_system_clipboard],
	'Import from primary to box'    => ['00S-P', \&App::Asciio::Actions::Clipboard::import_from_primary_to_box           ],
	'Import from primary to text'   => ['0A0-p', \&App::Asciio::Actions::Clipboard::import_from_primary_to_text          ],
	'Import from clipboard to box'  => ['000-b', \&App::Asciio::Actions::Clipboard::import_from_clipboard_to_box         ],
	'Import from clipboard to text' => ['000-t', \&App::Asciio::Actions::Clipboard::import_from_clipboard_to_text        ],
	),

'selection ->' => GROUP
	(
	SHORTCUTS    => '000-s',
	DESCRIPTION  => 'Selection modes',
	ENTER_GROUP  => \&App::Asciio::Actions::Selection::selection_enter,
	ESCAPE_KEYS  => ['000-s', '000-Escape'],
	ESCAPE_GROUP => \&App::Asciio::Actions::Selection::selection_escape, 
	
	'select flip mode'     => ['000-e',             \&App::Asciio::Actions::Selection::selection_mode_flip                ],
	'select motion'        => ['000-motion_notify', \&App::Asciio::Actions::Selection::select_motion, undef, { HIDE => 1 }],
	'select mouse click'   => ['000-button-press-1',\&App::Asciio::Actions::Selection::select_elements                    ],
	
	'polygon selection ->' => ['000-x', USE_GROUP('polygon')] ,
	),
	
	'polygon' => GROUP
		(
		SHORTCUTS    => 'polygon',
		DESCRIPTION  => 'Plygon selection mode',
		ENTER_GROUP  => \&App::Asciio::GTK::Asciio::polygon_selection_enter,
		ESCAPE_KEYS  => ['000-x', '000-Escape'],
		ESCAPE_GROUP => \&App::Asciio::GTK::Asciio::polygon_selection_escape, 
		
		'Polygon select motion'         => ['000-motion_notify',   \&App::Asciio::GTK::Asciio::polygon_selection_motion, 1, { HIDE => 1 }],
		'Polygon deselect motion'       => ['C00-motion_notify',   \&App::Asciio::GTK::Asciio::polygon_selection_motion, 0, { HIDE => 1 }],
		'Polygon select left-release'   => ['000-button-release-1',\&App::Asciio::GTK::Asciio::polygon_selection_button_release          ],
		'Polygon select left-release 2' => ['C00-button-release-1',\&App::Asciio::GTK::Asciio::polygon_selection_button_release          ],
		),

'graph selection ->' => GROUP
	(
	SHORTCUTS   => '00S-S',
	DESCRIPTION => 'Select elements in the elements graph',
	
	'Select all connected' => ['000-c', \&App::Asciio::Actions::ElementSelection::select_all_connected] ,
	'Select neighbors'     => ['000-n', \&App::Asciio::Actions::ElementSelection::select_neighbors    ] ,
	'Select predecessors'  => ['000-p', \&App::Asciio::Actions::ElementSelection::select_predecessors ] ,
	'Select ancestors'     => ['000-a', \&App::Asciio::Actions::ElementSelection::select_ancestors    ] ,
	'Select reachable'     => ['000-r', \&App::Asciio::Actions::ElementSelection::select_reachable    ] ,
	'Select successors'    => ['000-s', \&App::Asciio::Actions::ElementSelection::select_successors   ] ,
	'Select decendants'    => ['000-d', \&App::Asciio::Actions::ElementSelection::select_descendants  ] ,
	),

'clone ->' => GROUP
	(
	SHORTCUTS    => '000-c',
	DESCRIPTION  => 'Cloning and stamping',
	ENTER_GROUP  => \&App::Asciio::Actions::Clone::clone_enter,
	ESCAPE_KEYS  => '000-Escape',
	ESCAPE_GROUP => \&App::Asciio::Actions::Clone::clone_escape, 
	
	'clone motion'          => ['000-motion_notify',    \&App::Asciio::Actions::Clone::clone_mouse_motion, undef, { HIDE => 1 }     ], 
	'clone release'         => ['000-button-release-1', \&App::Asciio::Actions::Clone::clone_mouse_motion, undef, { HIDE => 1 }     ], 
	
	'clone insert'          => ['000-button-press-1',   \&App::Asciio::Actions::Clone::clone_add_element                            ],
	'clone insert2'         => ['000-Return',           \&App::Asciio::Actions::Clone::clone_add_element                            ],
	'clone arrow'           => ['000-a',                \&App::Asciio::Actions::Clone::clone_set_overlay, ['Asciio/wirl_arrow',   0]],
	'clone angled arrow'    => ['00S-A',                \&App::Asciio::Actions::Clone::clone_set_overlay, ['Asciio/angled_arrow', 0]],
	'clone box'             => ['000-b',                \&App::Asciio::Actions::Clone::clone_set_overlay, ['Asciio/box',  0]        ],
	'clone text'            => ['000-t',                \&App::Asciio::Actions::Clone::clone_set_overlay, ['Asciio/text', 0]        ],
	'clone flip hint lines' => ['000-h',                \&App::Asciio::Actions::Unsorted::flip_hint_lines                           ],
	'clone left'            => ['000-Left',             \&App::Asciio::Actions::ElementsManipulation::move_selection_left           ],
	'clone right'           => ['000-Right',            \&App::Asciio::Actions::ElementsManipulation::move_selection_right          ],
	'clone up'              => ['000-Up',               \&App::Asciio::Actions::ElementsManipulation::move_selection_up             ],
	'clone down'            => ['000-Down',             \&App::Asciio::Actions::ElementsManipulation::move_selection_down           ],
	
	'clone emulation left'  => ['C00-Left',             \&App::Asciio::Actions::Mouse::mouse_move, [-1,  0]                         ],
	'clone emulation right' => ['C00-Right',            \&App::Asciio::Actions::Mouse::mouse_move, [ 1,  0]                         ],
	'clone emulation up'    => ['C00-Up',               \&App::Asciio::Actions::Mouse::mouse_move, [ 0, -1]                         ],
	'clone emulation down'  => ['C00-Down',             \&App::Asciio::Actions::Mouse::mouse_move, [ 0,  1]                         ],
	),

'Insert ->' => GROUP
	(
	SHORTCUTS   => '000-i',
	DESCRIPTION => 'Insert asciio elements',
	
	'Box ->'             => ['000-b', USE_GROUP('insert_box')                                                  ],
	'Add text'           => ['000-t', \&App::Asciio::Actions::Elements::add_element, ['Asciio/text', 1]        ],
	'Add arrow'          => ['000-a', \&App::Asciio::Actions::Elements::add_element, ['Asciio/wirl_arrow', 0]  ],
	'Add angled arrow'   => ['00S-A', \&App::Asciio::Actions::Elements::add_element, ['Asciio/angled arrow', 0]],
	'Add diagonal arrow' =>
				[
				'0A0-a',
				MACRO
					(
					'Add arrow',
					'enable diagonals',
					# you can also call actions directly
					# [\&App::Asciio::Actions::Arrow::allow_diagonals, 1],
					)
				],
	'Add connector'      => ['000-c', \&App::Asciio::Actions::Elements::add_element, ['Asciio/connector', 0]],
	
	'Add pointer'        => [
				'000-p', 
				MACRO
					(
					[\&App::Asciio::Actions::Elements::add_element, ['🡴', 0 ]                       ],
					[\&App::Asciio::Actions::Elements::flip_autoconnect                             ],
					[\&App::Asciio::Actions::Elements::set_id, 'pointer'                            ],
					[\&App::Asciio::Actions::Colors::change_elements_colors, [0, [0.80, 0.10, 1.00]]],
					),
				],

	'Unicode ->'         => ['000-u', USE_GROUP('insert_unicode')  ] ,
	'Multiple ->'        => ['000-m', USE_GROUP('insert_multiple') ] ,
	'Connected ->'       => ['000-k', USE_GROUP('insert_connected')] ,
	'Stencil ->'         => ['000-s', USE_GROUP('insert_stencil')  ] ,
	'Elements ->'        => ['000-e', USE_GROUP('insert_element')  ] ,
	'Ruler ->'           => ['000-r', USE_GROUP('insert_ruler')    ] ,
	'Line ->'            => ['000-l', USE_GROUP('insert_line')     ] ,
	),
	
	'insert_stencil' => GROUP
		(
		SHORTCUTS   => 'insert_stencil',
		DESCRIPTION => 'Insert elements from stencils',
		
		'From user stencils'   => ['000-s', \&App::Asciio::Actions::Elements::open_user_stencil                     ], 
		'From default_stencil' => ['000-d', \&App::Asciio::Actions::Elements::open_stencil, 'default_stencil.asciio'], 
		'From any stencil'     => ['000-a', \&App::Asciio::Actions::Elements::open_stencil                          ], 
		
		'From user elements'   => ['000-0', \&App::Asciio::Actions::Elements::open_user_stencil, 'elements.asciio'  ], 
		'From user computer'   => ['000-1', \&App::Asciio::Actions::Elements::open_user_stencil, 'computer.asciio'  ], 
		'From user people'     => ['000-2', \&App::Asciio::Actions::Elements::open_user_stencil, 'people.asciio'    ], 
		'From user buildings'  => ['000-3', \&App::Asciio::Actions::Elements::open_user_stencil, 'buildings.asciio' ], 
		),
	
	'insert_multiple' => GROUP
		(
		SHORTCUTS   => 'insert_multiple',
		DESCRIPTION => 'Insert multilpe elements at once',
		
		'Add multiple boxes'           => ['000-b', \&App::Asciio::Actions::Elements::add_multiple_elements, 'Asciio/box' ],
		'Add multiple box connected'   => ['00S-B', \&App::Asciio::Actions::Elements::add_multiple_element_connected, ['Asciio/box',  1]],
		'Add multiple texts'           => ['000-t', \&App::Asciio::Actions::Elements::add_multiple_elements, 'Asciio/text'],
		'Add multiple texts connected' => ['00S-T', \&App::Asciio::Actions::Elements::add_multiple_element_connected, ['Asciio/text', 1]],
		),
	
	'insert_ruler' => GROUP
		(
		SHORTCUTS   => 'insert_ruler',
		DESCRIPTION => 'Insert rules in the canvas',
		
		'Add vertical ruler'   => ['000-v', \&App::Asciio::Actions::Ruler::add_ruler, {TYPE => 'VERTICAL'}  ],
		'Add horizontal ruler' => ['000-h', \&App::Asciio::Actions::Ruler::add_ruler, {TYPE => 'HORIZONTAL'}],
		'delete rulers'        => ['000-d', \&App::Asciio::Actions::Ruler::remove_ruler                     ],
		),
	
	'insert_line' => GROUP
		(
		SHORTCUTS   => 'insert_line',
		DESCRIPTION => 'Insert line elements',
		
		'Add ascii line'            => ['000-l', \&App::Asciio::Actions::Elements::add_line, 0               ], 
		'Add ascii no-connect line' => ['000-k', \&App::Asciio::Actions::Elements::add_non_connecting_line, 0], 
		),
	
	'insert_connected' => GROUP
		(
		SHORTCUTS   => 'insert_connected',
		DESCRIPTION => 'Insert element and connect them automatically',
		
		'Add box connected'            => ['000-b', \&App::Asciio::Actions::Elements::add_element_connected,          ['Asciio/box',  1]], 
		'Add multiple box connected'   => ['00S-B', \&App::Asciio::Actions::Elements::add_multiple_element_connected, ['Asciio/box',  1]], 
		'Add text connected'           => ['000-t', \&App::Asciio::Actions::Elements::add_element_connected,          ['Asciio/text', 1]], 
		'Add multiple texts connected' => ['00S-T', \&App::Asciio::Actions::Elements::add_multiple_element_connected, ['Asciio/text', 1]], 
		),
	
	'insert_element' => GROUP
		(
		SHORTCUTS   => 'insert_element',
		DESCRIPTION => 'Insert divers asciio elements',
		
		'Add connector type 2'            => ['000-c', \&App::Asciio::Actions::Elements::add_element, ['Asciio/connector2', 0]   ],
		'Add connector use top character' => ['00S-C', \&App::Asciio::Actions::Elements::add_center_connector_use_top_character  ],
		'Add if'                          => ['000-i', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/if', 1]     ],
		'Add process'                     => ['000-p', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/process', 1]],
		'Add rhombus'                     => ['000-r', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Shape/rhombus', 0]],
		'Add ellipse'                     => ['000-e', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Shape/ellipse', 0]],
		),
	
	'insert_box' => GROUP
		(
		SHORTCUTS   => 'insert_box',
		DESCRIPTION => 'Insert Asciio boxes ad exec-boxes',
		
		'Add box'                    => ['000-b', \&App::Asciio::Actions::Elements::add_element, ['Asciio/box', 0]                     ],
		'Add shrink box'             => ['000-s', \&App::Asciio::Actions::Elements::add_element, ['Asciio/shrink_box', 1]              ],
		
		'Add exec box'               => ['000-e', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/exec', 1]              ],
		'Add exec box verbatim'      => ['000-v', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/exec verbatim', 1]     ],
		'Add exec box verbatim once' => ['000-o', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/exec verbatim once', 1]],
		'Add line numbered box'      => ['000-l', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/exec add lines', 1]    ],
		),
	
	'insert_unicode' => GROUP
		(
		SHORTCUTS   => 'insert_unicode',
		DESCRIPTION => 'Insert unicode elements',
		
		'Add unicode box'                    => ['000-b', \&App::Asciio::Actions::Elements::add_element, ['Asciio/box unicode', 0]         ],
		'Add unicode arrow'                  => ['000-a', \&App::Asciio::Actions::Elements::add_element, ['Asciio/wirl_arrow unicode', 0]  ],
		'Add unicode angled arrow'           => ['00S-A', \&App::Asciio::Actions::Elements::add_element, ['Asciio/angled arrow unicode', 0]],
		'Add unicode line'                   => ['000-l', \&App::Asciio::Actions::Elements::add_line, 1                                    ],
		
		'Add unicode bold line'              => ['00S-L', \&App::Asciio::Actions::Elements::add_line, 2                                    ],
		'Add unicode double line'            => ['0A0-l', \&App::Asciio::Actions::Elements::add_line, 3                                    ],
		
		'Add unicode no-connect line'        => ['000-k', \&App::Asciio::Actions::Elements::add_non_connecting_line, 1                     ],
		'Add unicode no-connect bold line'   => ['00S-K', \&App::Asciio::Actions::Elements::add_non_connecting_line, 2                     ],
		'Add unicode no-connect double line' => ['0A0-K', \&App::Asciio::Actions::Elements::add_non_connecting_line, 3                     ],
		),

'element ->' =>  GROUP
	(
	SHORTCUTS   => '000-e',
	DESCRIPTION => 'Modify connectors',
	
	'set id'                  => ['000-i', \&App::Asciio::Actions::Elements::set_id],
	'remove id'               => ['00S-I', \&App::Asciio::Actions::Elements::remove_id],
	'cross ->'                => ['000-x', USE_GROUP('cross')],
	'attributes ->'           => ['000-a', USE_GROUP('attributes')],
	'element modification ->' => ['000-m', USE_GROUP('modification')],
	'freeze controls ->'      => ['000-f', USE_GROUP('freeze')],
	'spellcheck ->'           => ['000-s', USE_GROUP('spellcheck')],
	'change type ->'          => ['000-t', USE_GROUP('change_type')],
	'add connectors ->'       => ['000-o', USE_GROUP('element_add_connectors')],
	),
	
	'spellcheck' => GROUP
		(
		SHORTCUTS   => 'spellcheck',
		DESCRIPTION => 'Spell check selected elements',
		
		'spellcheck' => ['000-s', \&App::Asciio::Actions::Unsorted::spellcheck_elements],
		'clear'      => ['000-c', \&App::Asciio::Actions::Unsorted::clear_spellcheck],
		),
	
	'change_type' => GROUP
		(
		SHORTCUTS   => 'change_type',
		DESCRIPTION => 'Change from one type of element to another',
		
		'Box ->'          => ['000-b', USE_GROUP('box_type_change')          ],
		'Wirl Arrow ->'   => ['000-w', USE_GROUP('wirl_arrow_type_change')   ],
		'Angled Arrow ->' => ['000-a', USE_GROUP('angled_arrow_type_change') ],
		'Ellipse ->'      => ['000-e', USE_GROUP('ellipse_type_change')      ],
		'Rhombus ->'      => ['000-r', USE_GROUP('rhombus_type_change')      ],
		'Triangle Up ->'  => ['000-u', USE_GROUP('triangle_up_type_change')  ],
		'Triangle Down->' => ['000-d', USE_GROUP('triangle_down_type_change')],
		),
		
		'box_type_change' =>  GROUP
			(
			SHORTCUTS   => 'box_type_change',
			DESCRIPTION => 'Box type change',
			
			map { ( "box $_->[0]" => [ $_->[1], \&App::Asciio::Actions::ElementAttributes::change_attributes, ['editable_box2', $_->[0]] ] ) } 
				(
				['dash'                      , '000-d'],
				['dot'                       , '00S-D'],
				['star'                      , '000-s'],
				['math_parantheses'          , '000-m'],
				['unicode'                   , '000-u'],
				['unicode_imaginary'         , '000-i'],
				['unicode_bold'              , '00S-U'],
				['unicode_bold_imaginary'    , '00S-I'],
				['unicode_double'            , '000-l'],
				['unicode_with_filler_type1' , '000-1'],
				['unicode_with_filler_type2' , '000-2'],
				['unicode_with_filler_type3' , '000-3'],
				['unicode_with_filler_type4' , '000-4'],
				['unicode_hollow_dot'        , '000-h'],
				['unicode_math_paranthesesar', '00S-M']
				),
			),
		
		'ellipse_type_change' =>  GROUP
			(
			SHORTCUTS   => 'ellipse_type_change',
			DESCRIPTION => 'Ellipse type change',
			
			map { ( "ellipse $_->[0]" => [ $_->[1], \&App::Asciio::Actions::ElementAttributes::change_attributes, ['ellipse', $_->[0]] ] ) } 
				(
				['ellipse_normal'                 , '000-n'],
				['ellipse_normal_with_filler_star', '000-s'],
				),
			),
		
		'rhombus_type_change' =>  GROUP
			(
			SHORTCUTS   => 'rhombus_type_change',
			DESCRIPTION => 'Rhombus type change',
			
			map { ( "rhombus $_->[0]" => [ $_->[1], \&App::Asciio::Actions::ElementAttributes::change_attributes, ['rhombus', $_->[0]] ] ) } 
				(
				['rhombus_normal'                 , '000-n'],
				['rhombus_normal_with_filler_star', '000-s'],
				['rhombus_sparseness'             , '00S-S'],
				['rhombus_unicode_slash'          , '000-u'],
				)
			),
		
		'triangle_up_type_change' =>  GROUP
			(
			SHORTCUTS   => 'triangle_up_type_change',
			DESCRIPTION => 'Triangle up type change',
			
			map { ( "triangle $_->[0]" => [ $_->[1], \&App::Asciio::Actions::ElementAttributes::change_attributes, ['triangle_up', $_->[0]] ] ) } 
				(
				['triangle_up_normal', '000-n'],
				['triangle_up_dot'   , '000-s'],
				),
			),
		
		'triangle_down_type_change' =>  GROUP
			(
			SHORTCUTS   => 'triangle_down_type_change',
			DESCRIPTION => 'Triangle down type change',
			
			map { ( "triangle $_->[0]" => [ $_->[1], \&App::Asciio::Actions::ElementAttributes::change_attributes, ['triangle_down', $_->[0]] ] ) } 
				(
				['triangle_down_normal', '000-n'],
				['triangle_down_dot'   , '000-s'],
				),
			),
		
		'wirl_arrow_type_change' =>  GROUP
			(
			SHORTCUTS   => 'wirl_arrow_type_change',
			DESCRIPTION => 'Wirl arrow type change',
			
			map { ( "wirl arrow $_->[0]" => [ $_->[1], \&App::Asciio::Actions::ElementAttributes::change_attributes, ['section_wirl_arrow', $_->[0]] ] ) } 
				(
				['dash'                  , '000-d'] ,
				['dash_line'             , '00S-D'] ,
				['dot'                   , 'C00-d'] ,
				['dot_no_arrow'          , '0A0-d'] ,
				['star'                  , '000-s'] ,
				['octo'                  , '000-o'] ,
				['unicode'               , '000-1'] ,
				['unicode_line'          , '000-u'] ,
				['unicode_bold'          , '000-2'] ,
				['unicode_bold_line'     , '000-b'] ,
				['unicode_double'        , '000-3'] ,
				['unicode_double_line'   , '00S-B'] ,
				['unicode_imaginary'     , '000-4'] ,
				['unicode_imaginary_line', '000-i'] ,
				['unicode_hollow_dot'    , '000-h'] ,
				),
			),
		
		'angled_arrow_type_change' =>  GROUP
			(
			SHORTCUTS   => 'angled_arrow_type_change',
			DESCRIPTION => 'Angled arrow type change',
			
			map { ( "angled arrow $_->[0]" => [ $_->[1], \&App::Asciio::Actions::ElementAttributes::change_attributes, ['angled_arrow', $_->[0]] ] ) } 
				(
				['angled_arrow_dash'   , '000-d'] ,
				['angled_arrow_unicode', '000-u'] ,
				),
			),
	
	'element_add_connectors' => GROUP
		(
		SHORTCUTS          => 'element_add_connectors',
		DESCRIPTION        => 'Add and remove connectors to elements',
		ESCAPE_KEYS        => ['00S-C', '000-Escape'],
		
		'add connector'    => ['000-button-press-1', \&App::Asciio::Actions::Elements::add_numbered_connector_to_element   ],
		'remove connector' => ['000-button-press-3', \&App::Asciio::Actions::Elements::remove_numbered_connector_in_element],
		),
	
	'attributes' => GROUP
		(
		SHORTCUTS   => 'attributes',
		DESCRIPTION => 'Elements attributes copy/paste',
		
		'copy element attributes'          => [['000-c', '000-y'], \&App::Asciio::Actions::ElementAttributes::copy_attributes         ],
		'paste element attributes'         => ['000-p',            \&App::Asciio::Actions::ElementAttributes::paste_attributes        ],
		'paste element control attributes' => ['00S-P',            \&App::Asciio::Actions::ElementAttributes::paste_control_attributes],
		),
	
	'freeze' => GROUP
		(
		SHORTCUTS   => 'freeze',
		DESCRIPTION => 'Freeze and thaw elements',
		
		'freeze'               => ['000-f', \&App::Asciio::Actions::Elements::freeze_selected_elements              ],
		'freeze to background' => ['000-b', \&App::Asciio::Actions::Elements::freeze_selected_elements_to_background],
		'thaw'                 => ['000-t', \&App::Asciio::Actions::Elements::thaw_selected_elements                ],
		),
	
	'modification' => GROUP
		(
		SHORTCUTS   => 'modification',
		DESCRIPTION => 'Element Ascci or Unicode',
		
		'Shrink box'                => ['000-s', \&App::Asciio::Actions::ElementsManipulation::shrink_box                   ],
		'Make elements Unicode'     => ['000-u', \&App::Asciio::Actions::ElementAttributes::make_selection_unicode, 1       ],
		'Make elements ASCII'       => ['000-a', \&App::Asciio::Actions::ElementAttributes::make_selection_unicode, 0       ],
		
		'convert to a text element' => ['000-t', \&App::Asciio::Actions::Elements::convert_selected_elements_to_text_element],
		'convert to dots'           => ['000-d', \&App::Asciio::Actions::Elements::convert_selected_elements_to_dot_elements],
		),

	'cross' => GROUP
		(
		SHORTCUTS   => 'cross',
		DESCRIPTION => 'Cross mode enable/disable',
		
		'enable elements cross'  => ['000-x', \&App::Asciio::Actions::ElementsManipulation::set_elements_crossover, 1],
		'disable elements cross' => ['000-d', \&App::Asciio::Actions::ElementsManipulation::set_elements_crossover, 0],
		),

'arrow ->' => GROUP
	(
	SHORTCUTS   => '000-a',
	DESCRIPTION => 'Arrow manipulation functions',
	
	'Change arrow direction'   => ['000-d', \&App::Asciio::Actions::Arrow::change_arrow_direction                         ],
	'Flip start and end'       => ['000-f', \&App::Asciio::Actions::Arrow::flip_arrow_ends                                ],
	
	'Prepend section'          => ['000-s', \&App::Asciio::Actions::Multiwirl::prepend_section                            ],
	'Append section'           => ['000-e', \&App::Asciio::Actions::Multiwirl::append_section,                            ],
	'Insert section'           => ['00S-S', \&App::Asciio::Actions::Multiwirl::insert_wirl_arrow_section                  ],
	'Remove last section'      => ['000-r', \&App::Asciio::Actions::Multiwirl::remove_last_section_from_section_wirl_arrow],
	
	'Connectors ->'            => ['000-c', USE_GROUP('connectors')                                                       ] ,
	'Diagonal ->'              => ['00S-D', USE_GROUP('diagonal')                                                         ] ,
	
	'Flip drag selects arrows' => ['0A0-s', \&App::Asciio::Actions::Arrow::drag_selects_arrows                            ],
	# insert_section
	# remove_last_section
	# remove_first_section
	# change_section_direction
	# change_last_section_direction
	),
	
	'diagonal' => GROUP
		(
		SHORTCUTS   => 'diagonal',
		DESCRIPTION => 'Enable or disable diaonal arrows',
		
		'enable diagonals'  => ['000-d', \&App::Asciio::Actions::Arrow::allow_diagonals, 1],
		'disable diagonals' => ['00S-D', \&App::Asciio::Actions::Arrow::allow_diagonals, 0],
		),
	
	'connectors' => GROUP
		(
		SHORTCUTS   => 'connectors',
		DESCRIPTION => 'Enable or disable element connectors',
		
		'start enable connection'      => ['0A0-s', \&App::Asciio::Actions::Arrow::allow_connection, ['start', 1],],
		'start disable connection'     => ['0AS-S', \&App::Asciio::Actions::Arrow::allow_connection, ['start', 0],],
		'end enable connection'        => ['0A0-e', \&App::Asciio::Actions::Arrow::allow_connection, ['end',   1],],
		'end disable connection'       => ['0AS-E', \&App::Asciio::Actions::Arrow::allow_connection, ['end',   0],],
		
		'start flip enable connection' => ['C00-s', \&App::Asciio::Actions::Multiwirl::disable_arrow_connector, 0 ],
		'end flip enable connection'   => ['C00-e', \&App::Asciio::Actions::Multiwirl::disable_arrow_connector, 1 ],
		
		'start connectors ->'          => ['000-s', USE_GROUP('start_connectors')] ,
		'end connectors ->'            => ['000-e', USE_GROUP('end_connectors')  ] ,
		'both connectors ->'           => ['000-b', USE_GROUP('both_connectors') ] ,
		),
		
		'start_connectors' => GROUP
			(
			SHORTCUTS   => 'start_connectors',
			DESCRIPTION => 'Modify start connector look',
			
			'fixed start connectors ->' => ['000-f', USE_GROUP('fixed_start_connectors')] ,
			
			map { ( "start $_->[0]" => [ $_->[1], \&App::Asciio::Actions::Multiwirl::change_connector, ['start', $_->[2]] ] ) } 
				(
				#                                   right down left up   d45  d135  d225 d315
				['dash',           '000-minus',    ['-',  '|', '-', '|', '/', '\\', '/', '\\']],
				['arrow reversed', '00S-less',     ['<',  '^', '>', 'v', 'v', '^',  '^', 'v' ]],
				['arrow',          '00S-greater',  ['>',  'v', '<', '^', '^', 'v',  'v', '^' ]],
				['t',              '000-t',        ['┤',  '┴', '├', '┬', '/', '\\', '/', '\\']],
				['T',              '00S-T',        ['┫',  '┻', '┣', '┳', '/', '\\', '/', '\\']],
				),
			) ,
			
			'fixed_start_connectors' => GROUP
				(
				SHORTCUTS   => 'fixed_start_connectors',
				DESCRIPTION => 'Modify start connector to static',
				
				map { ( "both $_->[0]" => [ $_->[1], \&App::Asciio::Actions::Multiwirl::change_connectors, $_->[2]] ) } 
					(
					['dash fixed', '000-minus',    [ [ start => ['-'] ] ]], 
					['dot fixed' , '000-period',   [ [ start => ['.'] ] ]],
					['star fixed', '00S-asterisk', [ [ start => ['*'] ] ]],
					['o fixed'   , '000-o',        [ [ start => ['o'] ] ]],
					['O fixed'   , '00S-O',        [ [ start => ['O'] ] ]],
					['• fixed'   , '000-d',        [ [ start => ['•'] ] ]],
					),
				),
		
		'end_connectors' => GROUP
			(
			SHORTCUTS   => 'end_connectors',
			DESCRIPTION => 'Modify end connector look',
			
			'fixed end connectors ->' => ['000-f', USE_GROUP('fixed_end_connectors')] ,
			
			map { ( "end $_->[0]" => [ $_->[1], \&App::Asciio::Actions::Multiwirl::change_connector, ['end', $_->[2]] ] ) } 
				(
				#                                  right down left up   d45  d135  d225 d315
				['dash',           '000-minus',   ['-',  '|', '-', '|', '/', '\\', '/', '\\']],
				['arrow reversed', '00S-less',    ['<',  '^', '>', 'v', 'v', '^',  '^', 'v' ]],
				['arrow',          '00S-greater', ['>',  'v', '<', '^', '^', 'v',  'v', '^' ]],
				['t',              '000-t',       ['┤',  '┴', '├', '┬', '/', '\\', '/', '\\']],
				['T',              '00S-T',       ['┫',  '┻', '┣', '┳', '/', '\\', '/', '\\']],
				),
			),
			
			'fixed_end_connectors' => GROUP
				(
				SHORTCUTS   => 'fixed_end_connectors',
				DESCRIPTION => 'Modify end connector to static',
				
				map { ( "both $_->[0]" => [ $_->[1], \&App::Asciio::Actions::Multiwirl::change_connectors, $_->[2]] ) } 
					(
					['dash fixed', '000-minus',    [ [ end => ['-'] ] ]], 
					['dot fixed' , '000-period',   [ [ end => ['.'] ] ]],
					['star fixed', '00S-asterisk', [ [ end => ['*'] ] ]],
					['o fixed'   , '000-o',        [ [ end => ['o'] ] ]],
					['O fixed'   , '00S-O',        [ [ end => ['O'] ] ]],
					['• fixed'   , '000-d',        [ [ end => ['•'] ] ]],
					),
				),
		
		'both_connectors' => GROUP
			(
			SHORTCUTS   => 'both_connectors',
			DESCRIPTION => 'Modify both start and end connectors',
			
			'fixed both connectors ->' => ['000-f', USE_GROUP('fixed_both_connectors')] ,
			
			map { ( "both $_->[0]"     => [ $_->[1], \&App::Asciio::Actions::Multiwirl::change_connectors, $_->[2]] ) } 
				(
				#                                               right down left up   d45  d135  d225 d315
				['dash',           '000-minus',   [ [ start => ['-',  '|', '-', '|', '/', '\\', '/', '\\'] ], [ end => ['-',  '|', '-', '|', '/', '\\', '/', '\\'] ] ]],
				['arrow reversed', '00S-less',    [ [ start => ['<',  '^', '>', 'v', 'v', '^',  '^', 'v' ] ], [ end => ['<',  '^', '>', 'v', 'v', '^',  '^', 'v' ] ] ]],
				['arrow',          '00S-greater', [ [ start => ['>',  'v', '<', '^', '^', 'v',  'v', '^' ] ], [ end => ['>',  'v', '<', '^', '^', 'v',  'v', '^' ] ] ]],
				['t',              '000-t',       [ [ start => ['┤',  '┴', '├', '┬', '/', '\\', '/', '\\'] ], [ end => ['┤',  '┴', '├', '┬', '/', '\\', '/', '\\'] ] ]],
				['T',              '00S-T',       [ [ start => ['┫',  '┻', '┣', '┳', '/', '\\', '/', '\\'] ], [ end => ['┫',  '┻', '┣', '┳', '/', '\\', '/', '\\'] ] ]],
				),
			),
			
			'fixed_both_connectors' => GROUP
				(
				SHORTCUTS   => 'fixed_both_connectors',
				DESCRIPTION => 'Modify both start and end connectors to static',
				
				map { ( "both $_->[0]"  => [ $_->[1], \&App::Asciio::Actions::Multiwirl::change_connectors, $_->[2]] ) } 
					(
					['dash fixed', '000-minus',    [ [ start => ['-'] ], [ end => ['-'] ] ]], 
					['dot fixed' , '000-period',   [ [ start => ['.'] ], [ end => ['.'] ] ]],
					['star fixed', '00S-asterisk', [ [ start => ['*'] ], [ end => ['*'] ] ]],
					['o fixed'   , '000-o',        [ [ start => ['o'] ], [ end => ['o'] ] ]],
					['O fixed'   , '00S-O',        [ [ start => ['O'] ], [ end => ['O'] ] ]],
					['• fixed'   , '000-d',        [ [ start => ['•'] ], [ end => ['•'] ] ]],
					),
				),

'move arrow ends ->' => GROUP
	(
	SHORTCUTS   => '0A0-a',
	DESCRIPTION => 'Move arrow end with keyboard',
	ESCAPE_KEYS => '000-Escape',
	
	'arrow start up'     => ['000-Up',    \&App::Asciio::Actions::Arrow::move_arrow_start, [ 0, -1]],
	'arrow start down'   => ['000-Down',  \&App::Asciio::Actions::Arrow::move_arrow_start, [ 0,  1]],
	'arrow start right'  => ['000-Right', \&App::Asciio::Actions::Arrow::move_arrow_start, [ 1,  0]],
	'arrow start left'   => ['000-Left',  \&App::Asciio::Actions::Arrow::move_arrow_start, [-1,  0]],
	'arrow start up2'    => ['000-k',     \&App::Asciio::Actions::Arrow::move_arrow_start, [ 0, -1]],
	'arrow start down2'  => ['000-j',     \&App::Asciio::Actions::Arrow::move_arrow_start, [ 0,  1]],
	'arrow start right2' => ['000-l',     \&App::Asciio::Actions::Arrow::move_arrow_start, [ 1,  0]],
	'arrow start left2'  => ['000-h',     \&App::Asciio::Actions::Arrow::move_arrow_start, [-1,  0]],
	'arrow end up'       => ['00S-Up',    \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 0, -1]],
	'arrow end down'     => ['00S-Down',  \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 0,  1]],
	'arrow end right'    => ['00S-Right', \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 1,  0]],
	'arrow end left'     => ['00S-Left',  \&App::Asciio::Actions::Arrow::move_arrow_end,   [-1,  0]],
	'arrow end up2'      => ['00S-K',     \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 0, -1]],
	'arrow end down2'    => ['00S-J',     \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 0,  1]],
	'arrow end right2'   => ['00S-L',     \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 1,  0]],
	'arrow end left2'    => ['00S-H',     \&App::Asciio::Actions::Arrow::move_arrow_end,   [-1,  0]],
	),

'image box ->' => GROUP
	(
	SHORTCUTS   => '00S-I',
	DESCRIPTION => 'Insert and control an image box',
	
	'inserted from file'    => ['000-i', \&App::Asciio::GTK::Asciio::Actions::File::open_image                    ],
	'freeze to background'  => ['000-f', \&App::Asciio::Actions::Elements::freeze_selected_elements_to_background ],
	'thaw'                  => ['000-t', \&App::Asciio::Actions::Elements::thaw_selected_elements                 ],
	
	'rendering controls ->' => ['000-c', USE_GROUP('image_control')],
	),
	
	'image_control' => GROUP
		(
		SHORTCUTS   => 'image_control',
		DESCRIPTION => 'Control image box',
		ESCAPE_KEYS => [ '000-c', '000-Escape' ],
		
		'increase gray scale' => ['000-g', \&App::Asciio::Actions::Box::image_box_change_gray_scale, 0.1 ],
		'decrease gray scale' => ['00S-G', \&App::Asciio::Actions::Box::image_box_change_gray_scale, -0.1],
		'increase alpha'      => ['000-a', \&App::Asciio::Actions::Box::image_box_change_alpha, 0.1      ],
		'decrease alpha'      => ['00S-A', \&App::Asciio::Actions::Box::image_box_change_alpha, -0.1     ],
		'revert to default'   => ['000-r', \&App::Asciio::Actions::Box::image_box_revert_to_default_image],
		),

'eraser ->' => GROUP
	(
	SHORTCUTS    => '00S-E',
	DESCRIPTION => 'Eraser mode',
	ENTER_GROUP  => \&App::Asciio::Actions::Eraser::eraser_enter,
	ESCAPE_KEYS  => '000-Escape',
	ESCAPE_GROUP => \&App::Asciio::Actions::Eraser::eraser_escape, 
	
	'Eraser motion' => ['000-motion_notify', \&App::Asciio::Actions::Eraser::erase_elements, undef, { HIDE => 1 }],
	),

'align ->' => GROUP
	(
	SHORTCUTS   => '00S-A',
	DESCRIPTION => 'Element alignment functions',
	
	'Align top'          => ['000-t', \&App::Asciio::Actions::Align::align, 'top'       ],
	'Align left'         => ['000-l', \&App::Asciio::Actions::Align::align, 'left'      ],
	'Align bottom'       => ['000-b', \&App::Asciio::Actions::Align::align, 'bottom'    ],
	'Align right'        => ['000-r', \&App::Asciio::Actions::Align::align, 'right'     ],
	'Align vertically'   => ['000-v', \&App::Asciio::Actions::Align::align, 'vertical'  ],
	'Align horizontally' => ['000-h', \&App::Asciio::Actions::Align::align, 'horizontal'],
	),

'grouping ->' => GROUP
	(
	SHORTCUTS   => '000-g',
	DESCRIPTION => 'Group elements and control their Z position',
	
	'Group'                       => ['000-g', \&App::Asciio::Actions::ElementsManipulation::selected_elements                 ],
	'Ungroup'                     => ['000-u', \&App::Asciio::Actions::ElementsManipulation::unselected_elements               ],
	'Move to the front'           => ['000-f', \&App::Asciio::Actions::ElementsManipulation::move_selected_elements_to_front         ],
	'Move to the back'            => ['000-b', \&App::Asciio::Actions::ElementsManipulation::move_selected_elements_to_back          ],
	'Temporary move to the front' => ['00S-F', \&App::Asciio::Actions::ElementsManipulation::temporary_move_selected_element_to_front],
	),

'stripes ->' => GROUP
	(
	SHORTCUTS   => '0A0-g',
	DESCRIPTION => 'Transfor elements to stripe groups',
	
	'create stripes group'    => ['000-g', \&App::Asciio::Actions::ElementsManipulation::create_stripes_group, 0],
	'create one stripe group' => ['000-1', \&App::Asciio::Actions::ElementsManipulation::create_stripes_group, 1],
	'ungroup stripes group'   => ['000-u', \&App::Asciio::Actions::ElementsManipulation::unstripes_group  ],
	),

'find ->' => GROUP
	(
	SHORTCUTS   => '000-f',
	DESCRIPTION => 'Search and replace mode',
	ESCAPE_KEYS => '000-Escape',
	
	'find search'       => ['000-f',      \&App::Asciio::Actions::FindAndReplace::new_search    ],
	'find replace'      => ['000-r',      \&App::Asciio::Actions::FindAndReplace::replace       ],
	'find next'         => ['000-n',      \&App::Asciio::Actions::FindAndReplace::next          ],
	'find previous'     => ['00S-N',      \&App::Asciio::Actions::FindAndReplace::previous      ],
	'find clear'        => ['000-c',      \&App::Asciio::Actions::FindAndReplace::clear         ],
	'find select'       => ['000-Return', \&App::Asciio::Actions::FindAndReplace::select        ],
	'find select add'   => ['00S-Return', \&App::Asciio::Actions::FindAndReplace::select, 'add' ],
	'find select All'   => ['C00-Return', \&App::Asciio::Actions::FindAndReplace::select, 'all' ],
	'find zoom in'      => ['000-plus',   \&App::Asciio::Actions::FindAndReplace::zoom, 1       ],
	'find zoom out'     => ['000-minus',  \&App::Asciio::Actions::FindAndReplace::zoom, -1      ],
	'find zoom extents' => ['C00-minus',  \&App::Asciio::Actions::FindAndReplace::zoom, 0       ],
	
	# search and replace in all tabs, not implemented yet, reserving the shortcuts
	# 'find search all'  => ['C00-f',      \&App::Asciio::Actions::FindAndReplace::new_search, 'all'],
	# 'find replace all' => ['00S-R',      \&App::Asciio::Actions::FindAndReplace::replace, 'all'   ],
	),

'git ->' => GROUP
	(
	SHORTCUTS   => '00S-G',
	DESCRIPTION => 'Git mode',
	ESCAPE_KEYS => '000-Escape',
	
	'Show git bindings'          => ['00S-question',                        sub { $_[0]->show_binding_completions(1) ; }                           ],
	
	'Quick git'                  => [['000-button-press-3', '000-c'],       \&App::Asciio::Actions::Git::quick_link                                ],
	
	'Git add box'                => ['000-b',                               \&App::Asciio::Actions::Elements::add_element, ['Asciio/box',  1]      ],
	'Git add text'               => ['000-t',                               \&App::Asciio::Actions::Elements::add_element, ['Asciio/text', 1]      ],
	'Git add arrow'              => ['000-a',                               \&App::Asciio::Actions::Elements::add_element, ['Asciio/wirl_arrow', 0]],
	'Git edit selected element'  => [['000-2button-press-1', '000-Return'], \&App::Asciio::Actions::Git::edit_selected_element                     ],
	
	'Git mouse left-click'       => ['000-button-press-1',                  \&App::Asciio::Actions::Mouse::mouse_left_click                        ],
	'Git change arrow direction' => ['000-d',                               \&App::Asciio::Actions::Arrow::change_arrow_direction                  ],
	'Git undo'                   => ['000-u',                               \&App::Asciio::Actions::Unsorted::undo                                 ],
	'Git delete elements'        => [['000-Delete', '000-x'],               \&App::Asciio::Actions::ElementsManipulation::delete_selected_elements ],
	
	'Git mouse motion'           => ['000-motion_notify',                   \&App::Asciio::Actions::Mouse::mouse_motion, undef, { HIDE => 1 }      ], 
	'Git move elements left'     => ['000-Left',                            \&App::Asciio::Actions::ElementsManipulation::move_selection_left      ],
	'Git move elements right'    => ['000-Right',                           \&App::Asciio::Actions::ElementsManipulation::move_selection_right     ],
	'Git move elements up'       => ['000-Up',                              \&App::Asciio::Actions::ElementsManipulation::move_selection_up        ],
	'Git move elements down'     => ['000-Down',                            \&App::Asciio::Actions::ElementsManipulation::move_selection_down      ],
	
	'Git mouse right-click'      => ['0A0-button-press-3',                  \&App::Asciio::Actions::Mouse::mouse_right_click                       ],
	'Git flip hint lines'        => ['000-h',                               \&App::Asciio::Actions::Unsorted::flip_hint_lines                      ],
	),

'slides ->' => GROUP
	(
	SHORTCUTS    => '0A0-s',
	DESCRIPTION  => 'Slides mode',
	ENTER_GROUP  => \&App::Asciio::Actions::Presentation::start_manual_slideshow,
	ESCAPE_KEYS  => '000-Escape',
	ESCAPE_GROUP => \&App::Asciio::Actions::Presentation::escape_slideshow,
	
	'previous slide'         => ['000-p', \&App::Asciio::Actions::Presentation::previous_slide                                                ] ,
	'previous slide2'        => ['00S-N', \&App::Asciio::Actions::Presentation::previous_slide                                                ] ,
	'next slide'             => ['000-n', \&App::Asciio::Actions::Presentation::next_slide                                                    ] ,
	'first slide'            => ['000-g', \&App::Asciio::Actions::Presentation::first_slide                                                   ] ,
	'first slide2'           => ['000-0', \&App::Asciio::Actions::Presentation::first_slide                                                   ] ,
	
	'tag as slide'           => ['000-s', \&App::Asciio::Actions::Presentation::tag,                   { IS_SLIDE => 1, BG_COLOR => 'yellow' }] ,
	'tag all as slide'       => ['C00-s', \&App::Asciio::Actions::Presentation::tag_all,               { IS_SLIDE => 1, BG_COLOR => 'yellow' }] ,
	'untag as slide'         => ['00S-S', \&App::Asciio::Actions::Presentation::tag,                   undef                                  ] ,
	'set slide time'         => ['000-t', \&App::Asciio::Actions::Presentation::set_slide_time                                                ] ,
	'set default slide time' => ['00S-T', \&App::Asciio::Actions::Presentation::set_default_slide_time                                        ] ,
	'run slideshow ->'       => ['000-r', USE_GROUP('slideshow_run')                                                                          ] ,
	'run slideshow once ->'  => ['00S-R', USE_GROUP('slideshow_run_once')                                                                     ] ,
	'set slide directory'    => ['000-d', \&App::Asciio::Actions::Animation::set_slide_directory                                              ] ,
	
	'animation ->'           => ['000-a', USE_GROUP('animation')                                                                              ] ,
	),
	
	'slideshow_run'    => GROUP
		(
		SHORTCUTS    => 'slideshow_run',
		ENTER_GROUP  => [\&App::Asciio::Actions::Presentation::start_automatic_slideshow, 1000],
		ESCAPE_KEYS  => '000-Escape',
		ESCAPE_GROUP => \&App::Asciio::Actions::Presentation::escape_slideshow,
		
		'previous slide' => ['00S-N', \&App::Asciio::Actions::Presentation::previous_slide],
		'next slide'     => ['000-n', \&App::Asciio::Actions::Presentation::next_slide    ],
		'slower'         => ['000-s', \&App::Asciio::Actions::Presentation::slower_speed  ],
		'faster'         => ['000-f', \&App::Asciio::Actions::Presentation::faster_speed  ],
		'pause'          => ['000-p', \&App::Asciio::Actions::Presentation::pause         ],
		
		'next slideshow slide' => ['next_slideshow_slide', \&App::Asciio::Actions::Presentation::next_slideshow_slide],
		),
	
	'slideshow_run_once' => GROUP
		(
		SHORTCUTS    => 'slideshow_un_once',
		ENTER_GROUP  => [\&App::Asciio::Actions::Presentation::start_automatic_slideshow_once, [1000, 1]],
		ESCAPE_KEYS  => '000-Escape',
		ESCAPE_GROUP => \&App::Asciio::Actions::Presentation::escape_slideshow,
		
		'next slideshow slide' => ['next_slideshow_slide', \&App::Asciio::Actions::Presentation::next_slideshow_slide],
		),
	
	'animation ->' => GROUP
		(
		SHORTCUTS   => 'animation',
		DESCRIPTION => 'Animation scripts',
		ENTER_GROUP => \&App::Asciio::Actions::Animation::scan_script_directory,
		ESCAPE_KEYS => '000-Escape',
		HIDE        => 1,
		
		'show animation bindings'     => ['00S-question', sub { $_[0]->show_binding_completions(1, 1) ; } ],
		
		'previous numbered animation' => ['000-p',        \&App::Asciio::Actions::Animation::run_previous ],
		'previous numbered animation' => ['00S-N',        \&App::Asciio::Actions::Animation::run_previous ],
		'next numbered animation'     => ['000-n',        \&App::Asciio::Actions::Animation::run_next     ],
		'first numbered animation'    => ['000-g',        \&App::Asciio::Actions::Animation::run_first    ],
		're-run animation'            => ['000-r',        \&App::Asciio::Actions::Animation::rerun        ],
		'take snapshot'               => ['000-s',        \&App::Asciio::Actions::Animation::take_snapshot],
		# 'save document'      => ['000-s', \&App::Asciio::Actions::Animation::],
		# 'reset document'     => ['000-0', \&App::Asciio::Actions::Animation::],
		
		'find and run animation' => ['000-Tab', USE_GROUP('animation_complete')],
		),
	
	'animation_complete ->' => GROUP
		(
		SHORTCUTS    => 'animation_complete',
		DESCRIPTION  => 'Animation script competion',
		ENTER_GROUP  => [
				\&App::Asciio::Actions::Completion::enter,
					[
					\&App::Asciio::Actions::Animation::get_scripts,
					\&App::Asciio::Actions::Animation::run_script,
					]
				],
		ESCAPE_KEYS  => '000-Escape',
		ESCAPE_GROUP => \&App::Asciio::Actions::Completion::escape, 
		
		'complete complete'     => ['000-Tab'       , \&App::Asciio::Actions::Completion::key, 'tab',       { HIDE => 1 }],
		'complete complete all' => ['C00-Tab'       , \&App::Asciio::Actions::Completion::key, 'taball',    { HIDE => 1 }],
		'complete backspace'    => ['000-BackSpace' , \&App::Asciio::Actions::Completion::key, 'backspace', { HIDE => 1 }],
		'complete execute'      => ['000-Return'    , \&App::Asciio::Actions::Completion::key, 'return',    { HIDE => 1 }],
		'complete erase'        => ['C00-l'         , \&App::Asciio::Actions::Completion::key, 'erase',     { HIDE => 1 }],
		
		(map { ("complete $_"   => ["000-$_"        , \&App::Asciio::Actions::Completion::key, $_,          { HIDE => 1 }]) }('a'..'z', '0'..'9', '_', '-')),
		),

'pen ->' => GROUP
	(
	SHORTCUTS    => '00S-P',
	DESCRIPTION  => 'Pen mode',
	ENTER_GROUP  => \&App::Asciio::GTK::Asciio::Pen::mouse_emulation_enter,
	ESCAPE_KEYS  => '000-Escape',
	ESCAPE_GROUP => \&App::Asciio::GTK::Asciio::Pen::mouse_emulation_escape,
	
	'eraser ->'                             => ['C00-e', USE_GROUP('pen_eraser')   ],
	'pen show bindings'                     => ['C00-b', sub{  $_[0]->show_binding_completions(1) ; }                           ],
	'pen toggle direction'                  => ['C00-d', \&App::Asciio::GTK::Asciio::Pen::toggle_mouse_emulation_move_direction ],
	'pen change key mapping panel location' => ['C00-c', \&App::Asciio::GTK::Asciio::Pen::switch_key_mapping_panel_location     ],
	'pen next char set'                     => ['C00-n', \&App::Asciio::GTK::Asciio::Pen::switch_next_character_sets, 1         ],
	'pen previous char set'                 => ['C00-p', \&App::Asciio::GTK::Asciio::Pen::switch_previous_character_sets, 1     ],
	
	'pen insert or delete'                  => ['000-button-press-1',   \&App::Asciio::GTK::Asciio::Pen::handle_primary_input, 0                               ],
	'pen insert2 or delete2'                => ['000-Return',           \&App::Asciio::GTK::Asciio::Pen::handle_primary_input, 0                               ],
	'pen mouse button 3'                    => ['000-button-press-3',   \&App::Asciio::GTK::Asciio::Pen::handle_secondary_input                                ],
	
	'pen left quick'                        => ['0A0-h',                \&App::Asciio::GTK::Asciio::Pen::mouse_emulation_move_left_quick                       ],
	'pen right quick'                       => ['0A0-l',                \&App::Asciio::GTK::Asciio::Pen::mouse_emulation_move_right_quick                      ],
	'pen up quick'                          => ['0A0-k',                \&App::Asciio::GTK::Asciio::Pen::mouse_emulation_move_up_quick                         ],
	'pen down quick'                        => ['0A0-j',                \&App::Asciio::GTK::Asciio::Pen::mouse_emulation_move_down_quick                       ],
	'pen left'                              => [['000-Left', 'C00-h'],  \&App::Asciio::GTK::Asciio::Pen::mouse_emulation_move_left,        undef, { HIDE => 1 }],
	'pen right'                             => [['000-Right', 'C00-l'], \&App::Asciio::GTK::Asciio::Pen::mouse_emulation_move_right,       undef, { HIDE => 1 }],
	'pen up'                                => [['000-Up', 'C00-k'],    \&App::Asciio::GTK::Asciio::Pen::mouse_emulation_move_up,          undef, { HIDE => 1 }],
	'pen down'                              => [['000-Down', 'C00-j'],  \&App::Asciio::GTK::Asciio::Pen::mouse_emulation_move_down,        undef, { HIDE => 1 }],
	'pen space'                             => ['000-space',            \&App::Asciio::GTK::Asciio::Pen::mouse_emulation_move_space,       undef, { HIDE => 1 }],
	'pen left tab'                          => ['00S-ISO_Left_Tab',     \&App::Asciio::GTK::Asciio::Pen::mouse_emulation_move_left_tab,    undef, { HIDE => 1 }],
	'pen right tab'                         => ['000-Tab',              \&App::Asciio::GTK::Asciio::Pen::mouse_emulation_move_right_tab,   undef, { HIDE => 1 }],
	'pen enter'                             => ['00S-Return',           \&App::Asciio::GTK::Asciio::Pen::mouse_emulation_press_enter_key,  undef, { HIDE => 1 }],
	'pen delete dot'                        => ['000-Delete',           \&App::Asciio::GTK::Asciio::Pen::pen_delete_element,               1,     { HIDE => 1 }],
	'pen backspace dot'                     => ['000-BackSpace',        \&App::Asciio::GTK::Asciio::Pen::pen_back_delete_element,          1,     { HIDE => 1 }],
	
	'pen motion'                            => ['000-motion_notify',    \&App::Asciio::GTK::Asciio::Pen::pen_mouse_motion,                 undef, { HIDE => 1 }],
	'pen release'                           => ['000-button-release-1', \&App::Asciio::GTK::Asciio::Pen::pen_mouse_motion,                 undef, { HIDE => 1 }],
	'pen release 3'                         => ['000-button-release-3', \&App::Asciio::GTK::Asciio::Pen::pen_mouse_motion,                 undef, { HIDE => 1 }],
	
	
	(map { "pen insert " . $_ => ["00S-" . $_, \&App::Asciio::GTK::Asciio::Pen::enter_then_move_mouse, [$_], { HIDE => 1 }] }('A'..'Z')),
	(map { "pen insert " . $_ => ["000-" . $_, \&App::Asciio::GTK::Asciio::Pen::enter_then_move_mouse, [$_], { HIDE => 1 }] }('a'..'z', '0'..'9')),
	(
	map { "pen insert " . $_->[0] => ["00S-" . $_->[0], \&App::Asciio::GTK::Asciio::Pen::enter_then_move_mouse, [$_->[1]], { HIDE => 1 }]}
		(
		['Adiaeresis' , 'Ä'],
		['Aring'      , 'Å'],
		['Odiaeresis' , 'Ö'],
		['ampersand'  , '&'],
		['asciicircum', '^'],
		['asciitilde' , '~'],
		['asterisk'   , '*'],
		['at'         , '@'],
		['bar'        , '|'],
		['braceleft'  , '{'],
		['braceright' , '}'],
		['colon'      , ':'],
		['dollar'     , '$'],
		['exclam'     , '!'],
		['greater'    , '>'],
		['less'       , '<'],
		['numbersign' , '#'],
		['parenleft'  , '('],
		['parenright' , ')'],
		['percent'    , '%'],
		['plus'       , '+'],
		['question'   , '?'],
		['quotedbl'   , '"'],
		['underscore' , '_'],
		)
	),
	(
	map { "pen insert " . $_->[0] => ["000-" . $_->[0], \&App::Asciio::GTK::Asciio::Pen::enter_then_move_mouse, [$_->[1]], { HIDE =>1 }]}
		(
		['adiaeresis'  , 'ä' ] ,
		['apostrophe'  , '\''] ,
		['aring'       , 'å' ] ,
		['backslash'   , '\\'] ,
		['bracketleft' , '[' ] ,
		['bracketright', ']' ] ,
		['comma'       , ',' ] ,
		['equal'       , '=' ] ,
		['grave'       , '`' ] ,
		['minus'       , '-' ] ,
		['odiaeresis'  , 'ö' ] ,
		['period'      , '.' ] ,
		['semicolon'   , ';' ] ,
		['slash'       , '/' ] ,
		)
	),
	),
	
	'pen_eraser' => GROUP
		(
		SHORTCUTS   => 'pen_eraser',
		DESCRIPTION => 'Pen mode eraser',
		ENTER_GROUP => [\&App::Asciio::GTK::Asciio::Pen::sub_mode_switch, 'eraser'],
		ESCAPE_KEYS => '000-Escape',
		
		'return to pen mode'       => ['000-Escape',         sub{ $_[0]->run_actions_by_name("pen ->") ; }, undef,          { HIDE => 1 }],
		
		'pen delete element'       => ['000-button-press-1',   \&App::Asciio::GTK::Asciio::Pen::handle_primary_input, 0                  ],
		'pen delete dot'           => ['000-Delete',           \&App::Asciio::GTK::Asciio::Pen::pen_delete_element, 1,      { HIDE => 1 }],
		'pen backspace delete dot' => ['000-BackSpace',        \&App::Asciio::GTK::Asciio::Pen::pen_back_delete_element, 1, { HIDE => 1 }],
		
		'pen motion'               => ['000-motion_notify',    \&App::Asciio::GTK::Asciio::Pen::pen_mouse_motion, undef,    { HIDE => 1 }],
		'pen release'              => ['000-button-release-1', \&App::Asciio::GTK::Asciio::Pen::pen_mouse_motion, undef,    { HIDE => 1 }],
		'pen release 3'            => ['000-button-release-3', \&App::Asciio::GTK::Asciio::Pen::pen_mouse_motion, undef,    { HIDE => 1 }],
		),

'display options ->' => GROUP
	(
	SHORTCUTS   => '000-z',
	DESCRIPTION => 'Display options',
	
	'Change font'               => ['000-f', \&App::Asciio::Actions::Unsorted::change_font                           ],
	'Change color ->'           => ['000-c', USE_GROUP('color')                                                      ] ,
	
	'Flip binding completion'   => ['000-b', sub { $_[0]->{USE_BINDINGS_COMPLETION} ^= 1 ; $_[0]->update_display() ;}],
	'Flip element transparency' => ['000-t', \&App::Asciio::Actions::Unsorted::transparent_elements                  ],
	'Flip grid display'         => ['000-g', \&App::Asciio::Actions::Unsorted::flip_grid_display                     ],
	'Flip rulers display'       => ['000-r', \&App::Asciio::Actions::Unsorted::flip_rulers_display                   ],
	'Flip hint lines'           => ['000-h', \&App::Asciio::Actions::Unsorted::flip_hint_lines                       ],
	'Flip edit inline'          => ['000-e', \&App::Asciio::Actions::Unsorted::toggle_edit_inline                    ],
	'Flip show/hide connectors' => ['000-v', \&App::Asciio::Actions::Unsorted::flip_connector_display                ],
	'Flip display element id'   => ['000-i', sub { $_[0]->{DISPLAY}{DRAW_ID} ^= 1 ; $_[0]->update_display() }        ],
	),
	
	'color' => GROUP
		(
		SHORTCUTS => 'color',
		
		'Flip color scheme'         => ['000-s', \&App::Asciio::Actions::Colors::flip_color_scheme          ] ,
		
		'Elements foreground color' => ['000-f', \&App::Asciio::Actions::Colors::change_elements_colors, [0]] ,
		'Elements background color' => ['000-b', \&App::Asciio::Actions::Colors::change_elements_colors, [1]] ,
		'Asciio background color'   => ['00S-B', \&App::Asciio::Actions::Colors::change_background_color    ] ,
		'grid color'                => ['000-g', \&App::Asciio::Actions::Colors::change_grid_color          ] ,
		),

'debug ->' =>  GROUP
	(
	SHORTCUTS   => '00S-D',
	DESCRIPTION => 'Debug functions',
	
	'Display undo stack statistics' => ['000-u', \&App::Asciio::Actions::Unsorted::display_undo_stack_statistics ],
	'Dump self'                     => ['000-s', \&App::Asciio::Actions::Debug::dump_self                        ],
	'Dump all elements'             => ['000-e', \&App::Asciio::Actions::Debug::dump_all_elements                ],
	'Dump selected elements'        => ['00S-E', \&App::Asciio::Actions::Debug::dump_selected_elements           ],
	'Dump animation data'           => ['000-a', \&App::Asciio::Actions::Debug::dump_animation_data              ],
	'Display numbered objects'      => ['00S-T', sub { $_[0]->{NUMBERED_OBJECTS} ^= 1 ; $_[0]->update_display() }],
	'Test'                          => ['000-t', \&App::Asciio::Actions::Debug::test                             ],
	'ZBuffer Test'                  => ['000-z', \&App::Asciio::Actions::ZBuffer::dump_crossings                 ],
	),

CONTEXT_MENU('Asciio context_menu'       => 'as_context_menu', \&App::Asciio::Actions::Asciio::context_menu                ),
CONTEXT_MENU('Box context_menu'          => 'bo_context_menu', \&App::Asciio::Actions::Box::context_menu                   ),
CONTEXT_MENU('Multi_wirl context_menu'   => 'mw_context_menu', \&App::Asciio::Actions::Multiwirl::multi_wirl_context_menu  ),
CONTEXT_MENU('Angled arrow context_menu' => 'aa_ontext menu',  \&App::Asciio::Actions::Multiwirl::angled_arrow_context_menu),
CONTEXT_MENU('Shapes context_menu'       => 'sh_context_menu', \&App::Asciio::Actions::Shapes::context_menu                ),
) ;

# -----------------------------------------------------------------------------------

use utf8 ;

use App::Asciio::Actions ;
use App::Asciio::Actions::Align ;
use App::Asciio::Actions::Arrow ;
use App::Asciio::Actions::Asciio ;
use App::Asciio::Actions::Box ;
use App::Asciio::Actions::Clipboard ;
use App::Asciio::Actions::Clone ;
use App::Asciio::Actions::Colors ;
use App::Asciio::Actions::Completion ;
use App::Asciio::Actions::Debug ;
use App::Asciio::Actions::ElementAttributes ;
use App::Asciio::Actions::ElementSelection ;
use App::Asciio::Actions::Elements ;
use App::Asciio::Actions::ElementsManipulation ;
use App::Asciio::Actions::Eraser ;
use App::Asciio::Actions::File ;
use App::Asciio::Actions::FindAndReplace ;
use App::Asciio::Actions::Git ;
use App::Asciio::Actions::Mouse ;
use App::Asciio::Actions::Multiwirl ;
use App::Asciio::Actions::Presentation ;
use App::Asciio::Actions::Animation ;
use App::Asciio::Actions::Ruler ;
use App::Asciio::Actions::Selection ;
use App::Asciio::Actions::Shapes ;
use App::Asciio::Actions::Tabs ;
use App::Asciio::Actions::Unsorted ;
use App::Asciio::Actions::ZBuffer ;
use App::Asciio::GTK::Asciio::Actions::File ;
use App::Asciio::Utils::Scripting ;

