package App::Asciio::GTK::Asciio::stripes::image_box ;
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
my $pixbuf ;

eval { $pixbuf = $self->get_pixbuf($image, $image_type); } ;

if ($@ || ! defined $pixbuf)
	{
	my $error_message = "Image load failed: unsupported or unreadable image format." ;
	
	my $error_box = $self->SUPER::new
				({
				TEXT_ONLY => $error_message,
				TITLE     => '',
				EDITABLE  => 1,
				RESIZABLE => 1,
				}) ;
	
	return $error_box ;
	}

my ($max_width, $max_height) = (640, 480) ;

my ($character_width, $character_height) = ($element_definition->{CHARACTER_WIDTH}, $element_definition->{CHARACTER_HEIGHT}) ;
my ($pixbuf_width, $pixbuf_height)       = ($pixbuf->get_width(), $pixbuf->get_height()) ;

if ($pixbuf_width > $max_width || $pixbuf_height > $max_height)
	{
	my $scale_w = $max_width  / $pixbuf_width ;
	my $scale_h = $max_height / $pixbuf_height ;
	
	my $scale = $scale_w < $scale_h ? $scale_w : $scale_h ;
	
	my $new_w = int($pixbuf_width  * $scale) ;
	my $new_h = int($pixbuf_height * $scale) ;
	
	($pixbuf_width, $pixbuf_height) = ($new_w, $new_h) ;
	}

my ($chars_x_cnt, $chars_y_cnt) = (
	int($pixbuf_width  / $character_width),
	int($pixbuf_height / $character_height),
	) ;

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
	0,
	$image_type,
	$image_type,
	1,
	1,
	) ;

return $self ;
}

#-----------------------------------------------------------------------------

sub setup
{
my 
	(
	$self,
	$text_only, $title_text, $box_type, $end_x, $end_y, $resizable,
	$editable, $auto_shrink,
	$image, $use_gray, $image_type, $default_image_type, $gray_scale_factor, $alpha_factor
	) = @_ ;

$self->SUPER::setup
	(
	$text_only,
	$title_text,
	$box_type,
	$end_x, $end_y,
	$resizable,
	$editable,
	$auto_shrink,
	) ;

$self->{IMAGE}               //= $image ;
$self->{USE_GRAY}            //= $use_gray ;
$self->{IMAGE_TYPE}          //= $image_type ;
$self->{DEFAULT_IMAGE_TYPE}  //= $default_image_type ;
$self->{NAME}                //= 'image_box' ;
$self->{GRAY_SCALE_FACTOR}   //= $gray_scale_factor ;
$self->{ALPHA_FACTOR}        //= $alpha_factor ;
}

#-----------------------------------------------------------------------------

sub freeze
{
my ($self) = @_ ;

delete $self->{CACHE}{RENDERING} ;
$self->SUPER::freeze() ;
}

sub thaw
{
my ($self) = @_ ;

delete $self->{CACHE}{RENDERING} ;
$self->SUPER::thaw() ;
}

sub is_frozen
{
my ($self) = @_ ;

return $self->{FROZEN} ;
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

sub get_gray_png
{
my ($self, $pixbuf, $gray_scale_factor, $alpha_factor) = @_ ;

my $alpha = int($alpha_factor * 255) ;

# print "scale:${gray_scale_factor}; alpha:${alpha_factor}\n";

my $src_pixbuf = $pixbuf->add_alpha(1, 0, 0, 0);

my $gray_pixbuf = Gtk3::Gdk::Pixbuf->new
			(
			'rgb', 1, 8,
			$src_pixbuf->get_width,
			$src_pixbuf->get_height,
			) ;

$src_pixbuf->saturate_and_pixelate($gray_pixbuf, $gray_scale_factor, 0) ;

my $dest_pixbuf = Gtk3::Gdk::Pixbuf->new
			(
			'rgb', 1, 8,
			$gray_pixbuf->get_width,
			$gray_pixbuf->get_height,
			) ;

$gray_pixbuf->composite
		(
		$dest_pixbuf,
		0, 0,
		$gray_pixbuf->get_width,
		$gray_pixbuf->get_height,
		0, 0,
		1.0, 1.0,
		'nearest',
		$alpha
		) ;

return $dest_pixbuf ;
}

#-----------------------------------------------------------------------------

sub switch_images
{
my ($self, $gray_scale_factor_step, $alpha_factor_step) = @_ ;

delete $self->{CACHE}{RENDERING} ;

if(defined $gray_scale_factor_step || defined $alpha_factor_step)
	{
	$self->{GRAY_SCALE_FACTOR} -= $gray_scale_factor_step if defined $gray_scale_factor_step ;
	$self->{GRAY_SCALE_FACTOR}  = max($self->{GRAY_SCALE_FACTOR}, 0) ;
	$self->{GRAY_SCALE_FACTOR}  = min($self->{GRAY_SCALE_FACTOR}, 1) ;
	
	$self->{ALPHA_FACTOR}      -= $alpha_factor_step if defined $alpha_factor_step ;
	$self->{ALPHA_FACTOR}       = max($self->{ALPHA_FACTOR}, 0.05) ;
	$self->{ALPHA_FACTOR}       = min($self->{ALPHA_FACTOR}, 1) ;
	
	$self->{USE_GRAY}         = 1 ;
	}
else
	{
	$self->{GRAY_SCALE_FACTOR} = 1 ;
	$self->{ALPHA_FACTOR}      = 1 ;
	$self->{IMAGE_TYPE}        = $self->{DEFAULT_IMAGE_TYPE} ;
	$self->{USE_GRAY}          = 0 ;
	}
}

#-----------------------------------------------------------------------------

sub get_pixbuf
{
my ($self, $image, $image_type) = @_ ;

my $loader = Gtk3::Gdk::PixbufLoader->new_with_type($image_type) ;

$loader->write($image) ;
$loader->close() ;

return $loader->get_pixbuf() ;
}

#-----------------------------------------------------------------------------

sub prepare_scaled_pixbuf
{
my ($self, $character_width, $character_height) = @_ ;

my $pixbuf_width  = $self->{WIDTH}  * $character_width ;
my $pixbuf_height = $self->{HEIGHT} * $character_height ;

my $pixbuf = $self->get_pixbuf($self->{IMAGE}, $self->{IMAGE_TYPE}) ;
if ($self->{USE_GRAY})
	{
	$pixbuf = $self->get_gray_png($pixbuf, $self->{GRAY_SCALE_FACTOR}, $self->{ALPHA_FACTOR}) ;
	}

my $scaled = $pixbuf->scale_simple($pixbuf_width, $pixbuf_height, 'GDK_INTERP_BILINEAR') ;

return $scaled ;
}

#-----------------------------------------------------------------------------

1 ;

