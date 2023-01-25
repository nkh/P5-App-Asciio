
use App::Asciio::Actions::Unsorted ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Create multiple box elements from a text description'  => ['C00-m',           \&App::Asciio::Actions::Unsorted::insert_multiple_boxes_from_text_description, 1],
	'Create multiple text elements from a text description' => ['C00-t',           \&App::Asciio::Actions::Unsorted::insert_multiple_boxes_from_text_description, 0],
	'Flip transparent element background'                   => ['C0S-T',           \&App::Asciio::Actions::Unsorted::transparent_elements                          ],
	'Flip grid display'                                     => ['000-g',           \&App::Asciio::Actions::Unsorted::flip_grid_display                             ],
	'Undo'                                                  => ['C00-z',           \&App::Asciio::Actions::Unsorted::undo                                          ],
	'Display undo stack statistics'                         => ['C0S-Z',           \&App::Asciio::Actions::Unsorted::display_undo_stack_statistics                 ],
	'Redo'                                                  => ['C00-y',           \&App::Asciio::Actions::Unsorted::redo                                          ],
	'Display keyboard mapping'                              => ['000-F2',          \&App::Asciio::Actions::Unsorted::display_keyboard_mapping                      ],
	'Display commands'                                      => ['000-F3',          \&App::Asciio::Actions::Unsorted::display_commands                              ],
	'Display action files'                                  => ['000-F4',          \&App::Asciio::Actions::Unsorted::display_action_files                          ],
	'Zoom in'                                               => ['000-plus',        \&App::Asciio::Actions::Unsorted::zoom, 1                                       ],
	# 'Zoom in'                                               => ['000-KP_Add',      \&App::Asciio::Actions::Unsorted::zoom, 1                                       ],
	'Zoom out'                                              => ['000-minus',       \&App::Asciio::Actions::Unsorted::zoom, -1                                      ],
	# 'Zoom out'                                              => ['000-KP_Subtract', \&App::Asciio::Actions::Unsorted::zoom, -1                                      ],
	'Help'                                                  => ['000-F1',          \&App::Asciio::Actions::Unsorted::display_help                                  ],
	'External command output in a box'                      => ['000-x',           \&App::Asciio::Actions::Unsorted::external_command_output, 1                    ],
	'External command output in a box no frame'             => ['0A0-x',           \&App::Asciio::Actions::Unsorted::external_command_output, 0                    ],
	) ;

#----------------------------------------------------------------------------------------------

