package App::Asciio::Actions::ElementsManipulation ;

use strict ; use warnings ;

use App::Asciio::stripes::group ;
use Scalar::Util ;


#----------------------------------------------------------------------------------------------

sub edit_selected_element
{
my ($self, $alternate_mode) = @_ ;

my @selected_elements = $self->get_selected_elements(1) ;

if(@selected_elements == 1)
	{
	$self->{EDIT_TEXT_INLINE} ^= 1 if $alternate_mode ;
	
	$self->create_undo_snapshot() ;
	$self->edit_element($selected_elements[0]) ;
	
	# In gtk3's minimalist input mode, mouse clicks will cause elements to move, 
	# and this phenomenon is prevented by consuming semaphores
	$self->{EDIT_SEMAPHORE} = 3 if((defined $self->{EDIT_TEXT_INLINE}) && ($self->{EDIT_TEXT_INLINE} != 0)) ;
	
	$self->{EDIT_TEXT_INLINE} ^= 1 if $alternate_mode ;
	
	$self->update_display();
	}
}

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

$self->create_undo_snapshot() ;
$self->move_elements(-$offset, 0, $self->get_selected_elements(1)) ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub move_selection_right
{
my ($self, $offset) = @_ ;

$offset = 1 unless defined $offset ;

$self->create_undo_snapshot() ;
$self->move_elements($offset, 0, $self->get_selected_elements(1)) ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub move_selection_up
{
my ($self, $offset) = @_ ;

$offset = 1 unless defined $offset ;

$self->create_undo_snapshot() ;
$self->move_elements(0, -$offset, $self->get_selected_elements(1)) ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub move_selection_down
{
my ($self, $offset) = @_ ;

$offset = 1 unless defined $offset ;

$self->create_undo_snapshot() ;
$self->move_elements(0, $offset, $self->get_selected_elements(1)) ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub shrink_box
{
my ($self) = @_ ;

my @selected_elements = $self->get_selected_elements(1)  ;

if(@selected_elements)
	{
	$self->create_undo_snapshot() ;
	
	for my $element (@selected_elements)
		{
		$element->shrink() if $element->isa('App::Asciio::stripes::editable_box2') ;
		}
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
	
	my $group = {GROUP_COLOR => $self->get_group_color()} ;
	for my $element (@selected_elements)
		{
		push @{$element->{GROUP}}, $group  ;
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
my ($self) = @_ ;

$self->create_undo_snapshot() ;

create_stripes_group_from_selected_elements(@_) ;

$self->update_display();
}

sub create_stripes_group_from_selected_elements
{
my ($self, $as_one_stripe, $no_group_insertion) = @_ ;

my $strip_group ;

my @selected_elements = $self->get_selected_elements(1) ;

if(@selected_elements >= 1)
	{
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
	
	delete $_->{CACHE}{RENDERING} for @selected_elements ;
	
	($strip_group, my $ex, my $ey) = App::Asciio::stripes::group->new(\@selected_elements, \@connections, $as_one_stripe, $self) ;
	
	@$strip_group{'X', 'Y', 'SELECTED'} = ($ex, $ey, 1) ;
	
	unless ($no_group_insertion)
		{
		$self->add_elements($strip_group) ;
		$self->delete_elements(@selected_elements) ;
		}
	}

return $strip_group ;
}

#----------------------------------------------------------------------------------------------

sub ungroup_stripes_group
{
my ($self, $stripes_group) = @_ ;

my @selected_elements = $stripes_group // $self->get_selected_elements(1) ;

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

