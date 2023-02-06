
use App::Asciio::Actions::ElementsManipulation ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Select next element'                           => ['000-Tab',          \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [1, 0]         ],
	'Select previous element'                       => ['00S-ISO_Left_Tab', \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [0, 0]         ],
	'Select element by id'                          => ['C00-Tab',          \&App::Asciio::Actions::ElementsManipulation::select_element_by_id                     ],
	
	'Select all elements'                           => ['C00-a',            \&App::Asciio::Actions::ElementsManipulation::select_all_elements                      ],
	'Deselect all elements'                         => ['000-l',            \&App::Asciio::Actions::ElementsManipulation::deselect_all_elements                    ],
	'Select connected elements'                     => ['00S-P',            \&App::Asciio::Actions::ElementsManipulation::select_connected                         ],
	
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
	
	'Shrink box'                                    => ['000-0',            \&App::Asciio::Actions::ElementsManipulation::shrink_box                               ],
	'Resize element narrower'                       => ['000-1',            \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [-1, 0]           ],
	'Resize element taller'                         => ['000-2',            \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [0,  1]           ],
	'Resize element shorter'                        => ['000-3',            \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [0, -1]           ],
	'Resize element wider'                          => ['000-4',            \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [1,  0]           ],
	
	'stripes group'=> 
		{
		SHORTCUTS => '0A0-g',
		
		'create stripes group'                  => ['000-g',            \&App::Asciio::Actions::ElementsManipulation::create_stripes_group, 0                  ],
		'create one stripe group'               => ['000-1',            \&App::Asciio::Actions::ElementsManipulation::create_stripes_group, 1                  ],
		'ungroup stripes group'                 => ['000-u',            \&App::Asciio::Actions::ElementsManipulation::ungroup_stripes_group                    ],
		}
	) ;



