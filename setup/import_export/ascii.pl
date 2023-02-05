
use App::Asciio::Toolfunc ;

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

my $saved = write_file_utf8($file, $self->transform_elements_to_ascii_buffer()) ;
#~ open FH, ">:encoding(utf8)",   $file_name;
#~ print FH $self->transform_elements_to_ascii_buffer() ;
#~ close FH ;

return $saved ;
}

