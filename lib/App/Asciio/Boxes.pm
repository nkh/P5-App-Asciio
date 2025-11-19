
package App::Asciio::Boxes ;

use strict ; use warnings ;
use utf8 ;

use Clone ;

#----------------------------------------------------------------------------------------------

use Exporter qw( import ) ;

use constant TOP             => 0 ;
use constant TITLE_SEPARATOR => 1 ;
use constant BODY_SEPARATOR  => 2 ;
use constant BOTTOM          => 3 ;

use constant DISPLAY         => 0 ;
use constant NAME            => 1 ;
use constant LEFT            => 2 ;
use constant BODY            => 3 ;
use constant RIGHT           => 4 ;

our @EXPORT_OK = qw(TOP TITLE_SEPARATOR BODY_SEPARATOR BOTTOM DISPLAY NAME LEFT BODY RIGHT) ;
our %EXPORT_TAGS = ( const => [ qw(TOP TITLE_SEPARATOR BODY_SEPARATOR BOTTOM DISPLAY NAME LEFT BODY RIGHT) ] );

# ------------------------------------------------------------------------------

1 ;
