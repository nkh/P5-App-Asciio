
package App::Asciio::stripes::if_box ;

use base App::Asciio::stripes::single_stripe ;

use strict;
use warnings;

use List::Util qw(min max) ;
use Readonly ;
use Clone ;

#-----------------------------------------------------------------------------

sub new
{
my ($class, $element_definition) = @_ ;

my $self = bless  {}, __PACKAGE__ ;
	
$self->setup
	(
	$element_definition->{TEXT_ONLY},
	1, 1,
	$element_definition->{RESIZABLE},
	$element_definition->{EDITABLE},
	) ;

return $self ;
}

#-----------------------------------------------------------------------------

sub setup
{
my ($self, $text_only, $end_x, $end_y, $resizable, $editable) = @_ ;

# $end_x, $end_y are used if we want to keep a box size constant if the included text gets smaller
# if_boxes automatically fit to their content (so far) so those variables are not used

$text_only = '' unless defined $text_only ;

my ($text_width,  @lines) = (0) ;

for my $line (split("\n", $text_only))
	{
	$text_width  = max($text_width, length($line)) ;
	push @lines, $line ;
	}
	
my $number_of_lines = scalar(@lines) ;

my $lines_to_add = ($number_of_lines + 1) % 2 ; # always odd
unshift @lines, map {''} (1 ..  $lines_to_add / 2) ;
push @lines, map {''} (1 ..  $lines_to_add / 2) ;

$number_of_lines += $lines_to_add ;

my $half_the_lines = int($number_of_lines / 2) ;

my $extra_width = 2 + $half_the_lines ;
my $extra_height = 2 ;

my $text = ' ' x ($half_the_lines + 1). '.' . '-' x $text_width . '.' . "\n" ;

my @top_lines = (splice @lines, 0, $number_of_lines / 2) ;

my $left_indentation = $half_the_lines ;
my $inside_indentation = 0 ;

for my $line (@top_lines)
	{
	my $padding = ' ' x ($text_width - length($line)) ;
	
	$text .= ' ' x $left_indentation . '/ ' . ' ' x $inside_indentation .  $line . $padding . ' ' x $inside_indentation. ' \\' . "\n" ;
	$left_indentation-- ;
	$inside_indentation++ ;
	}

my $center_line = shift @lines  || '' ;
my $padding = ' ' x ($text_width - length($center_line)) ;

$center_line = '( ' . ' ' x $inside_indentation .  $center_line . $padding . ' ' x $inside_indentation .  ' )' ;
my $width = length($center_line) ;
$text .= $center_line . "\n" ;

$left_indentation = 1 ;
$inside_indentation-- ;

my @bottom_lines = @lines ;
push @bottom_lines, '' for (1 .. scalar(@top_lines) - scalar(@bottom_lines)) ;

for my $line (@bottom_lines)
	{
	my $padding = ' ' x ($text_width - length($line)) ;
	
	$text .= ' ' x $left_indentation .  '\\ ' .  ' ' x $inside_indentation .  $line . $padding . ' ' x $inside_indentation .  ' /' . "\n" ;
	$left_indentation++ ;
	$inside_indentation-- ;
	}

$text .= ' ' x ($half_the_lines + 1) . q{'} . '-' x $text_width . q{'} . "\n" ;

$self->set
	(
	TEXT => $text,
	WIDTH => $width,
	HEIGHT => $number_of_lines + 2,
	TEXT_ONLY => $text_only,
	RESIZABLE => $resizable,
	EDITABLE => $editable,
	STRIPES => [ {X_OFFSET => 0, Y_OFFSET => 0, WIDTH => $width, HEIGHT => ($text =~ tr[\n][\n]) + 1, TEXT => $text} ],
	) ;
}

#-----------------------------------------------------------------------------

sub get_selection_action
{
my ($self, $x, $y) = @_ ;

if	(
	($x == $self->{WIDTH} - 1 && $y == $self->{HEIGHT} - 1)
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
if($x == -1 && $y == $middle_height)
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
	{X =>  -1, Y => $middle_height, NAME => 'left_center'},
	{X =>  $self->{WIDTH}, Y => $middle_height, NAME => 'right_center'},
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
	return( {X =>  $middle_width, Y => -1, NAME => 'top_center'} ) ;
	}
elsif($name eq 'bottom_center')
	{
	return( {X =>  $middle_width, Y => $self->{HEIGHT}, NAME => 'bottom_center'} ) ;
	}
elsif($name eq 'left_center')
	{
	return {X =>  -1, Y => $middle_height, NAME => 'left_center'},
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

# if box is not resizable
return(0, 0, $self->{WIDTH}, $self->{HEIGHT}) ;

#~ return(0, 0, $self->{WIDTH}, $self->{HEIGHT})  unless $self->{RESIZABLE} ;

#~ my $new_end_x = $new_x ;
#~ my $new_end_y = $new_y ;

#~ if($new_end_x >= 0 &&  $new_end_y >= 0)
	#~ {
	#~ $self->setup($self->{TEXT_ONLY}, $new_end_x + 1, $new_end_y + 1, $self->{RESIZABLE}, $self->{EDITABLE}) ;
	#~ }
	
#~ return(0, 0, $self->{WIDTH}, $self->{HEIGHT}) ;
}

#-----------------------------------------------------------------------------

sub get_text
{
my ($self) = @_ ;
return($self->{TEXT_ONLY})  ;
}

#-----------------------------------------------------------------------------

sub set_text
{
my ($self, $text) = @_ ;

$text = 'edit_me' if($text eq '') ;

$self->setup($text, $self->{WIDTH}, $self->{HEIGHT}, $self->{RESIZABLE}, $self->{EDITABLE}) ;
}

#-----------------------------------------------------------------------------

sub edit
{
my ($self, $asciio) = @_ ;

return unless $self->{EDITABLE} ;

my ($text) = $asciio->display_edit_dialog('if object', $self->{TEXT_ONLY}) ;

my $tab_as_space = $self->{TAB_AS_SPACES} || (' ' x 3) ;
$text =~ s/\t/$tab_as_space/g ;

$self->set_text($text) ;
}

#-----------------------------------------------------------------------------

1 ;
