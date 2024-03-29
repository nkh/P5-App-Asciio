
package App::Asciio::Actions::Arrow ;

use strict;
use warnings;

#----------------------------------------------------------------------------------------------

use List::Util qw(min max) ;

use App::Asciio::Actions::Multiwirl ;

#----------------------------------------------------------------------------------------------

sub interactive_change_arrow_direction
{
my ($self) = @_ ;
my $changes_made = 0 ;

for (grep {ref $_ eq 'App::Asciio::stripes::section_wirl_arrow'} $self->get_selected_elements(1))
	{
	$self->create_undo_snapshot() unless $changes_made++ ;
	$_->change_last_section_direction() ;
	}

for (grep {ref $_ eq 'App::Asciio::stripes::angled_arrow'} $self->get_selected_elements(1))
	{
	$self->create_undo_snapshot() unless $changes_made++ ;
	$_->change_direction() ;
	}

$self->update_display() if $changes_made ;
}

#----------------------------------------------------------------------------------------------

sub change_arrow_direction
{
my ($self) = @_ ;

my @selection = $self->get_selected_elements(1) ;
my @arrows ;

if (1 == @selection && ref $selection[0] eq 'App::Asciio::stripes::editable_box2')
	{
	my @connections = $self->get_connections_containing(@selection) ;
	@arrows = $connections[0]{CONNECTED} if 1 == @connections ;
	}

push @arrows, grep {ref $_ eq 'App::Asciio::stripes::angled_arrow'} @selection ;
push @arrows, grep {ref $_ eq 'App::Asciio::stripes::section_wirl_arrow'} @selection  ;

for (@arrows)
	{
	$self->create_undo_snapshot() ;
	
	$_->change_direction() if ref $_ eq 'App::Asciio::stripes::angled_arrow' ;
	
	$_->change_section_direction($self->{MOUSE_X} - $_->{X}, $self->{MOUSE_Y} - $_->{Y})
		if ref $_ eq 'App::Asciio::stripes::section_wirl_arrow'  ;
	}

$self->update_display() if @arrows ;
}

#----------------------------------------------------------------------------------------------

sub flip_arrow_ends
{
my ($self) = @_ ;
my $changes_made = 0 ;

my %reverse_direction = 
	(
	'up', => 'down',
	'right' => 'left',
	'down' => 'up',
	'left' => 'right'
	) ;

for
	(
	grep 
		{
		my @connectors = $_->get_connector_points() ; 
		
		ref $_ eq 'App::Asciio::stripes::section_wirl_arrow'
		&& $_->get_number_of_sections() == 1
		&& @connectors > 0 ;
		} $self->get_selected_elements(1)
	)
	{
	$self->create_undo_snapshot() unless $changes_made++ ;
	
	my $new_direction = $_->get_section_direction(0) ;
	
	if($new_direction =~ /(.*)-(.*)/)
		{
		my ($start_direction, $end_direction) = ($1, $2) ;
		$new_direction = $reverse_direction{$end_direction} . '-' . $reverse_direction{$start_direction} ;
		}
	else
		{
		$new_direction = $reverse_direction{$new_direction} ;
		}
	
	my ($start_connector, $end_connector) = $_->get_connector_points() ;
	my $arrow = new App::Asciio::stripes::section_wirl_arrow
					({
					%{$_},
					POINTS => [ [ - $end_connector->{X}, - $end_connector->{Y}, $new_direction, ] ],
					DIRECTION => $new_direction,
					}) ;
	
	$self->add_element_at($arrow, $_->{X} + $end_connector->{X}, $_->{Y} + $end_connector->{Y}) ;
	$self->delete_elements($_) ;
	$self->select_elements(1, $arrow) ;
	}

$self->update_display() if $changes_made ;
}

#----------------------------------------------------------------------------------------------

