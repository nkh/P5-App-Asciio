
use strict; use warnings;

use Data::TreeDumper ;

use App::Asciio::Scripting ;
use App::Asciio::stripes::editable_box2 ;
use App::Asciio::stripes::process_box ;
use App::Asciio::stripes::single_stripe ;

#--------------------------------------------------------------------------------------------

my $box = add 'box1', new App::Asciio::stripes::editable_box2({ TEXT_ONLY => 'box', TITLE => '' }), 0, 0 ;
my $stripe = add 'stripe', new App::Asciio::stripes::single_stripe({ TEXT => 'stripe' }), 25, 0 ;
my $process = add 'process', new App::Asciio::stripes::process_box({ TEXT_ONLY => 'process' }), 50, 0 ;

ascii_out ;

$box->set_text('title', "line 1\nline 2") ;
$stripe->set_text("line 1\nline2") ;
$process->set_text("line 1\nline2\nline3") ;

ascii_out ;

for ($box, $process, $stripe)
	{
	print "\n-------------------------------------------------------\n\n" ;
	print 'type: ',  ref($_), "\n" ;
	print 'size:', join(",", $_->get_size()) , "\n" ;
	print DumpTree([$_->get_connection_points()], 'connection points:') , "\n" ;
	print 'text : ',  join("\n", $_->get_text()) , "\n" ;
	}

