
use strict;
use warnings;

use lib qw(documentation/scripting/lib) ;

use App::Asciio ;
use scripting_lib ;

#-----------------------------------------------------------------------------

my $asciio = new App::Asciio() ;
my ($command_line_switch_parse_ok, $command_line_parse_message, $asciio_config)
	= $asciio->ParseSwitches([@ARGV], 0) ;

die "Error: '$command_line_parse_message'!" unless $command_line_switch_parse_ok ;

$asciio->setup($asciio_config->{SETUP_INI_FILE}, $asciio_config->{SETUP_PATH}) ;

#-----------------------------------------------------------------------------

my $box1 = new_box(TEXT_ONLY =>'box1') ;
$asciio->add_element_at($box1, 0, 2) ;

my $box2 = new_box(TEXT_ONLY =>'box2') ;
$asciio->add_element_at($box2, 20, 10) ;

my $box3 = new_box(TEXT_ONLY =>'box3') ;
$asciio->add_element_at($box3, 40, 5) ;

my $arrow = new_wirl_arrow () ;
$asciio->add_element_at($arrow, 0,0) ;

my $start_connection = move_named_connector($arrow, 'startsection_0', $box1, 'bottom_center');
my $end_connection = move_named_connector($arrow, 'endsection_0', $box2, 'bottom_center') ;

die "missing connection!" unless defined $start_connection && defined $end_connection ;

$asciio->add_connections($start_connection, $end_connection) ;
get_canonizer()->([$start_connection, $end_connection]) ;

print $asciio->transform_elements_to_ascii_buffer() ;

#-----------------------------------------------------------------------------------------------------------

