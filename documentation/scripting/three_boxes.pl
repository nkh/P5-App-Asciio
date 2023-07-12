
use strict;
use warnings;

use App::Asciio::Scripting ;
use App::Asciio::stripes::editable_box2 ;

#-----------------------------------------------------------------------------

my ($x, $y) = (0, 0) ;

for my $text (qw(box_1 box_2 box_3))
	{
	add $text,
		new App::Asciio::stripes::editable_box2
			({
			TEXT_ONLY => $text,
			TITLE => '',
			EDITABLE => 1,
			RESIZABLE => 1,
			}),
		$x,
		$y ; 
	
	$x += 10 ;
	$y += 10 ;
	}

ascii_out ;

