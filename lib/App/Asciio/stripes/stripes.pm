
package App::Asciio::stripes::stripes ;

use strict;
use warnings;

use List::Util qw(max) ;

#---------------------------------------------------------------------------

sub new
{
my ($class, $element_definition) = @_ ;

my  @stripes ;

my ($total_width, $total_height) = (0, 0) ;
my ($min_x, $min_y, $max_x, $max_y) = (0, 0, 0, 0) ;

for my $stripe (@{$element_definition->{STRIPES}})
	{
	my $text = $stripe->{TEXT} ;
	
	my $width = 0 ;
	my $usc_length = usc_length($_) ;
	
	map { $width  = $width < $usc_length ? $usc_length : $width } split("\n", $text) ;
	
	my $height = ($text =~ tr[\n][\n]) + 1 ;
	
	push @stripes, 
		{
		TEXT => $text,
		X_OFFSET => $stripe->{X_OFFSET},
		Y_OFFSET => $stripe->{Y_OFFSET},
		WIDTH => $width, 
		HEIGHT => $height , 
		} ;
	
	($total_width) = max($total_width, $stripe->{X_OFFSET} + $width) ;
	($total_height) = max($total_height, $stripe->{Y_OFFSET} + $height) ;
	
	($min_x, $max_x) = minmax($min_x, $max_x, $stripe->{X_OFFSET}, $stripe->{X_OFFSET} + $width) ;
	($min_y, $max_y) = minmax($min_y, $max_y, $stripe->{Y_OFFSET}, $stripe->{Y_OFFSET} + $height) ;
	}

return bless  
	{
	STRIPES => \@stripes,
	EXTENTS => [$min_x, $max_x, $min_y, $max_y],
	WIDTH => $total_width,
	HEIGHT => $total_height,
	}, __PACKAGE__ ;
}

#---------------------------------------------------------------------------

sub get_stripes { my ($self) = @_ ; return $self->{STRIPES} ; }

#-----------------------------------------------------------------------------

sub get_size { my ($self) = @_ ; return($self->{WIDTH}, $self->{HEIGHT}) ; }

#-----------------------------------------------------------------------------

sub get_extents { my ($self) = @_ ; return($self->{EXTENTS}) ; }

#-----------------------------------------------------------------------------

sub resize { my ($self, $reference_x, $reference_y, $new_x, $new_y) = @_ ; return(0, 0, $self->{WIDTH}, $self->{HEIGHT}) ; }

#-----------------------------------------------------------------------------

sub get_action_menu_entries { ; }

#-----------------------------------------------------------------------------

sub get_selection_action { 'move' ; }

#-----------------------------------------------------------------------------

sub get_colors { my ($self) = @_ ; return  $self->{COLORS}{BACKGROUND}, $self->{COLORS}{FOREGROUND} ; }

#-----------------------------------------------------------------------------

sub set_background_color { my ($self, $background_color) = @_ ; $self->{COLORS}{BACKGROUND} = $background_color ; }

#-----------------------------------------------------------------------------

sub set_foreground_color { my ($self, $foreground_color) = @_ ; $self->{COLORS}{FOREGROUND} = $foreground_color ; }

#-----------------------------------------------------------------------------

sub set_colors
{
my ($self, $background_color, $foreground_color) = @_ ;
	
$self->{COLORS}{BACKGROUND} = $background_color ;
$self->{COLORS}{FOREGROUND} = $foreground_color ;
}

#-----------------------------------------------------------------------------

sub get_text { ; }

#-----------------------------------------------------------------------------

sub set_text { ; }

#-----------------------------------------------------------------------------

sub edit { ; }

#-----------------------------------------------------------------------------

sub match_connector { ; }

#-----------------------------------------------------------------------------

sub get_connector_points { ; }

sub get_connection_points { ; }

sub get_extra_points { ; }

#-----------------------------------------------------------------------------

sub get_named_connection { ; }

#-----------------------------------------------------------------------------

sub move_connector { ; }

#-----------------------------------------------------------------------------

sub is_autoconnect_enabled { my ($self) = @_ ; return ! $self->{AUTOCONNECT_DISABLED} ; }

#-----------------------------------------------------------------------------

sub enable_autoconnect { my ($self, $enable) = @_ ; $self->{AUTOCONNECT_DISABLED} = !$enable ; }

#-----------------------------------------------------------------------------

sub set
{
# set fields in the hash

my ($self, %key_values) = @_ ;

while (my ($key, $value) = each %key_values)
	{
	$self->{$key} = ${value} ;
	}

delete $self->{CACHE};
}

#-----------------------------------------------------------------------------

1 ;
