
package App::Asciio::stripes::rhombus ;
use base App::Asciio::stripes::stripes ;

use strict;
use warnings;
use utf8 ;

use List::Util qw(max) ;
use Readonly ;
use Clone ;
use utf8 ;

Readonly my $DEFAULT_BOX_TYPE =>
[
	[1, 'top',           ',',   '\'', ',',   1, ], 
	[1, 'top-middle',    ',\'',  '',  '\',', 1, ],
	[1, 'middle',        ':',    '',  ':',   1, ],
	[1, 'middle-bottom', '\',',  '',  ',\'', 1, ],
	[1, 'bottom',        '\'',   ',', '\'',  1, ] ,
	[1, 'fill-character','',     ' ', '',    1, ] ,
] ;

my %box_types = 
	(
	rhombus_normal =>
		[
			[1, 'top',             ',', '\'',   ',', 1, ], 
			[1, 'top-middle',    ',\'',   '', '\',', 1, ],
			[1, 'middle',          ':',   '',   ':', 1, ],
			[1, 'middle-bottom', '\',',   '', ',\'', 1, ],
			[1, 'bottom',         '\'',  ',',  '\'', 1, ] ,
			[1, 'fill-character','',     ' ', '',    1, ] ,
		],
	rhombus_normal_with_filler_star =>
		[
			[1, 'top',             ',', '\'',   ',', 1, ], 
			[1, 'top-middle',    ',\'',   '', '\',', 1, ],
			[1, 'middle',          ':',   '',   ':', 1, ],
			[1, 'middle-bottom', '\',',   '', ',\'', 1, ],
			[1, 'bottom',         '\'',  ',',  '\'', 1, ] ,
			[1, 'fill-character','',     '*', '',    1, ] ,
		],
	rhombus_sparseness =>
		[
			[1, 'top',            ',', '\'',  ',', 1, ], 
			[1, 'top-middle',    ', ',   '', ' ,', 1, ],
			[1, 'middle',         ':',   '',  ':', 1, ],
			[1, 'middle-bottom', ' ,',   '', ', ', 1, ],
			[1, 'bottom',        '\'',  ',', '\'', 1, ] ,
			[1, 'fill-character','',     ' ', '',    1, ] ,
		],
	rhombus_unicode_slash =>
		[
			[1, 'top',            ' ',  ',',  ' ', 1, ], 
			[1, 'top-middle',    '／',   '', '＼', 1, ],
			[1, 'middle',         '❬',   '',  '❭', 1, ],
			[1, 'middle-bottom', '＼',   '', '／', 1, ],
			[1, 'bottom',         ' ', '\'',  ' ', 1, ] ,
			[1, 'fill-character','',     ' ', '',    1, ] ,
		],
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
	$element_definition->{AUTO_SHRINK},
	) ;

return $self ;
}

#-----------------------------------------------------------------------------

