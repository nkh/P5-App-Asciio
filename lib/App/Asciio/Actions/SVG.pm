package App::Asciio::Actions::SVG ;

use strict ;
use warnings ;

use MIME::Base64 ;
use File::Slurper qw/write_text/ ;

our $VERSION = '0.01' ;

#-----------------------------------------------------------------------------

sub export_to_svg
{
my ($asciio, $options) = @_ ;

$options                       //= {} ;
$options->{SVG_DRAW_SELECTION} //= 0 ;
$options->{SVG_DRAW_IMAGE_BOX} //= 0 ;

my ($character_width, $character_height) = $asciio->get_character_size() ;
my ($canvas_width, $canvas_height)       = calculate_canvas_size($asciio, $character_width, $character_height) ;
my $font_size                            = $character_height * 0.8 ;
# my $font_size = $asciio->get_font() ;

my $svg = '' ;

$svg .= create_svg_header($canvas_width, $canvas_height) ;
$svg .= draw_background_and_grid($asciio, $canvas_width, $canvas_height, $character_width, $character_height) if $asciio->{DISPLAY_GRID} ;
$svg .= draw_elements($asciio, $options, $character_width, $character_height, $font_size) ;
# $svg .= draw_connections($asciio, $character_width, $character_height) ;
$svg .= draw_ruler_lines($asciio, $canvas_width, $canvas_height, $character_width, $character_height) if $asciio->{DISPLAY_RULERS} ;
$svg .= draw_selection($asciio, $character_width, $character_height) if $options->{SVG_DRAW_SELECTION} ; 

$svg .= "</svg>\n" ;

return $svg ;
}

#-----------------------------------------------------------------------------

sub calculate_canvas_size
{
my ($asciio, $character_width, $character_height) = @_ ;

my ($max_x, $max_y) = (0, 0) ;

for my $element (@{$asciio->{ELEMENTS}})
	{
	my ($emin_x, $emin_y, $emax_x, $emax_y) = @{$element->{EXTENTS}} ;
	
	my $element_max_x = $element->{X} + $emax_x ;
	my $element_max_y = $element->{Y} + $emax_y ;
	
	$max_x = $element_max_x if $element_max_x > $max_x ;
	$max_y = $element_max_y if $element_max_y > $max_y ;
	}

$max_x += 2 ;
$max_y += 2 ;

return ($max_x * $character_width, $max_y * $character_height) ;
}

#-----------------------------------------------------------------------------

sub create_svg_header
{
my ($canvas_width, $canvas_height) = @_ ;

my $svg = qq{<?xml version="1.0" encoding="UTF-8" standalone="no"?>\n} ;
$svg .= qq{<svg width="$canvas_width" height="$canvas_height" } ;
$svg .= qq{xmlns="http://www.w3.org/2000/svg" } ;
$svg .= qq{xmlns:xlink="http://www.w3.org/1999/xlink">\n} ;

return $svg ;
}

#-----------------------------------------------------------------------------

sub draw_background_and_grid
{
my ($asciio, $canvas_width, $canvas_height, $character_width, $character_height) = @_ ;

my $svg = '' ;

my $background_color = get_svg_color($asciio->get_color('background')) ;
$svg .= qq{<rect x="0" y="0" width="$canvas_width" height="$canvas_height" fill="$background_color" />\n} ;

if ($asciio->{DISPLAY_GRID})
	{
	my $grid_color     = get_svg_color($asciio->get_color('grid')) ;
	my $grid2_color    = get_svg_color($asciio->get_color('grid_2')) ;
	
	my $num_horizontal = int($canvas_height / $character_height) + 1 ;
	my $num_vertical   = int($canvas_width / $character_width) + 1 ;
	
	for my $h (0 .. $num_horizontal)
		{
		my $y      = $h * $character_height ;
		my $color  = ($h % 10 == 0 && $asciio->{DISPLAY_GRID2}) ? $grid2_color : $grid_color ;
		$svg      .= qq{<line x1="0" y1="$y" x2="$canvas_width" y2="$y" stroke="$color" stroke-width="1" />\n} ;
		}
	
	for my $v (0 .. $num_vertical)
		{
		my $x      = $v * $character_width ;
		my $color  = ($v % 10 == 0 && $asciio->{DISPLAY_GRID2}) ? $grid2_color : $grid_color ;
		$svg      .= qq{<line x1="$x" y1="0" x2="$x" y2="$canvas_height" stroke="$color" stroke-width="1" />\n} ;
		}
	}

return $svg ;
}

