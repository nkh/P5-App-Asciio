
use App::Asciio::Actions::ElementsManipulation ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Select next element'                           => ['000-Tab',          \&App::Asciio::Actions::ElementsManipulation::select_next_element                      ],
	'Select previous element'                       => ['00S-ISO_Left_Tab', \&App::Asciio::Actions::ElementsManipulation::select_previous_element                  ],
	
	'Select all elements'                           => ['C00-a',            \&App::Asciio::Actions::ElementsManipulation::select_all_elements                      ],
	'Deselect all elements'                         => ['000-l',            \&App::Asciio::Actions::ElementsManipulation::deselect_all_elements                    ],
	
	'Delete selected elements'                      => ['000-Delete',       \&App::Asciio::Actions::ElementsManipulation::delete_selected_elements                 ],
	
	'Group selected elements'                       => ['C00-g',            \&App::Asciio::Actions::ElementsManipulation::group_selected_elements                  ],
	'Ungroup selected elements'                     => ['C00-u',            \&App::Asciio::Actions::ElementsManipulation::ungroup_selected_elements                ],
	
	'Move selected elements to the front'           => ['C00-f',            \&App::Asciio::Actions::ElementsManipulation::move_selected_elements_to_front          ],
	'Move selected elements to the back'            => ['C00-b',            \&App::Asciio::Actions::ElementsManipulation::move_selected_elements_to_back           ],
	'Temporary move selected element to the front'  => ['0A0-f',            \&App::Asciio::Actions::ElementsManipulation::temporary_move_selected_element_to_front ],
	
	'Edit selected element'                         => ['000-Return',       \&App::Asciio::Actions::ElementsManipulation::edit_selected_element                    ],
	
	'Move selected elements left'                   => ['000-Left',         \&App::Asciio::Actions::ElementsManipulation::move_selection_left                      ],
	'Move selected elements right'                  => ['000-Right',        \&App::Asciio::Actions::ElementsManipulation::move_selection_right                     ],
	'Move selected elements up'                     => ['000-Up',           \&App::Asciio::Actions::ElementsManipulation::move_selection_up                        ],
	'Move selected elements down'                   => ['000-Down',         \&App::Asciio::Actions::ElementsManipulation::move_selection_down                      ],
	
	'Change arrow direction'                        => ['000-d',            \&App::Asciio::Actions::ElementsManipulation::change_arrow_direction                   ],
	'Flip arrow start and end'                      => ['000-f',            \&App::Asciio::Actions::ElementsManipulation::flip_arrow_ends                          ],
	) ;
	

