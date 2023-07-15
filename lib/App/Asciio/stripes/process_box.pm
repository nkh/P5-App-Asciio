
package App::Asciio::stripes::process_box ;
use base App::Asciio::stripes::stripes ;

use strict;
use warnings;

use List::Util qw(min max) ;
use Readonly ;

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
	) ;

return $self ;
}

#-----------------------------------------------------------------------------

sub setup
{
my ($self, $text_only, $end_x, $end_y, $editable, $resizable) = @_ ;

Readonly my $side_glyphs_size => 4 ; 

$text_only = '' unless defined $text_only ;

my @lines = split("\n", $text_only) ;
@lines = ('')  unless @lines;

my $number_of_lines = scalar(@lines) ;
my $text_lines = $number_of_lines ;

if($end_y - 3 > $number_of_lines)
	{
	my $lines_to_add = ($end_y - 3) - $number_of_lines ;
	$lines_to_add += $lines_to_add % 2 ; # number of lines is always even
	
	unshift @lines, map {''} (1 ..  $lines_to_add / 2) ;
	push @lines, map {''} (1 ..  $lines_to_add / 2) ;
	
	$number_of_lines += $lines_to_add ;
	}

my $half_the_lines = int($number_of_lines / 2) ;
my $element_width = 0 ;

my $current_half_the_lines = $half_the_lines ;
my (@lines_width_plus_offset) ;
for my $line (@lines)
	{
	push @lines_width_plus_offset, usc_length($line) + abs($current_half_the_lines) ;
	$current_half_the_lines-- ;
	}

my $text_width_plus_offset  = max(@lines_width_plus_offset, $end_x) ;

my @top_lines = (splice @lines, 0, $number_of_lines / 2) ;

my $center_line = shift @lines  || '' ;

my @bottom_lines = @lines ;
push @bottom_lines, '' for (1 .. scalar(@top_lines) - scalar(@bottom_lines)) ;

my (@stripes, $strip_text, $x_offset, $y_offset) ;

$strip_text = '_' x (($text_width_plus_offset - 1) + $side_glyphs_size) . "\n\\" . ' ' x (($text_width_plus_offset - 2) + $side_glyphs_size) . "\\" ;

push @stripes,
	{
	'HEIGHT' => 2,
	'TEXT' => $strip_text,
	'WIDTH' => $text_width_plus_offset + $side_glyphs_size,
	'X_OFFSET' => 0,
	'Y_OFFSET' =>0,
	} ;

$x_offset = 1 ;
$y_offset = 2 ;

$current_half_the_lines = $half_the_lines ;
for my $line (@top_lines)
	{
	my $front_padding = ' ' x $current_half_the_lines ;
	my $padding = ' ' x ($text_width_plus_offset  - (usc_length($line) + $current_half_the_lines)) ;
	my $strip_text = "\\ $front_padding$line$padding \\" ;
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $strip_text,
		'WIDTH' => usc_length($strip_text),
		'X_OFFSET' => $x_offset,
		'Y_OFFSET' => $y_offset ,
		} ;
	
	$x_offset++ ;
	$y_offset++ ;
	$current_half_the_lines-- ;
	}

my $padding = ' ' x ($text_width_plus_offset  - usc_length($center_line)) ;
$strip_text = ') ' . $center_line . $padding . ' )' ;
$element_width =  usc_length($strip_text) + $y_offset - 1 ; # first stripe is two lines high, compensate offset by substracting one
my $left_center_x = $y_offset - 2 ; # compensate as above and shft left

push @stripes,
	{
	'HEIGHT' => 1,
	'TEXT' => $strip_text,
	'WIDTH' => usc_length($strip_text),
	'X_OFFSET' => $x_offset,
	'Y_OFFSET' => $y_offset, 
	};

$y_offset++ ;
$x_offset-- ;
$current_half_the_lines = 1; 

for my $line (@bottom_lines)
	{
	my $front_padding = ' ' x $current_half_the_lines ;
	my $padding = ' ' x ($text_width_plus_offset  - (usc_length($line) + $current_half_the_lines)) ;
	
	my $strip_text = "/ $front_padding$line$padding /" ;
	
	push @stripes,
		{
		'HEIGHT' => 1,
		'TEXT' => $strip_text,
		'WIDTH' => usc_length($strip_text),
		'X_OFFSET' => $x_offset,
		'Y_OFFSET' => $y_offset ,
		} ;
	$x_offset-- ;
	$y_offset++ ;
	$current_half_the_lines++;
	}

$strip_text = '/' . '_' x (($text_width_plus_offset  - 2) + $side_glyphs_size ) . '/' ;
push @stripes,
	{
	'HEIGHT' => 1,
	'TEXT' => $strip_text,
	'WIDTH' => $text_width_plus_offset + $side_glyphs_size,
	'X_OFFSET' => 0,
	'Y_OFFSET' => $y_offset, 
	};

$self->set
	(
	STRIPES => \@stripes,
	WIDTH => $element_width,
	HEIGHT => $y_offset + 1,
	LEFT_CENTER_X => $left_center_x,
	RESIZE_POINT_X => $text_width_plus_offset + $side_glyphs_size - 1,
	TEXT_ONLY => $text_only,
	TEXT_BEGIN_X => int(($y_offset/2)+2),
	TEXT_BEGIN_Y => int(($y_offset-$text_lines+2)/2),
	EDITABLE => $editable,
	RESIZABLE => $resizable,
	EXTENTS => [0, 0, $element_width, $y_offset +  1],
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
return ( {X =>  $self->{RESIZE_POINT_X}, Y => $self->{HEIGHT} - 1 , NAME => 'resize'} ) ;
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

if($new_end_x >= 0 &&  $new_end_y >= 0)
	{
	$self->setup
		(
		$self->{TEXT_ONLY},
		$new_end_x + 1 - ($self->{WIDTH} - $self->{RESIZE_POINT_X}), # compensate for resize point X not equal to width
		$new_end_y + 1,
		$self->{EDITABLE}, $self->{RESIZABLE}
		) ;
	}

return(0, 0, $self->{WIDTH}, $self->{HEIGHT}) ;
}

#-----------------------------------------------------------------------------

sub get_text
{
my ($self) = @_ ;
return($self->{TEXT_ONLY}) ;
}

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

my ($text_only) = $asciio->display_edit_dialog('process object', $self->{TEXT_ONLY}, $asciio, $self->{X}, $self->{Y}, $self->{TEXT_BEGIN_X}, $self->{TEXT_BEGIN_Y}) ;

my $tab_as_space = $asciio->{TAB_AS_SPACES} ;
$text_only =~ s/\t/$tab_as_space/g ;

$self->set_text($text_only) ;
}

#-----------------------------------------------------------------------------

1 ;