#-----------------------------------------------------------------------------

sub draw_elements
{
my ($asciio, $options, $character_width, $character_height, $font_size) = @_ ;

my $svg = '' ;

for my $element (@{$asciio->{ELEMENTS}})
	{
	if ($element->isa('App::Asciio::GTK::Asciio::stripes::image_box'))
		{
		if ($options->{SVG_DRAW_IMAGE_BOX})
			{
			$svg .= draw_image_box_element($element, $character_width, $character_height) ;
			}
		}
	else
		{
		$svg .= draw_stripe_element($asciio, $element, $character_width, $character_height, $font_size) ;
		}
	}

return $svg ;
}

#-----------------------------------------------------------------------------

sub draw_stripe_element
{
my ($asciio, $element, $character_width, $character_height, $font_size) = @_ ;

my $svg = '' ;

my ($background_color, $foreground_color) = $asciio->get_element_colors($element) ;
my $bg_color                              = get_svg_color($background_color) ;
my $fg_color                              = get_svg_color($foreground_color) ;

my $stripes = $element->get_stripes() ;

for my $strip (@{$stripes})
	{
	my $line_index = 0 ;
	
	for my $line (split /\n/, $strip->{TEXT})
		{
		my $strip_bg = $bg_color ;
		my $strip_fg = $fg_color ;
		
		unless ($element->{SELECTED})
			{
			$strip_bg = get_svg_color($strip->{BACKGROUND}) if $strip->{BACKGROUND} ;
			$strip_fg = get_svg_color($strip->{FOREGROUND}) if $strip->{FOREGROUND} ;
			}
		
		my $base_x = ($element->{X} + $strip->{X_OFFSET}) * $character_width ;
		my $base_y = ($element->{Y} + $strip->{Y_OFFSET} + $line_index) * $character_height ;
		my $width  = $strip->{WIDTH} * $character_width ;
		
		$svg .= qq{<rect x="$base_x" y="$base_y" width="$width" height="$character_height" fill="$strip_bg" />\n} ;
		
		my @characters = split //, $line ;
		for my $char_index (0 .. $#characters)
			{
			my $char_x       = $base_x + ($char_index * $character_width) ;
			my $char_y       = $base_y + ($character_height * .85) ;
			my $escaped_char = escape_xml($characters[$char_index]) ;
			
			$svg .= qq{<text x="$char_x" y="$char_y" font-family="monospace" font-size="$font_size" fill="$strip_fg">$escaped_char</text>\n} ;
			}
		
		$line_index++ ;
		}
	}

return $svg ;
}

#-----------------------------------------------------------------------------

sub draw_image_box_element
{
my ($element, $character_width, $character_height) = @_ ;

my $svg = '' ;

if ($element->can('get_svg_image_data'))
	{
	my ($mime_type, $base64_data, $original_width, $original_height) = $element->get_svg_image_data() ;
	
	if ($base64_data)
		{
		my $x      = $element->{X} * $character_width ;
		my $y      = $element->{Y} * $character_height ;
		my $width  = $element->{WIDTH} * $character_width ;
		my $height = $element->{HEIGHT} * $character_height ;
		
		my $data_uri = "data:$mime_type;base64,$base64_data" ;
		$svg .= qq{<image x="$x" y="$y" width="$width" height="$height" xlink:href="$data_uri" />\n} ;
		}
	}

return $svg ;
}

#-----------------------------------------------------------------------------

sub draw_connections
{
my ($asciio, $character_width, $character_height) = @_ ;

my $svg = '' ;
my $connection_color = get_svg_color($asciio->get_color('connection')) ;

for my $connection (@{$asciio->{CONNECTIONS}})
	{
	my $connector = $connection->{CONNECTED}->get_named_connection($connection->{CONNECTOR}{NAME}) ;
	
	next unless $connector ;
	
	my $x = ($connector->{X} + $connection->{CONNECTED}{X}) * $character_width ;
	my $y = ($connector->{Y} + $connection->{CONNECTED}{Y}) * $character_height ;
	
	$svg .= qq{<rect x="$x" y="$y" width="$character_width" height="$character_height" } ;
	$svg .= qq{fill="none" stroke="$connection_color" stroke-width="1" />\n} ;
	}

return $svg ;
}

#-----------------------------------------------------------------------------

sub draw_ruler_lines
{
my ($asciio, $canvas_width, $canvas_height, $character_width, $character_height) = @_ ;

my $svg = '' ;
my $default_color = get_svg_color($asciio->get_color('ruler_line')) ;

for my $line (@{$asciio->{RULER_LINES}})
	{
	my $color = exists $line->{COLOR} ? get_svg_color($line->{COLOR}) : $default_color ;
	
	if ($line->{TYPE} eq 'VERTICAL')
		{
		my $x = $line->{POSITION} * $character_width ;
		$svg .= qq{<line x1="$x" y1="0" x2="$x" y2="$canvas_height" stroke="$color" stroke-width="1" />\n} ;
		}
	else
		{
		my $y = $line->{POSITION} * $character_height ;
		$svg .= qq{<line x1="0" y1="$y" x2="$canvas_width" y2="$y" stroke="$color" stroke-width="1" />\n} ;
		}
	}

return $svg ;
}

#-----------------------------------------------------------------------------

sub draw_selection
{
my ($asciio, $character_width, $character_height) = @_ ;

my $svg             = '' ;
my $selection_color = get_svg_color($asciio->get_color('selected_element_background')) ;

for my $element (@{$asciio->{ELEMENTS}})
	{
	if ($element->{SELECTED})
		{
		my ($emin_x, $emin_y, $emax_x, $emax_y) = @{$element->{EXTENTS}} ;
		
		my $x      = ($element->{X} + $emin_x) * $character_width ;
		my $y      = ($element->{Y} + $emin_y) * $character_height ;
		my $width  = ($emax_x - $emin_x) * $character_width ;
		my $height = ($emax_y - $emin_y) * $character_height ;
		
		$svg .= qq{<rect x="$x" y="$y" width="$width" height="$height" } ;
		$svg .= qq{fill="$selection_color" fill-opacity="0.3" stroke="$selection_color" stroke-width="1" />\n} ;
		}
	}

return $svg ;
}

#-----------------------------------------------------------------------------

sub get_svg_color
{
my ($color_array) = @_ ;

return '#000000' unless defined $color_array ;

my ($r, $g, $b) = @{$color_array} ;

$r = int($r * 255) ;
$g = int($g * 255) ;
$b = int($b * 255) ;

return sprintf('#%02x%02x%02x', $r, $g, $b) ;
}

#-----------------------------------------------------------------------------

sub escape_xml
{
my ($text) = @_ ;

$text =~ s/&/&amp;/g ;
$text =~ s/</&lt;/g ;
$text =~ s/>/&gt;/g ;
$text =~ s/"/&quot;/g ;
$text =~ s/'/&apos;/g ;

return $text ;
}

#-----------------------------------------------------------------------------

1 ;

__END__

=head1 NAME

App::Asciio::SVG::Export - SVG export for Asciio diagrams

=head1 SYNOPSIS

	use App::Asciio::SVG::Export ;
	
	my $svg = App::Asciio::SVG::Export::export_to_svg(
		$asciio_object,
		{
		SVG_DRAW_SELECTION => 1,
		SVG_DRAW_IMAGE_BOX => 1,
		}
	) ;

=head1 DESCRIPTION

Exports Asciio diagrams to SVG format, replicating the GTK rendering pipeline.
Supports grid, elements, connections, ruler lines, and optional selection/image rendering.

=back

=head1 AUTHOR

	Nadim Khemir

=head1 LICENSE

Same as Perl itself

=cut
