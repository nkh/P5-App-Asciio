
package App::Asciio::stripes::wirl_arrow ;

use base App::Asciio::stripes::stripes ;

use strict;
use warnings;

use List::Util qw(min max) ;
use Readonly ;
use Clone ;

#-----------------------------------------------------------------------------

Readonly my $DEFAULT_ARROW_TYPE => 
	[
	#name: $start, $body, $connection, $body_2, $end
	
	['origin',       '',  '*',   '',  '',  '', 1],
	['up',          '|',  '|',   '',  '', '^', 1],
	['down',        '|',  '|',   '',  '', 'v', 1],
	['left',        '-',  '-',   '',  '', '<', 1],
	['up-left',     '|',  '|',  '.', '-', '<', 1],
	['left-up',     '-',  '-', '\'', '|', '^', 1],
	['down-left',   '|',  '|', '\'', '-', '<', 1],
	['left-down',   '-',  '-',  '.', '|', 'v', 1],
	['right',       '-',  '-',   '',  '', '>', 1],
	['up-right',    '|',  '|',  '.', '-', '>', 1],
	['right-up',    '-',  '-', '\'', '|', '^', 1],
	['down-right',  '|',  '|', '\'', '-', '>', 1],
	['right-down',  '-',  '-',  '.', '|', 'v', 1],
	['45',          '/',  '/',   '',  '', '^', 1],
	['135',        '\\', '\\',   '',  '', 'v', 1],
	['225',        ' /',  '/',   '',  '', 'v', 1],
	['315',        '\\', '\\',   '',  '', '^', 1],
	] ;

sub new
{
my ($class, $element_definition) = @_ ;

my $self = bless  {}, __PACKAGE__ ;

$self->setup
	(
	$element_definition->{ARROW_TYPE} || Clone::clone($DEFAULT_ARROW_TYPE),
	$element_definition->{END_X}, $element_definition->{END_Y},
	$element_definition->{DIRECTION},
	$element_definition->{ALLOW_DIAGONAL_LINES},
	$element_definition->{EDITABLE},
	) ;

return $self ;
}

#-----------------------------------------------------------------------------

