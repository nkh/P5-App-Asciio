
use App::Asciio::Actions::Multiwirl ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'arrow gui commands' => 
		{
		SHORTCUTS => 'a',
		
		'Append multi_wirl section'           => ['000-s', \&App::Asciio::Actions::Multiwirl::append_section, undef,  \&App::Asciio::Actions::Multiwirl::multi_wirl_context_menu ],
		'Insert multi_wirl section'           => ['000-S', \&App::Asciio::Actions::Multiwirl::insert_wirl_arrow_section                                                          ],
		'Prepend multi_wirl section'          => ['0A0-s', \&App::Asciio::Actions::Multiwirl::prepend_section],
		'Remove last section from multi_wirl' => ['C00-s', \&App::Asciio::Actions::Multiwirl::remove_last_section_from_section_wirl_arrow                                        ],
		},
	
	'Change arrow direction'                        => ['000-d',            \&App::Asciio::Actions::ElementsManipulation::change_arrow_direction                   ],
	'Flip arrow start and end'                      => ['000-f',            \&App::Asciio::Actions::ElementsManipulation::flip_arrow_ends                          ],
	) ;


