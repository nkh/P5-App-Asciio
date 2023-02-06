package App::Asciio::Actions::ElementsManipulation ;

use App::Asciio::stripes::group ;

#----------------------------------------------------------------------------------------------

sub edit_selected_element
{
my ($self) = @_ ;

my @selected_elements = $self->get_selected_elements(1) ;

if(@selected_elements == 1)
	{
	$self->create_undo_snapshot() ;
	$self->edit_element($selected_elements[0]) ;
	
	delete $selected_elements[0]{CACHE}{RENDERING} ;
	
	$self->update_display();
	}
}

#----------------------------------------------------------------------------------------------

sub change_arrow_direction
{
my ($self) = @_ ;

$self->create_undo_snapshot() ;
my $changes_made = 0 ;

# App::Asciio::stripes::section_wirl_arrow
my @elements_to_redirect =  grep {ref $_ eq 'App::Asciio::stripes::section_wirl_arrow'} $self->get_selected_elements(1) ;

if(@elements_to_redirect)
	{
	$changes_made++ ;
	for (@elements_to_redirect)
		{
		$_->change_section_direction($self->{MOUSE_X} - $_->{X}, $self->{MOUSE_Y} - $_->{Y}) ;
		}
	}


# App::Asciio::stripes::angled_arrow
@elements_to_redirect =  grep {ref $_ eq 'App::Asciio::stripes::angled_arrow'} $self->get_selected_elements(1) ;

if(@elements_to_redirect)
	{
	$changes_made++ ;
	for (@elements_to_redirect)
		{
		$_->change_direction() ;
		}
	}

# all
if($changes_made)
	{
	$self->update_display()  ;
	}
else
	{
	$self->pop_undo_buffer(1) ;
	}
}

#----------------------------------------------------------------------------------------------

sub flip_arrow_ends
{
my ($self) = @_ ;

my @elements_to_flip =  
	grep 
		{
		my @connectors = $_->get_connector_points() ; 
		
		      ref $_ eq 'App::Asciio::stripes::section_wirl_arrow'
		&& $_->get_number_of_sections() == 1
		&& @connectors > 0 ;
		} $self->get_selected_elements(1) ;

if(@elements_to_flip)
	{
	$self->create_undo_snapshot() ;
	
	my %reverse_direction = 
		(
		'up', => 'down',
		'right' => 'left',
		'down' => 'up',
		'left' => 'right'
		) ;
		
	for (@elements_to_flip)
		{
		# create one with ends swapped
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
						POINTS => 
							[
								[
								- $end_connector->{X},
								- $end_connector->{Y},
								$new_direction,
								]
							],
						DIRECTION => $new_direction,
						}) ;
		
		#add new element, connects automatically
		$self->add_element_at($arrow, $_->{X} + $end_connector->{X}, $_->{Y} + $end_connector->{Y}) ;
		
		# remove element
		$self->delete_elements($_) ;
		
		# keep the element selected
		$self->select_elements(1, $arrow) ;
		}
	
	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

