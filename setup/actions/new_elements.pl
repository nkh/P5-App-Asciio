
use App::Asciio::Actions::Elements ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Add box'          => ['000-b', \&App::Asciio::Actions::Elements::add_element, ['stencils/asciio/box', 0]          ],
	'Add shrink box'   => ['00S-B', \&App::Asciio::Actions::Elements::add_element, ['stencils/asciio/shrink_box', 1]   ],
	'Add text'         => ['000-t', \&App::Asciio::Actions::Elements::add_element, ['stencils/asciio/text', 0]         ],
	'Add if'           => ['000-i', \&App::Asciio::Actions::Elements::add_element, ['stencils/asciio/boxes/if', 1]     ],
	'Add process'      => ['000-p', \&App::Asciio::Actions::Elements::add_element, ['stencils/asciio/boxes/process', 1]],
	'Add arrow'        => ['000-a', \&App::Asciio::Actions::Elements::add_element, ['stencils/asciio/wirl_arrow', 0]   ],
	'Add angled arrow' => ['00S-A', \&App::Asciio::Actions::Elements::add_element, ['stencils/asciio/angled_arrow', 0] ],
	) ;
	
#----------------------------------------------------------------------------------------------

