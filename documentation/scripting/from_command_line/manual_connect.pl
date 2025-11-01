
use strict; use warnings;

use App::Asciio::Scripting ;

#-----------------------------------------------------------------------------------------------------------

my $box1  = add 'box1',  new_box(TEXT_ONLY =>'box1'), 0, 2 ;
my $box2  = add 'box2',  new_box(TEXT_ONLY =>'box2'), 20, 10 ;
my $arrow = add 'arrow', new_wirl_arrow (), 0,  0 ;

my $start_connection = move_named_connector($arrow, 'startsection_0', $box1, 'bottom_center');
my $end_connection = move_named_connector($arrow, 'endsection_0', $box2, 'bottom_center') ;

die "missing connection!" unless defined $start_connection && defined $end_connection ;

set_connection($start_connection, $end_connection) ;

get_canonizer()->([$start_connection, $end_connection]) ;

ascii_out ;

