
package App::Asciio::stripes::angled_arrow ;

use base App::Asciio::stripes::stripes ;

use strict;
use warnings;

use List::Util qw(min max) ;
use Readonly ;

#-----------------------------------------------------------------------------

Readonly my $DEFAULT_ARROW_TYPE=> 
	# name: $start, $body, $connection, $body_2, $end, $vertical, $diagonal_connection
	[
		['origin'     , '*',  '?', '?', '?', '?', '?', '?', 1],
		['up'         , "'",  '|', '?', '?', '.', '?', '?', 1],
		['down'       , '.',  '|', '?', '?', "'", '?', '?', 1],
		['left'       , '-',  '-', '?', '?', '-', '?', '?', 1],
		['right'      , '-',  '-', '?', '?', '-', '?', '?', 1],
		['up-left'    , "'", '\\', '.', '-', '-', '|', "'", 1],
		['left-up'    , '-', '\\', "'", '-', '.', '|', "'", 1],
		['down-left'  , '.',  '/', "'", '-', '-', '|', "'", 1],
		['left-down'  , '-',  '/', '.', '-', "'", '|', "'", 1],
		['up-right'   , "'",  '/', '.', '-', '-', '|', "'", 1],
		['right-up'   , '-',  '/', "'", '-', '.', '|', "'", 1],
		['down-right' , '.', '\\', "'", '-', '-', '|', "'", 1],
		['right-down' , '-', '\\', '.', '-', "'", '|', "'", 1],
	] ;

#-----------------------------------------------------------------------------

sub new
{
my ($class, $element_definition) = @_ ;

my $self = bless  {}, __PACKAGE__ ;

$self->setup
	(
	$element_definition->{ARROW_TYPE} || $DEFAULT_ARROW_TYPE,
	$element_definition->{END_X}, $element_definition->{END_Y},
	$element_definition->{DIRECTION},
	$element_definition->{EDITABLE},
	) ;

return $self ;
}

#-----------------------------------------------------------------------------

sub setup
{
my ($self, $arrow_type, $end_x, $end_y, $direction, $editable) = @_ ;

my $glyphs = 
{
	# name => [$start, $body, $connection, $body_2, $end, $vertical, $diagonal_connection]
	$arrow_type->[0][0] => [@{$arrow_type->[0]}[1..7]],
	$arrow_type->[1][0] => [@{$arrow_type->[1]}[1..7]],
	$arrow_type->[2][0] => [@{$arrow_type->[2]}[1..7]],
	$arrow_type->[3][0] => [@{$arrow_type->[3]}[1..7]],
	$arrow_type->[4][0] => [@{$arrow_type->[4]}[1..7]],
	$arrow_type->[5][0] => [@{$arrow_type->[5]}[1..7]],
	$arrow_type->[6][0] => [@{$arrow_type->[6]}[1..7]],
	$arrow_type->[7][0] => [@{$arrow_type->[7]}[1..7]],
	$arrow_type->[8][0] => [@{$arrow_type->[8]}[1..7]],
	$arrow_type->[9][0] => [@{$arrow_type->[9]}[1..7]],
	$arrow_type->[10][0] => [@{$arrow_type->[10]}[1..7]],
	$arrow_type->[11][0] => [@{$arrow_type->[11]}[1..7]],
	$arrow_type->[12][0] => [@{$arrow_type->[12]}[1..7]],
} ;

(my ($stripes, $width, $height), $direction) = get_arrow($glyphs, $end_x, $end_y, $direction) ;

my ($ex1, $ey1, $ex2, $ey2) ;

if ($end_x < 0)
    {
    $ex1 = $end_x ;
    $ex2 = 1 ;
    }
else
    {
    $ex1 = 0 ;
    $ex2 = $end_x + 1 ;
    }

if ($end_y < 0)
    {
    $ey1 = $end_y ;
    $ey2 = 1 ;
    }
else
    {
    $ey1 = 0 ;
    $ey2 = $end_y + 1 ;
    }

$self->set
	(
	GLYPHS => $glyphs,
	ARROW_TYPE => $arrow_type,
	STRIPES => $stripes,
	WIDTH => $width,
	HEIGHT => $height,
	DIRECTION => $direction,
	END_X => $end_x,
	END_Y => $end_y,
	EXTENTS => [$ex1, $ey1, $ex2, $ey2],
	) ;
}

