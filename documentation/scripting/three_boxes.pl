
use strict;
use warnings;
use lib qw(lib lib/stripes) ;

use App::Asciio;
use App::Asciio::stripes::editable_box2 ;

#-----------------------------------------------------------------------------

my $asciio = new App::Asciio() ;

#-----------------------------------------------------------------------------

my ($current_x, $current_y) = (0, 0) ;

for my $element_text (qw(box_1 box_2 box_3))
	{
	my $new_element = new App::Asciio::stripes::editable_box2
						({
						TEXT_ONLY => $element_text,
						TITLE => '',
						EDITABLE => 1,
						RESIZABLE => 1,
						}) ;
						
	$asciio->add_element_at($new_element, $current_x, $current_y) ;
	
	$current_x += $asciio->{COPY_OFFSET_X} ; 
	$current_y += $asciio->{COPY_OFFSET_Y} ;
	}
	
print $asciio->transform_elements_to_ascii_buffer() ;

