package App::Asciio::GTK::Asciio::DisplayWidth ;

use strict ;
use warnings ;
use Cairo ;
use Pango ;

#-----------------------------------------------------------------------------

sub measure
{
my ($text, $asciio) = @_ ;

my $font //= $asciio->{FONT_FAMILY} ;
my $size //= $asciio->{FONT_SIZE} ;

my ($character_width, $character_height) = $asciio->get_character_size() ;

my $surface = Cairo::ImageSurface->create('argb32', 0, 0) ;
my $gc      = Cairo::Context->create($surface) ;
my $layout  = Pango::Cairo::create_layout($gc) ;

my $font_description = Pango::FontDescription->from_string($font . ' ' . $size) ;

$layout->set_font_description($font_description) ;
$layout->set_text($text) ;

my ($width, $height) = $layout->get_pixel_size ;

return int(($width / $character_width) + 0.5) ;
}

#-----------------------------------------------------------------------------

1;

