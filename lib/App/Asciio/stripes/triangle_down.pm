
package App::Asciio::stripes::triangle_down ;
use base App::Asciio::stripes::stripes ;

use strict;
use warnings;
use utf8 ;

use List::Util qw(max) ;
use Readonly ;

Readonly my $DEFAULT_BOX_TYPE =>
[
	['top', '.', '-', '.', ], 
	['middle', '\\', '/',  ],
	['bottom', '\'', ] ,
] ;

my %box_types = 
	(
	triangle_down_normal =>
		[
			['top',     '.', '-', '.', ], 
			['middle', '\\', '/',      ],
			['bottom', '\'',           ] ,
		] ,
	triangle_down_dot =>
		[
			['top',    '.', '.', '.', ], 
			['middle', '.', '.',      ],
			['bottom', '\'',          ] ,
		] ,
	) ;

use App::Asciio::String ;

#-----------------------------------------------------------------------------

sub new
{
my ($class, $element_definition) = @_ ;

my $self = bless  {}, __PACKAGE__ ;

$self->setup
	(
	$element_definition->{TEXT_ONLY},
	$element_definition->{WIDTH} || 1,
	$element_definition->{HEIGHT} || 1,
	$element_definition->{EDITABLE},
	$element_definition->{RESIZABLE},
	$element_definition->{BOX_TYPE} || Clone::clone($DEFAULT_BOX_TYPE),
	) ;

return $self ;
}

#-----------------------------------------------------------------------------

sub setup
{
# 3 row 5 col
#.---.
# \ / 
#  '  
# 4 row 7 col
#.-----.
# \   / 
#  \ /  
#   '   
# 5 row 9 col
#.-------.
# \     / 
#  \   /  
#   \ /   
#    '    
# 6 row 11 col
#.---------.
# \       / 
#  \     /  
#   \   /   
#    \ /    
#     '     
# max_col = 2 * max_row - 1

my ($self, $text_only, $end_x, $end_y, $editable, $resizable, $box_type) = @_ ;
Readonly my $mini_row => 3 ; 

my $height = max($mini_row, $end_y) ;
my $half_line_num = int($height / 2) ;

my @lines ; 

push @lines, map {''} (1 ..  $height) ;

my $element_width = $height * 2 - 1 ;
my $half_elament_width = int($element_width / 2) ;

my $y_offset = 0 ;
my (@stripes, $strip_text, $width, $x_offset, $left_center_x, $resize_point_x) ;

# divided into 3 parts
# up middle down
$left_center_x = int($height / 2) - 1;
for my $line (@lines)
	{
		if($y_offset == 0) {
			$width = $element_width ;
			$strip_text = $box_type->[0][1] . $box_type->[0][2] x ($width - 2) . $box_type->[0][3] ;
			$x_offset = 0 ;
		} elsif($y_offset == $height - 1) {
			$width = 1 ;
			$strip_text = $box_type->[2][1] ;
			$x_offset = $half_elament_width ;
			$resize_point_x = $half_elament_width + 1 ;
		} else {
			$width = $element_width - 2 * $y_offset ;
			$strip_text = $box_type->[1][1] . ' ' x ($width - 2) . $box_type->[1][2] ;
			$x_offset = $y_offset ;
		}
		
		push @stripes,
			{
			'HEIGHT' => 1,
			'TEXT' => $strip_text,
			'WIDTH' => unicode_length($strip_text) ,
			'X_OFFSET' => $x_offset,
			'Y_OFFSET' => $y_offset,
			} ;
		$y_offset++ ;
	}

$self->set
	(
	STRIPES => \@stripes,
	WIDTH => $element_width,
	HEIGHT => $height,
	LEFT_CENTER_X => $left_center_x,
	RESIZE_POINT_X => $resize_point_x,
	TEXT_ONLY => $text_only,
	EDITABLE => $editable,
	RESIZABLE => $resizable,
	BOX_TYPE => $box_type,
	EXTENTS => [0, 0, $element_width, $height],
	) ;
}

#-----------------------------------------------------------------------------

sub get_selection_action
{
my ($self, $x, $y) = @_ ;

($x == $self->{RESIZE_POINT_X} && $y == $self->{HEIGHT} - 2)
	? 'resize'
	: 'move' ;
}

#-----------------------------------------------------------------------------

sub match_connector
{
my ($self, $x, $y) = @_ ;

my $middle_width = int($self->{WIDTH} / 2) ;
my $middle_height = int($self->{HEIGHT} / 2) ;

if($x == $middle_width && $y == -1)
	{
	return {X =>  $x, Y => $y, NAME => 'top_center'} ;
	}
elsif($x == $middle_width && $y == $self->{HEIGHT})
	{
	return {X =>  $x, Y => $y, NAME => 'bottom_center'} ;
	}
if($x == $self->{LEFT_CENTER_X} && $y == $middle_height)
	{
	return {X =>  $x, Y => $y, NAME => 'left_center'} ;
	}
elsif($x == $self->{WIDTH} - int($self->{HEIGHT} / 2) && $y == $middle_height)
	{
	return {X =>  $x, Y => $y, NAME => 'right_center'} ;
	}
elsif($x >= 0 && $x < $self->{WIDTH} && $y >= 0 && $y < $self->{HEIGHT})
	{
	return {X =>  $middle_width, Y => -1, NAME => 'to_be_optimized'} ;
	}
else
	{
	return ;
	}
}

