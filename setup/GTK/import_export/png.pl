
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
	copy($file,"$file.bak") or die "export_pod: Copy failed while making backup copy: $!";		
	}

my $alloc = $self->{widget}->allocation;
my $pixbuf = Gtk2::Gdk::Pixbuf->get_from_drawable
			(
			$self->{PIXMAP},
			$self->{widget}->window->get_colormap,
			0, 0,
			0, 0,
			$alloc->width, $alloc->height
			);
			
$pixbuf->save($file, "png" );

return ;
}

