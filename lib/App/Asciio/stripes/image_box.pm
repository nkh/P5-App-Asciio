package App::Asciio::stripes::image_box ;
use parent qw/App::Asciio::stripes::editable_box2/ ;

use Gtk3 -init;

use strict;
use warnings;
use utf8;
use Encode;

use List::Util qw(min max) ;
use Readonly ;
use Clone ;

#-----------------------------------------------------------------------------

Readonly my $NO_BORDER => 
	[
	[0, 'top', '.', '-', '.', 1, ],
	[0, 'title separator', '|', '-', '|', 1, ],
	[0, 'body separator', '| ', '|', ' |', 1, ], 
	[0, 'bottom', '\'', '-', '\'', 1, ],
	[0, 'fill-character',  '',   ' ', '',   1, ],
	]  ;

sub new
{
my ($class, $element_definition) = @_ ;

my $self = bless  {}, __PACKAGE__ ;

my $box = Clone::clone($NO_BORDER) ;

my $image = $element_definition->{IMAGE} ;
my $image_type = $element_definition->{IMAGE_TYPE} ;
my $pixbuf = $self->get_pixbuf($image, $image_type) ;

my ($character_width, $character_height) = ($element_definition->{CHARACTER_WIDTH}, $element_definition->{CHARACTER_HEIGHT}) ;
my ($pixbuf_width, $pixbuf_height) = ($pixbuf->get_width(), $pixbuf->get_height()) ;
my ($chars_x_cnt, $chars_y_cnt) = (int($pixbuf_width / $character_width), int($pixbuf_height / $character_height)) ;

$self->setup
	(
	' ',
	$element_definition->{TITLE},
	$box,
	$chars_x_cnt, $chars_y_cnt,
	$element_definition->{RESIZABLE},
	$element_definition->{EDITABLE},
	$element_definition->{AUTO_SHRINK},
	$image,
	undef,
	$image_type,
	$image_type,
	0,
	1,
	1,
	) ;

return $self ;
}

#-----------------------------------------------------------------------------
sub setup
{
my ($self, $text_only, $title_text, $box_type, $end_x, $end_y, $resizable, $editable, $auto_shrink, $image, $draw_image, $image_type, $default_image_type, $freeze, $gray_scale_factor, $alpha_factor) = @_ ;

App::Asciio::stripes::editable_box2::setup
	(
	$self,
	$text_only,
	$title_text,
	$box_type,
	$end_x, $end_y,
	$resizable,
	$editable,
	$auto_shrink,
	) ;

$self->{IMAGE} //= $image ;
$self->{DRAW_IMAGE} //= $draw_image ;
$self->{IMAGE_TYPE} //= $image_type ;
$self->{DEFAULT_IMAGE_TYPE} //= $default_image_type ;
$self->{NAME} //= 'image_box' ;
$self->{FREEZE} //= $freeze ;
$self->{GRAY_SCALE_FACTOR} //= $gray_scale_factor ;
$self->{ALPHA_FACTOR} //= $alpha_factor ;
}

#-----------------------------------------------------------------------------
sub freeze
{
my ($self) = @_ ;

$self->{RESIZABLE} = 0 ;
$self->{FREEZE} = 1 ;
}

#-----------------------------------------------------------------------------
sub unfreeze
{
my ($self) = @_ ;

$self->{RESIZABLE} = 1 ;
$self->{FREEZE} = 0 ;
}

#-----------------------------------------------------------------------------
sub is_freeze
{
my ($self) = @_ ;

return $self->{FREEZE} ;
}

#-----------------------------------------------------------------------------
sub set_text { ; }

#-----------------------------------------------------------------------------
sub edit { ; }

#-----------------------------------------------------------------------------
sub rotate_text { ; }

#-----------------------------------------------------------------------------
sub shrink { ; }

#-----------------------------------------------------------------------------
# :TODO: this function is very slow and there is currently no way to speed it up.
sub get_gray_png
{
my ($self, $pixbuf, $gray_scale_factor, $alpha_factor) = @_ ;

my $alpha_factor_value = max($alpha_factor, 0) ;
my $has_alpha = $pixbuf->get_has_alpha();
my $pixels = $pixbuf->get_pixels();
my $rowstride = $pixbuf->get_rowstride();
my $bits_per_sample = $pixbuf->get_bits_per_sample();
my $width = $pixbuf->get_width();
my $height = $pixbuf->get_height();
my $channels = $pixbuf->get_n_channels();

# Create a new Pixbuf with alpha channel
my $new_pixbuf = Gtk3::Gdk::Pixbuf->new('rgb', 1, $bits_per_sample, $width, $height);
my $new_pixels = $new_pixbuf->get_pixels();
my $new_rowstride = $new_pixbuf->get_rowstride();
my $new_channels = $new_pixbuf->get_n_channels();

# my $t0 = Time::HiRes::gettimeofday();

for my $y (0 .. $height - 1) 
	{
	for my $x (0 .. $width - 1) 
		{
		my $offset = $y * $rowstride + $x * $channels;
		my $new_offset = $y * $new_rowstride + $x * $new_channels;

		my ($r, $g, $b, $a) ;
		if ($has_alpha) {
			($r, $g, $b, $a) = map { ord(substr($pixels, $offset + $_, 1)) } 0 .. $channels - 1;
		} else {
			($r, $g, $b) = map { ord(substr($pixels, $offset + $_, 1)) } 0 .. $channels - 1;
			$a = 255 ;
		}

		my $gray = int(($r + $g + $b) / 3);

		my $new_gray = int(min($gray * $gray_scale_factor, 255));

		substr($new_pixels, $new_offset + $_, 1, chr($new_gray)) for 0 .. 2;

		# Adjust alpha channel value
		my $new_alpha = int($a * $alpha_factor_value);
		substr($new_pixels, $new_offset + 3, 1, chr($new_alpha));
		}
	}
# my $t1 = Time::HiRes::gettimeofday();
# printf STDERR "add time: %0.4f sec.\n", $t1 - $t0 ;

my $gray_pixbuf = Gtk3::Gdk::Pixbuf->new_from_data($new_pixels, 'rgb', 1, $bits_per_sample, $width, $height, $new_rowstride);

$self->{IMAGE_TYPE} = 'png' ;
return $gray_pixbuf->save_to_bufferv($self->{IMAGE_TYPE}, [], []) ;
}

