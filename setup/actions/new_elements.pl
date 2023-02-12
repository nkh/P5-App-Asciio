
use App::Asciio::Actions::Elements ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Insert gui commands' => 
		{
		SHORTCUTS => '000-i',
		
		# needsubs that are not gtk3 dependent
		# 'Import from primary to box'                     => [ '???' ],
		# 'Import from clipboard to box'                   => [ '???' ],
		
		'External command output in a box'                      => ['000-x',           \&App::Asciio::Actions::Unsorted::external_command_output, 1                    ],
		'External command output in a box no frame'             => ['00S-X',           \&App::Asciio::Actions::Unsorted::external_command_output, 0                    ],
		
		# 'Insert from file'     => [ 'f' ], ???
		
		'Create multiple box elements from a text description'  => ['00S-M',           \&App::Asciio::Actions::Unsorted::insert_multiple_boxes_from_text_description, 1],
		'Create multiple text elements from a text description' => ['00S-T',           \&App::Asciio::Actions::Unsorted::insert_multiple_boxes_from_text_description, 0],
		
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
	) ;
	
#----------------------------------------------------------------------------------------------