#-----------------------------------------------------------------------------

my %direction_to_arrow = 
	(
	'origin' => \&draw_origin,
	'up' => \&draw_up,
	'down' => \&draw_down,
	'left' => \&draw_left,
	'up-left' => \&draw_upleft,
	'left-up' => \&draw_leftup,
	'down-left' => \&draw_downleft,
	'left-down' => \&draw_leftdown, 
	'right' => \&draw_right,
	'up-right' => \&draw_upright,
	'right-up' => \&draw_rightup,
	'down-right' => \&draw_downright,
	'right-down' => \&draw_rightdown,
	) ;   

sub get_arrow
{
my ($glyphs, $end_x, $end_y, $direction) = @_ ;

use constant CENTER => 1 ;
use constant LEFT => 0 ;
use constant RIGHT => 2 ;
use constant UP => 0 ;
use constant DOWN => 2 ;

my @position_to_direction =
	(
	[$direction =~ /^up/ ? 'up-left' : 'left-up', 'left',  $direction =~ /^down/ ? 'down-left' : 'left-down'] ,
	['up', 'origin', 'down'],
	[$direction =~ /^up/ ? 'up-right' : 'right-up', 'right', $direction =~ /^down/ ? 'down-right' : 'right-down'],
	) ;

$direction = $position_to_direction
		[$end_x == 0 ? CENTER : $end_x < 0 ? LEFT : RIGHT]
		[$end_y == 0 ? CENTER : $end_y < 0 ? UP : DOWN] ;

my $drawing_sub = $direction_to_arrow{$direction} ;
 
return($drawing_sub->($glyphs, $end_x, $end_y), $direction) ;
}

#--------------------------------------------------------------------------------------------------------------

sub draw_origin
{
my ($glyphs, $end_x, $end_y) = @_ ;

my ($start, $body, $connection, $body_2, $end, $vertical, $diagonal_connection) = @{$glyphs->{origin}} ;

my ($stripes, $width, $height) = ([], 1, 1) ;

push @{$stripes},
	{
	'HEIGHT' => 1,
	'TEXT' => $start,
	'WIDTH' => 1,
	'X_OFFSET' => 0,
	'Y_OFFSET' => 0,
	} ;

return($stripes, $width, $height) ;
} 

#--------------------------------------------------------------------------------------------------------------

sub draw_up
{
my ($glyphs, $end_x, $end_y) = @_ ;

my ($start, $body, $connection, $body_2, $end, $vertical, $diagonal_connection) = @{$glyphs->{up}} ;

my ($width, $height) = ( $end_x + 1,  -$end_y + 1) ;

my @stripes ;

push @stripes,
	{
	'HEIGHT' => 1,
	'TEXT' => $start,
	'WIDTH' => 1,
	'X_OFFSET' => 0,
	'Y_OFFSET' => 0,
	} ;

for(1 .. $height - 1)
	{
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $body,
		'WIDTH' => 1,
		'X_OFFSET' => 0,
		'Y_OFFSET' => -$_,
		};
	}

push @stripes,
	{
	'HEIGHT' => 1,
	'TEXT' => $end,
	'WIDTH' => 1,
	'X_OFFSET' => 0,
	'Y_OFFSET' => $end_y,
	} ;

return(\@stripes, $width, $height) ;
}

#--------------------------------------------------------------------------------------------------------------

sub draw_down
{
my ($glyphs, $end_x, $end_y) = @_ ;

my ($start, $body, $connection, $body_2, $end, $vertical, $diagonal_connection) = @{$glyphs->{down}} ;

my ($width, $height) = ( $end_x + 1,  $end_y + 1) ;

my @stripes ;

push @stripes,
	{
	'HEIGHT' => 1,
	'TEXT' => $start,
	'WIDTH' => 1,
	'X_OFFSET' => 0,
	'Y_OFFSET' => 0,
	} ;

for(1 .. $height - 1)
	{
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $body,
		'WIDTH' => 1,
		'X_OFFSET' => 0,
		'Y_OFFSET' => $_,
		} ;
	}

