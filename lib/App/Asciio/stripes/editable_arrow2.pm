
package App::Asciio::stripes::editable_arrow2 ;

use base App::Asciio::stripes::stripes ;

use strict;
use warnings;

use List::Util qw(min max) ;
use Readonly ;
use Clone ;

#-----------------------------------------------------------------------------

Readonly my $DEFAULT_ARROW_TYPE => 
	[
	['Up', '|', '|', '^', 1, ],
	['45', '/', '/', '^', 1, ],
	['Right', '-', '-', '>', 1, ],
	['135', '\\', '\\', 'v', 1, ],
	['Down', '|', '|', 'v', 1, ],
	['225', '/', '/', 'v', 1, ],
	['Left', '-', '-', '<', 1, ],
	['315', '\\', '\\', '^', 1, ],
	] ;

sub new
{
my ($class, $element_definition) = @_ ;

my $self = bless  {}, __PACKAGE__ ;
	
$self->setup
	(
	$element_definition->{ARROW_TYPE} || Clone::clone($DEFAULT_ARROW_TYPE),
	$element_definition->{END_X}, $element_definition->{END_Y},
	$element_definition->{EDITABLE},
	) ;

return $self ;
}

#-----------------------------------------------------------------------------

sub setup
{
my ($self, $arrow_type, $end_x, $end_y, $editable) = @_ ;

my ($stripes, $real_end_x, $real_end_y) = get_arrow($arrow_type, $end_x, $end_y) ;

$self->set
	(
	STRIPES => $stripes,
	END_X => $real_end_x,
	END_Y => $real_end_y,
	ARROW_TYPE => $arrow_type,
	CACHE => undef,
	) ;
}

#-----------------------------------------------------------------------------

