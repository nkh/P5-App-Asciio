
use App::Asciio::Actions::Elements ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
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
	'Add help box'           => [ 'C00-h', \&App::Asciio::Actions::Elements::add_help_box,                                             ],
	) ;
	
#----------------------------------------------------------------------------------------------

