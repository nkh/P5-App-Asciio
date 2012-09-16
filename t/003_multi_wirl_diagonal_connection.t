
use strict;
use warnings;
use lib qw(lib lib/stripes) ;

use Test::More 'no_plan';

#-----------------------------------------------------------------------------

use Readonly ;
Readonly my $QUOTE_GLYPH => "'" ;
Readonly my $DOT_GLYPH => '.' ;
Readonly my $MINUS_GLYPH => '-' ;
Readonly my $PIPE_GLYPH => '|' ;
Readonly my $SLASH_GLYPH => '/' ;
Readonly my $BACKSLAH_GLYPH => '\\' ;

for my $multi_wirl
		(
		# expected   # 2 points                      
		
		#right + diagonal
		[$QUOTE_GLYPH, [4, 0, 'right'], [7, -3, '45']],
		[$QUOTE_GLYPH, [4, 0, 'right'], [1, -3, '315']],
		[$DOT_GLYPH, [4, 0, 'right'], [7, 3, '135']],
		[$DOT_GLYPH, [4, 0, 'right'], [1, 3, '225']],
		
		#down + diagonal
		[$QUOTE_GLYPH, [0, 4, 'down'], [3, 1, '45']], #5
		[$QUOTE_GLYPH, [0, 4, 'down'], [-3, 1, '315']],
		[$DOT_GLYPH, [0, 4, 'down'], [3, 7, '135']],
		[$DOT_GLYPH, [0, 4, 'down'], [-3, 7, '225']],

		#45+ diagonal
		[$SLASH_GLYPH, [4, -4, '45'], [7, -7, '45']], #9
		[$QUOTE_GLYPH, [4, -4, '45'], [1, -7, '315']],
		[$DOT_GLYPH, [4, -4, '45'], [7, -1, '135']],
		[$DOT_GLYPH, [4, -4, '45'], [1, -1, '225']],
		
		#225 + diagonal
		[$QUOTE_GLYPH, [-4, 4, '225'], [-1, 1, '45']], #13
		[$QUOTE_GLYPH, [-4, 4, '225'], [-7, 1, '315']],
		[$DOT_GLYPH, [-4, 4, '225'], [-1, 7, '135']],
		[$SLASH_GLYPH, [-4, 4, '225'], [-7, 7, '225']],
		
		#left + diagonal
		[$QUOTE_GLYPH, [-4, 0, 'left'], [-1, -3, '45']], #17
		[$QUOTE_GLYPH, [-4, 0, 'left'], [-7, -3, '315']],
		[$DOT_GLYPH, [-4, 0, 'left'], [-1, 3, '135']],
		[$DOT_GLYPH, [-4, 0, 'left'], [-7, 3, '225']],
		
		#up + diagonal
		[$QUOTE_GLYPH, [0, -4, 'up'], [3, -7, '45']], # 21
		[$QUOTE_GLYPH, [0, -4, 'up'], [-3, -7, '315']],
		[$DOT_GLYPH, [0, -4, 'up'], [3, -1, '135']],
		[$DOT_GLYPH, [0, -4, 'up'], [-3, -1, '225']],
		
		#135 + diagonal
		[$QUOTE_GLYPH, [4, 4, '135'], [7, 1, '45']], # 25
		[$QUOTE_GLYPH, [4, 4, '135'], [1, 1, '315']],
		[$BACKSLAH_GLYPH, [4, 4, '135'], [7, 7, '135']],
		[$DOT_GLYPH, [4, 4, '135'], [1, 7, '225']],
		
		#315 + diagonal
		[$QUOTE_GLYPH, [-4, -4, '315'], [-1, -7, '45']], # 29
		[$BACKSLAH_GLYPH, [-4, -4, '315'], [-7, -7, '315']],
		[$DOT_GLYPH, [-4, -4, '315'], [-1, -1, '135']],
		[$DOT_GLYPH, [-4, -4, '315'], [-7, -1, '225']],
		
		# digonal + non diagonal
		#45
		[$QUOTE_GLYPH, [4, -4, '45'], [4, -7, 'up']], #33
		[$DOT_GLYPH, [4, -4, '45'], [7, -4, 'right']],
		[$DOT_GLYPH, [4, -4, '45'], [4, 1, 'down']],
		[$DOT_GLYPH, [4, -4, '45'], [1, -4, 'left']],
		
		#225
		[$QUOTE_GLYPH, [-4, 4, '225'], [-4, 1, 'up']], #37
		[$QUOTE_GLYPH, [-4, 4, '225'], [1, 4, 'right']],
		[$DOT_GLYPH, [-4, 4, '225'], [-4, 7, 'down']],
		[$QUOTE_GLYPH, [-4, 4, '225'], [-7, 4, 'left']],
		
		#135
		[$QUOTE_GLYPH, [4, 4, '135'], [4, 1, 'up']], # 41
		[$QUOTE_GLYPH, [4, 4, '135'], [7, 4, 'right']],
		[$DOT_GLYPH, [4, 4, '135'], [4, 7, 'down']],
		[$QUOTE_GLYPH, [4, 4, '135'], [1, 4, 'left']],
		
		#315
		[$QUOTE_GLYPH, [-4, -4, '315'], [-4, -7, 'up']], # 45
		[$DOT_GLYPH, [-4, -4, '315'], [-1, -4, 'right']],
		[$DOT_GLYPH, [-4, -4, '315'], [-4, -1, 'down']],
		[$DOT_GLYPH, [-4, -4, '315'], [-7, -4, 'left']],
		)
		{
		my ($expected_connection_character, $point_1, $point_2) = @{$multi_wirl} ;
		my $origin = [10, 10] ; # offset the arrow as character with negative indexes don't ger rendered
		
		my ($text, $arrow_1_direction,$arrow_2_direction)  = get_multi_wirl_connection_text($origin, $point_1, $point_2) ;
		#~ print $text ;
		
		my @buffer ;
		my $line_index = 0 ;
		
		for my $line (split "\n", $text)
			{
			$buffer[$line_index++] = [split '', $line] ;
			}
		
		my ($origin_x, $origin_y) = @{$origin} ;
		my ($point_1_x, $point_1_y) = @{$point_1} ;
		
		is($buffer[$point_1_y + $origin_y][$point_1_x + $origin_x], $expected_connection_character)
			 or diag <<EOD ;
directions:$point_1->[2], $point_2->[2]
real directions: $arrow_1_direction,$arrow_2_direction
$text
EOD
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
					ALLOW_DIAGONAL_LINES => 1,
					EDITABLE => 1,
					RESIZABLE => 1,
					}) ;
					
my ($character_width, $character_height) = $asciio->get_character_size() ; 
my ($origin_x, $origin_y) = @{$origin} ;
@$new_element{'X', 'Y'} = ($origin_x, $origin_y) ;

$asciio->add_elements($new_element) ;

return 
	$asciio->transform_elements_to_ascii_buffer(),
	$new_element->{ARROWS}[0]{DIRECTION},
	$new_element->{ARROWS}[1]{DIRECTION},
	;
}

#-----------------------------------------------------------------------------


