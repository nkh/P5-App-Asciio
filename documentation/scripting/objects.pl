
use strict;
use warnings;
use lib qw(lib lib/stripes) ;
use Data::TreeDumper ;

use App::Asciio ;
use App::Asciio::stripes::editable_box2 ;
use App::Asciio::stripes::process_box ;
use App::Asciio::stripes::single_stripe ;

#-----------------------------------------------------------------------------

my $asciio = new App::Asciio() ;

#-----------------------------------------------------------------------------

my ($current_x, $current_y) = (0, 0) ;

my $new_box = new App::Asciio::stripes::editable_box2
				({
				TEXT_ONLY => 'box',
				TITLE => '',
				EDITABLE => 1,
				RESIZABLE => 1,
				}) ;
$asciio->add_element_at($new_box, 0, 0) ;

my $new_process = new App::Asciio::stripes::process_box
				({
				TEXT_ONLY => 'process',
				EDITABLE => 1,
				RESIZABLE => 1,
				}) ;
$asciio->add_element_at($new_process, 25, 0) ;

my $new_stripe = new App::Asciio::stripes::single_stripe
				({
				TEXT => 'stripe',
				}) ;
$asciio->add_element_at($new_stripe, 50, 0) ;

print $asciio->transform_elements_to_ascii_buffer() ;

$new_box->set_text('title', "line 1\nline 2") ;
$new_process->set_text("line 1\nline2\nline3") ;
$new_stripe->set_text( "line 1\nline2") ;

print $asciio->transform_elements_to_ascii_buffer() ;

for ($new_box, $new_process, $new_stripe)
	{
	print "\n-------------------------------------------------------\n\n" ;
	print 'type: ',  ref($_), "\n" ;
	print 'size:', join(",", $_->get_size()) , "\n" ;
	print DumpTree([$_->get_connection_points()], 'connection points:') , "\n" ;
	print 'text : ',  join("\n", $_->get_text()) , "\n" ;
	}

