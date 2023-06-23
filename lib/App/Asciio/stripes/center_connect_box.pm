
package App::Asciio::stripes::center_connect_box ;
use parent qw/App::Asciio::stripes::editable_box2/ ;

use strict;
use warnings;

use Readonly ;
use Clone ;

#-----------------------------------------------------------------------------

Readonly my $DEFAULT_BOX_TYPE => 
	[
	[0, 'top', '.', '-', '.', 1, ],
	[0, 'title separator', '|', '-', '|', 1, ],
	[0, 'body separator', '| ', '|', ' |', 1, ], 
	[0, 'bottom', '\'', '-', '\'', 1, ],
	]  ;

sub new
{
my ($class, $element_definition) = @_ ;

my $self = bless  {}, __PACKAGE__ ;

my $box = $element_definition->{BOX_TYPE} // Clone::clone($DEFAULT_BOX_TYPE) ;

App::Asciio::stripes::editable_box2::setup
	(
	$self,
	$element_definition->{TEXT_ONLY},
	$element_definition->{TITLE},
	$box,
	1, 1,
	$element_definition->{RESIZABLE},
	$element_definition->{EDITABLE},
	$element_definition->{AUTO_SHRINK},
	) ;

return $self ;
}

#-----------------------------------------------------------------------------


sub get_selection_action { return 'move' }

#-----------------------------------------------------------------------------

sub match_connector
{
my ($self, $x, $y) = @_ ;

my $middle_width = int($self->{WIDTH} / 2) ;
my $middle_height = int($self->{HEIGHT} / 2) ;

if($x == $middle_width && $y == $middle_height)
	{
	return {X => $middle_width, Y => $middle_height, NAME => 'top_center'}  
	}
else
	{
	return
	}
}

#-----------------------------------------------------------------------------

sub get_connection_points
{
my ($self) = @_ ;
my $middle_width = int($self->{WIDTH} / 2)  ;
my $middle_height = int($self->{HEIGHT} / 2) ;

return
	(
	{X =>  $middle_width, Y => $middle_height, NAME => 'top_center'},
	{X =>  $middle_width, Y => $middle_height, NAME => 'bottom_center'},
	{X =>  $middle_width, Y => $middle_height, NAME => 'left_center'},
	{X =>  $middle_width, Y => $middle_height, NAME => 'right_center'},
	) ;
}

#-----------------------------------------------------------------------------

sub get_extra_points
{
return 
}

#-----------------------------------------------------------------------------

sub get_named_connection
{
my ($self, $name) = @_ ;
my $middle_width = int($self->{WIDTH} / 2)  ;
my $middle_height = int($self->{HEIGHT} / 2) ;

return {X =>  $middle_width, Y => $middle_height, NAME => 'top_center'} ;
}

#-----------------------------------------------------------------------------

1 ;
