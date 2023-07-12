
use strict; use warnings;

use App::Asciio::Scripting ;
use App::Asciio::stripes::section_wirl_arrow;

#-----------------------------------------------------------------------------

add 'multi_wirl',
	new App::Asciio::stripes::section_wirl_arrow
		({
		POINTS => [[5, 5, 'downright'], [10, 7, 'downright'], [7, 14, 'downleft'], ],
		DIRECTION => '',
		}),
	5, 5 ;

print to_ascii() ;

