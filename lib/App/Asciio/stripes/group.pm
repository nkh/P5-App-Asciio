
package App::Asciio::stripes::group ;
use base App::Asciio::stripes::stripes ;

use strict;
use warnings;

use List::Util qw(min max) ;
use List::MoreUtils qw(minmax) ;
use Module::Util qw(find_installed) ;
use File::Basename ;

use App::Asciio::String ;

#-----------------------------------------------------------------------------

sub new
{
my ($class, $elements, $connections, $as_one_strip, $asciio_handle) = @_ ;

my  @stripes ;

my ($total_width, $total_height) = (0, 0) ;
my ($min_x, $min_y, $max_x, $max_y) = (10_000, 10_000, 0, 0) ;

my ($min_ex) = min( map { $_->{X} } @$elements) ;
my ($min_ey) = min( map { $_->{Y} } @$elements) ;

# X Y are not the minimum coordinate of the element, 
# there is a case where the arrow is reversed
# X_OFFSET and Y_OFFSET may be negative
for my $element (@{$elements})
	{
	for my $stripe (@{$element->get_stripes()})
		{
		$min_ex = min($min_ex, $element->{X} + $stripe->{X_OFFSET}) ;
		$min_ey = min($min_ey, $element->{Y} + $stripe->{Y_OFFSET}) ;
		}
	}

for my $element (@{$elements})
	{
	delete $element->{CACHE} ;
	
	my $element_offset_x = $element->{X} - $min_ex ;
	my $element_offset_y = $element->{Y} - $min_ey ;
	
	for my $stripe (@{$element->get_stripes()})
		{
		my $text = $stripe->{TEXT} ;
		
		my $width = max( map{ unicode_length($_) } split("\n", $text)) ;
		
		my $height = ($text =~ tr[\n][\n]) + 1 ;
		
		if(! $as_one_strip)
			{
			my @background_color ;
			@background_color = ("BACKGROUND" => $element->{COLORS}{BACKGROUND}) if defined $element->{COLORS}{BACKGROUND} ;
			@background_color = ("BACKGROUND" => $stripe->{BACKGROUND}) if defined $stripe->{BACKGROUND} ;
			
			my @foreground_color ;
			@foreground_color = ("FOREGROUND" => $element->{COLORS}{FOREGROUND}) if defined $element->{COLORS}{FOREGROUND} ;
			@foreground_color = ("FOREGROUND" => $stripe->{FOREGROUND}) if defined $stripe->{FOREGROUND} ;
			
			push @stripes, 
				{
				TEXT => $text,
				X_OFFSET => $stripe->{X_OFFSET} + $element_offset_x,
				Y_OFFSET => $stripe->{Y_OFFSET} + $element_offset_y,
				WIDTH => $width, 
				HEIGHT => $height , 
				@background_color,
				@foreground_color,
				} ;
			}
		
		($total_width) = max($total_width, $stripe->{X_OFFSET} + $width + $element_offset_x) ;
		($total_height) = max($total_height, $stripe->{Y_OFFSET} + $height + $element_offset_y) ;
		
		$min_x = min($min_x, $stripe->{X_OFFSET} + $element_offset_x) ;
		$max_x = max($max_x, $stripe->{X_OFFSET} + $width + $element_offset_x) ;
		$min_y = min($min_y, $stripe->{Y_OFFSET} + $element_offset_y) ;
		$max_y = max($max_y, $stripe->{Y_OFFSET} + $height + $element_offset_y) ;
		}
	}

$total_width -= $min_x ;
$total_height -= $min_y ;

if ($as_one_strip)
	{
	my $asciio = App::Asciio->new() ;
	$asciio->add_elements(@{$elements}) ;
	$asciio->{USE_CROSS_MODE} = $asciio_handle->{USE_CROSS_MODE} if(defined $asciio_handle->{USE_CROSS_MODE}) ;
	
	my $text = $asciio->transform_elements_to_ascii_buffer() ;
	
	my $cropped_text = '' ;
	for my $line (split /\n/, $text)
		{
		$line =~ s/^\s{$min_ex}// ;
		$cropped_text .= sprintf "%-${total_width}s\n", $line ;
		}
	
	$text = $cropped_text ;
	
	@stripes =
		({
		TEXT => $text,
		X_OFFSET => 0,
		Y_OFFSET => 0,
		WIDTH => $total_width, 
		HEIGHT => $total_height, 
		}) ;
	}

return bless({
		STRIPES => \@stripes,
		EXTENTS => [$min_x, $min_y, $max_x, $max_y],
		EX => $min_ex,
		EY => $min_ey,
		WIDTH => $total_width,
		HEIGHT => $total_height,
		ELEMENTS => $elements,
		CONNECTIONS => $connections,
		}, __PACKAGE__),
	$min_ex,
	$min_ey ;
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

sub allow_border_connection { my($self, $allow) = @_ ; $self->{ALLOW_BORDER_CONNECTION} = $allow ; }
sub is_border_connection_allowed { my($self) = @_ ; return $self->{ALLOW_BORDER_CONNECTION} ; }

#-----------------------------------------------------------------------------

1 ;
