
package App::Asciio::stripes::section_wirl_arrow ;
use base App::Asciio::stripes::stripes ;

use strict;
use warnings;

use List::Util qw(min max) ;
use Readonly ;
use Clone ;

use App::Asciio::stripes::wirl_arrow ;

#-----------------------------------------------------------------------------

Readonly my $DEFAULT_ARROW_TYPE =>
			[
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
			['225',         '/',  '/',   '',  '', 'v', 1],
			['315',        '\\', '\\',   '',  '', '^', 1],
			] ;

# constants for connector overlays
Readonly my $body_index => 2 ;
Readonly my $connection_index => 3 ;

Readonly my $up_index=> 1 ;
Readonly my $left_index=> 3 ;
Readonly my $leftup_index => 5 ;
Readonly my $leftdown_index => 7 ;
Readonly my $rightup_index => 10 ;
Readonly my $rightdown_index => 12 ;

#-----------------------------------------------------------------------------

sub new
{
my ($class, $element_definition) = @_ ;

my $self = bless {}, __PACKAGE__ ;

$self->setup
	(
	$element_definition->{ARROW_TYPE} || Clone::clone($DEFAULT_ARROW_TYPE),
	$element_definition->{POINTS},
	$element_definition->{DIRECTION},
	$element_definition->{ALLOW_DIAGONAL_LINES},
	$element_definition->{EDITABLE},
	$element_definition->{NOT_CONNECTABLE_START},
	$element_definition->{NOT_CONNECTABLE_END},
	) ;

return $self ;
}

#-----------------------------------------------------------------------------

sub setup
{
my ($self, $arrow_type, $points, $direction, $allow_diagonal_lines, $editable, $not_connectable_start, $not_connectable_end) = @_ ;

if('ARRAY' eq ref $points && @{$points} > 0)
	{
	delete $self->{CACHE} ;
	
	my ($start_x, $start_y, $arrows) = (0, 0, []) ;
	
	my $points_offsets ;
	my $arrow_index = 0 ; # must have a numeric index or 'undo' won't work
	
	for my $point (@{$points})
		{
		my ($x, $y, $point_direction) = @{$point} ;
		
		my $arrow = new App::Asciio::stripes::wirl_arrow
					({
					ARROW_TYPE => $arrow_type,
					END_X => $x - $start_x,
					END_Y => $y - $start_y,
					DIRECTION => $point_direction || $direction,
					ALLOW_DIAGONAL_LINES => $allow_diagonal_lines,
					EDITABLE => $editable,
					}) ;
		
		$points_offsets->[$arrow_index++] = [$start_x, $start_y] ;
		
		push @{$arrows},  $arrow ;
		($start_x, $start_y) = ($x, $y) ;
		}
	
	$self->set
		(
		POINTS_OFFSETS => $points_offsets,
		ARROWS => $arrows,
		
		# keep data to allow section insertion later
		ARROW_TYPE => $arrow_type,
		DIRECTION => $direction,
		ALLOW_DIAGONAL_LINES => $allow_diagonal_lines,
		EDITABLE => $editable,
		NOT_CONNECTABLE_START => $not_connectable_start,
		NOT_CONNECTABLE_END => $not_connectable_end,
		) ;
	
	my ($width, $height) = $self->get_width_and_height() ;
	$self->set
			(
			WIDTH => $width,
			HEIGHT => $height,
			) ;
	}
else
	{
	die "Bad 'section wirl arrow' defintion! Expecting points array." ;
	}
}

#-----------------------------------------------------------------------------

my %diagonal_direction_to_overlay_character =
	(
	(map {$_ => q{\\}} qw( down-right right-down up-left left-up)), 
	(map {$_ => q{/}} qw( down-left left-down up-right right-up)), 
	) ;