sub setup
{
my ($self, $arrow_type, $end_x, $end_y, $direction, $allow_diagonal_lines, $editable) = @_ ;

my ($stripes, $width, $height) ;

($stripes, $width, $height, $direction) = get_arrow($arrow_type, $end_x, $end_y, $direction, $allow_diagonal_lines) ;

$self->set
	(
	STRIPES => $stripes,
	WIDTH => $width,
	HEIGHT => $height,
	DIRECTION => $direction,
	ARROW_TYPE => $arrow_type,
	END_X => $end_x,
	END_Y => $end_y,
	ALLOW_DIAGONAL_LINES => $allow_diagonal_lines,
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
my ($arrow_type, $end_x, $end_y, $direction, $allow_diagonal_lines) = @_ ;

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

return($direction_to_arrow{$direction}->($arrow_type, $end_x, $end_y, $allow_diagonal_lines), $direction) ;
}

#-----------------------------------------------------------------------------

sub draw_down
{
my ($arrow_type, $end_x, $end_y) = @_ ;

my ($stripes, $width, $height) = ([], 1, $end_y + 1) ;
my ($start, $body, $connection, $body_2, $end) = @{$arrow_type->[2]}[1 .. 5] ;

push @{$stripes},
	{
	'HEIGHT' => $height,
	'TEXT' => $height == 2	? "$start\n$end" : $start . "\n" . ("$body\n" x ($height -2)) . $end,
	'WIDTH' => 1,
	'X_OFFSET' => 0,
	'Y_OFFSET' => 0,
	} ;

return($stripes, $width, $height) ;
}

#-----------------------------------------------------------------------------

sub draw_origin
{
my ($arrow_type, $end_x, $end_y) = @_ ;

my ($stripes, $width, $height) = ([], 1, 1) ;
my ($start, $body, $connection, $body_2, $end) = @{$arrow_type->[0]}[1 .. 5] ;

push @{$stripes},
	{
	'HEIGHT' => 1,
	'TEXT' => $body,
	'WIDTH' => 1,
	'X_OFFSET' => 0,
	'Y_OFFSET' => 0,
	} ;

return($stripes, $width, $height) ;
} 

#-----------------------------------------------------------------------------

sub draw_up
{
my ($arrow_type, $end_x, $end_y) = @_ ;

my ($stripes, $width, $height) = ([], 1, -$end_y + 1) ;
my ($start, $body, $connection, $body_2, $end) = @{$arrow_type->[1]}[1 .. 5] ;

push @{$stripes},
	{
	'HEIGHT' => $height,
	'TEXT' => $height == 2 ? "$end\n$start" : $end . "\n" . ("$body\n" x ($height -2)) . $start, 
	'WIDTH' => 1,
	'X_OFFSET' => 0,
	'Y_OFFSET' => $end_y, 
	} ;

return($stripes, $width, $height) ;
}

#-----------------------------------------------------------------------------

sub draw_left
{
my ($arrow_type, $end_x, $end_y) = @_ ;

my ($stripes, $width, $height) = ([], -$end_x + 1, 1) ;
my ($start, $body, $connection, $body_2, $end) = @{$arrow_type->[3]}[1 .. 5] ;

push @{$stripes},
	{
	'HEIGHT' => 1,
	'TEXT' => $width == 2 ? "$end$start" : $end . $body x ($width -2) . $start,
	'WIDTH' => $width,
	'X_OFFSET' => $end_x,
	'Y_OFFSET' => 0,
	} ;

return($stripes, $width, $height) ;
}

#-----------------------------------------------------------------------------

sub draw_upleft # or 315
{
my ($arrow_type, $end_x, $end_y, $allow_diagonal_lines) = @_ ;

my ($stripes, $width, $height) = ([], -$end_x + 1, -$end_y + 1) ;

if($allow_diagonal_lines && $end_x == $end_y)
	{
	my ($start, $body, $connection, $body_2, $end) = @{$arrow_type->[16]}[1 .. 5] ;
	push @{$stripes}, get_315_stripes($end_x, $start, $body, $end) ;
	}
else
	{
	my ($start, $body, $connection, $body_2, $end) = @{$arrow_type->[4]}[1 .. 5] ;
	push @{$stripes},
		{
		'HEIGHT' => $height ,
		'TEXT' => "$connection\n" . "$body\n" x  ($height - 2) . $start,
		'WIDTH' => 1,
		'X_OFFSET' => 0,
		'Y_OFFSET' => $end_y,
		},
		{
		'HEIGHT' => 1,
		'TEXT' => $end . $body_2 x  ($width - 2),
		'WIDTH' => $width - 1,
		'X_OFFSET' => $end_x,
		'Y_OFFSET' => $end_y ,
		} ;
	}

return($stripes, $width, $height) ;
}

#-----------------------------------------------------------------------------

sub draw_leftup # or 315
{
my ($arrow_type, $end_x, $end_y, $allow_diagonal_lines) = @_ ;

my ($stripes, $width, $height) = ([], -$end_x + 1, 	-$end_y + 1) ;
my ($start, $body, $connection, $body_2, $end) = @{$arrow_type->[5]}[1 .. 5] ;

if($allow_diagonal_lines && $end_x == $end_y)
	{
	my ($start, $body, $connection, $body_2, $end) = @{$arrow_type->[16]}[1 .. 5] ;
	push @{$stripes}, get_315_stripes($end_x, $start, $body, $end) ;
	}
else
	{
	push @{$stripes},
		{
		'HEIGHT' => 1 ,
		'TEXT' => $connection . $body x  ($width - 2) . $start,
		'WIDTH' => $width,
		'X_OFFSET' => $end_x,
		'Y_OFFSET' => 0,
		},
		{
		'HEIGHT' => $height - 1,
		'TEXT' => "$end\n" . "$body_2\n" x  ($height - 2),
		'WIDTH' => 1,
		'X_OFFSET' => $end_x,
		'Y_OFFSET' => $end_y ,
		} ;
	}

return($stripes, $width, $height) ;
}

#-----------------------------------------------------------------------------

sub get_315_stripes
{
my ($position, $start, $body, $end) = @_ ;

my @stripes ;

push @stripes,
	{
	'HEIGHT' => 1,
	'TEXT' => $start,
	'WIDTH' => 1,
	'X_OFFSET' => 0,
	'Y_OFFSET' => 0,
	} ;
	
for(my $xy = -$position - 1 ; $xy> 0 ; $xy--)
	{
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $body,
		'WIDTH' => 1,
		'X_OFFSET' => -$xy,
		'Y_OFFSET' => -$xy,
		} ;
	}

push @stripes,
	{
	'HEIGHT' => 1,
	'TEXT' => $end,
	'WIDTH' => 1,
	'X_OFFSET' => $position ,
	'Y_OFFSET' => $position ,
	} ;

return(@stripes) ;
}

