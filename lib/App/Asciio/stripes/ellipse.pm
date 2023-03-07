
package App::Asciio::stripes::ellipse ;
use base App::Asciio::stripes::stripes ;

use strict;
use warnings;
use utf8 ;

use List::Util qw(max) ;
use Readonly ;

Readonly my $DEFAULT_BOX_TYPE =>
[
	[1, 'top',           ',',   '\'', ',',   1, ], 
	[1, 'top-middle',    ',\'',  '',  '\',', 1, ],
	[1, 'middle',        ':',    '',  ':',   1, ],
	[1, 'middle-bottom', '\',',  '',  ',\'', 1, ],
	[1, 'bottom',        '\'',   ',', '\'',  1, ] ,
] ;

use App::Asciio::Toolfunc ;

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

sub fill_ellipse_strip
{
#~ https://enchantia.com/software/graphapp/doc/tech/ellipses.html
my ($xc, $yc, $a, $b) = @_;	#~ e(x,y) = b^2*x^2 + a^2*y^2 - a^2*b^2
my $x = 0;
my $y = $b;
my ($rx, $ry) = ($x, $y);
my ($width, $height) = (1, 1);
my ($a2, $b2) = ($a * $a, $b * $b);
my ($crit1, $crit2, $crit3) = (-(int($a2/4) + $a%2 + $b2),  -(int($b2/4) + $b%2 + $a2), -(int($b2/4) + $b%2));
my $t = -$a2 * $y; #~ e(x+1/2,y-1/2) - (a^2+b^2)/
my ($dxt, $dyt) = (2 * $b2 * $x, -2 * $a2 * $y);
my ($d2xt, $d2yt) = (2 * $b2, 2 * $a2) ;
my @strips_arr;

if ($b == 0) {
	push @strips_arr, [$xc-$a, $yc, 2*$a+1, 1];
	return @strips_arr;
}

while ($y>=0 && $x<=$a) 
	{
	if ($t + $b2*$x <= $crit1 ||     #~ e(x+1,y-1/2) <= 0
		$t + $a2*$y <= $crit3)
		{     #~ e(x+1/2,y) <= 0
			if ($height == 1)
				{
				#~ draw nothing
				}
			elsif ($ry*2+1 > ($height-1)*2) {
				push @strips_arr, [$xc-$rx, $yc-$ry, $width, $height-1];
				push @strips_arr, [$xc-$rx, $yc+$ry+1, $width, 1-$height];
				$ry -= $height-1;
				$height = 1;
			}
		else 
			{
			push @strips_arr, [$xc-$rx, $yc-$ry, $width, $ry*2+1];
			$ry -= $ry;
			$height = 1;
			}
		$x++;
		$dxt += $d2xt;
		$t += $dxt;
		$rx++;
		$width += 2;
	}
	elsif ($t - $a2*$y > $crit2) { #~ e(x+1/2,y-1) > 0
		$y--;
		$dyt += $d2yt;
		$t += $dyt;
		$height++;
	}
	else {
		if ($ry*2+1 > $height*2) {
			push @strips_arr, [$xc-$rx, $yc-$ry, $width, $height];
			push @strips_arr, [$xc-$rx, $yc+$ry+1, $width, -$height];
		}
		else {
			push @strips_arr, [$xc-$rx, $yc-$ry, $width, $ry*2+1];
		}
		$x++;
		$dxt += $d2xt;
		$t += $dxt;
		$y--;
		$dyt += $d2yt;
		$t += $dyt;
		$rx++;
		$width += 2;
		$ry -= $height;
		$height = 1;
	}
	}

if ($ry > $height) 
	{
	push @strips_arr, [$xc-$rx, $yc-$ry, $width, $height];
	push @strips_arr, [$xc-$rx, $yc+$ry+1, $width, -$height];
	}
else 
	{
	push @strips_arr, [$xc-$rx, $yc-$ry, $width, $ry*2+1];
	}
return @strips_arr;
}


#-----------------------------------------------------------------------------

