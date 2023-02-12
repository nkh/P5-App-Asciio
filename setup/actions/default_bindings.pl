
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

#----------------------------------------------------------------------------------------------

register_action_handlers
(
'Undo'                             => [['C00-z', '000-u'],            \&App::Asciio::Actions::Unsorted::undo    ],
'Redo'                             => [['C00-y', 'C00-r'],            \&App::Asciio::Actions::Unsorted::redo    ],
'Zoom in'                          => ['000-plus',                    \&App::Asciio::Actions::Unsorted::zoom, 1 ],
'Zoom out'                         => ['000-minus',                   \&App::Asciio::Actions::Unsorted::zoom, -1],
'Copy to clipboard'                => [ ['C00-c', 'C00-Insert', 'y'], \&App::Asciio::Actions::Clipboard::copy_to_clipboard    ],
'Insert from clipboard'            => [ ['C00-v', '00S-Insert', 'p'], \&App::Asciio::Actions::Clipboard::insert_from_clipboard],

'Change elements foreground color' => ['000-c', \&App::Asciio::Actions::Colors::change_elements_colors, 0     ],
'Change elements background color' => ['000-C', \&App::Asciio::Actions::Colors::change_elements_colors, 1     ],
'Flip arrow start and end'         => ['000-f', \&App::Asciio::Actions::ElementsManipulation::flip_arrow_ends ],
'Remove rulers'                    => ['0A0-r', \&App::Asciio::Actions::Ruler::remove_ruler                   ],

'Select next element'              => [['000-Tab', '000-n'],  \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [1, 0]         ],
'Select previous element'          => [['00S-ISO_Left_Tab', '00S-N'], \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [0, 0] ],
'Select element by id'             => ['C00-Tab',          \&App::Asciio::Actions::ElementsManipulation::select_element_by_id                        ],

'Select all elements'              => [['C00-a', '00S-V'], \&App::Asciio::Actions::ElementsManipulation::select_all_elements                         ],
'Deselect all elements'            => ['000-Escape',       \&App::Asciio::Actions::ElementsManipulation::deselect_all_elements                       ],
'Select connected elements'        => ['000-v',            \&App::Asciio::Actions::ElementsManipulation::select_connected                            ],

'Delete selected elements'         => [['000-Delete', '000-d'], \&App::Asciio::Actions::ElementsManipulation::delete_selected_elements               ],
'Edit selected element'            => ['000-Return',       \&App::Asciio::Actions::ElementsManipulation::edit_selected_element                       ],

'Move selected elements left'      => ['000-Left',         \&App::Asciio::Actions::ElementsManipulation::move_selection_left                         ],
'Move selected elements right'     => ['000-Right',        \&App::Asciio::Actions::ElementsManipulation::move_selection_right                        ],
'Move selected elements up'        => ['000-Up',           \&App::Asciio::Actions::ElementsManipulation::move_selection_up                           ],
'Move selected elements down'      => ['000-Down',         \&App::Asciio::Actions::ElementsManipulation::move_selection_down                         ],

'Move selected elements left 2'    => ['h',                \&App::Asciio::Actions::ElementsManipulation::move_selection_left ],
'Move selected elements right 2'   => ['l',                \&App::Asciio::Actions::ElementsManipulation::move_selection_right],
'Move selected elements up 2'      => ['k',                \&App::Asciio::Actions::ElementsManipulation::move_selection_up   ],
'Move selected elements down 2'    => ['j',                \&App::Asciio::Actions::ElementsManipulation::move_selection_down ],

'Shrink box'                       => ['000-s',            \&App::Asciio::Actions::ElementsManipulation::shrink_box                                  ],

'Make element narrower'            => ['000-1',            \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [-1, 0]              ],
'Make element taller'              => ['000-2',            \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [0,  1]              ],
'Make element shorter'             => ['000-3',            \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [0, -1]              ],
'Make element wider'               => ['000-4',            \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [1,  0]              ],

'Quick link'                       => [['00S-button_press-1', '000-period', '.'], \&App::Asciio::Actions::Mouse::quick_link                    ] ,
'Insert flex point'                => ['0A0-button_press-1', \&App::Asciio::Actions::Multiwirl::insert_wirl_arrow_section ],

# 'left button pressed'              => ['000-button_press-1', \&left_button_pressed                                        ] ,

'Toggle mouse'                     => ['000-apostrophe',     \&App::Asciio::Actions::Mouse::toggle_mouse                  ] ,

'Mouse left-click'                 => ['000-odiaeresis',     \&App::Asciio::Actions::Mouse::mouse_left_click              ] ,
'Mouse shift-left-click'           => ['00S-Odiaeresis',     \&App::Asciio::Actions::Mouse::mouse_shift_left_click        ] ,
'Mouse ctl-left-click'             => ['C00-odiaeresis',     \&App::Asciio::Actions::Mouse::mouse_ctl_left_click          ] ,
'Mouse alt-left-click'             => ['0A0-odiaeresis',     \&App::Asciio::Actions::Mouse::mouse_alt_left_click          ] ,

'Mouse right-click'                => ['000-adiaeresis',     \&App::Asciio::Actions::Mouse::mouse_right_click             ] ,

'Mouse drag left'                  => ['00S-Left',           \&App::Asciio::Actions::Mouse::mouse_drag_left               ] ,
'Mouse drag right'                 => ['00S-Right',          \&App::Asciio::Actions::Mouse::mouse_drag_right              ] ,
'Mouse drag up'                    => ['00S-Up',             \&App::Asciio::Actions::Mouse::mouse_drag_up                 ] ,
'Mouse drag down'                  => ['00S-Down',           \&App::Asciio::Actions::Mouse::mouse_drag_down               ] ,

'Mouse on element id'              => ['000-m',              \&App::Asciio::Actions::Mouse::mouse_on_element_id           ] ,
#~ 'C00-button_release' => ['', ] ,
#~ 'C00-motion_notify' =>['', ] ,

'Angled arrow context_menu'        => ['angled arrow context menu', undef, undef, \&angled_arrow_context_menu ],
'box_context_menu'                 => ['box_context_menu', undef, undef, \&App::Asciio::Actions::Box::box_context_menu],

'grouping default commands' => 
	{
	SHORTCUTS => '000-g',
	
	'Group selected elements'                      => ['000-g', \&App::Asciio::Actions::ElementsManipulation::group_selected_elements                     ],
	'Ungroup selected elements'                    => ['000-u', \&App::Asciio::Actions::ElementsManipulation::ungroup_selected_elements                   ],
	'Move selected elements to the front'          => ['000-f', \&App::Asciio::Actions::ElementsManipulation::move_selected_elements_to_front             ],
	'Move selected elements to the back'           => ['000-b', \&App::Asciio::Actions::ElementsManipulation::move_selected_elements_to_back              ],
	'Temporary move selected element to the front' => ['00S-F', \&App::Asciio::Actions::ElementsManipulation::temporary_move_selected_element_to_front    ],
	},

'stripes default commands' => 
	{
	SHORTCUTS => '0A0-g',
	
	'create stripes group'    => ['000-g', \&App::Asciio::Actions::ElementsManipulation::create_stripes_group, 0                     ],
	'create one stripe group' => ['000-1', \&App::Asciio::Actions::ElementsManipulation::create_stripes_group, 1                     ],
	'ungroup stripes group'   => ['000-u', \&App::Asciio::Actions::ElementsManipulation::ungroup_stripes_group                       ],
	},

'align default commands' => 
	{
	SHORTCUTS => '000-A',
	
	'Align left'   => ['000-l', \&App::Asciio::Actions::Align::align, 'left'  ],
	'Align center' => ['000-c', \&App::Asciio::Actions::Align::align, 'center'],
	'Align right'  => ['000-r', \&App::Asciio::Actions::Align::align, 'right' ],
	'Align top'    => ['000-t', \&App::Asciio::Actions::Align::align, 'top'   ],
	'Align middle' => ['000-m', \&App::Asciio::Actions::Align::align, 'middle'],
	'Align bottom' => ['000-b', \&App::Asciio::Actions::Align::align, 'bottom'],
	# spread vertically	# spread horizontally # adjacent vert # adjacent hor # stack
	},

'change default color'=> 
	{
	SHORTCUTS => '000-z',
	
	'Change Asciio background color'      => ['000-c', \&App::Asciio::Actions::Colors::change_background_color ],
	'Change grid color'                   => ['000-C', \&App::Asciio::Actions::Colors::change_grid_color       ],
	'Flip color scheme'                   => ['000-s', \&App::Asciio::Actions::Colors::flip_color_scheme       ],
	'Flip transparent element background' => ['000-t', \&App::Asciio::Actions::Unsorted::transparent_elements  ],
	'Flip grid display'                   => ['000-g', \&App::Asciio::Actions::Unsorted::flip_grid_display     ],
	},

'arrow default commands' => 
	{
	SHORTCUTS => '000-a',
	
	'Change arrow direction'              => ['000-d', \&App::Asciio::Actions::ElementsManipulation::change_arrow_direction                                                  ],
	'Append multi_wirl section'           => ['000-s', \&App::Asciio::Actions::Multiwirl::append_section, undef,  \&App::Asciio::Actions::Multiwirl::multi_wirl_context_menu ],
	'Insert multi_wirl section'           => ['000-S', \&App::Asciio::Actions::Multiwirl::insert_wirl_arrow_section                                                          ],
	'Prepend multi_wirl section'          => ['0A0-s', \&App::Asciio::Actions::Multiwirl::prepend_section                                                                    ],
	'Remove last section from multi_wirl' => ['C00-s', \&App::Asciio::Actions::Multiwirl::remove_last_section_from_section_wirl_arrow                                        ],
	},

'debug default commands' => 
	{
	SHORTCUTS => '00S-D',
	
	'Display undo stack statistics' => ['000-u', \&App::Asciio::Actions::Unsorted::display_undo_stack_statistics ],
	'Dump self'                     => ['000-s', \&App::Asciio::Actions::Debug::dump_self                        ],
	'Dump all elements'             => ['000-e', \&App::Asciio::Actions::Debug::dump_all_elements                ],
	'Dump selected elements'        => ['000-E', \&App::Asciio::Actions::Debug::dump_selected_elements           ],
	'Display numbered objects'      => ['000-t', sub { $_[0]->{NUMBERED_OBJECTS} ^= 1 ; $_[0]->update_display() }],
	'Test'                          => ['000-o', \&App::Asciio::Actions::Debug::test                             ],
	},

'command default mode'=> 
	{
	SHORTCUTS => '00S-colon',
	
	# 'Help'                     => [ 'h' ],
	'Display keyboard mapping' => ['000-k', \&App::Asciio::Actions::Unsorted::display_keyboard_mapping],
	'Display commands'         => ['000-c', \&App::Asciio::Actions::Unsorted::display_commands        ],
	'Display action files'     => ['000-f', \&App::Asciio::Actions::Unsorted::display_action_files    ],
	
	'Open'                     => ['000-e', \&App::Asciio::Actions::File::open        ],
	'Save'                     => ['000-w', \&App::Asciio::Actions::File::save, undef ],
	'SaveAs'                   => ['00S-W', \&App::Asciio::Actions::File::save, 'as'  ],
	'Insert'                   => ['000-r', \&App::Asciio::Actions::File::insert      ],
	'Quit'                     => ['000-q', \&App::Asciio::Actions::File::quit        ],
	'Quit no save'             => ['00S-Q', \&App::Asciio::Actions::File::quit_no_save],
	},

'Insert default commands' => 
	{
	SHORTCUTS => '000-i',
	
	# need subs that are not gtk3 dependent
	# 'Import from primary to box'                     => [ '???' ],
	# 'Import from clipboard to box'                   => [ '???' ],
	
	'External command output in a box'                      => ['000-x', \&App::Asciio::Actions::Unsorted::external_command_output, 1                    ],
	'External command output in a box no frame'             => ['00S-X', \&App::Asciio::Actions::Unsorted::external_command_output, 0                    ],
	
	# 'Insert from file'     => [ 'f' ], ???
	
	'Create multiple box elements from a text description'  => ['00S-M', \&App::Asciio::Actions::Unsorted::insert_multiple_boxes_from_text_description, 1],
	'Create multiple text elements from a text description' => ['00S-T', \&App::Asciio::Actions::Unsorted::insert_multiple_boxes_from_text_description, 0],
	
	'Add vertical ruler'     => [ '000-r', \&App::Asciio::Actions::Ruler::add_ruler,      {TYPE => 'VERTICAL'},  \&App::Asciio::Actions::Ruler::rulers_context_menu ],
	'Add horizontal ruler'   => [ '00S-R', \&App::Asciio::Actions::Ruler::add_ruler,      {TYPE => 'HORIZONTAL'}                       ],
	'Add box'                => [ '000-b', \&App::Asciio::Actions::Elements::add_element, ['Stencils/Asciio/box', 0]                   ],
	'Add shrink box'         => [ '00S-B', \&App::Asciio::Actions::Elements::add_element, ['Stencils/Asciio/shrink_box', 1]            ],
	'Add text'               => [ '000-t', \&App::Asciio::Actions::Elements::add_element, ['Stencils/Asciio/text', 1]                  ],
	'Add if'                 => [ '000-i', \&App::Asciio::Actions::Elements::add_element, ['Stencils/Asciio/Boxes/if', 1]              ],
	'Add process'            => [ '000-p', \&App::Asciio::Actions::Elements::add_element, ['Stencils/Asciio/Boxes/process', 1]         ],
	'Add exec box'           => [ '000-e', \&App::Asciio::Actions::Elements::add_element, ['Stencils/Asciio/Boxes/exec', 1]            ],
	'Add exec box no border' => [ '00S-E', \&App::Asciio::Actions::Elements::add_element, ['Stencils/Asciio/Boxes/exec no border', 1]  ],
	'Add arrow'              => [ '000-a', \&App::Asciio::Actions::Elements::add_element, ['Stencils/Asciio/wirl_arrow', 0]            ],
	'Add angled arrow'       => [ '00S-A', \&App::Asciio::Actions::Elements::add_element, ['Stencils/Asciio/angled_arrow', 0]          ],
	'Add connector'          => [ '000-c', \&App::Asciio::Actions::Elements::add_element, ['Stencils/Asciio/connector', 0]             ],
	'Add help box'           => [ '000-h', \&App::Asciio::Actions::Elements::add_help_box,                                             ],
	},

'slides default commands' => 
	{
	SHORTCUTS => '00S-S',
	
	'Load slides'    => ['000-l', \&App::Asciio::Actions::Presentation::load_slides   ] ,
	'previous slide' => ['00S-N', \&App::Asciio::Actions::Presentation::previous_slide],
	'next slide'     => ['000-n', \&App::Asciio::Actions::Presentation::next_slide    ],
	'first slide'    => ['000-g', \&App::Asciio::Actions::Presentation::first_slide   ],
	},

) ;

#----------------------------------------------------------------------------------------------

sub angled_arrow_context_menu
{
my ($self, $popup_x, $popup_y) = @_ ;
my @context_menu_entries ;

my @selected_elements = $self->get_selected_elements(1) ;

if(@selected_elements == 1 && 'App::Asciio::stripes::angled_arrow' eq ref $selected_elements[0])
	{
	my $element = $selected_elements[0] ;
	
	push @context_menu_entries, 
		[
		$selected_elements[0]->is_autoconnect_enabled() ? '/disable autoconnection' :  '/enable autoconnection', 
		sub 
			{
			$self->create_undo_snapshot() ;
			$selected_elements[0]->enable_autoconnect(! $selected_elements[0]->is_autoconnect_enabled()) ;
			$self->update_display() ;
			}
		] ;
	}

return(@context_menu_entries) ;
}

#----------------------------------------------------------------------------------------------

