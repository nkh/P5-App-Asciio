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
	
	$self->{EDIT_TEXT_INLINE} ^= 1 if $alternate_mode ;
	
	$self->update_display();
	}
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
	
	for (@selected_elements)
		{
		if( ref($_) =~ /arrow/)
			{
			push @{$_->{GROUP}}, $group  if scalar($self->get_connections_containing($_)) == 2 ;
			}
		else
			{
			push @{$_->{GROUP}}, $group  ;
			}
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

sub move_temporary_back
{
my ($self) = @_ ;

if(defined $self->{ACTIONS_STORAGE}{temporary_move_selected_element_to_front}[0])
	{
	my ($element, $position)  = @{$self->{ACTIONS_STORAGE}{temporary_move_selected_element_to_front}} ;
	
	my $current_position = 0 ;
	for (@{$self->{ELEMENTS}})
		{
		if($element == $_)
			{
			splice @{$self->{ELEMENTS}}, $current_position, 1 ;
			splice @{$self->{ELEMENTS}}, $position, 0, $element ;
			last ;
			}
			
		$current_position++ ;
		}
		
	delete $self->{ACTIONS_STORAGE}{temporary_move_selected_element_to_front} ;
	}
}

#----------------------------------------------------------------------------------------------

sub temporary_move_element_to_front
{
my ($self, $element) = @_ ;

return unless defined $element ;

move_temporary_back($self) ;

my $position = 0 ;
for (@{$self->{ELEMENTS}})
	{
	last if $element == $_ ;
	$position++ ;
	}

$self->move_elements_to_front($element) ;
$self->{ACTIONS_STORAGE}{temporary_move_selected_element_to_front} = [$element, $position] ;
}

#----------------------------------------------------------------------------------------------

sub temporary_move_selected_element_to_front
{
my ($self) = @_ ;

$self->create_undo_snapshot() ;

if(defined $self->{ACTIONS_STORAGE}{temporary_move_selected_element_to_front}[0])
	{
	move_temporary_back($self) ;
	}
else
	{
	my @selected_elements = $self->get_selected_elements(1)  ;
	
	temporary_move_element_to_front($self, $selected_elements[0]) if @selected_elements == 1  ;
	}

$self->update_display() ;
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

my @selected_elements = grep { defined $_ && !($_->is_background_element) } $self->get_selected_elements(1) ;

if(@selected_elements >= 1)
	{
	my @connections ;
	
	my %selected_elements = map { $_ => 1 } @selected_elements ;
	
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
	
	delete $_->{CACHE}{RENDERING} for @selected_elements ;
	
	($strip_group, my $ex, my $ey) = App::Asciio::stripes::group->new
							(
							\@selected_elements, \@connections, $as_one_stripe,
							$self->get_color('element_background'), $self->get_color('element_foreground')
							) ;
	
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

sub set_elements_crossover
{
my ($self, $enable) = @_ ;

my @selected_elements = $self->get_selected_elements(1) ;

if(@selected_elements >= 1)
	{
	$self->create_undo_snapshot() ;
	for(@selected_elements)
		{
		$_->enable_crossover($enable) ;
		}
	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

1 ;

