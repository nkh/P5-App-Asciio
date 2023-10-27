
use strict;
use warnings;
use lib qw(lib lib/stripes) ;

use Test::More 'no_plan';

#-----------------------------------------------------------------------------

use Readonly ;

Readonly my $QUOTE_GLYPH => "'" ;
Readonly my $DOT_GLYPH   => '.' ;
Readonly my $MINUS_GLYPH => '-' ;
Readonly my $PIPE_GLYPH  => '|' ;

for my $multi_wirl
		(
		# expected   # 2 points                      
		[$MINUS_GLYPH, [-2, -2, 'upleft'], [-4, -2, 'left']],
		[$DOT_GLYPH, [0, -2, 'up'],      [-4, -2, 'left']],
		[$QUOTE_GLYPH, [2, -2, 'upright'], [0, -4, 'upleft']],
		
		[$QUOTE_GLYPH, [5, 0, 'right'],    [0, -2, 'upleft']],
		[$DOT_GLYPH, [5, -2, 'rightup'], [0, -2, 'left']],
		[$QUOTE_GLYPH, [5, 2, 'rightdown'], [0, 2, 'left']],
		
		[$MINUS_GLYPH, [-2, 5, 'downleft'],    [-5, 5, 'left']],
		[$QUOTE_GLYPH, [0, 5, 'down'], [-5, 5, 'left']],
		[$DOT_GLYPH, [5, 2, 'downright'], [0, 4, 'downleft']],
		
		[$MINUS_GLYPH, [-2, 0, 'left'],    [-5, 0, 'left']],
		[$DOT_GLYPH,  [-2, -2, 'leftup'], [-5, -2, 'left']],
		[$QUOTE_GLYPH, [-2, 2, 'leftdown'], [-5, 2, 'left']],
		
		#--------------------------------------------------------------------------------------
		
		[$QUOTE_GLYPH, [-2, -2, 'upleft'], [-2, -4, 'up']],
		[$PIPE_GLYPH, [0, -2, 'up'],      [0, -4, 'up']],
		[$QUOTE_GLYPH, [2, -2, 'upright'], [2, -4, 'up']],
		
		[$QUOTE_GLYPH, [5, 0, 'right'],    [5, -2, 'up']],
		[$PIPE_GLYPH, [5, -2, 'rightup'], [5, -4, 'up']],
		[$QUOTE_GLYPH, [5, 2, 'rightdown'], [10, 0, 'rightup']],
		
		[$QUOTE_GLYPH, [-2, 5, 'downleft'],    [-2, 0, 'up']],
		[$QUOTE_GLYPH, [0, 5, 'down'], [2, 0, 'rightup']],
		[$QUOTE_GLYPH, [5, 2, 'downright'], [5, 0, 'up']],
		
		[$QUOTE_GLYPH, [-2, 0, 'left'],    [-2, -2, 'up']],
		[$PIPE_GLYPH,  [-2, -2, 'leftup'], [-2, -4, 'up']],
		[$QUOTE_GLYPH, [-2, 2, 'leftdown'], [-4, 0, 'leftup']],
		
		#--------------------------------------------------------------------------------------
		
		[$QUOTE_GLYPH, [-2, -2, 'upleft'], [0, -4, 'upright']],
		[$DOT_GLYPH, [0, -2, 'up'],      [4, 0, 'right']],
		[$MINUS_GLYPH, [2, -2, 'upright'], [4, -2, 'right']],
		
		[$MINUS_GLYPH, [5, 0, 'right'],    [8, 0, 'right']],
		[$DOT_GLYPH, [5, -2, 'rightup'], [8, -2, 'right']],
		[$QUOTE_GLYPH, [5, 2, 'rightdown'], [10, 2, 'right']],
		
		[$DOT_GLYPH, [-2, 5, 'downleft'],    [0, 7, 'downright']],
		[$QUOTE_GLYPH, [0, 5, 'down'], [5, 5, 'right']],
		[$MINUS_GLYPH, [5, 2, 'downright'], [8, 2, 'right']],
		
		[$QUOTE_GLYPH, [-2, 0, 'left'],    [0, -2, 'upright']],
		[$DOT_GLYPH,  [-2, -2, 'leftup'], [0, -2, 'right']],
		[$QUOTE_GLYPH, [-2, 2, 'leftdown'], [0, 2, 'right']],
		
		#--------------------------------------------------------------------------------------
		
		[$DOT_GLYPH, [-2, -2, 'upleft'], [-2, 4, 'down']],
		[$DOT_GLYPH, [0, -2, 'up'],      [4, 0, 'rightdown']],
		[$DOT_GLYPH, [2, -2, 'upright'], [2, 2, 'down']],
		
		[$DOT_GLYPH, [5, 0, 'right'],    [5, 5, 'down']],
		[$DOT_GLYPH, [5, -2, 'rightup'], [8, 2, 'rightdown']],
		[$PIPE_GLYPH, [5, 2, 'rightdown'], [5, 5, 'down']],
		
		[$DOT_GLYPH, [-2, 5, 'downleft'],    [-2, 7, 'down']],
		[$PIPE_GLYPH, [0, 5, 'down'], [0, 8, 'down']],
		[$DOT_GLYPH, [5, 2, 'downright'], [5, 5, 'down']],
		
		[$DOT_GLYPH, [-2, 0, 'left'],    [-2, 5, 'down']],
		[$DOT_GLYPH,  [-2, -2, 'leftup'], [-4, -4, 'leftdown']],
		[$PIPE_GLYPH, [-2, 2, 'leftdown'], [-2, 4, 'down']],
		
		#--------------------------------------------------------------------------------------
		
		)
		{
		my ($expected_connection_character, $point_1, $point_2) = $multi_wirl->@* ;
		my ($origin_x, $origin_y) = (10, 10) ; # offset the arrow as character with negative indexes don't get rendered
		
		my $text = get_multi_wirl_connection_text([$origin_x, $origin_y], $point_1, $point_2) ;
		
		my ($line_index, @buffer) = (0) ;
		for my $line (split "\n", $text)
			{
			$buffer[$line_index++] = [split '', $line] ;
			}
		
		my ($point_1_x, $point_1_y) = @{$point_1} ;
		
		is($buffer[$point_1_y + $origin_y][$point_1_x + $origin_x], $expected_connection_character)
			or diag "$point_1->[2], $point_2->[2]\n$text" ;
		}

#-----------------------------------------------------------------------------

sub get_multi_wirl_connection_text
{
my ($origin, @points) = @_ ;

use App::Asciio ;
use App::Asciio::stripes::section_wirl_arrow;
my $asciio = new App::Asciio() ;
$asciio->set_character_size(8, 16) ;

my $new_element = new App::Asciio::stripes::section_wirl_arrow
					({
					POINTS => [@points],
					DIRECTION => '',
					ALLOW_DIAGONAL_LINES => 0,
					EDITABLE => 1,
					RESIZABLE => 1,
					}) ;
					
my ($character_width, $character_height) = $asciio->get_character_size() ; 
my ($origin_x, $origin_y) = @{$origin} ;
@$new_element{'X', 'Y'} = ($origin_x, $origin_y) ;

$asciio->add_elements($new_element) ;

return join("\n", $asciio->transform_elements_to_ascii_array()) . "\n" ;
}

#-----------------------------------------------------------------------------