push @stripes,
	{
	'HEIGHT' => 1,
	'TEXT' => $end,
	'WIDTH' => 1,
	'X_OFFSET' => 0,
	'Y_OFFSET' => $end_y,
	} ;

return(\@stripes, $width, $height) ;
}

#--------------------------------------------------------------------------------------------------------------

sub draw_left
{
my ($glyphs, $end_x, $end_y) = @_ ;

my ($start, $body, $connection, $body_2, $end, $vertical, $diagonal_connection) = @{$glyphs->{left}} ;

my ($width, $height) = ( -$end_x + 1,  $end_y + 1) ;

my @stripes ;

my $stripe = $end .  ($body x ( -$end_x - 1)) . $start ;
push @stripes,
	{
	'HEIGHT' => 1,
	'TEXT' => $stripe,
	'WIDTH' => length($stripe),
	'X_OFFSET' => $end_x,
	'Y_OFFSET' => 0,
	} ;

return(\@stripes, $width, $height) ;
}

#--------------------------------------------------------------------------------------------------------------

sub draw_right
{
my ($glyphs, $end_x, $end_y) = @_ ;

my ($start, $body, $connection, $body_2, $end, $vertical, $diagonal_connection) = @{$glyphs->{right}} ;

my ($width, $height) = ($end_x + 1,  $end_y + 1) ;

my @stripes ;

my $stripe = $start .  ($body x ($end_x - 1)) . $end ;
push @stripes,
	{
	'HEIGHT' => 1,
	'TEXT' => $stripe,
	'WIDTH' => length($stripe),
	'X_OFFSET' => 0,
	'Y_OFFSET' => 0,
	} ;

return(\@stripes, $width, $height) ;
}

#--------------------------------------------------------------------------------------------------------------

sub draw_upright
{
my ($glyphs, $end_x, $end_y) = @_ ;
my ($start, $body, $connection, $body_2, $end, $vertical, $diagonal_connection) = @{$glyphs->{'up-right'}} ;

my ($width, $height) = ( $end_x + 1, 	-$end_y + 1) ;

my ($position_x, $position_y) = (0, 0) ;
my @stripes ;

#~ require Enbugger ;
#~ Enbugger->stop ;

if($end_x >= -$end_y) # enought horizontal length to have a proper diagonal up
	{
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $start,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x++, # diagonal
		'Y_OFFSET' => $position_y--, # diagonal
		} ;
	
	for(-$position_y .. (-$end_y - 1))
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $body,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x++, # diagonal
			'Y_OFFSET' => $position_y--, # diagonal
			} ;
		}
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $connection,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x++, # going right
		'Y_OFFSET' => $position_y, # staying horizontal
		} ;
	
	if($end_x > -$end_y)
		{
		for($position_x .. ($end_x - 1))
			{
			push @stripes,
				{
				'HEIGHT' => 1,
				'TEXT' => $body_2,
				'WIDTH' => 1,
				'X_OFFSET' => $position_x++, # going right
				'Y_OFFSET' => $position_y, # staying horizontal
				} ;
			}
		
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $end,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x, # finished
			'Y_OFFSET' => $position_y, # finished
			} ;
		}
	}

if($end_x < -$end_y) # not enought horizontal length to have a proper diagonal up
	{
	my $number_of_verticals = ($height - $width) - 1 ;
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $start,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x, 
		'Y_OFFSET' => $position_y--, # up
		} ;
	
	for(1 .. $number_of_verticals)
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $vertical,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x, 
			'Y_OFFSET' => $position_y--,
			} ;
		}
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $diagonal_connection,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x++, # going right
		'Y_OFFSET' => $position_y--, # going up
		} if($end_x != 0) ;
	
	my $number_of_diagonals = $height - ($number_of_verticals + 3) ;
	
	for(1 .. $number_of_diagonals)
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $body,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x++, # going right
			'Y_OFFSET' => $position_y--, # going up
			} ;
		}
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $connection,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x, 
		'Y_OFFSET' => $position_y,
		} ;
	}

