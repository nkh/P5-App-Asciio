
use Cairo ;
use List::Util qw(min max) ;

register_import_export_handlers 
	(
	png => 
		{
		IMPORT => undef ,
		EXPORT => \&export_png,
		},
	) ;

sub export_png
{
my ($self, $elements_to_save, $file)  = @_ ;

if($self->{CREATE_BACKUP} && -e $file)
	{
	use File::Copy;
	copy($file,"$file.bak") or die "export_pod: Copy failed while making backup copy: $!" ;
	}

local $self->{BINDINGS_COMPLETION} = undef ;

my ($font_character_width, $font_character_height) = $self->get_character_size($self->{FONT_FAMILY}, $self->{FONT_BINDINGS_SIZE}) ;

my $width  = max( ( map { $_->{X} + 1 + $_->{EXTENTS}[2]} $elements_to_save->@* )) * $font_character_width ;
my $height = max( ( map { $_->{Y} + 1 + $_->{EXTENTS}[3]} $elements_to_save->@* )) * $font_character_height ;

my $surface = Cairo::ImageSurface->create('argb32', $width, $height);
my $cr      = Cairo::Context->create($surface);

App::Asciio::GTK::Asciio::expose_event($self->{widget}, $cr, $self) ;

$surface->write_to_png("$file");
}