sub get_arrow
{
my ($arrow_type, $end_x, $end_y) = @_ ;
my ($stripes, $real_end_x, $real_end_y, $height, $width) = ([]) ;

$end_y *= 2 ; # compensate for aspect ratio

my $direction = $end_x >= 0
			? $end_y <= 0
				? -$end_y > $end_x
					? -$end_y / 4 > $end_x
						? 'up'
						:'45'
					: -$end_y > $end_x / 2
						? '45'
						: 'right'
				: $end_y < $end_x
					? $end_y < $end_x / 2
						? 'right'
						:'135'
					: $end_y  / 4 < $end_x
						? '135'
						: 'down'
			: $end_y < 0
				? $end_y < $end_x
					? $end_y / 4 < $end_x
						? 'up'
						: '315'
					: $end_y < $end_x / 2
						? '315'
						: 'left'
				: $end_y > -$end_x
					? $end_y / 4 > -$end_x
						? 'down'
						: '225'
					: $end_y > -$end_x / 2
						? '225'
						: 'left' ;

$end_y /= 2 ; # done compensating for aspect ratio

my $arrow ;

for ($direction)
	{
	$_ eq 'up' and do
		{
		my ($start, $body, $end) = @{$arrow_type->[0]}[1 .. 3] ;
		
		$height = -$end_y + 1 ;
		$real_end_y = $end_y ;
		$real_end_x = 0 ;
		
		$arrow = $height == 2
				? $end . "\n" . $start
				: $end . "\n" . ("$body\n" x ($height -2)) . $start ;
				
		push @{$stripes},
			{
			'HEIGHT' => $height,
			'TEXT' => $arrow,
			'WIDTH' => 1,
			'X_OFFSET' => 0,
			'Y_OFFSET' => $end_y,
			};
			
		last ;
		} ;
		
	$_ eq '45' and do
		{
		my ($start, $body, $end) = @{$arrow_type->[1]}[1 .. 3] ;
		
		$height = -$end_y + 1 ;
		$real_end_y = $end_y ;
		
		$width = $height ;
		$real_end_x = - $real_end_y;
		
		push @{$stripes},
			{
			'HEIGHT' => 1,
			'TEXT' => $start,
			'WIDTH' => 1,
			'X_OFFSET' => 0,
			'Y_OFFSET' => 0,
			};
			
		for(my $position = -$end_y - 1 ; $position > 0 ; $position--)
			{
			push @{$stripes},
				{
				'HEIGHT' => 1,
				'TEXT' => $body,
				'WIDTH' => 1,
				'X_OFFSET' => $position,
				'Y_OFFSET' => -$position,
				};
			}
			
		push @{$stripes},
			{
			'HEIGHT' => 1,
			'TEXT' => $end,
			'WIDTH' => 1,
			'X_OFFSET' => -$end_y ,
			'Y_OFFSET' => $end_y ,
			};
			
		last ;
		} ;
		
	$_ eq 'right' and do
		{
		my ($start, $body, $end) = @{$arrow_type->[2]}[1 .. 3] ;
		
		$width = $end_x + 1 ;
		$real_end_x = $end_x ;
		$real_end_y = 0 ;
		
		$arrow = $width == 1
				? $end
				: $width == 2
					? $start . $end
					: $start . ($body x ($width -2)) . $end ;
					
		push @{$stripes},
			{
			'HEIGHT' => 1,
			'TEXT' => $arrow,
			'WIDTH' => $width,
			'X_OFFSET' => 0,
			'Y_OFFSET' => 0,
			};
			
		last ;
		} ;
		
	$_ eq '135' and do
		{
		my ($start, $body, $end) = @{$arrow_type->[3]}[1 .. 3] ;
		
		$height = $end_y + 1 ;
		$real_end_y = $end_y ;
		
		$width = $height ;
		$real_end_x = $real_end_y ;
		
		push @{$stripes},
			{
			'HEIGHT' => 1,
			'TEXT' => $start,
			'WIDTH' => 1,
			'X_OFFSET' => 0 ,
			'Y_OFFSET' => 0 ,
			};
			
		for(my $position = 1 ; $position < $end_y ; $position++)
			{
			push @{$stripes},
				{
				'HEIGHT' => 1,
				'TEXT' => $body,
				'WIDTH' => 1,
				'X_OFFSET' => $position,
				'Y_OFFSET' => $position,
				};
			}
			
		push @{$stripes},
			{
			'HEIGHT' => 1,
			'TEXT' => $end,
			'WIDTH' => 1,
			'X_OFFSET' => $end_y ,
			'Y_OFFSET' => $end_y ,
			};
			
		last ;
		} ;
		
	$_ eq 'down' and do
		{
		my ($start, $body, $end) = @{$arrow_type->[4]}[1 .. 3] ;
		$height = $end_y + 1 ;
		$real_end_y = $end_y ;
		$real_end_x  = 0 ;
		
		$arrow = $height == 2
				? $start . "\n" . $end
				: $start . "\n" . ("$body\n" x ($height -2)) . $end ;
				
		push @{$stripes},
			{
			'HEIGHT' => $height,
			'TEXT' => $arrow,
			'WIDTH' => 1,
			'X_OFFSET' => 0,
			'Y_OFFSET' => 0,
			};
		last ;
		} ;
		
	$_ eq '225' and do
		{
		my ($start, $body, $end) = @{$arrow_type->[5]}[1 .. 3] ;
		
		$height = $end_y + 1 ;
		$real_end_y = $end_y ;
		
		$width = $height ;
		$real_end_x = -$real_end_y ;
		
		push @{$stripes},
			{
			'HEIGHT' => 1,
			'TEXT' => $start,
			'WIDTH' => 1,
			'X_OFFSET' => 0,
			'Y_OFFSET' => 0,
			};
			
		for(my $position = $end_y - 1 ; $position > 0 ; $position--)
			{
			push @{$stripes},
				{
				'HEIGHT' => 1,
				'TEXT' => $body,
				'WIDTH' => 1,
				'X_OFFSET' => -$position,
				'Y_OFFSET' => $position,
				};
			}
			
		push @{$stripes},
			{
			'HEIGHT' => 1,
			'TEXT' => $end,
			'WIDTH' => 1,
			'X_OFFSET' => -$end_y ,
			'Y_OFFSET' => $end_y ,
			};
			
		last ;
		} ;
		
	$_ eq 'left' and do
		{
		my ($start, $body, $end) = @{$arrow_type->[6]}[1 .. 3] ;
		
		$width = -$end_x + 1 ;
		
		$real_end_y = 0 ;
		$real_end_x = $end_x ;
		
		$arrow = $width == 2
				? $end . $start
				: $end . ($body x ($width -2)) . $start ;
				
		push @{$stripes},
			{
			'HEIGHT' => 1,
			'TEXT' => $arrow,
			'WIDTH' => $width,
			'X_OFFSET' => $end_x,
			'Y_OFFSET' => 0,
			};
			
		last ;
		} ;
		
	$_ eq '315' and do
		{
		my ($start, $body, $end) = @{$arrow_type->[7]}[1 .. 3] ;
		
		$height = -$end_y + 1 ;
		$real_end_y = $end_y ;
		
		$width = $height ;
		$real_end_x = $real_end_y ;
		
		push @{$stripes},
			{
			'HEIGHT' => 1,
			'TEXT' => $start,
			'WIDTH' => 1,
			'X_OFFSET' => 0,
			'Y_OFFSET' => 0,
			};
			
		for(my $position = 1 ; $position < -$end_y ; $position++)
			{
			push @{$stripes},
				{
				'HEIGHT' => 1,
				'TEXT' => '\\',
				'WIDTH' => 1,
				'X_OFFSET' => -$position,
				'Y_OFFSET' => -$position,
				};
			}
			
		push @{$stripes},
			{
			'HEIGHT' => 1,
			'TEXT' => $end,
			'WIDTH' => 1,
			'X_OFFSET' => $end_y,
			'Y_OFFSET' => $end_y,
			};
			
		last ;
		} ;
	}

return($stripes, $real_end_x, $real_end_y) ;
}

#-----------------------------------------------------------------------------

sub get_extra_points
{
my ($self) = @_ ;

return
	(
	{X =>  $self->{END_X}, Y => $self->{END_Y}, NAME => 'resize'},
	) ;
}

#-----------------------------------------------------------------------------

sub get_selection_action
{
my ($self, $x, $y) = @_ ;

if ($x == $self->{END_X} && $y == $self->{END_Y})
	{
	'resize' ;
	}
else
	{
	'move' ;
	}
}

#-----------------------------------------------------------------------------

sub resize
{
my ($self, $reference_x, $reference_y, $new_x, $new_y) = @_ ;

my $new_end_x = $new_x ;
my $new_end_y = $new_y ;

$self->setup($self->{ARROW_TYPE}, $new_end_x, $new_end_y, $self->{EDITABLE}) ;

return(0, 0, $self->{END_X} + 1, $self->{END_X} + 1) ;
}

#-----------------------------------------------------------------------------

sub get_text
{
my ($self) = @_ ;
}

#-----------------------------------------------------------------------------

sub set_text
{
my ($self) = @_ ;
}

#-----------------------------------------------------------------------------

sub edit
{
my ($self, $asciio) = @_ ;

return unless $self->{EDITABLE} ;

$self->display_box_edit_dialog() ;

$self->setup($self->{ARROW_TYPE}, $self->{END_X}, $self->{END_Y}, $self->{EDITABLE}) ;
}


#-----------------------------------------------------------------------------

1 ;