my %diagonal_non_diagonal_to_overlay_character =
	(
	(map {$_ => q{.}} qw( down-right right-down up-left left-up)), 
	(map {$_ => q{'}} qw( down-left left-down up-right right-up)), 
	) ;

sub get_stripes
{
my ($self) = @_ ;

my $stripes = $self->{CACHE}{STRIPES} ;

unless (defined $stripes)
	{
	my @stripes ;
	
	my $arrow_index = 0 ;
	for my $arrow(@{$self->{ARROWS}})
		{
		push @stripes, 
			map 
			{
				{
				TEXT     => $_->{TEXT},
				WIDTH    => $_->{WIDTH}, 
				HEIGHT   => $_->{HEIGHT} , 
				X_OFFSET => $_->{X_OFFSET} + $self->{POINTS_OFFSETS}[$arrow_index][0],
				Y_OFFSET => $_->{Y_OFFSET} + $self->{POINTS_OFFSETS}[$arrow_index][1],
				}
			} @{$arrow->get_stripes()} ;
			
		$arrow_index++ ;
		}
	
	# handle connections
	my ($previous_direction) = ($self->{ARROWS}[0]{DIRECTION} =~ /^([^-]+)/) ;
	
	my $previous_was_diagonal ;
	
	$arrow_index = 0 ;
	for my $arrow(@{$self->{ARROWS}})
		{
		last if @{$self->{ARROWS}} == 1 ;
		
		my ($connection, $d1, $d2) ;
			
		if($arrow->{DIRECTION} =~ /^([^-]+)-([^-]+)$/) 
			{
			($d1, $d2) = ($1, $2) ;
			}
		else
			{
			$d1 = $arrow->{DIRECTION};
			}
		
		if($self->{ALLOW_DIAGONAL_LINES} && $arrow->{WIDTH} == $arrow->{HEIGHT})
			{
			# this section is diagonal
			if
				(
				$previous_was_diagonal
				&& 
					(
					$previous_was_diagonal eq $arrow->{DIRECTION} 
					|| 
					(defined $d2 && $previous_was_diagonal eq "$d2-$d1")
					)
				)
				{
				# two diagonals going in the same direction
				$connection = $diagonal_direction_to_overlay_character{$arrow->{DIRECTION}} ;
				}
			else
				{
				# previous non diagonal or two diagonals not going in the same direction
				$connection  = ($d1 eq 'up' || (defined $d2 && $d2 eq 'up')) ?  q{'} : q{.} ;
				}
			
			$previous_was_diagonal = $arrow->{DIRECTION} ;
			}
		else
			{
			# straight or angled arrow
			if(defined $previous_was_diagonal)
				{
				if($arrow->{DIRECTION} =~ /^down/)
					{
					$connection = q{.}   ;
					}
				elsif($arrow->{DIRECTION} =~ /^up/)
					{
					$connection = q{'}  ;
					}
				else
					{
					$connection = $previous_was_diagonal =~ /down/ ? q{'} : q{.} ;
					}
				}
			else
				{
				if($previous_direction ne $d1)
					{
					if($d1 eq 'down')
						{
						if($previous_direction eq 'right')
							{
							$connection = $self->{ARROW_TYPE}[$rightdown_index][$connection_index] ;
							}
						elsif($previous_direction eq 'left')
							{
							$connection = $self->{ARROW_TYPE}[$leftdown_index][$connection_index] ;
							}
						else
							{
							$connection = $self->{ARROW_TYPE}[$up_index][$connection_index] ;
							}
						}
					elsif($d1 eq 'up')
						{
						if($previous_direction eq 'right')
							{
							$connection = $self->{ARROW_TYPE}[$rightup_index][$connection_index] ;
							}
						elsif($previous_direction eq 'left')
							{
							$connection = $self->{ARROW_TYPE}[$leftup_index][$connection_index] ;
							}
						else
							{
							$connection = $self->{ARROW_TYPE}[$up_index][$connection_index] ;
							}
						}
					elsif($previous_direction eq 'down')
						{
						if($d1 eq 'left')
							{
							$connection = $self->{ARROW_TYPE}[$rightup_index][$connection_index] ;
							}
						else
							{
							$connection = $self->{ARROW_TYPE}[$leftup_index][$connection_index] ;
							}
						}
					elsif($previous_direction eq 'up')
						{
						if($d1 eq 'left')
							{
							$connection = $self->{ARROW_TYPE}[$rightdown_index][$connection_index] ;
							}
						else
							{
							$connection = $self->{ARROW_TYPE}[$leftdown_index][$connection_index] ;
							}
						}
					else
						{
						$connection = $self->{ARROW_TYPE}[$left_index][$body_index] ;
						}
					}
				}
			
			$previous_direction = defined $d2 ? $d2 : $d1 ;
			$previous_was_diagonal = undef ;
			}
		
		if($arrow_index != 0 && defined $connection) # first character of the first section is always right
			{
			# overlay the first character of this arrow
			push @stripes, 
				{
				TEXT     => $connection,
				WIDTH    => 1,
				HEIGHT   => 1,
				X_OFFSET => $self->{POINTS_OFFSETS}[$arrow_index][0],
				Y_OFFSET => $self->{POINTS_OFFSETS}[$arrow_index][1],
				} ;
			}
		
		$arrow_index++ ;
		}
	
	$stripes = $self->{CACHE}{STRIPES} = \@stripes ;
	}

return $stripes ;
}

#-----------------------------------------------------------------------------

sub get_selection_action
{
my ($self, $x, $y) = @_ ;

my $action = 'move' ;

my $arrow_index = 0 ;
for my $arrow(@{$self->{ARROWS}})
	{
	my ($start_connector, $end_connector) = $arrow->get_connector_points() ;
	
	$start_connector->{X} += $self->{POINTS_OFFSETS}[$arrow_index][0] ;
	$start_connector->{Y} += $self->{POINTS_OFFSETS}[$arrow_index][1] ;
	
	if($x == $start_connector->{X} && $y == $start_connector->{Y})
		{
		$action = 'resize' ;
		last ;
		}
	
	$end_connector->{X} += $self->{POINTS_OFFSETS}[$arrow_index][0] ;
	$end_connector->{Y} += $self->{POINTS_OFFSETS}[$arrow_index][1] ;
	
	if($x == $end_connector->{X} && $y == $end_connector->{Y})
		{
		$action = 'resize' ;
		last ;
		}
	
	$arrow_index++ ;
	}

return $action ;
}

#-----------------------------------------------------------------------------

sub allow_connection
{
my ($self, $which, $connect) = @_ ;

if($which eq 'start')
	{
	$self->{NOT_CONNECTABLE_START} = !$connect ;
	}
else
	{
	$self->{NOT_CONNECTABLE_END} = !$connect ;
	}
}

#-----------------------------------------------------------------------------

sub is_connection_allowed
{
my ($self, $which) = @_ ;

if($which eq 'start')
	{
	return(! $self->{NOT_CONNECTABLE_START}) ;
	}
else
	{
	return(! $self->{NOT_CONNECTABLE_END}) ;
	}
}

#-----------------------------------------------------------------------------

sub are_diagonals_allowed
{
my ($self, $allow) = @_ ;
return $self->{ALLOW_DIAGONAL_LINES} ;
}

#-----------------------------------------------------------------------------

sub allow_diagonals
{
my ($self, $allow) = @_ ;
$self->{ALLOW_DIAGONAL_LINES} = $allow ;

for my $arrow(@{$self->{ARROWS}})
	{
	$arrow->{ALLOW_DIAGONAL_LINES} = $allow ;
	}
}

#-----------------------------------------------------------------------------

sub get_connector_points
{
my ($self) = @_ ;

my (@all_connector_points)  = $self->get_all_points() ;
my (@connector_points) ;

push @connector_points, $all_connector_points[0] unless $self->{NOT_CONNECTABLE_START} ;
push @connector_points, $all_connector_points[-1] unless $self->{NOT_CONNECTABLE_END} ;

return(@connector_points) ;
}

#-----------------------------------------------------------------------------

sub get_extra_points
{
my ($self) = @_ ;

my(@all_connector_points)  = $self->get_all_points() ;

shift @all_connector_points unless $self->{NOT_CONNECTABLE_START} ;
pop @all_connector_points  unless $self->{NOT_CONNECTABLE_END} ;

return(@all_connector_points) ;
}

#-----------------------------------------------------------------------------

sub get_all_points
{
my ($self) = @_ ;

my(@connector_points) ;

my $arrow_index = 0 ;

for my $arrow(@{$self->{ARROWS}})
	{
	my ($start_connector, $end_connector) = $arrow->get_connector_points() ;
	
	if($arrow == $self->{ARROWS}[0])
		{
		$start_connector->{X} += $self->{POINTS_OFFSETS}[$arrow_index][0] ;
		$start_connector->{Y} += $self->{POINTS_OFFSETS}[$arrow_index][1] ;
		$start_connector->{NAME} .= "section_$arrow_index" ;
		
		push @connector_points, $start_connector ;
		}
		
	$end_connector->{X} += $self->{POINTS_OFFSETS}[$arrow_index][0] ;
	$end_connector->{Y} += $self->{POINTS_OFFSETS}[$arrow_index][1] ;
	$end_connector->{NAME} .= "section_$arrow_index" ;
	
	push @connector_points, $end_connector ;
	$arrow_index++ ;
	}

return(@connector_points) ;
}

#-----------------------------------------------------------------------------

sub get_named_connection
{
my ($self, $name) = @_ ;

my $connection ;

my $arrow_index = 0 ;

for my $arrow(@{$self->{ARROWS}})
	{
	my ($start_connector, $end_connector) = $arrow->get_connector_points() ;
	
	if($arrow == $self->{ARROWS}[0])
		{
		$start_connector->{NAME} .= "section_$arrow_index" ;
		
		if($name eq  $start_connector->{NAME})
			{
			$start_connector->{X} += $self->{POINTS_OFFSETS}[$arrow_index][0] ;
			$start_connector->{Y} += $self->{POINTS_OFFSETS}[$arrow_index][1] ;
			$connection = $start_connector ;
			
			for my $arrow_type (@{$arrow->{ARROW_TYPE}})
				{
				$connection->{CHAR} = $arrow_type->[1] and last if $arrow->{DIRECTION} eq $arrow_type->[0] ;
				}
			
			last ;
			}
		}
	
	$end_connector->{NAME} .= "section_$arrow_index" ;
	
	if($name eq  $end_connector->{NAME})
		{
		$end_connector->{X} += $self->{POINTS_OFFSETS}[$arrow_index][0] ;
		$end_connector->{Y} += $self->{POINTS_OFFSETS}[$arrow_index][1] ;
		$connection = $end_connector ;
		
		for my $arrow_type (@{$arrow->{ARROW_TYPE}})
			{
			$connection->{CHAR} = $arrow_type->[5] and last if $arrow->{DIRECTION} eq $arrow_type->[0] ;
			}
		
		last ;
		}
	
	$arrow_index++ ;
	}

return $connection ;
}

#-----------------------------------------------------------------------------

sub move_connector
{
my ($self, $connector_name, $x_offset, $y_offset, $hint) = @_ ;

my $connection = $self->get_named_connection($connector_name) ;

(my $no_section_connetor_name = $connector_name) =~ s/section_.*// ;

if($connection)
	{
	delete $self->{CACHE} ;
	
	my ($x_offset, $y_offset, $width, $height, undef) = 
		$self->resize
			(
			$connection->{X},
			$connection->{Y},
			$connection->{X} + $x_offset,
			$connection->{Y} + $y_offset,
			$hint,
			#~ [$no_section_connetor_name, $connector_name],
			[$connector_name, $no_section_connetor_name],
			) ;
	
	return
		(
		$x_offset, $y_offset, $width, $height,
		$self->get_named_connection($connector_name)
		) ;
	}
else
	{
	die "unknown connector '$connector_name'!\n" ;
	}
}

#-----------------------------------------------------------------------------

sub resize
{
my ($self, $reference_x, $reference_y, $new_x, $new_y, $hint, $connector_name_array) = @_ ;

Readonly my $MULTI_WIRL_CONNECTOR_NAME_INDEX => 0 ;
Readonly my $WIRL_CONNECTOR_NAME_INDEX => 1 ;

delete $self->{CACHE} ;

my ($start_element, $start_element_index, $end_element, $end_element_index) ;

# find elements connected by the connector
if(defined $connector_name_array)
	{
	($start_element, $start_element_index, $end_element, $end_element_index, $connector_name_array) = 
		$self->find_elements_for_connector_named($connector_name_array) ;
	}
else
	{
	($start_element, $start_element_index, $end_element, $end_element_index, $connector_name_array) = 
		$self->find_elements_for_connector_at($reference_x, $reference_y) ;
	}

my ($start_x_offset, $start_y_offset) = (0, 0) ;
if(defined $start_element)
	{
	my $is_start ;
	if(defined $connector_name_array)
		{
		if
			(
			$connector_name_array->[$WIRL_CONNECTOR_NAME_INDEX] eq 'start'
			|| $connector_name_array->[$MULTI_WIRL_CONNECTOR_NAME_INDEX] eq 'startsection_0'
			)
			{
			$is_start++ ;
			}
		}
	else
		{
		if($reference_x == 0 && $reference_y == 0)
			{
			$is_start++  ;
			}
		}
	
	if($is_start)
		{
		#~ print "Moving start connector\n" ;
		
		($start_x_offset, $start_y_offset) = 
			$start_element->resize
				(
				0, 0,
				$new_x, $new_y,
				$hint,
				$connector_name_array->[$WIRL_CONNECTOR_NAME_INDEX]
				) ;
		
		my $arrow_index = 0 ;
		for my $arrow(@{$self->{ARROWS}})
			{
			# offsets all other wirl_arrow start offsets
			if($arrow == $start_element)
				{
				}
			else
				{
				$self->{POINTS_OFFSETS}[$arrow_index][0] -= $start_x_offset ;
				$self->{POINTS_OFFSETS}[$arrow_index][1] -= $start_y_offset ;
				}
				
			$arrow_index++ ;
			}
		}
	else
		{
		my $start_element_x_offset = $self->{POINTS_OFFSETS}[$start_element_index][0] ;
		my $start_element_y_offset = $self->{POINTS_OFFSETS}[$start_element_index][1] ;
		
		my ($x_offset, $y_offset) = 
			$start_element ->resize
							(
							$reference_x - $start_element_x_offset,
							$reference_y - $start_element_y_offset,
							$new_x - $start_element_x_offset,
							$new_y - $start_element_y_offset,
							$hint,
							$connector_name_array->[$WIRL_CONNECTOR_NAME_INDEX]
							) ;
							
		$self->{POINTS_OFFSETS}[$start_element_index][0] += $x_offset ;
		$self->{POINTS_OFFSETS}[$start_element_index][1] += $y_offset ;
		
		if(defined $end_element)
			{
			my ($x_offset, $y_offset) = $end_element->resize(0, 0, $new_x - $reference_x, $new_y - $reference_y) ;
			$self->{POINTS_OFFSETS}[$end_element_index][0] += $x_offset ;
			$self->{POINTS_OFFSETS}[$end_element_index][1] += $y_offset ;
			}
		}
	}

my ($width, $height) = $self->get_width_and_height() ;
$self->set(WIDTH => $width, HEIGHT => $height) ;

return($start_x_offset, $start_y_offset, $width, $height, $connector_name_array) ;
}

sub find_elements_for_connector_at
{
my ($self, $reference_x, $reference_y) = @_ ;

my ($start_element, $start_element_index, $end_element, $end_element_index, $connector_name, $wirl_connector_name) ;

my $arrow_index = 0 ;
for my $arrow(@{$self->{ARROWS}})
	{
	my ($start_connector, $end_connector) = $arrow->get_connector_points() ;
	
	if($reference_x == 0 && $reference_y == 0)
		{
		($start_element, $start_element_index) = ($arrow, $arrow_index) ;
		$wirl_connector_name = $start_connector->{NAME} ;
		$connector_name =  $wirl_connector_name . "section_$arrow_index" ;
		last ;
		}
	
	if(defined $start_element)
		{
		($end_element, $end_element_index) = ($arrow, $arrow_index) ;
		last ;
		}
	
	if
		(
		   $reference_x == $end_connector->{X} + $self->{POINTS_OFFSETS}[$arrow_index][0]
		&& $reference_y == $end_connector->{Y} + $self->{POINTS_OFFSETS}[$arrow_index][1]
		)
		{
		($start_element, $start_element_index) = ($arrow, $arrow_index) ;
		$wirl_connector_name = $end_connector->{NAME} ;
		$connector_name =  $wirl_connector_name . "section_$arrow_index" ;
		}
	
	$arrow_index++ ;
	}

return($start_element, $start_element_index, $end_element, $end_element_index, [$connector_name, $wirl_connector_name])
}

sub find_elements_for_connector_named
{
my ($self, $connector_name_array) = @_ ;

my ($connector_name, $wirl_connector_name) = @{$connector_name_array} ;

my ($start_element, $start_element_index, $end_element, $end_element_index) ;

my $arrow_index = 0 ;
for my $arrow(@{$self->{ARROWS}})
	{
	my ($start_connector, $end_connector) = $arrow->get_connector_points() ;
	
	if($connector_name eq  $start_connector->{NAME} . "section_$arrow_index" )
		{
		($start_element, $start_element_index) = ($arrow, $arrow_index) ;
		last ;
		}
	
	if(defined $start_element)
		{
		($end_element, $end_element_index) = ($arrow, $arrow_index) ;
		last ;
		}
	
	if($connector_name eq $end_connector->{NAME} . "section_$arrow_index")
		{
		($start_element, $start_element_index) = ($arrow, $arrow_index) ;
		}
	
	$arrow_index++ ;
	}

return($start_element, $start_element_index, $end_element, $end_element_index, $connector_name_array) ;
}

#-----------------------------------------------------------------------------

sub get_number_of_sections { my ($self) = @_ ; return scalar(@{$self->{ARROWS}}) ; }

#-----------------------------------------------------------------------------

sub get_section_direction
{
my ($self, $section_index) = @_ ;

if(exists($self->{ARROWS}[$section_index]))
	{
	return $self->{ARROWS}[$section_index]->get_direction() ;
	}
else
	{
	return ;
	}
}

#-----------------------------------------------------------------------------

sub insert_section
{
my ($self, $x_offset, $y_offset) = @_ ;

delete $self->{CACHE} ;

my $index = 0 ;

for my $arrow (@{$self->{ARROWS}})
	{
	if
		(
		$self->is_over_element
				(
				$arrow,
				$x_offset, $y_offset, 0,
				@{$self->{POINTS_OFFSETS}[$index]}
				)
		)
		{
		my ($original_arrow_end_x, $original_arrow_end_y) = ($arrow->{END_X}, $arrow->{END_Y}) ;
		
		my $first_section = new App::Asciio::stripes::wirl_arrow
					({
					END_X => $x_offset - $self->{POINTS_OFFSETS}[$index][0], 
					END_Y => $y_offset - $self->{POINTS_OFFSETS}[$index][1],
					ARROW_TYPE => $arrow->{ARROW_TYPE},
					DIRECTION => $arrow->{DIRECTION},
					ALLOW_DIAGONAL_LINES => $arrow->{ALLOW_DIAGONAL_LINES},
					EDITABLE => $arrow->{EDITABLE},
					}) ;
		
		$self->{ARROWS}[$index] = $first_section ;
		
		my $new_section = new App::Asciio::stripes::wirl_arrow
					({
					END_X => ($self->{POINTS_OFFSETS}[$index][0] + $original_arrow_end_x) - $x_offset, 
					END_Y => ($self->{POINTS_OFFSETS}[$index][1] + $original_arrow_end_y) - $y_offset,
					ARROW_TYPE => $arrow->{ARROW_TYPE},
					DIRECTION => $arrow->{DIRECTION},
					ALLOW_DIAGONAL_LINES => $arrow->{ALLOW_DIAGONAL_LINES},
					EDITABLE => $arrow->{EDITABLE},
					}) ;
					
		splice @{$self->{ARROWS}}, $index + 1, 0, $new_section ;
		splice @{$self->{POINTS_OFFSETS}}, $index + 1, 0, [$x_offset, $y_offset] ;
		
		last ;
		}
	
	$index++ ;
	}
}

#-----------------------------------------------------------------------------

sub prepend_section
{
my ($self, $extend_x, $extend_y) = @_ ;

delete $self->{CACHE} ;

my $arrow = new App::Asciio::stripes::wirl_arrow
			({
			END_X => -$extend_x, 
			END_Y => -$extend_y,
			ARROW_TYPE => $self->{ARROW_TYPE},
			DIRECTION => $self->{DIRECTION},
			ALLOW_DIAGONAL_LINES => $self->{ALLOW_DIAGONAL_LINES},
			EDITABLE => $self->{EDITABLE},
			}) ;

my $arrow_index = 0 ;
for my $arrow(@{$self->{ARROWS}})
	{
	$self->{POINTS_OFFSETS}[$arrow_index][0] += -$extend_x ;
	$self->{POINTS_OFFSETS}[$arrow_index][1] += -$extend_y ;
	
	$arrow_index++ ;
	}

unshift @{$self->{POINTS_OFFSETS}}, [0, 0] ;
unshift @{$self->{ARROWS}}, $arrow ;

my ($width, $height) = $self->get_width_and_height() ;
$self->set(WIDTH => $width, HEIGHT => $height,) ;
}

#-----------------------------------------------------------------------------

sub append_section
{
my ($self, $extend_x, $extend_y) = @_ ;

delete $self->{CACHE} ;

my $last_point = $self->get_points()->[-1] ;

my $arrow = new App::Asciio::stripes::wirl_arrow
			({
			END_X => $extend_x - $last_point->[0],
			END_Y => $extend_y - $last_point->[1],
			ARROW_TYPE => $self->{ARROW_TYPE},
			DIRECTION => $self->{DIRECTION},
			ALLOW_DIAGONAL_LINES => $self->{ALLOW_DIAGONAL_LINES},
			EDITABLE => $self->{EDITABLE},
			}) ;

my ($start_x, $start_y) = @{$self->{POINTS_OFFSETS}[-1]} ;
my ($start_connector, $end_connector) = $self->{ARROWS}[-1]->get_connector_points() ;

$start_x += $end_connector->{X} ;
$start_y += $end_connector->{Y} ;

push @{$self->{POINTS_OFFSETS}}, [$start_x, $start_y] ;
push @{$self->{ARROWS}}, $arrow ;

my ($width, $height) = $self->get_width_and_height() ;
$self->set(WIDTH => $width, HEIGHT => $height,) ;
}

#-----------------------------------------------------------------------------

sub remove_last_section
{
my ($self) = @_ ;

return if @{$self->{ARROWS}} == 1 ;

delete $self->{CACHE} ;

pop @{$self->{POINTS_OFFSETS}} ;
pop @{$self->{ARROWS}} ;

my ($width, $height) = $self->get_width_and_height() ;
$self->set(WIDTH => $width, HEIGHT => $height,) ;
}

#-----------------------------------------------------------------------------

sub remove_first_section
{
my ($self) = @_ ;

return(0, 0) if @{$self->{ARROWS}} == 1 ;

delete $self->{CACHE} ;

my $second_arrow_x_offset = $self->{POINTS_OFFSETS}[1][0] ;
my $second_arrow_y_offset = $self->{POINTS_OFFSETS}[1][1] ;

shift @{$self->{POINTS_OFFSETS}} ;
shift @{$self->{ARROWS}} ;

my $arrow_index = 0 ;
for my $arrow(@{$self->{ARROWS}})
	{
	$self->{POINTS_OFFSETS}[$arrow_index][0] -= $second_arrow_x_offset ;
	$self->{POINTS_OFFSETS}[$arrow_index][1] -= $second_arrow_y_offset ;
	
	$arrow_index++ ;
	}

my ($width, $height) = $self->get_width_and_height() ;
$self->set(WIDTH => $width, HEIGHT => $height,) ;

return($second_arrow_x_offset, $second_arrow_y_offset) ;
}

#-----------------------------------------------------------------------------

sub change_section_direction
{
my ($self, $x, $y) = @_ ;

delete $self->{CACHE} ;

if(1 == @{$self->{ARROWS}})
	{
	my $direction = $self->{ARROWS}[0]->get_direction() ;
	
	if($direction =~ /(.*)-(.*)/)
		{
		$self->{ARROWS}[0]->resize(0, 0, 0, 0, "$2-$1") ;
		}
	}
else
	{
	my $index = 0 ;
	
	for my $arrow(@{$self->{ARROWS}})
		{
		if
			(
			$self->is_over_element
					(
					$arrow,
					$x, $y, 0,
					@{$self->{POINTS_OFFSETS}[$index]}
					)
			)
			{
			my $direction = $arrow->get_direction() ;
			
			if($direction =~ /(.*)-(.*)/)
				{
				$arrow->resize(0, 0, 0, 0, "$2-$1") ;
				}
				
			last ;
			}
		
		$index++ ;
		}
	}
}

#-----------------------------------------------------------------------------

sub is_over_element
{
my ($self, $element, $x, $y, $field, $element_offset_x, $element_offset_y, ) = @_ ;

$field ||= 0 ;
my $is_under = 0 ;

for my $strip (@{$element->get_stripes()})
	{
	my $stripe_x = $element_offset_x + $strip->{X_OFFSET} ;
	my $stripe_y = $element_offset_y + $strip->{Y_OFFSET} ;
	
	if
		(
		$stripe_x - $field <= $x   && $x < $stripe_x + $strip->{WIDTH} + $field
		&& $stripe_y - $field <= $y && $y < $stripe_y + $strip->{HEIGHT} + $field
		) 
		{
		$is_under++ ;
		last ;
		}
	}

return($is_under) ;
}

#-----------------------------------------------------------------------------

sub get_width_and_height
{
my ($self) = @_ ;

my ($smallest_x, $biggest_x, $smallest_y, $biggest_y) = (0, 0, 0, 0) ;

my $arrow_index = 0 ;
for my $start_point (@{$self->{POINTS_OFFSETS}})
	{
	my ($x, $y) = @{$start_point} ;
	
	my ($start_connector, $end_connector) = $self->{ARROWS}[$arrow_index]->get_connector_points() ;
	$x += $end_connector->{X} ;
	$y += $end_connector->{Y} ;
	
	$smallest_x = min($smallest_x, $x) ;
	$smallest_y = min($smallest_y, $y) ;
	$biggest_x = max($biggest_x, $x) ;
	$biggest_y = max($biggest_y, $y) ;
	
	$arrow_index++ ;
	}

$self->{EXTENTS} = [$smallest_x, $smallest_y, $biggest_x + 1, $biggest_y + 1] ;

return(($biggest_x - $smallest_x) + 1, ($biggest_y - $smallest_y) + 1) ;
}

#-----------------------------------------------------------------------------

sub get_arrow_type { my ($self) = @_ ; return($self->{ARROW_TYPE})  ; }

#-----------------------------------------------------------------------------

sub set_arrow_type
{
my ($self, $arrow_type) = @_ ;

delete $self->{CACHE} ;
$self->setup($arrow_type, $self->get_points(), $self->{DIRECTION}, $self->{ALLOW_DIAGONAL_LINES}, $self->{EDITABLE}) ;
}

#-----------------------------------------------------------------------------

sub get_points
{
my ($self) = @_ ;

my @points ;
my $arrow_index = 0 ;

for my $point_offset (@{$self->{POINTS_OFFSETS}})
	{
	my ($x_offset, $y_offset) = @{$point_offset} ;
	my ($start_connector, $end_connector, $direction) 
		= (
			$self->{ARROWS}[$arrow_index]->get_connector_points(),
			$self->{ARROWS}[$arrow_index]->get_direction()
		) ;
	
	push @points, [$x_offset + $end_connector->{X}, $y_offset + $end_connector->{Y}, $direction] ;
	
	$arrow_index++ ;
	}

return \@points ;
}

#-----------------------------------------------------------------------------

sub edit
{
my ($self) = @_ ;

return unless $self->{EDITABLE} ;

delete $self->{CACHE} ;

$self->display_arrow_edit_dialog() ;
}

#-----------------------------------------------------------------------------

1 ;