sub setup
{
# 3 row 5 col
#    ,', 
#   :   :
#    ',' 
# 5 row 9 col
#     ,',  
#   ,'   ', 
#  :       :
#   ',   ,'
#     ','   
# 7 row 13 col
#      ,',      
#    ,'   ',    
#  ,'       ',  
# :           : 
#  ',       ,'  
#    ',   ,'    
#      ','      
# 9 row 17 col
#       ,',       
#     ,'   ',     
#   ,'       ',   
# ,'           ', 
#:               :
# ',           ,' 
#   ',       ,'   
#     ',   ,'     
#       ','       
# max_col = 2 * max_row - 1

my ($self, $text_only, $end_x, $end_y, $editable, $resizable, $box_type, $auto_shrink) = @_ ;
Readonly my $mini_row => 3 ; 

my $fill_char = ' ';

if($box_type->[5][3])
{
    $fill_char = substr($box_type->[5][3], 0, 1);
}

$end_y = -5 if $auto_shrink ;

# $number_of_lines must be odd
if($end_y > 3 && ($end_y % 2) == 0)
	{
	$end_y++ ;
	}

my $number_of_lines = max($mini_row, $end_y) ;
my @text_lines = defined $text_only && $text_only ne ''
	? split("\n", $text_only)
	: ('') ;

my $text_width = max(map {unicode_length $_} @text_lines);
my $text_heigh = @text_lines;

my ($element_width, $height);

if($text_heigh % 2 == 0)
	{
	$element_width = $text_width + 2 + 2 * ($text_heigh - 1);
	}
else
	{
	$element_width = $text_width + 2 + 2 * ($text_heigh - 2);
	}

if($element_width % 2 == 0)
	{
	$height = int(($element_width + 1) / 2) + 2;
	}
else
	{
	$height = int(($element_width + 1) / 2) + 1;
	}

$height = max($number_of_lines, $height);
if($height % 2 == 0)
	{
	$height++ ;
	}

$element_width = $height * 2 - 1 ;
my $start_text_row = int(($height - $text_heigh) / 2);
my $half_line_num = int($height / 2);

my $half_element_width = int($element_width / 2);

my (@stripes, $strip_text, $width, $x_offset, $left_center_x, $resize_point_x, $text_offset) ;
my ($text_begin_x, $text_begin_y) ;
$text_begin_y = $start_text_row ;

# divided into 5 parts
# up up-middle middle middle-down down
# minimal case up-middle and middle-down does not exist
for my $y_offset (0 .. $height - 1)
	{
	if($y_offset == 0)
		{
		$width = 3 ;
		$strip_text = $box_type->[0][2] . $box_type->[0][3] . $box_type->[0][4];
		$x_offset = $half_element_width - 1 ;
		}
	elsif($y_offset < $half_line_num)
		{
		$width = 3 + $y_offset * 4 ;
		$x_offset = $half_element_width - 1 - 2 * $y_offset ;
		
		if($y_offset >= $start_text_row && @text_lines)
			{
			my $text = shift @text_lines ;
			
			$text_offset = int(($element_width-$text_width)/2) unless $text_offset ;
			unless(defined $text_begin_x)
				{
				$text_begin_x = $text_offset;
				}
			
			my $padding = $text_offset - $x_offset - 2;
			$padding = 0 if $padding < 0;
			
			$strip_text = $box_type->[1][2] . ($fill_char x $padding) . $text . ($fill_char x ($width - 4 - unicode_length($text) - $padding)) . $box_type->[1][4] ;
			}
		else
			{
			$strip_text = $box_type->[1][2] . ($fill_char x ($width - 4)) . $box_type->[1][4] ;
			}
		}
	elsif($y_offset == $half_line_num)
		{
		$left_center_x = -1 ;
		$width = $element_width ;
		$x_offset = 0;
		
		if($y_offset >= $start_text_row && @text_lines)
			{
			my $text = shift @text_lines ;
			
			$text_offset = int(($element_width-$text_width)/2) unless $text_offset ; 
			unless(defined $text_begin_x)
				{
				$text_begin_x = $text_offset;
				}
			
			my $padding = $text_offset - $x_offset - 1;
			$padding = 0 if $padding < 0;
			
			$strip_text = $box_type->[2][2] . ($fill_char x $padding) . $text . ($fill_char x ($element_width - 2 - unicode_length($text) - $padding)) . $box_type->[2][4] ;
			}
		else
			{
			$strip_text = $box_type->[2][2] . ($fill_char x ($element_width - 2)) . $box_type->[2][4] ;
			}
		}
	elsif($y_offset < $height - 1)
		{
		$width = 3 + ($height - $y_offset - 1) * 4 ;
		$x_offset = $half_element_width - 1 - 2 * ($height - $y_offset - 1) ;
		
		if($y_offset >= $start_text_row && @text_lines)
			{
			my $text = shift @text_lines ;
			$text_offset = int(($element_width-$text_width)/2) unless $text_offset ;
			unless(defined $text_begin_x)
				{
				$text_begin_x = $text_offset;
				}
			
			my $padding = $text_offset - $x_offset - 2;
			$padding = 0 if $padding < 0;
			
			$strip_text = $box_type->[3][2] . ($fill_char x $padding) . $text . ($fill_char x ($width - 4 - unicode_length($text) - $padding)) . $box_type->[3][4] ;
			}
		else
			{
			$strip_text = $box_type->[3][2] . ($fill_char x ($width - 4)) . $box_type->[3][4] ;
			}
		}
	else
		{
		$resize_point_x = $half_element_width + 1 ;
		$width = 3 ;
		$strip_text = $box_type->[4][2] . $box_type->[4][3] . $box_type->[4][4] ;
		$x_offset = $half_element_width - 1 ;
		}
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $strip_text,
		'WIDTH' => unicode_length($strip_text) ,
		'X_OFFSET' => $x_offset,
		'Y_OFFSET' => $y_offset,
		} ;
	}

# position to the center of the rhombus if text not found
unless(defined $text_begin_x)
	{
	$text_begin_x = int($element_width / 2) ;
	}


$self->set
	(
	STRIPES => \@stripes,
	WIDTH => $element_width,
	HEIGHT => $height,
	LEFT_CENTER_X => $left_center_x,
	RESIZE_POINT_X => $resize_point_x,
	TEXT_ONLY => $text_only,
	TEXT_BEGIN_X => $text_begin_x,
	TEXT_BEGIN_Y => $text_begin_y,
	EDITABLE => $editable,
	RESIZABLE => $resizable,
	BOX_TYPE => $box_type,
	AUTO_SHRINK => $auto_shrink,
	EXTENTS => [0, 0, $element_width, $height],
	) ;
}

#-----------------------------------------------------------------------------

