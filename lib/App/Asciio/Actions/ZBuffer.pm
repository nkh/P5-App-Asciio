
package App::Asciio::Actions::ZBuffer ;

use strict ; use warnings ;

use App::Asciio::ZBuffer ;


#-----------------------------------------------------------------------------

sub dump_crossings
{
my ($asciio) = @_ ;

use Term::Size::Any qw(chars) ;

my $zbuffer = App::Asciio::ZBuffer->new(@{$asciio->{ELEMENTS}}) ;
$zbuffer->cross_overlay ;

$zbuffer->render_text ;
}


#-----------------------------------------------------------------------------

1 ;

