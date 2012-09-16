
use strict;
use warnings;
use lib qw(lib lib/stripes) ;

use Test::More 'no_plan';

use Data::TreeDumper ;
use Hash::Slice 'slice' ;

#-----------------------------------------------------------------------------

use Readonly ;
Readonly my $QUOTE_GLYPH => "'" ;
Readonly my $DOT_GLYPH => '.' ;
Readonly my $MINUS_GLYPH => '-' ;
Readonly my $PIPE_GLYPH => '|' ;

for my $angled_arrow_test
		(
		# up, down, left, up, and origin are generic, angled arrow direction does not matter
		{
		ORIGIN => {X => 0, Y => 0}, END_X => 0, END_Y => 0, DIRECTION => 'up-right', RENDERING => <<'EOR',
s
EOR
		},
		{
		ORIGIN => {X => 1, Y => 0}, END_X => -1, END_Y => 0, DIRECTION => 'up-right', RENDERING => <<'EOR',
es
EOR
		},
		{
		ORIGIN => {X => 2, Y => 0}, END_X => -2, END_Y => 0, DIRECTION => 'up-right', RENDERING => <<'EOR',
e1s
EOR
		},
		{
		ORIGIN => {X => 3, Y => 0}, END_X => -3, END_Y => 0, DIRECTION => 'up-right', RENDERING => <<'EOR',
e11s
EOR
		},
		{
		ORIGIN => {X => 0, Y => 0}, END_X => 1, END_Y => 0, DIRECTION => 'up-right', RENDERING => <<'EOR',
se
EOR
		},
		{
		ORIGIN => {X => 0, Y => 0}, END_X => 2, END_Y => 0, DIRECTION => 'up-right', RENDERING => <<'EOR',
s1e
EOR
		},
		
		#----------------------------------------------------------
		
		{
		ORIGIN => {X => 0, Y => 2}, END_X => 2, END_Y => -2, DIRECTION => 'up-right', RENDERING => <<'EOR',
  c
 1
s
EOR
		},
		{
		ORIGIN => {X => 0, Y => 1}, END_X => 2, END_Y => -1, DIRECTION => 'up-right', RENDERING => <<'EOR',
 ce
s
EOR
		},
		{
		ORIGIN => {X => 0, Y => 1}, END_X => 1, END_Y => -1, DIRECTION => 'up-right', RENDERING => <<'EOR',
 c
s
EOR
		},
		
		#----------------------------------------------------------
		
		{
		ORIGIN => {X => 7, Y => 4}, END_X => -7, END_Y => -4, DIRECTION => 'up-left', RENDERING => <<'EOR',
e22c
    1
     1
      1
       s
EOR
		},
		{
		ORIGIN => {X => 6, Y => 4}, END_X => -6, END_Y => -4, DIRECTION => 'up-left', RENDERING => <<'EOR',
e2c
   1
    1
     1
      s
EOR
		},
		{
		ORIGIN => {X => 5, Y => 4}, END_X => -5, END_Y => -4, DIRECTION => 'up-left', RENDERING => <<'EOR',
ec
  1
   1
    1
     s
EOR
		},
		{
		ORIGIN => {X => 4, Y => 4}, END_X => -4, END_Y => -4, DIRECTION => 'up-left', RENDERING => <<'EOR',
c
 1
  1
   1
    s
EOR
		},
		{
		ORIGIN => {X => 3, Y => 4}, END_X => -3, END_Y => -4, DIRECTION => 'up-left', RENDERING => <<'EOR',
c
 1
  1
   C
   s
EOR
		},
		{
		ORIGIN => {X => 2, Y => 4}, END_X => -2, END_Y => -4, DIRECTION => 'up-left', RENDERING => <<'EOR',
c
 1
  C
  |
  s
EOR
		},
		{
		ORIGIN => {X => 1, Y => 4}, END_X => -1, END_Y => -4, DIRECTION => 'up-left', RENDERING => <<'EOR',
c
 C
 |
 |
 s
EOR
		},
		{
		ORIGIN => {X => 0, Y => 4}, END_X => 0, END_Y => -4, DIRECTION => 'up-left', RENDERING => <<'EOR',
e
1
1
1
s
EOR
		},
		
		#----------------------------------------------------------
		
		{
		ORIGIN => {X => 7, Y => 4}, END_X => -7, END_Y => -4, DIRECTION => 'left-up', RENDERING => <<'EOR',
e
 1
  1
   1
    c22s
EOR
		},
		{
		ORIGIN => {X => 6, Y => 4}, END_X => -6, END_Y => -4, DIRECTION => 'left-up', RENDERING => <<'EOR',
e
 1
  1
   1
    c2s
EOR
		},
		{
		ORIGIN => {X => 5, Y => 4}, END_X => -5, END_Y => -4, DIRECTION => 'left-up', RENDERING => <<'EOR',
e
 1
  1
   1
    cs
EOR
		},
		{
		ORIGIN => {X => 4, Y => 4}, END_X => -4, END_Y => -4, DIRECTION => 'left-up', RENDERING => <<'EOR',
e
 1
  1
   1
    c
EOR
		},
		{
		ORIGIN => {X => 3, Y => 4}, END_X => -3, END_Y => -4, DIRECTION => 'left-up', RENDERING => <<'EOR',
e
C
 1
  1
   c
EOR
		},
		{
		ORIGIN => {X => 2, Y => 4}, END_X => -2, END_Y => -4, DIRECTION => 'left-up', RENDERING => <<'EOR',
e
|
C
 1
  c
EOR
		},
		{
		ORIGIN => {X => 1, Y => 4}, END_X => -1, END_Y => -4, DIRECTION => 'left-up', RENDERING => <<'EOR',
e
|
|
C
 c
EOR
		},
		{
		# dranw as 'up'
		ORIGIN => {X => 0, Y => 4}, END_X => 0, END_Y => -4, DIRECTION => 'left-up', RENDERING => <<'EOR',
e
1
1
1
s
EOR
		},
		
		#--------------------------------------------------------------------------------------		
		{
		ORIGIN => {X => 0, Y => 4}, END_X => 7, END_Y => -4, DIRECTION => 'up-right', RENDERING => <<'EOR',
    c22e
   1
  1
 1
s
EOR
		},
		{
		ORIGIN => {X => 0, Y => 4}, END_X => 6, END_Y => -4, DIRECTION => 'up-right', RENDERING => <<'EOR',
    c2e
   1
  1
 1
s
EOR
		},
		{
		ORIGIN => {X => 0, Y => 4}, END_X => 5, END_Y => -4, DIRECTION => 'up-right', RENDERING => <<'EOR',
    ce
   1
  1
 1
s
EOR
		},
		{
		ORIGIN => {X => 0, Y => 4}, END_X => 4, END_Y => -4, DIRECTION => 'up-right', RENDERING => <<'EOR',
    c
   1
  1
 1
s
EOR
		},
		{
		ORIGIN => {X => 0, Y => 4}, END_X => 3, END_Y => -4, DIRECTION => 'up-right', RENDERING => <<'EOR',
   c
  1
 1
C
s
EOR
		},
		{
		ORIGIN => {X => 0, Y => 4}, END_X => 2, END_Y => -4, DIRECTION => 'up-right', RENDERING => <<'EOR',
  c
 1
C
|
s
EOR
		},
		{
		ORIGIN => {X => 0, Y => 4}, END_X => 1, END_Y => -4, DIRECTION => 'up-right', RENDERING => <<'EOR',
 c
C
|
|
s
EOR
		},
		{
		# drawn as 'up'
		ORIGIN => {X => 0, Y => 4}, END_X => 0, END_Y => -4, DIRECTION => 'up-right', RENDERING => <<'EOR',
e
1
1
1
s
EOR
		},
		
		#--------------------------------------------------------------------------------------
		{
		ORIGIN => {X => 0, Y => 4}, END_X => 7, END_Y => -4, DIRECTION => 'right-up', RENDERING => <<'EOR',
       e
      1
     1
    1
s22c
EOR
		},
		{
		ORIGIN => {X => 0, Y => 4}, END_X => 6, END_Y => -4, DIRECTION => 'right-up', RENDERING => <<'EOR',
      e
     1
    1
   1
s2c
EOR
		},
		{
		ORIGIN => {X => 0, Y => 4}, END_X => 5, END_Y => -4, DIRECTION => 'right-up', RENDERING => <<'EOR',
     e
    1
   1
  1
sc
EOR
		},
		{
		ORIGIN => {X => 0, Y => 4}, END_X => 4, END_Y => -4, DIRECTION => 'right-up', RENDERING => <<'EOR',
    e
   1
  1
 1
c
EOR
		},
		{
		ORIGIN => {X => 0, Y => 4}, END_X => 3, END_Y => -4, DIRECTION => 'right-up', RENDERING => <<'EOR',
   e
   C
  1
 1
c
EOR
		},
		{
		ORIGIN => {X => 0, Y => 4}, END_X => 2, END_Y => -4, DIRECTION => 'right-up', RENDERING => <<'EOR',
  e
  |
  C
 1
c
EOR
		},
		{
		ORIGIN => {X => 0, Y => 4}, END_X => 1, END_Y => -4, DIRECTION => 'right-up', RENDERING => <<'EOR',
 e
 |
 |
 C
c
EOR
		},
		{
		# drawn as 'up'
		ORIGIN => {X => 0, Y => 4}, END_X => 0, END_Y => -4, DIRECTION => 'right-up', RENDERING => <<'EOR',
e
1
1
1
s
EOR
		},
		#--------------------------------------------------------------------------------------
		
		{
		ORIGIN => {X => 7, Y => 0}, END_X => -7, END_Y => 4, DIRECTION => 'down-left', RENDERING => <<'EOR',
       s
      1
     1
    1
e22c
EOR
		},
		{
		ORIGIN => {X => 6, Y => 0}, END_X => -6, END_Y => 4, DIRECTION => 'down-left', RENDERING => <<'EOR',
      s
     1
    1
   1
e2c
EOR
		},
		{
		ORIGIN => {X => 5, Y => 0}, END_X => -5, END_Y => 4, DIRECTION => 'down-left', RENDERING => <<'EOR',
     s
    1
   1
  1
ec
EOR
		},
		{
		ORIGIN => {X => 4, Y => 0}, END_X => -4, END_Y => 4, DIRECTION => 'down-left', RENDERING => <<'EOR',
    s
   1
  1
 1
c
EOR
		},
		{
		ORIGIN => {X => 3, Y => 0}, END_X => -3, END_Y => 4, DIRECTION => 'down-left', RENDERING => <<'EOR',
   s
   C
  1
 1
c
EOR
		},
		{
		ORIGIN => {X => 2, Y => 0}, END_X => -2, END_Y => 4, DIRECTION => 'down-left', RENDERING => <<'EOR',
  s
  |
  C
 1
c
EOR
		},
		{
		ORIGIN => {X => 1, Y => 0}, END_X => -1, END_Y => 4, DIRECTION => 'down-left', RENDERING => <<'EOR',
 s
 |
 |
 C
c
EOR
		},
		{
		# drawn as 'down'
		ORIGIN => {X => 0, Y => 0}, END_X => 0, END_Y => 4, DIRECTION => 'down-left', RENDERING => <<'EOR',
s
1
1
1
e
EOR
		},

		#--------------------------------------------------------------------------------------

		{
		ORIGIN => {X => 7, Y => 0}, END_X => -7, END_Y => 4, DIRECTION => 'left-down', RENDERING => <<'EOR',
    c22s
   1
  1
 1
e
EOR
		},
		{
		ORIGIN => {X => 6, Y => 0}, END_X => -6, END_Y => 4, DIRECTION => 'left-down', RENDERING => <<'EOR',
    c2s
   1
  1
 1
e
EOR
		},
		{
		ORIGIN => {X => 5, Y => 0}, END_X => -5, END_Y => 4, DIRECTION => 'left-down', RENDERING => <<'EOR',
    cs
   1
  1
 1
e
EOR
		},
		{
		ORIGIN => {X => 4, Y => 0}, END_X => -4, END_Y => 4, DIRECTION => 'left-down', RENDERING => <<'EOR',
    c
   1
  1
 1
e
EOR
		},
		{
		ORIGIN => {X => 3, Y => 0}, END_X => -3, END_Y => 4, DIRECTION => 'left-down', RENDERING => <<'EOR',
   c
  1
 1
C
e
EOR
		},
		{
		ORIGIN => {X => 2, Y => 0}, END_X => -2, END_Y => 4, DIRECTION => 'left-down', RENDERING => <<'EOR',
  c
 1
C
|
e
EOR
		},
		{
		ORIGIN => {X => 1, Y => 0}, END_X => -1, END_Y => 4, DIRECTION => 'left-down', RENDERING => <<'EOR',
 c
C
|
|
e
EOR
		},
		{
		# drawn as 'down'
		ORIGIN => {X => 0, Y => 0}, END_X => 0, END_Y => 4, DIRECTION => 'left-down', RENDERING => <<'EOR',
s
1
1
1
e
EOR
		},
		#--------------------------------------------------------------------------------------		)

		{
		ORIGIN => {X => 0, Y => 0}, END_X => 7, END_Y => 4, DIRECTION => 'down-right', RENDERING => <<'EOR',
s
 1
  1
   1
    c22e
EOR
		},
		{
		ORIGIN => {X => 0, Y => 0}, END_X => 6, END_Y => 4, DIRECTION => 'down-right', RENDERING => <<'EOR',
s
 1
  1
   1
    c2e
EOR
		},
		{
		ORIGIN => {X => 0, Y => 0}, END_X => 5, END_Y => 4, DIRECTION => 'down-right', RENDERING => <<'EOR',
s
 1
  1
   1
    ce
EOR
		},
		{
		ORIGIN => {X => 0, Y => 0}, END_X => 4, END_Y => 4, DIRECTION => 'down-right', RENDERING => <<'EOR',
s
 1
  1
   1
    c
EOR
		},
		{
		ORIGIN => {X => 0, Y => 0}, END_X => 3, END_Y => 4, DIRECTION => 'down-right', RENDERING => <<'EOR',
s
C
 1
  1
   c
EOR
		},
		{
		ORIGIN => {X => 0, Y => 0}, END_X => 2, END_Y => 4, DIRECTION => 'down-right', RENDERING => <<'EOR',
s
|
C
 1
  c
EOR
		},
		{
		ORIGIN => {X => 0, Y => 0}, END_X => 1, END_Y => 4, DIRECTION => 'down-right', RENDERING => <<'EOR',
s
|
|
C
 c
EOR
		},
		{
		# drawn as 'down'
		ORIGIN => {X => 0, Y => 0}, END_X => 0, END_Y => 4, DIRECTION => 'down-right', RENDERING => <<'EOR',
s
1
1
1
e
EOR
		},
		#--------------------------------------------------------------------------------------
		
		{
		ORIGIN => {X => 0, Y => 0}, END_X => 7, END_Y => 4, DIRECTION => 'right-down', RENDERING => <<'EOR',
s22c
    1
     1
      1
       e
EOR
		},
		{
		ORIGIN => {X => 0, Y => 0}, END_X => 6, END_Y => 4, DIRECTION => 'right-down', RENDERING => <<'EOR',
s2c
   1
    1
     1
      e
EOR
		},
		{
		ORIGIN => {X => 0, Y => 0}, END_X => 5, END_Y => 4, DIRECTION => 'right-down', RENDERING => <<'EOR',
sc
  1
   1
    1
     e
EOR
		},
		{
		ORIGIN => {X => 0, Y => 0}, END_X => 4, END_Y => 4, DIRECTION => 'right-down', RENDERING => <<'EOR',
c
 1
  1
   1
    e
EOR
		},
		{
		ORIGIN => {X => 0, Y => 0}, END_X => 3, END_Y => 4, DIRECTION => 'right-down', RENDERING => <<'EOR',
c
 1
  1
   C
   e
EOR
		},
		{
		ORIGIN => {X => 0, Y => 0}, END_X => 2, END_Y => 4, DIRECTION => 'right-down', RENDERING => <<'EOR',
c
 1
  C
  |
  e
EOR
		},
		{
		ORIGIN => {X => 0, Y => 0}, END_X => 1, END_Y => 4, DIRECTION => 'right-down', RENDERING => <<'EOR',
c
 C
 |
 |
 e
EOR
		},
		{
		# drawn as 'down'
		ORIGIN => {X => 0, Y => 0}, END_X => 0, END_Y => 4, DIRECTION => 'right-down', RENDERING => <<'EOR',
s
1
1
1
e
EOR
		},		
		)
		{
		my ($text, $asciio, $new_element) = get_angled_arrow_text($angled_arrow_test) ;
		is
			(
			"\n$text", "\n$angled_arrow_test->{RENDERING}",
			DumpTree
				(
				scalar(slice($angled_arrow_test, qw[END_X END_Y DIRECTION])),
				'',
				DISPLAY_ADDRESS => 0,
				USE_ASCII => 0 ,
				) 
			)
			or do
				{
				diag DumpTree 
					(
					[split /\n/, $text],
					'got:',
					QUOTE_VALUES => 1,
					DISPLAY_ADDRESS => 0,
					USE_ASCII => 0 ,
					) ;

				diag DumpTree 
					(
					[split /\n/, $angled_arrow_test->{RENDERING}],
					'expected:',
					QUOTE_VALUES => 1,
					DISPLAY_ADDRESS => 0,
					USE_ASCII => 0 ,
					) ;

				#~ diag DumpTree 
					#~ (
					#~ $asciio,
					#~ 'asciio:',
					#~ QUOTE_VALUES => 1,
					#~ DISPLAY_ADDRESS => 1,
					#~ USE_ASCII => 0 ,
					#~ ) ;
					
				last ;
				}
		}