return(\@stripes, $width, $height) ;
}

#--------------------------------------------------------------------------------------------------------------

sub draw_upleft
{
my ($glyphs, $end_x, $end_y) = @_ ;

my ($start, $body, $connection, $body_2, $end, $vertical, $diagonal_connection) = @{$glyphs->{'up-left'}} ;

my ($width, $height) = ( -$end_x + 1, 	-$end_y + 1) ;

my ($position_x, $position_y) = (0, 0) ;
my @stripes ;

#~ require Enbugger ;
#~ Enbugger->stop ;

if($width >= $height) # enought horizontal length to have a proper diagonal up
	{
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $start,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x--,
		'Y_OFFSET' => $position_y--,
		} ;
	
	for(-$position_y .. (-$end_y - 1))
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $body,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x--,
			'Y_OFFSET' => $position_y--,
			} ;
		}
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $connection,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x--,
		'Y_OFFSET' => $position_y,
		} ;
	
	if($width > $height)
		{
		for(1 .. ($width - $height) - 1)
			{
			push @stripes,
				{
				'HEIGHT' => 1,
				'TEXT' => $body_2,
				'WIDTH' => 1,
				'X_OFFSET' => $position_x--, 
				'Y_OFFSET' => $position_y,
				} ;
			}
		
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $end,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x,
			'Y_OFFSET' => $position_y,
			} ;
		}
	}
else
	{
	my $number_of_verticals = ($height - $width) - 1  ;
	my $number_of_diagonals = $height - ($number_of_verticals + 3) ;
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $start,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x,
		'Y_OFFSET' => $position_y--, 
		} ;
	
	for(1 .. $number_of_verticals)
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $vertical,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x, 
			'Y_OFFSET' => $position_y--,
			} ;
		}
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $diagonal_connection,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x--,
		'Y_OFFSET' => $position_y--, 
		} if($end_x != 0) ;
	
	for(1 .. $number_of_diagonals)
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $body,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x--,
			'Y_OFFSET' => $position_y--,
			} ;
		}
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $connection,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x, 
		'Y_OFFSET' => $position_y,
		} ;
	}

return(\@stripes, $width, $height) ;
}

#--------------------------------------------------------------------------------------------------------------

sub draw_leftup
{
my ($glyphs, $end_x, $end_y) = @_ ;

my ($start, $body, $connection, $body_2, $end, $vertical, $diagonal_connection) = @{$glyphs->{'left-up'}} ;

my ($width, $height) = ( -$end_x + 1, 	-$end_y + 1) ;

my ($position_x, $position_y) = (0, 0) ;
my @stripes ;

if($width > $height) # enought horizontal length to have a proper diagonal up
	{
	my $start_body_connector = $connection . $body_2 x (($width - $height) - 1) . $start ;
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $start_body_connector,
		'WIDTH' => length($start_body_connector),
		'X_OFFSET' => - length($start_body_connector) + 1, 
		'Y_OFFSET' => $position_y--,
		} ;
	
	$position_x -= length($start_body_connector) ;
	
	for(1 .. ($height - 2))  # two connectors
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $body,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x--,
			'Y_OFFSET' => $position_y--,
			} ;
		}
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $end,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x,
		'Y_OFFSET' => $position_y,
		} ;
	}
else
	{
	my $number_of_verticals = $height - $width ;
	my $number_of_diagonals = $height - ($number_of_verticals + 2) ;
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $connection,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x--, 
		'Y_OFFSET' => $position_y--,
		} ;
		
	for(1 .. $number_of_diagonals)
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $body,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x--,
			'Y_OFFSET' => $position_y--,
			} ;
		}
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $diagonal_connection,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x,
		'Y_OFFSET' => $position_y--, 
		} if($end_x != $end_y) ;
	
	for(1 .. $number_of_verticals - 1)
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $vertical,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x,
			'Y_OFFSET' => $position_y--, 
			} ;
		}
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $end,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x,
		'Y_OFFSET' => $position_y,
		}  ;
		
	}