sub setup
{
my ($self, $text_only, $end_x, $end_y, $editable, $resizable, $box_type, $auto_shrink) = @_;
Readonly my $mini_row => 5;
Readonly my $mini_col => 5;

my $max_row = max($end_y, $mini_row);
my $max_col = max($end_x, $mini_col);

$max_col++ if ($max_col > $mini_col && ($max_col % 2) == 0);
$max_row++ if ($max_row > $mini_row && ($max_row % 2) == 0);



($max_col, $max_row) = (-5, -5) if $auto_shrink;
my ($half_x, $half_y) = (int($max_col/2), int($max_row/2));
my @strips = fill_ellipse_strip($half_x, $half_y, $half_x, $half_y);


#~        |
#~  ------|--ooooo----->
#~        |ooooooooo
#~        ooooooooooo
#~        ooooooooooo
#~        ooooooooooo
#~        |ooooooooo
#~        |  ooooo
#~        v
#~        |
#~  ------|--ooooo----->
#~        |oo     oo
#~        o         o
#~        o         o
#~        o         o
#~        |oo     oo
#~        |  ooooo
#~        v
#~ 0             4               1             3               2 
#~ [3, 0, 5, 1], [3, 7, 5, -1], [1, 1, 9, 1], [1, 6, 9, -1], [0, 2, 11, 3]
#~ convert to
#~ [3, 0, 5, 1], [1, 1, 9, 1], [0, 2, 11, 3], [1, 5, 9, 1], [3, 6, 5, 1]
#~ convert to
#~ [3, 0, 5, 1], [1, 1, 9, 1], [0, 2, 11, 1], [0, 2, 11, 1], [0, 2, 11, 1], [1, 5, 9, 1], [3, 6, 5, 1]

my @new_strips;
my $cnt = 0;
for my $strip(@strips)
{
if($cnt % 2 == 0)
{
push @new_strips, $strip;

}
$cnt++;
}
$cnt = 0;
for my $strip(reverse(@strips))
{
if($cnt % 2 != 0)
{
$strip->[1] = $strip->[1] + $strip->[3];
$strip->[3] = abs($strip->[3]);
push @new_strips, $strip;
}
$cnt++;
}

my @sigle_strips;
my $index_remain = 1;
for my $strip(@new_strips)
{
    $index_remain = $strip->[3];
    while($index_remain != 0)
    {
        push @sigle_strips, [$strip->[0], $strip->[2]];
        $strip->[3]--;
        $index_remain = $strip->[3];
    }

}

my $resize_point_x = $sigle_strips[int($max_row/2)+1][1] - 1;
my $element_width =$sigle_strips[int($max_row/2)][1];


my $strip = $sigle_strips[0];

my $diff_cnt = $strip->[1];
my $strip_text;
my ($high_mark, $mid_mark, $low_mark, $bottom_mark) = (0, 0, 0, 0);
if($diff_cnt == 1)
{
    $strip_text = '-';
}
elsif($diff_cnt == 2)
{
    $strip_text = '--';
}
elsif($diff_cnt == 3)
{
    $strip_text = '\'-`';
}
elsif($diff_cnt == 4)
{
    $strip_text = '.--.';

}
elsif($diff_cnt == 5)
{
    $strip_text = '.-\'-.';
}
elsif($diff_cnt == 6)
{
    $strip_text = '_.--._';
}

elsif($diff_cnt == 7)
{
    $strip_text = '_.-\'-._';
}
else
{
    my $remaining = $diff_cnt % 8;
    $mid_mark = int($diff_cnt / 8);
    $low_mark = int($diff_cnt / 8);
    $bottom_mark = int($diff_cnt / 8);
    $high_mark = int($diff_cnt / 8) * 2;
    if($remaining == 1)
    {
        $high_mark += 1;
    }
    elsif($remaining == 2)
    {
        $high_mark += 2;
    }
    elsif($remaining == 3)
    {
        $high_mark += 1;
        $low_mark += 1;
    }
    elsif($remaining == 4)
    {
        $high_mark += 2;
        $low_mark += 1;
    }
    elsif($remaining == 5)
    {
        $high_mark += 1;
        $low_mark += 1;
        $bottom_mark += 1;
    }
    elsif($remaining == 6)
    {
        $high_mark += 2;
        $mid_mark += 1;
        $low_mark += 1;
    }
    elsif($remaining == 7)
    {
        $high_mark += 1;
        $mid_mark += 1;
        $low_mark += 1;
        $bottom_mark += 1;
    }
    $strip_text = '_' x $bottom_mark . '.' x $low_mark . '-' x $mid_mark . '\'' x $high_mark . '-' x $mid_mark . '.' x $low_mark . '_' x $bottom_mark;
}

my @final_stripes;

push @final_stripes,
{
    'HEIGHT' => 1,
    'TEXT' => $strip_text,
    'WIDTH' => usc_length($strip_text),
    'X_OFFSET' => $strip->[0],
    'Y_OFFSET' => 0,
};

my $strip_index = 1;
my ($now_strip, $pre_strip);
my $strip_cnt = 0;
for $strip_index(1..$#sigle_strips-1)
{
    $now_strip = $sigle_strips[$strip_index][1];
    if($strip_index < $half_y)
    {
        $pre_strip = $sigle_strips[$strip_index-1][1];
    }
    else
    {
        $pre_strip = $sigle_strips[$strip_index+1][1];
    }
    $strip_cnt = abs($now_strip - $pre_strip);
    if($strip_cnt == 0)
    {
        $strip_text = ':' . ' ' x ($now_strip - 2) . ':';
    }
    elsif($strip_cnt == 2)
    {
        if($strip_index < $half_y)
        {
            $strip_text = '/'. ' ' x ($now_strip - 2) . '\\';
        }
        else
        {
            $strip_text = '\\'. ' ' x ($now_strip - 2) . '/';
        }
    }
    elsif($strip_cnt == 4)
    {
        if($strip_index < $half_y)
        {
            $strip_text = '.\''. ' ' x ($now_strip - 4) . '`.';
        }
        else
        {
            $strip_text = '`.'. ' ' x ($now_strip - 4) . '.\'';
        }
    }
    elsif($strip_cnt == 6)
    {
        if($strip_index < $half_y)
        {
            $strip_text = '_.\'' . ' ' x ($now_strip - 6) . '`._';
        }
        else
        {
            $strip_text = '`._' . ' ' x ($now_strip - 6) . '_.\'';
        }
    }
    else
    {
        my $remaining = $strip_cnt % 8;
        my $left_mark = int($strip_cnt / 8);
        my $mid_mark = int($strip_cnt / 8);
        my $bottom_mark = int($strip_cnt / 8);
        my $right_mark = int($strip_cnt / 8);
        if($remaining == 2)
        {
            $right_mark += 1;
        }
        elsif($remaining == 4)
        {
            $right_mark += 1;
            $left_mark += 1;
        }
        elsif($remaining == 6)
        {
            $right_mark += 1;
            $mid_mark += 1;
            $left_mark += 1;
        }
        if($strip_index < $half_y)
        {
        $strip_text = '_' x $bottom_mark . '.' x $left_mark . '-' x $mid_mark . '\'' x $right_mark . ' ' x ($now_strip - 2 * $left_mark - 2 * $mid_mark - 2 * $right_mark - 2 * $bottom_mark) . '`' x $right_mark . '-' x $mid_mark . '.' x $left_mark . '_' x $bottom_mark;
        }
        else
        {
            $strip_text = '`' x $right_mark . '-' x $mid_mark . '.' x $left_mark . '_' x $bottom_mark . ' ' x ($now_strip - 2 * $left_mark - 2 * $mid_mark - 2 * $right_mark - 2 * $bottom_mark) . '_' x $bottom_mark . '.' x $left_mark . '-' x $mid_mark . '\'' x $right_mark;
        }
    }
    
push @final_stripes,
{
    'HEIGHT' => 1,
    'TEXT' => $strip_text,
    'WIDTH' => usc_length($strip_text),
    'X_OFFSET' => $sigle_strips[$strip_index][0],
    'Y_OFFSET' => $strip_index,
};
}

$strip = $sigle_strips[$#sigle_strips];
$diff_cnt = $strip->[1];
if($diff_cnt == 1)
{
$strip_text = '-';
}
elsif($diff_cnt == 2)
{
$strip_text = '--';
}
elsif($diff_cnt == 3)
{
$strip_text = '---';
}
elsif($diff_cnt == 4)
{
$strip_text = '-..-';
}
elsif($diff_cnt == 5)
{
$strip_text = '`-.-\'';
}
elsif($diff_cnt == 6)
{
$strip_text = '-.__.-';
}
elsif($diff_cnt == 7)
{
$strip_text = '`-._.-\'';
}
else
{
    my $remaining = $diff_cnt % 8;
    $mid_mark = int($diff_cnt / 8);
    $high_mark = int($diff_cnt / 8);
    $low_mark = int($diff_cnt / 8);
    $bottom_mark = int($diff_cnt / 8) * 2;
    if($remaining == 1)
    {
        $bottom_mark += 1;
    }
    elsif($remaining == 2)
    {
        $bottom_mark += 2;
    }
    elsif($remaining == 3)
    {
        $bottom_mark += 1;
        $low_mark += 1;
    }
    elsif($remaining == 4)
    {
        $bottom_mark += 2;
        $high_mark += 1;
    }
    elsif($remaining == 5)
    {
        $bottom_mark += 1;
        $high_mark += 1;
        $low_mark += 1;
    }
    elsif($remaining == 6)
    {
        $bottom_mark += 2;
        $high_mark += 1;
        $low_mark += 1;
    }
    elsif($remaining == 7)
    {
        $bottom_mark += 1;
        $high_mark += 1;
        $low_mark += 1;
        $mid_mark += 1;
    }
    $strip_text = '`' x $high_mark . '-' x $mid_mark . '.' x $low_mark . '_' x $bottom_mark . '.' x $low_mark . '-' x $mid_mark . '\'' x $high_mark;

}
push @final_stripes,
{
    'HEIGHT' => 1,
    'TEXT' => $strip_text,
    'WIDTH' => usc_length($strip_text),
    'X_OFFSET' => $strip->[0],
    'Y_OFFSET' => $#sigle_strips,
};
  
$self->set
(
    STRIPES => \@final_stripes,
    WIDTH => $element_width,
    HEIGHT => $max_row,
    LEFT_CENTER_X => -1,
    RESIZE_POINT_X => $resize_point_x,
    TEXT_ONLY => $text_only,
    EDITABLE => $editable,
    RESIZABLE => $resizable,
    BOX_TYPE => $box_type,
    AUTO_SHRINK => $auto_shrink,
    EXTENTS => [0, 0, $element_width, $max_row],
    
);
}

#-----------------------------------------------------------------------------

sub get_selection_action
{
my ($self, $x, $y) = @_ ;

($x == $self->{RESIZE_POINT_X} && $y == int($self->{HEIGHT}/2) + 1)
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
	{X =>  $self->{RESIZE_POINT_X}, Y => int($self->{HEIGHT}/2) + 1 , NAME => 'resize'},
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
	if($new_x == -1)
		{
		$new_x = -2;
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

sub allow_border_connection { ; }

#-----------------------------------------------------------------------------

sub is_border_connection_allowed { ; }

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

$text_only = $self->display_box_edit_dialog($text_only, '', $asciio) ;

my $tab_as_space = $asciio->{TAB_AS_SPACES} ;
$text_only =~ s/\t/$tab_as_space/g ;

$text_only = make_vertical_text($text_only)  if $self->{VERTICAL_TEXT} ;

$self->set_text($text_only) ;
}

#-----------------------------------------------------------------------------

1 ;