#-----------------------------------------------------------------------------
sub switch_images
{
my ($self, $gray_scale_factor_step, $alpha_factor_step) = @_ ;

if(defined $gray_scale_factor_step || defined $alpha_factor_step)
	{
	my $pixbuf = $self->get_pixbuf($self->{IMAGE}, $self->{IMAGE_TYPE}) ;

	# gray_scale_factor_step start from 1 and gradually increase
	# alpha_factor_step start from 1 and gradually decrease until 0
	$self->{GRAY_SCALE_FACTOR} += $gray_scale_factor_step if defined $gray_scale_factor_step ;
	$self->{GRAY_SCALE_FACTOR} = max(1, $self->{GRAY_SCALE_FACTOR}) ;
	$self->{ALPHA_FACTOR} -= $alpha_factor_step if defined $alpha_factor_step ;
	$self->{ALPHA_FACTOR} = max($self->{ALPHA_FACTOR}, 0.05) ;
	$self->{ALPHA_FACTOR} = min($self->{ALPHA_FACTOR}, 1) ;

	$self->{DRAW_IMAGE} = $self->get_gray_png($pixbuf, $self->{GRAY_SCALE_FACTOR}, $self->{ALPHA_FACTOR}) ;
	}
else
	{
	$self->{GRAY_SCALE_FACTOR} = 1 ;
	$self->{ALPHA_FACTOR} = 1 ;
	$self->{IMAGE_TYPE} = $self->{DEFAULT_IMAGE_TYPE} ;
	$self->{DRAW_IMAGE} = undef ;
	}
}

#-----------------------------------------------------------------------------
sub get_pixbuf
{
my ($self, $image, $image_type) = @_ ;

print("we in imagetype:$image_type\n") ;

my $loader = Gtk3::Gdk::PixbufLoader->new_with_type($image_type);

$loader->write($image);
$loader->close();
return $loader->get_pixbuf();
}

#-----------------------------------------------------------------------------
sub gui_draw
{
my ($self, $asciio, $element_index, $gc, $font_description, $character_width, $character_height) = @_ ;

my $is_selected = $self->{SELECTED} // 0 ;
$is_selected = 1 if $is_selected > 0 ;

my ($background_color, $foreground_color) =  $self->get_colors() ;

if($is_selected)
	{
	if(exists $self->{GROUP} and defined $self->{GROUP}[-1])
		{
		$background_color = $self->{GROUP}[-1]{GROUP_COLOR}[0]
		}
	else
		{
		$background_color = $asciio->get_color('selected_element_background');
		}
	}
else
	{
	unless (defined $background_color)
		{
		if(exists $self->{GROUP} and defined $self->{GROUP}[-1])
			{
			$background_color = $self->{GROUP}[-1]{GROUP_COLOR}[1]
			}
		else
			{
			$background_color = $asciio->get_color('element_background') ;
			}
		}
	}
		
my ($pixbuf_width, $pixbuf_height) = (($self->{WIDTH} * $character_width), ($self->{HEIGHT} * $character_height)) ;

my $loader = Gtk3::Gdk::PixbufLoader->new_with_type($self->{IMAGE_TYPE});
$loader->write($self->{DRAW_IMAGE} // $self->{IMAGE});
$loader->close();
my $pixbuf = $loader->get_pixbuf();

# GDK_INTERP_HYPER Better results but more computational overhead
my $scaled_pixbuf = $pixbuf->scale_simple($pixbuf_width, $pixbuf_height, 'GDK_INTERP_BILINEAR');

$gc->set_source_rgba(@{$background_color}, $asciio->{OPAQUE_ELEMENTS});
Gtk3::Gdk::cairo_set_source_pixbuf($gc, $scaled_pixbuf, $self->{X} * $character_width, $self->{Y} * $character_height);
$gc->paint() ;
}

#-----------------------------------------------------------------------------
1 ;