return(\@stripes, $width, $height) ;
}

#---------------------------------------------------------------------------------

sub draw_rightup
{
my ($glyphs, $end_x, $end_y) = @_ ;

my ($start, $body, $connection, $body_2, $end, $vertical, $diagonal_connection) = @{$glyphs->{'right-up'}} ;

my ($width, $height) = ( $end_x + 1, 	-$end_y + 1) ;

my ($position_x, $position_y) = (0, 0) ;
my @stripes ;

if($end_x > -$end_y)
	{
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $start,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x++,
		'Y_OFFSET' => $position_y,
		} ;
	
	for(1 .. ($width - $height) - 1)
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $body_2,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x++,
			'Y_OFFSET' => $position_y,
			} ;
		}
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $connection,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x++,
		'Y_OFFSET' => $position_y--, 
		} ;
	
	for($position_x .. ($end_x - 1))
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $body,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x++,
			'Y_OFFSET' => $position_y--, 
			} ;
		}
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $end,
		'WIDTH' => 1,
		'X_OFFSET' => $end_x,
		'Y_OFFSET' => $end_y,
		} ;
	}
else
	{
	my $number_of_verticals = ($height ==  $width) ? 0 : ($height -  $width)  -1 ;
	my $has_diagonal_connection = ($height ==  $width) ? 0 : 1 ;
	
	my $number_of_diagonals = $height - ($number_of_verticals + 2 + $has_diagonal_connection) ;
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $connection,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x++,
		'Y_OFFSET' => $position_y--,
		} ;
	
	for(1 .. $number_of_diagonals)
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $body,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x++,
			'Y_OFFSET' => $position_y--,
			} ;
		}
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $diagonal_connection,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x, 
		'Y_OFFSET' => $position_y--,
		} if $has_diagonal_connection ;
	
	for(1 .. $number_of_verticals)
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $vertical,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x,
			'Y_OFFSET' => $position_y--,
			} ;
		}
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $end,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x, 
		'Y_OFFSET' => $position_y--,
		} if($end_x != 0) ;
	}

return(\@stripes, $width, $height) ;
}

#---------------------------------------------------------------------------------

sub draw_downleft
{
my ($glyphs, $end_x, $end_y) = @_ ;

my ($start, $body, $connection, $body_2, $end, $vertical, $diagonal_connection) = @{$glyphs->{'down-left'}} ;

my ($width, $height) = ( -$end_x + 1,  $end_y + 1) ;

my ($position_x, $position_y) = (0, 0) ;
my @stripes ;

if($width >= $height) # enought horizontal length to have a proper diagonal up
	{
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $start,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x--, 
		'Y_OFFSET' => $position_y++,
		} ;
	
	for(1 .. ($height - 2))  # two connectors
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $body,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x--,
			'Y_OFFSET' => $position_y++,
			} ;
		}
	
	my $left_text = ''  ;
	$left_text .= $body_2 x (($width - $height) - 1)  if $width > $height ;
	
	if($width > $height)
		{
		$left_text = $end . $body_2 x (($width - $height) - 1)  ;
		}
		
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $left_text . $connection,
		'WIDTH' => length($left_text) + 1,
		'X_OFFSET' => $end_x,
		'Y_OFFSET' => $position_y,
		} ;
	}
else # not enought horizontal length to have a proper diagonal up
	{
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $start,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x, 
		'Y_OFFSET' => $position_y++,
		} ;
	
	for (1 .. ($height - $width) - 1)
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $vertical,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x, 
			'Y_OFFSET' => $position_y++,
			} ;
		}
	
	if($end_x != 0)
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $diagonal_connection,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x--, 
			'Y_OFFSET' => $position_y++, 
			} ;
		}
	
	for(1 .. (-$end_x  + $position_x))
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $body,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x--, 
			'Y_OFFSET' => $position_y++, 
			} ;
		}
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $connection,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x, 
		'Y_OFFSET' => $position_y,
		} ;
	}

