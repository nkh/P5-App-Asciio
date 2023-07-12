
use strict; use warnings;

use Data::TreeDumper ;

use App::Asciio::Scripting ;
use App::Asciio::stripes::if_box ;

#-----------------------------------------------------------------------------

my @text = (
	'a == 1235',
	'b < 0',
	'b > 125',
	'very long',
	'&& $x >= $y_123',
	'c eq 35',
	' $a ~= /^$/',
	) ;

my ($box_index, $next_line) = (0, 0) ;

for (1 .. 7)
	{
	my $text ; 
	for (1 .. $box_index)
		{
		$text .= $text[rand(@text)] . "\n" ;
		}
	
	my $if_box = new App::Asciio::stripes::if_box
				({
				TEXT_ONLY => $text,
				EDITABLE => 1,
				RESIZABLE => 1,
				}) ;
	
	add 'if_box', $if_box, 0, $next_line ;
	
	my ($w, $h) = $if_box->get_size() ;
	$next_line += $h + 1 ;
	
	$box_index++ ;
	}

ascii_out ;

