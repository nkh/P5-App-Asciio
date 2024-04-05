
use File::Slurp ;

register_import_export_handlers 
	(
	txt => 
		{
		IMPORT => undef ,
		EXPORT => \&export_ascii,
		},
	) ;

use File::Slurp ;

sub export_ascii
{
my ($self, $elements_to_save, $file)  = @_ ;

if($self->{CREATE_BACKUP} && -e $file)
	{
	use File::Copy;
	copy($file,"$file.bak") or die "export_pod: Copy failed while making backup copy: $!";		
	}

my $saved = write_file($file, {binmode => ':utf8'}, $self->transform_asciios_all_elements_to_ascii_buffer()) ;

return $saved ;
}