return(\@stripes, $width, $height) ;
}

#----------------------------------------------------------------------------------------------------------

sub draw_leftdown
{
my ($glyphs, $end_x, $end_y) = @_ ;

my ($start, $body, $connection, $body_2, $end, $vertical, $diagonal_connection) = @{$glyphs->{'left-down'}} ;

my ($width, $height) = ( -$end_x + 1,  $end_y + 1) ;

my ($position_x, $position_y) = (0, 0) ;
my @stripes ;

if($width >= $height) # enought horizontal length to have a proper diagonal up
	{
	my $start_body_connector = $connection;
	$start_body_connector .= $body_2 x (($width - $height) - 1) if $width > $height ;
	
	if($width > $height)
		{
		$start_body_connector .= $start  ;
		}
		
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $start_body_connector,
		'WIDTH' => length($start_body_connector),
		'X_OFFSET' => - length($start_body_connector) + 1, 
		'Y_OFFSET' => $position_y++,
		} ;
	
	$position_x -= length($start_body_connector) ;
	
	for(1 .. ($height - 2))  # two connectors
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $body,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x--,
			'Y_OFFSET' => $position_y++,
			} ;
		}
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $end,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x,
		'Y_OFFSET' => $position_y,
		} ;
	}
else 
	{
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $connection,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x--, 
		'Y_OFFSET' => $position_y++,
		} ;
	
	for(1 .. (-$end_x  + $position_x))
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $body,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x--, 
			'Y_OFFSET' => $position_y++, 
			} ;
		}
	
	if($end_x != 0)
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $diagonal_connection,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x, 
			'Y_OFFSET' => $position_y++, 
			} ; 
		}
	
	for (1 .. ($height - $width) - 1)
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $vertical,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x, 
			'Y_OFFSET' => $position_y++,
			} ;
		}
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $end,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x, 
		'Y_OFFSET' => $position_y,
		} ;
	}

return(\@stripes, $width, $height) ;
}

#----------------------------------------------------------------------------------------------------------

sub draw_downright
{
my ($glyphs, $end_x, $end_y) = @_ ;

my ($start, $body, $connection, $body_2, $end, $vertical, $diagonal_connection) = @{$glyphs->{'down-right'}} ;

my ($width, $height) = ( $end_x + 1,  $end_y + 1) ;

my ($position_x, $position_y) = (0, 0) ;
my @stripes ;

#~ require Enbugger ;
#~ Enbugger->stop ;

if($end_x >= $end_y) # enought horizontal length to have a proper diagonal up
	{
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $start,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x++, # diagonal
		'Y_OFFSET' => $position_y++, # diagonal
		} ;
	
	for($position_y .. ($end_y - 1))
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $body,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x++, # diagonal
			'Y_OFFSET' => $position_y++, # diagonal
			} ;
		}
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $connection,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x++, # going right
		'Y_OFFSET' => $position_y, # staying horizontal
		} ;
	
	if($end_x > $end_y)
		{
		for($position_x .. ($end_x - 1))
			{
			push @stripes,
				{
				'HEIGHT' => 1,
				'TEXT' => $body_2,
				'WIDTH' => 1,
				'X_OFFSET' => $position_x++, # going right
				'Y_OFFSET' => $position_y, # staying horizontal
				} ;
			}
		
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $end,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x, # finished
			'Y_OFFSET' => $position_y, # finished
			} ;
		}
	}

if($end_x < $end_y) # not enought horizontal length to have a proper diagonal up
	{
	my $number_of_verticals = ($end_y - $end_x) - 1 ;
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $start,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x, 
		'Y_OFFSET' => $position_y++, 
		} ;
	
	for(1 .. $number_of_verticals)
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $vertical,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x, 
			'Y_OFFSET' => $position_y++, 
			} ;
		}
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $diagonal_connection,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x++, 
		'Y_OFFSET' => $position_y++, 
		} if($end_x != 0) ;
	
	my $number_of_diagonals = $height - ($number_of_verticals + 3) ;
	
	for(1 .. $number_of_diagonals)
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $body,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x++,
			'Y_OFFSET' => $position_y++,
			} ;
		}
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $connection,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x, 
		'Y_OFFSET' => $position_y,
		} ;
	}

