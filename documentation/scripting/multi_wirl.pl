
use strict;
use warnings;
use lib qw(lib lib/stripes) ;

use App::Asciio ;
use App::Asciio::stripes::section_wirl_arrow;

#-----------------------------------------------------------------------------

my $asciio = new App::Asciio() ;

#-----------------------------------------------------------------------------

my $new_element = new App::Asciio::stripes::section_wirl_arrow
					({
					POINTS => [[5, 5, 'downright'], [10, 7, 'downright'], [7, 14, 'downleft'], ],
					DIRECTION => '',
					ALLOW_DIAGONAL_LINES => 0,
					EDITABLE => 1,
					RESIZABLE => 1,
					}) ;

$asciio->add_element_at($new_element, 5, 5) ;
	
print $asciio->transform_elements_to_ascii_buffer() ;

