
package App::Asciio::Actions::ElementSelection ;

use strict ; use warnings ;

#----------------------------------------------------------------------------------------------

sub select_element_direction
{
my ($self, $direction_mouse_box) = @_ ;
my ($direction, $move_mouse, $box_only) = @{$direction_mouse_box} ;

return unless exists $self->{ELEMENTS}[0] ;

$self->create_undo_snapshot() ;

my @selected_elements = $self->get_selected_elements(1) ;

my @elements = $direction ? (@{$self->{ELEMENTS}}, @{$self->{ELEMENTS}}) : reverse (@{$self->{ELEMENTS}}, @{$self->{ELEMENTS}}) ;
my $next_element = $direction ? $self->{ELEMENTS}[0] : $self->{ELEMENTS}[-1] ;

if(@selected_elements)
	{
	my $seen_selected ;
	
	for my $element (@elements) 
		{
		my $is_selected = $self->is_element_selected($element) ;
		if($seen_selected && !$is_selected)
			{
			if($box_only == 1)
				{
				if(ref($element) !~ /arrow/)
					{
					$next_element = $element ; last ;
					}
				}
			elsif($box_only == 2)
				{
				if(ref($element) =~ /arrow/)
					{
					$next_element = $element ; last ;
					}
				}
			else
				{
				$next_element = $element ; last ;
				}
			}
		
		$seen_selected++ if $is_selected ;
		}
	}

$self->deselect_all_elements() ;
$self->select_elements(1, $next_element) ;
@$self{'MOUSE_X', 'MOUSE_Y', 'PREVIOUS_X', 'PREVIOUS_Y'} = map { @$next_element{'X', 'Y'} } 1 .. 2 if $move_mouse ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub select_element_by_id
{
my ($self) = @_ ;
my $id = $self->display_edit_dialog('element id', '', $self) ;

if(exists $self->{ELEMENTS}[$id - 1])
	{
	$self->create_undo_snapshot() ;
	$self->select_elements_flip($self->{ELEMENTS}[$id - 1]) ;
	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

sub select_all_elements
{
my ($self) = @_ ;

$self->select_all_elements() ;
$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub deselect_all_elements
{
my ($self) = @_ ;

$self->deselect_all_elements() ;

$self->{SELECTION_RECTANGLE}{START_X} = $self->{MOUSE_X} ;
$self->{SELECTION_RECTANGLE}{END_X} = $self->{MOUSE_X} ;
$self->{SELECTION_RECTANGLE}{START_Y} = $self->{MOUSE_Y} ;
$self->{SELECTION_RECTANGLE}{END_Y} = $self->{MOUSE_Y} ;
$self->{DRAGGING} = '' ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub select_all_elements_by_words
{
my ($self) = @_ ;

$self->deselect_all_elements();

$self->select_all_elements_by_search_words();

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub select_all_elements_by_words_no_group
{
my ($self) = @_ ;

$self->deselect_all_elements();

$self->select_all_elements_by_search_words_ignore_group();

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub select_successors    { select_filtered($_[0], $_[1] // 0, sub { $_[0]{CONNECTOR}{NAME} =~ /^start/ }) ; }
sub select_predecessors  { select_filtered($_[0], $_[1] // 0, sub { $_[0]{CONNECTOR}{NAME} =~ /^end/ }) ; }
sub select_neighbors     { select_filtered($_[0], $_[1] // 0, sub { 1 }) ; }

sub select_descendants   { select_recusrsive($_[0], \&select_successors) ; }
sub select_ancestors     { select_recusrsive($_[0], \&select_predecessors) ; }
sub select_reachable     { select_descendants($_[0]) ; select_ancestors($_[0]) ; }
sub select_all_connected { select_recusrsive($_[0], \&select_neighbors) ; }

#----------------------------------------------------------------------------------------------

sub select_filtered
{
# CONNECTED  => an arrow
# CONNECTOR  => name of the arrow connector: start or end
# CONNECTEE  => element the arrow is connected to
# CONNECTION => the element's connection that the arrow's connector is connected to, name, position, ...

my ($self, $no_undo_snapshot, $filter) = @_ ;

$self->create_undo_snapshot() unless $no_undo_snapshot ;

my %selected_elements = map { $_ => 1 } $self->get_selected_elements(1) ;

my (@arrows_to_select, %connected_arrows) ;

for my $connection ($self->{CONNECTIONS}->@*)
	{
	if
		(
			(
			   exists $selected_elements{$connection->{CONNECTEE}} # is it a connection to a selected box/element
			|| exists $selected_elements{$connection->{CONNECTED}} # is the arrow itself selected
			)
			&& $filter->($connection)
		)
		{
		# add the arrow connected to the selected element to list of arrows to select
		push @arrows_to_select, $connection->{CONNECTED} ;
		
		# remember the arrow to check if another connection uses the same arrow
		$connected_arrows{$connection->{CONNECTED}}++ ;
		}
	}

$self->select_elements
	(
	1,
	@arrows_to_select,
	map { $_->{CONNECTEE} } # select the element that this arrow connects to
		grep { exists $connected_arrows{$_->{CONNECTED}} } # is connection arrow connected to selected element 
			$self->{CONNECTIONS}->@*
	) ;

$self->update_display() ;
}

sub select_recusrsive
{
my ($self, $selector) = @_ ;

$self->create_undo_snapshot() ;

my ($before_selection, $after_selection) ;
do
	{
	$before_selection = scalar($self->get_selected_elements(1)) ;
	
	$selector->($self, 1) ; # no undo snapshot as we've done it above 
	
	$after_selection = scalar($self->get_selected_elements(1)) ;
	
	} while $before_selection != $after_selection ;
}


#----------------------------------------------------------------------------------------------
1 ;
