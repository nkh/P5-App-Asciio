
package App::Asciio::stripes::group ;
use base App::Asciio::stripes::stripes ;

use strict;
use warnings;

use List::Util qw(min max) ;
use List::MoreUtils qw(minmax) ;
use Module::Util qw(find_installed) ;
use File::Basename ;

use App::Asciio::Toolfunc ;

#-----------------------------------------------------------------------------

sub new
{
my ($class, $elements, $connections, $as_one_strip) = @_ ;

my  @stripes ;

my ($total_width, $total_height) = (0, 0) ;
my ($min_x, $min_y, $max_x, $max_y) = (10_000, 10_000, 0, 0) ;

my ($min_ex) = min( map { $_->{X} } @$elements) ;
my ($min_ey) = min( map { $_->{Y} } @$elements) ;

for my $element (@{$elements})
	{
	delete $element->{CACHE} ;
	
	my $element_offset_x = $element->{X} - $min_ex ;
	my $element_offset_y = $element->{Y} - $min_ey ;
	
	for my $stripe (@{$element->get_stripes()})
		{
		my $text = $stripe->{TEXT} ;
		
		my $width = 0 ;
		map {$width  = max($width, usc_length($_))} split("\n", $text) ;
		
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
		EXTENTS => [$min_x, $max_x, $min_y, $max_y],
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

1 ;