#-----------------------------------------------------------------------------

sub get_angled_arrow_text
{
my ($angled_arrow_definition) = @_ ;

use App::Asciio ;
use App::Asciio::stripes::angled_arrow;
my $asciio = new App::Asciio() ;
$asciio->set_character_size(8, 16) ;

my $new_element = new App::Asciio::stripes::angled_arrow
					({
					GLYPHS => 
						#name: => [$start, $body, $connection, $body_2, $end]
						{
						'origin' => ['s', '1', 'c', '2', 'e', '|', 'C'],
						'up'=> ['s', '1', 'c', '2', 'e', '|', 'C'],
						'down' => ['s', '1', 'c', '2', 'e', '|', 'C'],
						'left' => ['s', '1', 'c', '2', 'e', '|', 'C'],
						'upleft' => ['s', '1', 'c', '2', 'e', '|', 'C'],
						'leftup' => ['s', '1', 'c', '2', 'e', '|', 'C'],
						'downleft' => ['s', '1', 'c', '2', 'e', '|', 'C'],
						'leftdown' => ['s', '1', 'c', '2', 'e', '|', 'C'],
						'right' => ['s', '1', 'c', '2', 'e', '|', 'C'],
						'upright' => ['s', '1', 'c', '2', 'e', '|', 'C'],
						'rightup' => ['s', '1', 'c', '2', 'e', '|', 'C'],
						'downright' => ['s', '1', 'c', '2', 'e', '|', 'C'],
						'rightdown' => ['s', '1', 'c', '2', 'e', '|', 'C'],
						},
					
					%{$angled_arrow_definition},
					RESIZABLE => 1,
					}) ;
					
@$new_element{'X', 'Y'} = ($angled_arrow_definition->{ORIGIN}{X}, $angled_arrow_definition->{ORIGIN}{Y}) ;

$asciio->add_elements($new_element) ;

return($asciio->transform_elements_to_ascii_buffer(), $asciio, $new_element) ;
}


