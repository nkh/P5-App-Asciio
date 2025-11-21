
use File::Slurper qw(write_text) ;

register_import_export_handlers 
	(
	txt => 
		{
		IMPORT => undef ,
		EXPORT => \&export_ascii,
		},
	) ;

sub export_ascii
{
my ($self, $elements_to_save, $file)  = @_ ;

if($self->{CREATE_BACKUP} && -e $file)
	{
	use File::Copy;
	copy($file,"$file.bak") or die "export_pod: Copy failed while making backup copy: $!";		
	}

my $saved = write_text($file, $self->transform_elements_to_ascii_buffer()) ;

return $file ;
}

