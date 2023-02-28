
use File::Slurp ;

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
my ($self, $elements_to_save, $file)  = @_ ;

if($self->{CREATE_BACKUP} && -e $file)
	{
	use File::Copy;
	copy($file,"$file.bak") or die "export_pod: Copy failed while making backup copy: $!";		
	}

write_file("$file.txt", {binmode => ':utf8'}, $self->transform_elements_to_ascii_buffer()) ;

qx"cat '$file.txt' | goat > '$file'" ;
qx"rm '$file.txt'" ;

return () ;
}

