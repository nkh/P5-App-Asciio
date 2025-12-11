
package App::Asciio::GTK::Asciio::Actions::File ;

use utf8;
use Encode qw(decode encode FB_CROAK) ;

use File::Basename ;
use File::Slurper qw(read_binary) ;
use App::Asciio::String ;

use App::Asciio::GTK::Asciio::stripes::image_box ;

#----------------------------------------------------------------------------------------------

sub open_image
{
my ($self, $file_name) = @_;

$file_name   = normalize_file_name($file_name) ;
$file_name ||= $self->get_file_name('open') ;

return unless defined $file_name && $file_name ne q[] ;

my (undef, undef, $extension) = File::Basename::fileparse($file_name, ('\..*')) ;
$extension =~ s/^\.// ;

my $image_type = lc($extension) ;
$image_type = 'jpeg' if $image_type eq 'jpg' ;

my ($error_message, $image_data) ;

if ($image_type ne 'png' && $image_type ne 'jpeg')
	{
	$error_message = "Unsupported image type '$image_type'." ;
	}
else
	{
	eval { $image_data = read_binary($file_name) } ;
	
	$error_message = "Read failed: $file_name" if $@ ;
	}

my $image_box ;
if (defined $error_message)
	{
	$image_box = new App::Asciio::stripes::editable_box2
			({
			TEXT_ONLY => $error_message,
			TITLE     => '',
			EDITABLE  => 1,
			RESIZABLE => 1,
			}) ;
	}
else
	{
	my ($character_width, $character_height) = $self->get_character_size();
	
	$image_box = App::Asciio::GTK::Asciio::stripes::image_box->new
			({
			NAME            => 'image_box',
			TEXT_ONLY       => ' ',
			TITLE           => '',
			EDITABLE        => 0,
			RESIZABLE       => 1,
			AUTO_SHRINK     => 0,
			CHARACTER_WIDTH => $character_width,
			CHARACTER_HEIGHT=> $character_height,
			IMAGE           => $image_data,
			IMAGE_TYPE      => $image_type,
			}) ;
	}

$self->add_element_at($image_box, $self->{MOUSE_X}, $self->{MOUSE_Y});
$self->select_elements(1, $image_box);
$self->update_display();
}

#----------------------------------------------------------------------------------------------

1 ;