#-----------------------------------------------------------------------------

sub draw_downleft # or 225
{
my ($arrow_type, $end_x, $end_y, $allow_diagonal_lines) = @_ ;

my ($stripes, $width, $height) = ([], -$end_x + 1, $end_y + 1) ;
my ($start, $body, $connection, $body_2, $end) = @{$arrow_type->[6]}[1 .. 5] ;

if($allow_diagonal_lines && -$end_x == $end_y)
	{
	my ($start, $body, $connection, $body_2, $end) = @{$arrow_type->[15]}[1 .. 5] ;
	push @{$stripes}, get_225_stripes($end_x, $start, $body, $end) ;
	}
else
	{
	push @{$stripes},
		{
		'HEIGHT' => $height ,
		'TEXT' => "$start\n" . "$body\n" x  ($height - 2) .  $connection,
		'WIDTH' => 1,
		'X_OFFSET' => 0,
		'Y_OFFSET' => 0,
		},
		{
		'HEIGHT' => 1,
		'TEXT' => $end . $body_2 x  ($width - 2),
		'WIDTH' => $width - 1,
		'X_OFFSET' => $end_x,
		'Y_OFFSET' => $end_y ,
		} ;
	}

return($stripes, $width, $height) ;
}

#-----------------------------------------------------------------------------

sub draw_leftdown # or 225
{
my ($arrow_type, $end_x, $end_y, $allow_diagonal_lines) = @_ ;

my ($stripes, $width, $height) = ([], -$end_x + 1, $end_y + 1) ;
my ($start, $body, $connection, $body_2, $end) = @{$arrow_type->[7]}[1 .. 5] ;

if($allow_diagonal_lines && -$end_x == $end_y)
	{
	my ($start, $body, $connection, $body_2, $end) = @{$arrow_type->[15]}[1 .. 5] ;
	push @{$stripes}, get_225_stripes($end_x, $start, $body, $end) ;
	}
else
	{
	push @{$stripes},
		{
		'HEIGHT' => 1 ,
		'TEXT' => $connection . $body x  ($width - 2) . $start,
		'WIDTH' => $width,
		'X_OFFSET' => $end_x,
		'Y_OFFSET' => 0,
		},
		{
		'HEIGHT' => $height - 1,
		'TEXT' => "$body_2\n" x  ($height - 2) . $end,
		'WIDTH' => 1,
		'X_OFFSET' => $end_x,
		'Y_OFFSET' => 1 ,
		} ;
	}

return($stripes, $width, $height) ;
}

#-----------------------------------------------------------------------------

sub get_225_stripes
{
my ($position, $start, $body, $end) = @_ ;

my @stripes ;

push @stripes,
	{
	'HEIGHT' => 1,
	'TEXT' => $start,
	'WIDTH' => 1,
	'X_OFFSET' => 0,
	'Y_OFFSET' => 0,
	} ;

for(my $xy = -$position - 1 ; $xy> 0 ; $xy--)
	{
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $body,
		'WIDTH' => 1,
		'X_OFFSET' => -$xy,
		'Y_OFFSET' => $xy,
		} ;
	}

push @stripes,
	{
	'HEIGHT' => 1,
	'TEXT' => $end,
	'WIDTH' => 1,
	'X_OFFSET' => $position ,
	'Y_OFFSET' => -$position ,
	} ;

return(@stripes) ;
}

#-----------------------------------------------------------------------------

sub draw_right
{
my ($arrow_type, $end_x, $end_y) = @_ ;

my ($stripes, $width, $height) = ([], $end_x + 1, 1) ;
my ($start, $body, $connection, $body_2, $end) = @{$arrow_type->[8]}[1 .. 5] ;

push @{$stripes},
	{
	'HEIGHT' => 1,
	'TEXT' => $width == 2 ? "$start$end" : $start . $body x ($width -2) . $end,
	'WIDTH' => $width,
	'X_OFFSET' => 0,
	'Y_OFFSET' => 0,
	} ;

return($stripes, $width, $height) ;
}

#-----------------------------------------------------------------------------