sub select_element_direction
{
my ($self, $direction_and_mouse) = @_ ;
my ($direction, $move_mouse) = @{$direction_and_mouse} ;

return unless exists $self->{ELEMENTS}[0] ;

$self->create_undo_snapshot() ;

my @selected_elements = $self->get_selected_elements(1) ;

my @elements = $direction ? @{$self->{ELEMENTS}} : reverse @{$self->{ELEMENTS}} ;
my $next_element = $direction ? $self->{ELEMENTS}[0] : $self->{ELEMENTS}[-1] ;
my $last_selectable_element = $direction ? $selected_elements[-1] : $selected_elements[0] ;

if(@selected_elements)
	{
	my $seen_selected ;
	
	for my $element (@elements) 
		{
		if(! $self->is_element_selected($element) && $seen_selected)
			{
			$next_element = $element ; last ;
			}
		
		$seen_selected = $element == $last_selectable_element ;
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

my $id = $self->display_edit_dialog('element id', '') ;

return unless exists $self->{ELEMENTS}[$id - 1] ;

$self->create_undo_snapshot() ;

$self->select_elements_flip($self->{ELEMENTS}[$id - 1]) ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub select_all_elements
{
my ($self) = @_ ;

$self->select_all_elements() ;
$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub select_connected
{
my ($self) = @_ ;

my %selected_elements = map { $_ => 1 } $self->get_selected_elements(1) ;

my (@selected_elements_connected, %selected_elements_connected, @not_connected_to_selected_element) ;

for my $connection (@{$self->{CONNECTIONS}})
	{
	if(exists $selected_elements{$connection->{CONNECTEE}})
		{
		push @selected_elements_connected, $connection->{CONNECTED} ;
		$selected_elements_connected{$connection->{CONNECTED}}++ ;
		}
	else
		{
		push @not_connected_to_selected_element, $connection ;
		}
	}

$self->select_elements(1, @selected_elements_connected) ;
$self->select_elements(1, map { $_->{CONNECTEE} } grep { exists $selected_elements_connected{$_->{CONNECTED}} } @not_connected_to_selected_element) ;

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

sub delete_selected_elements
{
my ($self) = @_ ;

$self->create_undo_snapshot() ;

$self->delete_elements($self->get_selected_elements(1)) ;
$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub move_selection_left
{
my ($self, $offset) = @_ ;

$offset = 1 unless defined $offset ;

if($self->{MOUSE_TOGGLE})
	{
	if($self->{MOUSE_X} >= $offset)
		{
		$self->{MOUSE_X} -= $offset ;
		$self->{SELECTION_RECTANGLE}{START_X} = $self->{MOUSE_X} ;
		$self->{SELECTION_RECTANGLE}{END_X} = $self->{MOUSE_X} ;
		$self->{SELECTION_RECTANGLE}{START_Y} = $self->{MOUSE_Y} ;
		$self->{SELECTION_RECTANGLE}{END_Y} = $self->{MOUSE_Y} ;
		$self->{DRAGGING} = '' ;
		$self->{PREVIOUS_X} = $self->{MOUSE_X} ;
		$self->{PREVIOUS_Y} = $self->{MOUSE_Y} ;
		}
	}
else
	{
	$self->create_undo_snapshot() ;
	$self->move_elements(-$offset, 0, $self->get_selected_elements(1)) ;
	}

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub move_selection_right
{
my ($self, $offset) = @_ ;

$offset = 1 unless defined $offset ;

if($self->{MOUSE_TOGGLE})
	{
	if($self->{MOUSE_X} < 300)
		{
		$self->{MOUSE_X} += $offset ;
		$self->{SELECTION_RECTANGLE}{START_X} = $self->{MOUSE_X} ;
		$self->{SELECTION_RECTANGLE}{END_X} = $self->{MOUSE_X} ;
		$self->{SELECTION_RECTANGLE}{START_Y} = $self->{MOUSE_Y} ;
		$self->{SELECTION_RECTANGLE}{END_Y} = $self->{MOUSE_Y} ;
		$self->{PREVIOUS_X} = $self->{MOUSE_X} ;
		$self->{PREVIOUS_Y} = $self->{MOUSE_Y} ;
		}
	}
else
	{
	$self->create_undo_snapshot() ;
	$self->move_elements($offset, 0, $self->get_selected_elements(1)) ;
	}

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub move_selection_up
{
my ($self, $offset) = @_ ;

$offset = 1 unless defined $offset ;

if($self->{MOUSE_TOGGLE})
	{
	if($self->{MOUSE_Y} >= $offset)
		{
		$self->{MOUSE_Y} -= $offset ;
		$self->{SELECTION_RECTANGLE}{START_X} = $self->{MOUSE_X} ;
		$self->{SELECTION_RECTANGLE}{END_X} = $self->{MOUSE_X} ;
		$self->{SELECTION_RECTANGLE}{START_Y} = $self->{MOUSE_Y} ;
		$self->{SELECTION_RECTANGLE}{END_Y} = $self->{MOUSE_Y} ;
		$self->{DRAGGING} = '' ;
		$self->{PREVIOUS_X} = $self->{MOUSE_X} ;
		$self->{PREVIOUS_Y} = $self->{MOUSE_Y} ;
		}
	}
else
	{
	$self->create_undo_snapshot() ;
	$self->move_elements(0, -$offset, $self->get_selected_elements(1)) ;
	}

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub move_selection_down
{
my ($self, $offset) = @_ ;

$offset = 1 unless defined $offset ;

if($self->{MOUSE_TOGGLE})
	{
	if($self->{MOUSE_Y} < 200)
		{
		$self->{MOUSE_Y} += $offset ;
		$self->{SELECTION_RECTANGLE}{START_X} = $self->{MOUSE_X} ;
		$self->{SELECTION_RECTANGLE}{END_X} = $self->{MOUSE_X} ;
		$self->{SELECTION_RECTANGLE}{START_Y} = $self->{MOUSE_Y} ;
		$self->{SELECTION_RECTANGLE}{END_Y} = $self->{MOUSE_Y} ;
		$self->{DRAGGING} = '' ;
		$self->{PREVIOUS_X} = $self->{MOUSE_X} ;
		$self->{PREVIOUS_Y} = $self->{MOUSE_Y} ;
		}
	}
else
	{
	$self->create_undo_snapshot() ;
	$self->move_elements(0, $offset, $self->get_selected_elements(1)) ;
	}

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub group_selected_elements
{
my ($self) = @_ ;

my @selected_elements = $self->get_selected_elements(1)  ;

if(@selected_elements >= 2)
	{
	$self->create_undo_snapshot() ;
	
	my $group = {'GROUP_COLOR' => $self->get_group_color()} ;
	for my $element (@selected_elements)
		{
		push @{$element->{'GROUP'}}, $group  ;
		}
	}
	
$self->update_display() ;
}


#----------------------------------------------------------------------------------------------

sub ungroup_selected_elements
{
my ($self) = @_ ;

my @selected_elements = $self->get_selected_elements(1)  ;

for my $grouped (grep {exists $_->{GROUP} } @selected_elements)
	{
	pop @{$grouped->{GROUP}} ;
	}

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub move_selected_elements_to_front
{
my ($self) = @_ ;

my @selected_elements = $self->get_selected_elements(1)  ;

if(@selected_elements)
	{
	$self->create_undo_snapshot() ;
	$self->move_elements_to_front(@selected_elements) ;
	}
	
$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub move_selected_elements_to_back
{
my ($self) = @_ ;

my @selected_elements = $self->get_selected_elements(1)  ;

if(@selected_elements)
	{
	$self->create_undo_snapshot() ;
	$self->move_elements_to_back(@selected_elements) ;
	}
	
$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub temporary_move_selected_element_to_front
{
my ($self) = @_ ;

if(defined $self->{ACTIONS_STORAGE}{temporary_move_selected_element_to_front})
	{
	my ($element, $position)  = @{$self->{ACTIONS_STORAGE}{temporary_move_selected_element_to_front}} ;
	
	my $current_position = 0 ;
	for (@{$self->{ELEMENTS}})
		{
		if($element == $_)
			{
			$self->create_undo_snapshot() ;
			
			splice @{$self->{ELEMENTS}}, $current_position, 1 ;
			splice @{$self->{ELEMENTS}}, $position, 0, $element ;
	
			$self->update_display() ;
			last ;
			}
			
		$current_position++ ;
		}
		
	delete $self->{ACTIONS_STORAGE}{temporary_move_selected_element_to_front} ;
	}
else
	{
	my @selected_elements = $self->get_selected_elements(1)  ;
	
	if(@selected_elements == 1 )
		{
		$self->create_undo_snapshot() ;
		
		my $selected_element = $selected_elements[0] ;
		
		my $position = 0 ;
		for (@{$self->{ELEMENTS}})
			{
			last if $selected_element == $_ ;
			$position++ ;
			}
		
		$self->move_elements_to_front($selected_element) ;
		$self->{ACTIONS_STORAGE}{temporary_move_selected_element_to_front} = 
			[$selected_element, $position] ;
			
		$self->update_display() ;
		}
	}
}

#-----------------------------------------------------------------------------

sub resize_element_offset
{
my ($self, $offsets) = @_ ;

my ($x_offset, $y_offset) = @$offsets ;

if($x_offset != 0 || $y_offset != 0)
	{
	for my $selected_element ($self->get_selected_elements(1))
		{
		$self->{RESIZE_CONNECTOR_NAME} =
			$self->resize_element
					(
					-1, - 1,
					$x_offset, $y_offset,
					$selected_element,
					$self->{RESIZE_CONNECTOR_NAME},
					) ;
		}
	
	$self->update_display();
	}
}

#----------------------------------------------------------------------------------------------

sub create_stripes_group
{
my ($self, $as_one_stripe) = @_ ;

my @selected_elements = $self->get_selected_elements(1) ;

if(@selected_elements > 1)
	{
	$self->create_undo_snapshot() ;
	
	my @connections ;
	
	my %selected_elements = map { $_ => 1 } $self->get_selected_elements(1) ;
	
	my @selected_elements_connected ;
	
	for my $connection (@{$self->{CONNECTIONS}})
		{
		if(exists $selected_elements{$connection->{CONNECTEE}})
			{
			push @selected_elements_connected, $connection->{CONNECTED} ;
			push @connections, $connection
			}
		}
	
	$self->select_elements(1, @selected_elements_connected) ;
	
	@selected_elements = $self->get_selected_elements(1) ;
	
	my ($new_element, $ex, $ey) = App::Asciio::stripes::group->new(\@selected_elements, \@connections, $as_one_stripe) ;
	
	@$new_element{'X', 'Y', 'SELECTED'} = ($ex, $ey, 1) ;
	$self->add_elements($new_element) ;
	
	$self->delete_elements(@selected_elements) ;
	}

$self->update_display();
}

#----------------------------------------------------------------------------------------------

sub ungroup_stripes_group
{
my ($self) = @_ ;

my @selected_elements = $self->get_selected_elements(1) ;

if(@selected_elements == 1 && ref $selected_elements[0] eq 'App::Asciio::stripes::group')
	{
	my $group = $selected_elements[0] ;
	my $elements = $group->{ELEMENTS} ;
	my $connections = $group->{CONNECTIONS} ;
	
	my $x_offset = $group->{X} - $group->{EX} ;
	my $y_offset = $group->{Y} - $group->{EY} ;
	
	for my $element (@$elements)
		{
		@$element{'X', 'Y'} = ($element->{X} + $x_offset, $element->{Y} + $y_offset) ;
		}
	
	$self->add_elements(@{$elements}) ;
	push @{$self->{CONNECTIONS}}, @{$connections} ;
	
	delete $group->{CACHE} ;
	$self->delete_elements($group) ;
	
	$self->update_display();
	}
}

#----------------------------------------------------------------------------------------------

1 ;

