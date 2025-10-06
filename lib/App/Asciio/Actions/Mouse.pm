
package App::Asciio::Actions::Mouse ;

#----------------------------------------------------------------------------------------------

use List::MoreUtils qw(any minmax first_value) ;
use Readonly ;

use App::Asciio::stripes::section_wirl_arrow ;

Readonly my $PREFERED_DIRECTION => 'right-down' ; # or 'down-right' ;

#----------------------------------------------------------------------------------------------

sub toggle_mouse
{
my ($self) = @_;

$self->{MOUSE_TOGGLE} ^= 1 ;
$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub mouse_left_release
{
my ($self) = @_;

if((defined $self->{EDIT_SEMAPHORE}) && ($self->{EDIT_SEMAPHORE} > 0))
   {
   $self->{EDIT_SEMAPHORE}--;
   return ;
   }

undef $self->{DRAGGING} ;
delete $self->{IN_DRAG_DROP} ;

$self->pop_undo_buffer(1) if defined $self->{MODIFIED_INDEX} && defined $self->{MODIFIED} && $self->{MODIFIED_INDEX} == $self->{MODIFIED} ;
$self->update_display();
}

#----------------------------------------------------------------------------------------------

sub mouse_move
{
my ($self, $offsets) = @_;
my ($x_offset, $y_offset) = @{$offsets} ;

($self->{PREVIOUS_X}, $self->{PREVIOUS_Y}) = ($self->{MOUSE_X}, $self->{MOUSE_Y}) ;

$self->{MOUSE_X} += $x_offset ;
$self->{MOUSE_Y} += $y_offset ;

($self->{SELECTION_RECTANGLE}{START_X}, $self->{SELECTION_RECTANGLE}{START_Y}) = ($self->{MOUSE_X}, $self->{MOUSE_Y}) ;
($self->{SELECTION_RECTANGLE}{END_X},   $self->{SELECTION_RECTANGLE}{END_Y})   = ($self->{MOUSE_X}, $self->{MOUSE_Y}) ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub mouse_left_click
{
my ($self) = @_;

return if $self->{IN_DRAG_DROP} ;

my ($x, $y) = @{$self}{'MOUSE_X', 'MOUSE_Y'} ;

my ($first_element) = first_value {$self->is_over_element($_, $x, $y)} reverse @{$self->{ELEMENTS}} ;

if(defined $first_element)
	{
	unless($self->is_element_selected($first_element))
		{
		# make the element under cursor the only selected element
		$self->deselect_all_elements() ;
		$self->select_elements(1, $first_element) ;
		}
	}
else
	{
	$self->deselect_all_elements()  ;
	}

$self->{SELECTION_RECTANGLE} = {START_X => $x , START_Y => $y} ;

$self->update_display();
}

#----------------------------------------------------------------------------------------------

sub expand_selection
{
my ($self) = @_ ;

# shift left click should expand the selected elements
}

#----------------------------------------------------------------------------------------------

sub mouse_duplicate_element
{
my ($self) = @_ ;
my ($x, $y) = @{$self}{'MOUSE_X', 'MOUSE_Y'} ;

my ($first_element) = first_value {$self->is_over_element($_, $x, $y)} reverse @{$self->{ELEMENTS}} ;

$self->select_elements(1, $first_element) if defined $first_element ;

$self->run_actions_by_name('Copy to clipboard', ['Insert from clipboard', 0, 0])  ;
}


#----------------------------------------------------------------------------------------------

sub mouse_element_selection_flip
{
my ($self) = @_ ;
my ($x, $y) = @{$self}{'MOUSE_X', 'MOUSE_Y'} ;

my ($first_element) = first_value {$self->is_over_element($_, $x, $y)} reverse @{$self->{ELEMENTS}} ;

if(defined $first_element)
	{
	$self->create_undo_snapshot() ;
	$self->select_elements_flip($first_element)
	}

$self->{SELECTION_RECTANGLE} = {START_X => $x , START_Y => $y} ;
$self->update_display();
}

#----------------------------------------------------------------------------------------------

sub quick_link
{
my ($self) = @_ ;
my ($x, $y) = @{$self}{'MOUSE_X', 'MOUSE_Y'} ;

$self->create_undo_snapshot() ;

my ($destination_element) = first_value {$self->is_over_element($_, $x, $y)} reverse @{$self->{ELEMENTS}} ;

if($destination_element)
	{
	connect_to_destination_element($self, $destination_element, $x, $y) ;
	}
else
	{
	my $new_box = $self->add_new_element_named('Asciio/box', $x, $y) ;
	
	connect_to_destination_element($self, $new_box, $x, $y) ;
	}
}

#----------------------------------------------------------------------------------------------

sub connect_to_destination_element
{
my ($self, $destination_element, $x, $y) = @_ ;

my @destination_connections = grep {$_->{NAME} ne 'resize'} $destination_element->get_connection_points() ;

if(@destination_connections)
	{
	my @selected_elements = grep {$_ != $destination_element} $self->get_selected_elements(1) ;
	my $destination_connection = $destination_connections[0] ;
	
	if(@selected_elements)
		{
		$self->deselect_all_elements() ;
		
		for my $element (@selected_elements)
			{
			# link $element to $destination_element
			my @source_connections = grep {$_->{NAME} ne 'resize'} $element->get_connection_points() ;
			
			if(@source_connections)
				{
				connect_from_box($self,  $element, $source_connections[0], $destination_element, $destination_connection) ;
				}
			else
				{
				connect_from_arrow($self,  $element, $destination_element, $destination_connection) ;
				}
			}
		
		$self->select_elements(1, @selected_elements) ;
		}
	else
		{
		$self->select_elements(1, $destination_element) ;
		}
	
	$self->update_display() ; # will also canonize the connections
	}
}

#----------------------------------------------------------------------------------------------

sub connect_from_box
{
my ($self,  $element, $source_connection, $destination_element, $destination_connection) = @_ ;

my $wirl_arrow = new App::Asciio::stripes::section_wirl_arrow
					({
					POINTS => 
					[
						[
						($destination_element->{X} + $destination_connection->{X})
						 - ($element->{X} + $source_connection->{X}),
								
						($destination_element->{Y} + $destination_connection->{Y})
						- ($element->{Y} + $source_connection->{Y}),
						
						$PREFERED_DIRECTION,
						],
					],		 
					DIRECTION => $PREFERED_DIRECTION,
					ALLOW_DIAGONAL_LINES => 0,
					EDITABLE => 1,
					RESIZABLE => 1,
					}) ;

$self->add_element_at_no_connection
		(
		$wirl_arrow, 
		$element->{X} + $source_connection->{X},
		$element->{Y} + $source_connection->{Y},
		) ;

$self->add_connections
	({
	CONNECTED => $wirl_arrow,
	CONNECTOR => $wirl_arrow->get_named_connection('startsection_0'),
	CONNECTEE => $element,
	CONNECTION => $source_connection,
	}) ;

$self->add_connections
	({
	CONNECTED => $wirl_arrow,
	CONNECTOR => $wirl_arrow->get_named_connection('endsection_0'),
	CONNECTEE => $destination_element,
	CONNECTION => $destination_connection,
	}) ;
}

#----------------------------------------------------------------------------------------------

sub connect_from_arrow
{
my ($self,  $element, $destination_element, $destination_connection) = @_ ;

my %source_connectors = map {$_->{NAME} => $_} grep {$_->{NAME} ne 'resize'} $element->get_connector_points() ;

for(grep {$_->{CONNECTED} == $element } @{$self->{CONNECTIONS}})
	{
	delete $source_connectors{$_->{CONNECTOR}{NAME}} ;
	}

my ($unconnected_connector_name) = reverse sort keys %source_connectors ;

if($unconnected_connector_name)
	{
	my $unconnected_connector = $source_connectors{$unconnected_connector_name} ;
		
	my ($x_offset, $y_offset) = 
		$element->move_connector
				(
				$unconnected_connector_name, 
				
				($destination_element->{X} + $destination_connection->{X}) - ($element->{X} + $unconnected_connector->{X}),
				($destination_element->{Y} + $destination_connection->{Y}) - ($element->{Y} + $unconnected_connector->{Y}),
				) ;
			
	$element->{X} += $x_offset ;
	$element->{Y} += $y_offset ;
	
	my $new_connection = 
		{
		CONNECTED => $element,
		CONNECTOR =>$unconnected_connector,
		CONNECTEE => $destination_element,
		CONNECTION => $destination_connection,
		} ;
		
	$self->add_connections($new_connection) ;
	}
}

#----------------------------------------------------------------------------------------------

sub mouse_right_click
{
my ($self, $event) = @_;

$self->display_popup_menu($event) ; # display_popup_menu is handled by derived Asciio
}

#----------------------------------------------------------------------------------------------

sub mouse_motion
{
my ($self, $event) = @_ ;

my ($x, $y) = @{$event->{COORDINATES}}[0, 1] ;

if($event->{STATE} eq 'dragging-button1' && ($self->{PREVIOUS_X} != $x || $self->{PREVIOUS_Y} != $y))
	{
	mouse_drag($self, $x, $y) ;
	}

($self->{PREVIOUS_X}, $self->{PREVIOUS_Y}) = ($self->{MOUSE_X}, $self->{MOUSE_Y}) ;
($self->{MOUSE_X}, $self->{MOUSE_Y}) = ($x, $y) ;
}

sub mouse_drag_left()  { my ($self) = @_ ; mouse_drag($self, $self->{MOUSE_X} - 1 , $self->{MOUSE_Y}) ; }
sub mouse_drag_right() { my ($self) = @_ ; mouse_drag($self, $self->{MOUSE_X} + 1 , $self->{MOUSE_Y}) ; }
sub mouse_drag_up()    { my ($self) = @_ ; mouse_drag($self, $self->{MOUSE_X},      $self->{MOUSE_Y} - 1) ; }
sub mouse_drag_down()  { my ($self) = @_ ; mouse_drag($self, $self->{MOUSE_X},      $self->{MOUSE_Y} + 1) ; }

sub mouse_drag
{
my ($self, $x, $y) = @_ ;

my @selected_elements = $self->get_selected_elements(1) ;
my ($first_element) = first_value {$self->is_over_element($_, $self->{PREVIOUS_X}, $self->{PREVIOUS_Y})} reverse @selected_elements ;

if(@selected_elements <= 1)
	{
	if(! defined $self->{DRAGGING})
		{
		$self->{DRAGGING} = defined $first_element
					? $first_element->get_selection_action
								(
								$self->{PREVIOUS_X} - $first_element->{X},
								$self->{PREVIOUS_Y} - $first_element->{Y},
								)
					: 'select' ;
		}
	}
else
	{
	$self->{DRAGGING} = defined $first_element ? 'move' : 'select'
		unless defined $self->{DRAGGING} ;
	}

($self->{MOUSE_X}, $self->{MOUSE_Y}) = ($x, $y) ;

if($self->{PREVIOUS_X} != $x || $self->{PREVIOUS_Y} != $y)
	{
	if    ($self->{DRAGGING} eq 'move')   { $self->move_elements_event($x, $y) ; }
	elsif ($self->{DRAGGING} eq 'resize') { $self->resize_element_event($x, $y) ; }
	elsif ($self->{DRAGGING} eq 'select') 
		{
		if($self->{DRAG_SELECTS_ARROWS})
			{
			$self->select_element_event($x, $y) ; 
			}
		else
			{
			$self->select_element_event($x, $y, sub { my $element = shift ; ref($_) !~ /arrow/ ;}) ; 
			}
		}
	
	($self->{PREVIOUS_X}, $self->{PREVIOUS_Y}) = ($x, $y) ;
	}
}

#----------------------------------------------------------------------------------------------

sub mouse_drag_canvas
{
my ($self, $event) = @_ ;

my ($x, $y) = @{$event->{COORDINATES}}[0, 1] ;

if($event->{STATE} eq 'dragging-button1' && ($self->{PREVIOUS_X} != $x || $self->{PREVIOUS_Y} != $y))
	{
	my ($character_width, $character_height) = $self->get_character_size() ;
	
	my $h_value = $self->{sc_window}->get_hadjustment()->get_value() ;
	my $v_value = $self->{sc_window}->get_vadjustment()->get_value() ;
	
	my $new_h_value = $h_value - (($x - $self->{PREVIOUS_X}) * $character_width) ;
	my $new_v_value = $v_value - (($y - $self->{PREVIOUS_Y}) * $character_height) ;
	
	if($new_h_value >= 0)
		{
		$self->{sc_window}->get_hadjustment()->set_value($new_h_value) ;
		}
	else
		{
		# scrollbar reached top
		}
	
	if($new_v_value >= 0)
		{
		$self->{sc_window}->get_vadjustment()->set_value($new_v_value) ;
		}
	else
		{
		# scrollbar reached top
		}
	}
else
	{
	($self->{PREVIOUS_X}, $self->{PREVIOUS_Y}) = ($self->{MOUSE_X}, $self->{MOUSE_Y}) ;
	($self->{MOUSE_X}, $self->{MOUSE_Y}) = ($x, $y) ;
	}
}

#----------------------------------------------------------------------------------------------

sub mouse_on_element_id
{
my ($self) = @_ ;

my $id = $self->display_edit_dialog('element id', '', $self) ;
$id = "$id" + 0 ;

return unless exists $self->{ELEMENTS}[$id - 1] ;

my $element = $self->{ELEMENTS}[$id - 1 ] ;
my ($x, $y) = ($element->{X}, $element->{Y}) ;

($self->{MOUSE_X}, $self->{MOUSE_Y}) = ($x, $y) ;
$self->{PREVIOUS_X} = $x ;
$self->{PREVIOUS_Y} = $y ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

1 ;

