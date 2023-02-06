
use strict;
use warnings;

use lib qw(lib) ;

use App::Asciio ;
use scripting_lib ;

use Module::Util qw(find_installed) ;
use File::Basename ;

#-----------------------------------------------------------------------------

my $asciio = new App::Asciio() ;

# $asciio->setup($asciio_config->{SETUP_INI_FILE}, $asciio_config->{SETUP_PATH}) ;

my ($command_line_switch_parse_ok, $command_line_parse_message, $asciio_config)
	= $asciio->ParseSwitches([@ARGV], 0) ;

die "Error: '$command_line_parse_message'!" unless $command_line_switch_parse_ok ;

if(@{$asciio_config->{SETUP_PATHS}})
	{
	$asciio->setup($asciio_config->{SETUP_PATHS}) ;
	}
else
	{
	my ($basename, $path, $ext) = File::Basename::fileparse(find_installed('App::Asciio'), ('\..*')) ;
	$asciio->setup([$path . $basename . '/setup/setup.ini']) ;
	}

#-----------------------------------------------------------------------------

my $box1 = new_box(TEXT_ONLY =>'box1') ;
$asciio->add_element_at($box1, 0, 2) ;

my $box2 = new_box(TEXT_ONLY =>'box2') ;
$asciio->add_element_at($box2, 20, 10) ;

my $box3 = new_box(TEXT_ONLY =>'box3') ;
$asciio->add_element_at($box3, 40, 5) ;

add_connection($asciio, $box1, $box2, 'down') ;
add_connection($asciio, $box2, $box3, ) ;
add_connection($asciio, $box3, $box1, 'up') ;
optimize_connections($asciio) ;

my $process = $asciio->add_new_element_named('Stencils/Asciio/Boxes/process', 5, 15) ;
$process->set_text("line 1\nline 2\nline 3") ;

print $asciio->transform_elements_to_ascii_buffer() ;