sub get_selection_action
{
my ($self, $x, $y) = @_ ;

($x == $self->{RESIZE_POINT_X} && $y == $self->{HEIGHT} - 1)
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
elsif($x == $self->{WIDTH} && $y == $middle_height)
	{
	return {X =>  $x, Y => $y, NAME => 'right_center'} ;
	}
elsif($x >= 0 && $x < $self->{WIDTH} && $y >= 0 && $y < $self->{HEIGHT})
	{
	return {X =>  $middle_width, Y => -1, NAME => 'to_be_optimized'} ;
	}
elsif($self->{ALLOW_BORDER_CONNECTION} && $x >= -1 && $x <= $self->{WIDTH} && $y >= -1 && $y <= $self->{HEIGHT})
	{
	return {X =>  $x, Y => $y, NAME => 'border'} ;
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
	{X =>  $self->{WIDTH}, Y => $middle_height, NAME => 'right_center'},
	) ;
}

#-----------------------------------------------------------------------------

sub get_extra_points
{
my ($self) = @_ ;
return
	(
	{X =>  $self->{RESIZE_POINT_X}, Y => $self->{HEIGHT} - 1 , NAME => 'resize'},
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
	return {X =>  $self->{WIDTH}, Y => $middle_height, NAME => 'right_center'},
	}
else
	{
	return ;
	}
}

#-----------------------------------------------------------------------------

sub resize
{
my ($self, $reference_x, $reference_y, $new_x, $new_y) = @_ ;

my $new_end_x = $new_x ;
my $new_end_y = $new_y ;

if($reference_x == -1 && $reference_y == -1)
	{
	if($new_y == -1)
		{
		$new_y = -2;
		}

	$self->setup
		(
		$self->{TEXT_ONLY},
		$self->{WIDTH} + $new_x,
		$self->{HEIGHT} + $new_y,
		$self->{EDITABLE}, $self->{RESIZABLE},
		$self->{BOX_TYPE}, $self->{AUTO_SHRINK}
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
			$self->{BOX_TYPE}, $self->{AUTO_SHRINK}
			) ;
		}
	}

return(0, 0, $self->{WIDTH}, $self->{HEIGHT}) ;
}

#-----------------------------------------------------------------------------

sub get_text { my ($self) = @_ ; return($self->{TEXT_ONLY}) ; }

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

sub allow_border_connection { my($self, $allow) = @_ ; $self->{ALLOW_BORDER_CONNECTION} = $allow ; }
sub is_border_connection_allowed { my($self) = @_ ; return $self->{ALLOW_BORDER_CONNECTION} ; }

#-----------------------------------------------------------------------------

sub flip_auto_shrink { my($self) = @_ ; $self->{AUTO_SHRINK} ^= 1 ; }

#-----------------------------------------------------------------------------

sub is_auto_shrink { my($self) = @_ ; return $self->{AUTO_SHRINK} ; }

#-----------------------------------------------------------------------------

sub shrink
{
my ($self) = @_ ;
$self->setup
	(
	$self->{TEXT_ONLY},
	-5, # magic number are ugly
	-5,
	$self->{EDITABLE}, $self->{RESIZABLE},
	$self->{BOX_TYPE}, $self->{AUTO_SHRINK}
	) ;
}

#-----------------------------------------------------------------------------

sub rotate_text
{
my ($self) = @_ ;

my $text = make_vertical_text($self->{TEXT_ONLY})  ;

$self->set_text($text) ;
$self->shrink() ;

$self->{VERTICAL_TEXT} ^= 1 ;
}

#-----------------------------------------------------------------------------

sub set_text
{
my ($self, $text) = @_ ;
$self->setup
	(
	$text,
	$self->{RESIZE_POINT_X} -	3, # magic number are ugly
	$self->{HEIGHT} - 1,
	$self->{EDITABLE}, $self->{RESIZABLE},
	$self->{BOX_TYPE}, $self->{AUTO_SHRINK}
	) ;
}

#-----------------------------------------------------------------------------
sub set_box_type
{
my ($self, $box_type) = @_;
$self->setup
	(
	$self->{TEXT_ONLY},
	$self->{RESIZE_POINT_X} - 3, # magic number are ugly
	$self->{HEIGHT} - 1,
	$self->{EDITABLE}, $self->{RESIZABLE},
	$box_type, $self->{AUTO_SHRINK}
	) ;
}

#-----------------------------------------------------------------------------

sub edit
{
my ($self, $asciio) = @_ ;

return unless $self->{EDITABLE} ;

my $text_only = $self->{TEXT_ONLY} ;
$text_only = make_vertical_text($text_only)  if $self->{VERTICAL_TEXT} ;

$text_only = $self->display_box_edit_dialog($text_only, '', $asciio, $self->{X}, $self->{Y}, $self->{TEXT_BEGIN_X}, $self->{TEXT_BEGIN_Y}) ;

my $tab_as_space = $asciio->{TAB_AS_SPACES} ;
$text_only =~ s/\t/$tab_as_space/g ;

$text_only = make_vertical_text($text_only)  if $self->{VERTICAL_TEXT} ;

$self->set_text($text_only) ;
}

#-----------------------------------------------------------------------------

sub get_attributes 
{
my ($self) = @_ ;

return
	(
	"rhombus",
	Clone::clone($self->get_box_type()),
	) ;
}

#-----------------------------------------------------------------------------

1 ;