#-----------------------------------------------------------------------------

sub get_connection_points
{
my ($self) = @_ ;
my $middle_width = int($self->{WIDTH} / 2)  ;
my $middle_height = int($self->{HEIGHT} / 2) ;

return
	(
	{X =>  $middle_width, Y => -1, NAME => 'top_center'},
	{X =>  $middle_width, Y => $self->{HEIGHT}, NAME => 'bottom_center'},
	{X =>  $self->{LEFT_CENTER_X}, Y => $middle_height, NAME => 'left_center'},
	{X =>  $self->{WIDTH} - int($self->{HEIGHT} / 2), Y => $middle_height, NAME => 'right_center'},
	) ;
}

#-----------------------------------------------------------------------------

sub get_extra_points
{
my ($self) = @_ ;

return
	(
	{X =>  $self->{RESIZE_POINT_X}, Y => $self->{HEIGHT} - 2 , NAME => 'resize'},
	) ;
}

#-----------------------------------------------------------------------------

sub get_named_connection
{
my ($self, $name) = @_ ;
my $middle_width = int($self->{WIDTH} / 2)  ;
my $middle_height = int($self->{HEIGHT} / 2) ;

if($name eq 'top_center')
	{
	return {X =>  $middle_width, Y => -1, NAME => 'top_center'} ;
	}
elsif($name eq 'bottom_center')
	{
	return {X =>  $middle_width, Y => $self->{HEIGHT}, NAME => 'bottom_center'} ;
	}
elsif($name eq 'left_center')
	{
	return {X =>  $self->{LEFT_CENTER_X}, Y => $middle_height, NAME => 'left_center'},
	}
elsif($name eq 'right_center')
	{
	return {X =>  $self->{WIDTH} - int($self->{HEIGHT} / 2), Y => $middle_height, NAME => 'right_center'},
	}
else
	{
	return ;
	}
}

#-----------------------------------------------------------------------------

sub is_auto_shrink { my($self) = @_ ; return $self->{AUTO_SHRINK} ; }
sub flip_auto_shrink { my($self) = @_ ; $self->{AUTO_SHRINK} ^= 1 ; }

#-----------------------------------------------------------------------------

sub resize
{
my ($self, $reference_x, $reference_y, $new_x, $new_y) = @_ ;

my $new_end_x = $new_x ;
my $new_end_y = $new_y ;

if($reference_x == -1 && $reference_y == -1)
	{
	$self->setup
		(
		$self->{TEXT_ONLY},
		$self->{WIDTH} + $new_x,
		$self->{HEIGHT} + $new_y,
		$self->{EDITABLE}, $self->{RESIZABLE},
		$self->{BOX_TYPE}
		) ;
	}
else 
	{
	if($new_end_x >= 0 &&  $new_end_y >= 0)
		{
		$self->setup
			(
			$self->{TEXT_ONLY},
			$new_end_x + 1 - ($self->{WIDTH} - $self->{RESIZE_POINT_X}), # compensate for resize point X not equal to width
			$new_end_y + 1,
			$self->{EDITABLE}, $self->{RESIZABLE},
			$self->{BOX_TYPE}
			) ;
		}
	}

return(0, 0, $self->{WIDTH}, $self->{HEIGHT}) ;
}

#-----------------------------------------------------------------------------

sub get_box_type { my ($self) = @_ ; return($self->{BOX_TYPE})  ; }

#-----------------------------------------------------------------------------

sub change_attributes
{
my ($self, $type) = @_ ;

return unless defined $type  ;

my $new_box_type = $box_types{$type} // $type ;

$self->set_box_type(Clone::clone($new_box_type)) ;
}

#-----------------------------------------------------------------------------
sub set_box_type
{
my ($self, $box_type) = @_;
$self->setup
	(
	$self->{TEXT_ONLY},
	$self->{RESIZE_POINT_X} - 3, # magic number are ugly
	$self->{HEIGHT},
	$self->{EDITABLE}, $self->{RESIZABLE},
	$box_type
	) ;
}

#-----------------------------------------------------------------------------

sub get_text { my ($self) = @_ ; return($self->{TEXT_ONLY}) ; }

#-----------------------------------------------------------------------------

sub set_text
{
my ($self, $text) = @_ ;
$self->setup
	(
	$text,
	$self->{RESIZE_POINT_X} - 3, # magic number are ugly
	$self->{HEIGHT} - 1,
	$self->{EDITABLE}, $self->{RESIZABLE}
	) ;
}

#-----------------------------------------------------------------------------

sub edit
{
my ($self, $asciio) = @_ ;

return unless $self->{EDITABLE} ;

my ($text_only) = $asciio->display_edit_dialog('asciio', $self->{TEXT_ONLY}, $asciio, $self->{X}, $self->{Y}) ;

my $tab_as_space = $asciio->{TAB_AS_SPACES} ;
$text_only =~ s/\t/$tab_as_space/g ;

$self->set_text($text_only) ;
}

#-----------------------------------------------------------------------------

sub get_attributes 
{
my ($self) = @_ ;

return
	(
	"triangle_down",
	Clone::clone($self->get_box_type()),
	) ;
}

#-----------------------------------------------------------------------------

1 ;