sub move_arrow_start
{
my ($self, $direction) = @_ ;

$self->create_undo_snapshot() ;

for (grep {ref $_ eq 'App::Asciio::stripes::section_wirl_arrow'} $self->get_selected_elements(1))
	{
	$_->{X} += $direction->[0] ;
	$_->{Y} += $direction->[1] ;
	
	if($self->is_connected($_))
		{
		# disconnect current connections
		$self->delete_connections_containing($_) ;
		}
	
	for my $section (1 .. $_->get_number_of_sections())
		{
		my $last_section = $section - 1 ;
		$_->move_connector("endsection_$last_section", -$direction->[0], -$direction->[1]) ;
		}
	
	$self->connect_elements($_, @{$self->{ELEMENTS}}) ;
	# $self->call_hook('CANONIZE_CONNECTIONS', $self->{CONNECTIONS}, $self->get_character_size()) ;
	}

for (grep {ref $_ eq 'App::Asciio::stripes::angled_arrow'} $self->get_selected_elements(1))
	{
	$_->{X} += $direction->[0] ;
	$_->{Y} += $direction->[1] ;
	
	$_->setup($_->{ARROW_TYPE}, $_->{END_X} - $direction->[0], $_->{END_Y} - $direction->[1], $_->{DIRECTION}, $_->{EDITABLE}) ;
	
	$self->connect_elements($_, @{$self->{ELEMENTS}}) ;
	$self->call_hook('CANONIZE_CONNECTIONS', $self->{CONNECTIONS}, $self->get_character_size()) ;
	}

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub move_arrow_end
{
my ($self, $direction) = @_ ;

$self->create_undo_snapshot() ;

for (grep {ref $_ eq 'App::Asciio::stripes::section_wirl_arrow'} $self->get_selected_elements(1))
	{
	if($self->is_connected($_))
		{
		# disconnect current connections
		$self->delete_connections_containing($_) ;
		}
	
	my $last_section = $_->get_number_of_sections() - 1 ;
	$_->move_connector("endsection_$last_section", $direction->[0], $direction->[1]) ;
	
	$self->connect_elements($_, @{$self->{ELEMENTS}}) ;
	# $self->call_hook('CANONIZE_CONNECTIONS', $self->{CONNECTIONS}, $self->get_character_size()) ;
	}

for (grep {ref $_ eq 'App::Asciio::stripes::angled_arrow'} $self->get_selected_elements(1))
	{
	$_->setup($_->{ARROW_TYPE}, $_->{END_X} + $direction->[0], $_->{END_Y} + $direction->[1], $_->{DIRECTION}, $_->{EDITABLE}) ;
	
	$self->connect_elements($_) ;
	$self->call_hook('CANONIZE_CONNECTIONS', $self->{CONNECTIONS}, $self->get_character_size()) ;
	}

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub interactive_to_mouse
{
my ($self, $event) = @_ ;

App::Asciio::Actions::Mouse::mouse_motion($self, $event) ;

my @selected_elements = $self->get_selected_elements(1) ;

if(1 == @selected_elements)
	{
	for (grep {ref $_ eq 'App::Asciio::stripes::section_wirl_arrow'} @selected_elements)
		{
		App::Asciio::Actions::Multiwirl::move_last_section_to($self, $_, $self->{MOUSE_X}, $self->{MOUSE_Y}) ;
		$self->update_display() ;
		}
	
	for (grep {ref $_ eq 'App::Asciio::stripes::angled_arrow'} @selected_elements)
		{
		$_->setup($_->{ARROW_TYPE}, $self->{MOUSE_X} - $_->{X}, $self->{MOUSE_Y} - $_->{Y}, $_->{DIRECTION}, $_->{EDITABLE}) ;
		
		$self->connect_elements($_) ;
		$self->call_hook('CANONIZE_CONNECTIONS', $self->{CONNECTIONS}, $self->get_character_size()) ;
		
		$self->update_display() ;
		}
	}
}

#----------------------------------------------------------------------------------------------

1 ;