return(\@stripes, $width, $height) ;
}

#----------------------------------------------------------------------------------------------------------

sub draw_rightdown
{
my ($glyphs, $end_x, $end_y) = @_ ;

my ($start, $body, $connection, $body_2, $end, $vertical, $diagonal_connection) = @{$glyphs->{'right-down'}} ;

my ($width, $height) = ( $end_x + 1,  $end_y + 1) ;

my ($position_x, $position_y) = (0, 0) ;
my @stripes ;

if($end_x >= $end_y) # enought horizontal length to have a proper diagonal down
	{
	if($end_x > $end_y)
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $start,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x++, # going right
			'Y_OFFSET' => $position_y, # stay on this line
			} ;
		
		for(1 .. ($end_x  - $end_y) - 1)
			{
			push @stripes,
				{
				'HEIGHT' => 1,
				'TEXT' => $body_2,
				'WIDTH' => 1,
				'X_OFFSET' => $position_x++, 
				'Y_OFFSET' => $position_y, 
				} ;
			}
		}
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $connection,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x++,
		'Y_OFFSET' => $position_y++,
		} ;
	
	for(1 .. ($end_y - $position_y))
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $body,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x++,
			'Y_OFFSET' => $position_y++,
			} ;
		}
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $end,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x,
		'Y_OFFSET' => $position_y,
		} ;
	}

if($end_x < $end_y) # not enought horizontal length to have a proper diagonal up
	{
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $connection,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x, 
		'Y_OFFSET' => $position_y++,
		} ;
	
	for(1 .. (($end_x - 1) - $position_x))
		{
		$position_x++ ;
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $body,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x,
			'Y_OFFSET' => $position_y++,
			} ;
		}
	
	if($end_x != 0)
		{
		$position_x++ ;
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $diagonal_connection,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x, 
			'Y_OFFSET' => $position_y++,
			} ; 
		}
	
	for (0 .. ($end_y -$position_y) - 1)
		{
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $vertical,
			'WIDTH' => 1,
			'X_OFFSET' => $position_x, 
			'Y_OFFSET' => $position_y++,
			};
		}
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $end,
		'WIDTH' => 1,
		'X_OFFSET' => $position_x, 
		'Y_OFFSET' => $position_y++,
		} ;
	}

return(\@stripes, $width, $height) ;
}

#-----------------------------------------------------------------------------

sub get_selection_action
{
my ($self, $x, $y) = @_ ;

if	(
	   ($x == 0 && $y == 0)
	|| ($x == $self->{END_X} && $y == $self->{END_Y})
	)
	{
	'resize' ;
	}
else
	{
	'move' ;
	}
}

#-----------------------------------------------------------------------------

sub get_connector_points
{
my ($self) = @_ ;

return
	(
	{X => 0, Y => 0, NAME => 'start'},
	{X => $self->{END_X}, Y => $self->{END_Y}, NAME => 'end'},
	) ;
}
#-----------------------------------------------------------------------------

sub get_named_connection
{
my ($self, $name) = @_ ;

if($name eq 'start')
	{
	return( {X => 0, Y => 0, NAME => 'start', CHAR => $self->{GLYPHS}{$self->{DIRECTION}}[0]} ) if exists $self->{GLYPHS} ;
	return( {X => 0, Y => 0, NAME => 'start', CHAR => '?'} ) ;
	}
elsif($name eq 'end')
	{
	return( {X => $self->{END_X}, Y => $self->{END_Y}, NAME => 'end', CHAR => $self->{GLYPHS}{$self->{DIRECTION}}[4]} ) if exists $self->{GLYPHS} ;
	return( {X => $self->{END_X}, Y => $self->{END_Y}, NAME => 'end', CHAR => '?'} ) ;
	}
else
	{
	return ;
	}
}

