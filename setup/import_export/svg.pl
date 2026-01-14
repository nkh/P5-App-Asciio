
use App::Asciio::Actions::SVG ;
use File::Slurper qw(read_text write_text) ;

register_import_export_handlers 
	(
	svg => 
		{
		IMPORT => undef ,
		EXPORT => \&export_svg,
		},
	) ;


sub export_svg
{
my ($self, $elements_to_save, $file) = @_ ;

if($self->{CREATE_BACKUP} && -e $file)
	{
	use File::Copy;
	copy($file,"$file.bak") or die "export_svg: Copy failed while making backup copy: $!" ;
	}

write_text($file, App::Asciio::Actions::SVG::export_to_svg($self, {})) ;
}

sub export_svg_via_goat
{
my ($self, $elements_to_save, $file)  = @_ ;

if($self->{CREATE_BACKUP} && -e $file)
	{
	use File::Copy;
	copy($file,"$file.bak") or die "export_svg: Copy failed while making backup copy: $!" ;
	}

write_text("$file.txt", $self->transform_elements_to_ascii_buffer()) ;

qx"cat '$file.txt' | goat > '$file'" ;
qx"rm '$file.txt'" ;

return () ;
}

