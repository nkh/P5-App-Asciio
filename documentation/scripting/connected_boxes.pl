
use strict; use warnings;

use App::Asciio::Scripting ;
use App::Asciio::stripes::process_box ;

#-----------------------------------------------------------------------------

add 'box1', new_box(TEXT_ONLY =>'box1'),  0,  2 ;
add 'box2', new_box(TEXT_ONLY =>'box2'), 20, 10 ;
add 'box3', new_box(TEXT_ONLY =>'box3'), 40,  5 ;

connect_elements 'box1', 'box2', 'down' ;
connect_elements 'box2', 'box3' ;
connect_elements 'box3', 'box1', 'up' ;

my $process = add_type 'process', 'Asciio/Boxes/process', 5, 15 ;
$process->set_text("line 1\nline 2\nline 3") ;

optimize ;

save_to "from_script.asciio" ;

ascii_out ;

select_all_elements ;