#-----------------------------------------------------------------------------

sub get_direction
{
my ($self) = @_ ;

return $self->{DIRECTION} ;
}

#-----------------------------------------------------------------------------

sub change_direction
{
my ($self, $x, $y) = @_ ;

my $direction = $self->get_direction() ;

if($direction =~ /(.*)-(.*)/)
	{
	$self->resize(0, 0, 0, 0, "$2-$1") ;
	}
}

#-----------------------------------------------------------------------------

sub move_connector
{
my ($self, $connector_name, $x_offset, $y_offset, $hint) = @_ ;

if($connector_name eq 'start')
	{
	my ($x_offset, $y_offset, $width, $height, undef) = 
		$self->resize(0, 0, $x_offset, $y_offset, $hint) ;
	
	return 
		$x_offset, $y_offset, $width, $height,
		{X => $self->{END_X}, Y => $self->{END_Y}, NAME => 'start'} ;
	}
elsif($connector_name eq 'end')
	{
	my ($x_offset, $y_offset, $width, $height, undef) = 
		$self->resize(-1, -1, $self->{END_X} + $x_offset, $self->{END_Y} + $y_offset, $hint) ;
	
	return 
		$x_offset, $y_offset, $width, $height,
		{X => $self->{END_X}, Y => $self->{END_Y}, NAME => 'end'} ;
	}
else
	{
	die "unknown connector '$connector_name'!\n" ;
	}
}

#-----------------------------------------------------------------------------

sub resize
{
my ($self, $reference_x, $reference_y, $new_x, $new_y, $hint, $connector_name) = @_ ;

my $is_start ;

if(defined $connector_name)
	{
	if($connector_name eq 'start')
		{
		$is_start++ ;
		}
	}
else
	{
	if($reference_x == 0 && $reference_y == 0)
		{
		$is_start++ ;
		}
	}

if($is_start)
	{
	my $x_offset = $new_x ;
	my $y_offset = $new_y ;
	
	my $new_end_x = $self->{END_X} - $x_offset ;
	my $new_end_y = $self->{END_Y} - $y_offset ;
	
	$self->setup($self->{ARROW_TYPE}, $new_end_x, $new_end_y, $hint || $self->{DIRECTION}, $self->{EDITABLE}) ;
	
	return($x_offset, $y_offset, $self->{WIDTH}, $self->{HEIGHT}, 'start') ;
	}
else
	{
	my $new_end_x = $new_x ;
	my $new_end_y = $new_y ;
	
	$self->setup($self->{ARROW_TYPE}, $new_end_x, $new_end_y, $hint || $self->{DIRECTION}, $self->{EDITABLE}) ;
	
	return(0, 0, $self->{WIDTH}, $self->{HEIGHT}, 'end') ;
	}
}

#-----------------------------------------------------------------------------

sub get_all_points { my ($self) = @_ ; $self->get_connector_points() ; }

#-----------------------------------------------------------------------------

sub get_section_direction { my ($self, $section_index) = @_ ; return $self->{DIRECTION} ; }

#-----------------------------------------------------------------------------

sub edit
{
my ($self, $asciio) = @_ ;

$self->display_arrow_edit_dialog() ;

$self->setup
	(
	$self->{ARROW_TYPE},
	$self->{END_X}, $self->{END_Y},
	$self->{DIRECTION},
	$self->{EDITABLE},
	) ;
}

#-----------------------------------------------------------------------------

sub set_arrow_type
{
my ($self, $arrow_type) = @_ ;

delete $self->{CACHE} ;

$self->setup
	(
	$arrow_type,
	$self->{END_X}, $self->{END_Y},
	$self->{DIRECTION},
	$self->{EDITABLE},
	) ;
}

#-----------------------------------------------------------------------------
sub copy_type
{
my ($self, $asciio) = @_ ;

$asciio->{FORMAT_PAINTER}{NAME} = "angled_arrow" ;
$asciio->{FORMAT_PAINTER}{TYPE} = Clone::clone($self->get_arrow_type()) ;

}

#-----------------------------------------------------------------------------


1 ;
