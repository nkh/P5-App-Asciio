
package App::Asciio::stripes::stripes ;

use strict;
use warnings;

use List::MoreUtils qw(minmax) ;

sub new
{
my ($class, $element_definition) = @_ ;

my  @stripes ;

my ($total_width, $total_height) = (0, 0) ;

for my $stripe (@{$element_definition->{STRIPES}})
	{
	my $text = $stripe->{TEXT} ;

	my $width = 0 ;
	map {$width  = $width < length($_) ? length($_)  : $width} split("\n", $text) ;

	my $height = ($text =~ tr[\n][\n]) + 1 ;

	push @stripes, 
		{
		TEXT => $text,
		X_OFFSET => $stripe->{X_OFFSET},
		Y_OFFSET => $stripe->{Y_OFFSET},
		WIDTH => $width, 
		HEIGHT => $height , 
		} ;
		
	(undef, $total_width) = minmax($total_width,  $stripe->{X_OFFSET} + $width) ;
	(undef, $total_height) = minmax($total_height,  $stripe->{Y_OFFSET} + $height) ;
	}
	
return bless  
		{
		STRIPES => \@stripes,
		WIDTH => $total_width,
		HEIGHT => $total_height,
		}, __PACKAGE__ ;	
}

#---------------------------------------------------------------------------

sub get_mask_and_element_stripes
{
my ($self) = @_ ;

my @elements_stripes ;

for my $stripe (@{$self->{STRIPES}})
	{
	push @elements_stripes, {X_OFFSET => $stripe->{X_OFFSET}, Y_OFFSET => $stripe->{Y_OFFSET}, WIDTH => $stripe->{WIDTH}, HEIGHT => $stripe->{HEIGHT}, TEXT => $stripe->{TEXT}} ;
	}
	
return(@elements_stripes) ;
}

#-----------------------------------------------------------------------------

sub get_size
{
my ($self) = @_ ;

return($self->{WIDTH}, $self->{HEIGHT}) ;
}

#-----------------------------------------------------------------------------

sub resize
{
my ($self, $reference_x, $reference_y, $new_x, $new_y) = @_ ;

return(0, 0, $self->{WIDTH}, $self->{HEIGHT}) ;
}

#-----------------------------------------------------------------------------

sub get_action_menu_entries
{
}

#-----------------------------------------------------------------------------

sub get_selection_action
{
'move' ;
}

#-----------------------------------------------------------------------------

sub get_colors
{
my ($self) = @_ ;
return  $self->{COLORS}{BACKGROUND}, $self->{COLORS}{FOREGROUND} ;
}

#-----------------------------------------------------------------------------

sub set_background_color
{
my ($self, $background_color) = @_ ;
	
$self->{COLORS}{BACKGROUND} = $background_color ;
}

#-----------------------------------------------------------------------------

sub set_foreground_color
{
my ($self, $foreground_color) = @_ ;
	
$self->{COLORS}{FOREGROUND} = $foreground_color ;
}

#-----------------------------------------------------------------------------

sub set_colors
{
my ($self, $background_color, $foreground_color) = @_ ;
	
$self->{COLORS}{BACKGROUND} = $background_color ;
$self->{COLORS}{FOREGROUND} = $foreground_color ;
}

#-----------------------------------------------------------------------------

sub get_text
{
}

#-----------------------------------------------------------------------------

sub set_text
{
}

#-----------------------------------------------------------------------------

sub edit
{
}

#-----------------------------------------------------------------------------

sub match_connector
{
}

#-----------------------------------------------------------------------------

sub get_connector_points
{
}

sub get_connection_points
{
}

sub get_extra_points
{
}

#-----------------------------------------------------------------------------

sub get_named_connection
{
}

#-----------------------------------------------------------------------------

sub move_connector
{
}

#-----------------------------------------------------------------------------

sub is_autoconnect_enabled
{
my ($self) = @_ ;

return ! $self->{AUTOCONNECT_DISABLED} ;
}

#-----------------------------------------------------------------------------

sub enable_autoconnect
{
my ($self, $enable) = @_ ;

$self->{AUTOCONNECT_DISABLED} = !$enable ;
}

#-----------------------------------------------------------------------------

sub set
{
# set fields in the hash

my ($self, %key_values) = @_ ;

while (my ($key, $value) = each %key_values)
	{
	#~ print "setting $key, $value\n" ;
	$self->{$key} = ${value} ;
	}
}

#-----------------------------------------------------------------------------

1 ;