sub draw_upright # or 45
{
my ($arrow_type, $end_x, $end_y, $allow_diagonal_lines) = @_ ;

my ($stripes, $width, $height) = ([], $end_x + 1, -$end_y + 1) ;
my ($start, $body, $connection, $body_2, $end) = @{$arrow_type->[9]}[1 .. 5] ;

if($allow_diagonal_lines && -$end_x == $end_y)
	{
	my ($start, $body, $connection, $body_2, $end) = @{$arrow_type->[13]}[1 .. 5] ;
	push @{$stripes}, get_45_stripes($end_x, $start, $body, $end) ;
	}
else
	{
	push @{$stripes},
		{
		'HEIGHT' => $height ,
		'TEXT' => "$connection\n". "$body\n" x ($height -2) . $start,
		'WIDTH' => 1,
		'X_OFFSET' => 0,
		'Y_OFFSET' => $end_y,
		},
		{
		'HEIGHT' => 1,
		'TEXT' => $body_2 x ($width -2) . $end,
		'WIDTH' => $end_x,
		'X_OFFSET' => 1,
		'Y_OFFSET' => $end_y,
		} ;
	}

return($stripes, $width, $height) ;
}

#-----------------------------------------------------------------------------

sub draw_rightup # or 45
{
my ($arrow_type, $end_x, $end_y, $allow_diagonal_lines) = @_ ;

my ($stripes, $width, $height) = ([], $end_x + 1, -$end_y + 1) ;
my ($start, $body, $connection, $body_2, $end) = @{$arrow_type->[10]}[1 .. 5] ;

if($allow_diagonal_lines && -$end_x == $end_y)
	{
	my ($start, $body, $connection, $body_2, $end) = @{$arrow_type->[13]}[1 .. 5] ;
	push @{$stripes}, get_45_stripes($end_x, $start, $body, $end) ;
	}
else
	{
	push @{$stripes},
		{
		'HEIGHT' => 1,
		'TEXT' => $start . $body x ($width -2) . $connection,
		'WIDTH' => $width,
		'X_OFFSET' => 0,
		'Y_OFFSET' => 0,
		},
		{
		'HEIGHT' => $height - 1,
		'TEXT' => "$end\n" . "$body_2\n" x ($height -2),
		'WIDTH' => 1,
		'X_OFFSET' => $end_x,
		'Y_OFFSET' => $end_y,
		} ;
	}

return($stripes, $width, $height) ;
}

#-----------------------------------------------------------------------------

sub get_45_stripes
{
my ($position, $start, $body, $end) = @_ ;

my @stripes ;

push @stripes,
	{
	'HEIGHT' => 1,
	'TEXT' => $start,
	'WIDTH' => 1,
	'X_OFFSET' => 0,
	'Y_OFFSET' => 0,
	} ;

for(my $xy = $position - 1 ; $xy > 0 ; $xy--)
	{
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $body,
		'WIDTH' => 1,
		'X_OFFSET' => $xy,
		'Y_OFFSET' => -$xy,
		} ;
	}

push @stripes,
	{
	'HEIGHT' => 1,
	'TEXT' => $end,
	'WIDTH' => 1,
	'X_OFFSET' => $position ,
	'Y_OFFSET' => -$position ,
	} ;

return(@stripes) ;
}

#-----------------------------------------------------------------------------

sub draw_downright # or 135
{
my ($arrow_type, $end_x, $end_y, $allow_diagonal_lines) = @_ ;

my ($stripes, $width, $height) = ([], $end_x + 1, $end_y + 1) ;
my ($start, $body, $connection, $body_2, $end) = @{$arrow_type->[11]}[1 .. 5] ;

if($allow_diagonal_lines && $end_x == $end_y)
	{
	my ($start, $body, $connection, $body_2, $end) = @{$arrow_type->[14]}[1 .. 5] ;
	push @{$stripes}, get_135_stripes($end_x, $start, $body, $end) ;
	}
else
	{
	push @{$stripes},
		{
		'HEIGHT' => $height ,
		'TEXT' => "$start\n" ."$body\n" x ($height -2) . $connection,
		'WIDTH' => 1,
		'X_OFFSET' => 0,
		'Y_OFFSET' => 0,
		},
		{
		'HEIGHT' => 1,
		'TEXT' => $body_2 x ($width -2) . $end,
		'WIDTH' => $width - 1,
		'X_OFFSET' => 1,
		'Y_OFFSET' => $end_y,
		} ;
	}

return($stripes, $width, $height) ;
}

