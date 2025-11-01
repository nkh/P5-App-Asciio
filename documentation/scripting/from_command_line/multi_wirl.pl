
use strict; use warnings;

use App::Asciio::Scripting ;

#-----------------------------------------------------------------------------

add 'multi_wirl', new_wirl_arrow([5, 5, 'downright'], [10, 7, 'downright'], [7, 14, 'downleft']), 5, 5 ;

ascii_out ;

