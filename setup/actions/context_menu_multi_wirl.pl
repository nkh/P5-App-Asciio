
use App::Asciio::Actions::Multiwirl ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Append multi_wirl section'            => ['000-s', \&App::Asciio::Actions::Multiwirl::append_section, undef,  \&App::Asciio::Actions::Multiwirl::multi_wirl_context_menu ],
	'Prepend multi_wirl section'           => ['0A0-s', \&App::Asciio::Actions::Multiwirl::prepend_section                                                                    ],
	'Remove last section from multi_wirl'  => ['CA0-s', \&App::Asciio::Actions::Multiwirl::remove_last_section_from_section_wirl_arrow                                        ],
	# 'Remove first section from multi_wirl' => ['000-q', \&App::Asciio::Actions::Multiwirl::remove_first_section_from_section_wirl_arrow                                       ],
	'Insert multi_wirl section'            => ['00S-S', \&App::Asciio::Actions::Multiwirl::insert_wirl_arrow_section                                                          ],
	) ;