#-----------------------------------------------------------------------------

sub draw_rightdown # or 135
{
my ($arrow_type, $end_x, $end_y, $allow_diagonal_lines) = @_ ;

my ($stripes, $width, $height) = ([], $end_x + 1, $end_y + 1) ;
my ($start, $body, $connection, $body_2, $end) = @{$arrow_type->[12]}[1 .. 5] ;

if($allow_diagonal_lines && $end_x == $end_y)
	{
	my ($start, $body, $connection, $body_2, $end) = @{$arrow_type->[14]}[1 .. 5] ;
	push @{$stripes}, get_135_stripes($end_x, $start, $body, $end) ;
	}
else
	{
	push @{$stripes},
		{
		'HEIGHT' => 1,
		'TEXT' => $start . $body x ($width -2) . $connection,
		'WIDTH' => $width,
		'X_OFFSET' => 0,
		'Y_OFFSET' => 0,
		},
		{
		'HEIGHT' => $height - 1 ,
		'TEXT' => "$body_2\n" x ($height -2) . $end,
		'WIDTH' => 1,
		'X_OFFSET' => $end_x,
		'Y_OFFSET' => 1,
		} ;
	}

return($stripes, $width, $height) ;
}

#-----------------------------------------------------------------------------

sub get_135_stripes
{
my ($position, $start, $body, $end) = @_ ;

my @stripes ;

push @stripes,
	{
	'HEIGHT' => 1,
	'TEXT' => $start,
	'WIDTH' => 1,
	'X_OFFSET' => 0 ,
	'Y_OFFSET' => 0 ,
	} ;

for(my $xy = 1 ; $xy < $position ; $xy++)
	{
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $body,
		'WIDTH' => 1,
		'X_OFFSET' => $xy,
		'Y_OFFSET' => $xy,
		} ;
	}

push @stripes,
	{
	'HEIGHT' => 1,
	'TEXT' => $end,
	'WIDTH' => 1,
	'X_OFFSET' => $position,
	'Y_OFFSET' => $position,
	} ;

return(@stripes) ;
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

my @connectors ;
push @connectors, {X => 0,              Y => 0,              NAME => 'start'} ;
push @connectors, {X => $self->{END_X}, Y => $self->{END_Y}, NAME => 'end'} ;

@connectors
}

#-----------------------------------------------------------------------------

sub get_named_connection
{
my ($self, $name) = @_ ;

if($name eq 'start')
	{
	return( {X => 0, Y => 0, NAME => 'start', CHAR => 'X'} ) ;
	}
elsif($name eq 'end')
	{
	return( {X => $self->{END_X}, Y => $self->{END_Y}, NAME => 'end', CHAR => 'Y'} ) ;
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
	
	$self->setup($self->{ARROW_TYPE}, $new_end_x, $new_end_y, $hint // $self->{DIRECTION},$self ->{ALLOW_DIAGONAL_LINES}, $self->{EDITABLE}) ;
	
	return($x_offset, $y_offset, $self->{WIDTH}, $self->{HEIGHT}, 'start') ;
	}
else
	{
	my $new_end_x = $new_x ;
	my $new_end_y = $new_y ;
	
	$self->setup($self->{ARROW_TYPE}, $new_end_x, $new_end_y, $hint // $self->{DIRECTION}, $self ->{ALLOW_DIAGONAL_LINES}, $self->{EDITABLE}) ;
	
	return(0, 0, $self->{WIDTH}, $self->{HEIGHT}, 'end') ;
	}
}

sub regenerate
{
my ($self) = @_ ;

$self->setup($self->{ARROW_TYPE}, $self->{END_X}, $self->{END_Y}, $self->{DIRECTION}, $self ->{ALLOW_DIAGONAL_LINES}, $self->{EDITABLE}) ;
}

#-----------------------------------------------------------------------------

sub edit
{
my ($self, $asciio) = @_ ;

return unless $self->{EDITABLE} ;

$self->display_arrow_edit_dialog() ;

my ($stripes, $width, $height, $x_offset, $y_offset) =
	$direction_to_arrow{$self->{DIRECTION}}->($self->{ARROW_TYPE}, $self->{END_X}, $self->{END_Y}) ;

$self->set(STRIPES => $stripes,) ;
}

#-----------------------------------------------------------------------------

1 ;









