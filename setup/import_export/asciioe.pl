
#----------------------------------------------------------------------------------------------------------------------------

use File::Slurp ;

#----------------------------------------------------------------------------------------------------------------------------

register_import_export_handlers 
	(
	asciioe => 
		{
		IMPORT => \&import_asciioe,
		EXPORT => \&export_asciioe,
		},
	) ;

#----------------------------------------------------------------------------------------------------------------------------

sub import_asciioe
{
my ($self, $file)  = @_ ;

my $self_to_resurect= do $file  or die "import_asciioe: can't load file '$file': $! $@\n" ;
return($self_to_resurect, $file) ;
}

#----------------------------------------------------------------------------------------------------------------------------

sub export_asciioe
{
my ($self, $elements_to_save, $file, $data)  = @_ ;

if($self->{CREATE_BACKUP} && -e $file)
	{
	use File::Copy;
	copy($file,"$file.bak") or die "export_pod: Copy failed while making backup copy: $!" ;
	}

my $saved = write_file($file, $self->serialize_self(1) .'$VAR1 ;') ;

return $saved ;
}

 
