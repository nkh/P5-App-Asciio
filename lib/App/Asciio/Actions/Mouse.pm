
package App::Asciio::Actions::Mouse ;

#----------------------------------------------------------------------------------------------

use List::MoreUtils qw(any minmax first_value) ;
use Readonly ;

use App::Asciio::stripes::section_wirl_arrow ;

Readonly my $PREFERED_DIRECTION => 'right-down' ; # or 'down-right' ;

#----------------------------------------------------------------------------------------------

sub quick_link
{
my ($self) = @_ ;

$self->create_undo_snapshot() ;

my ($x, $y) = @{$self}{'MOUSE_X', 'MOUSE_Y'} ;
my ($destination_element) = first_value {$self->is_over_element($_, $x, $y)} reverse @{$self->{ELEMENTS}} ;

if($destination_element)
{
connect_to_destination_element($self, $destination_element, $x, $y) ;
}
else
{
# user clicked in void or un-linkable object
my $new_box = $self->add_new_element_named('Stencils/Asciio/box', $x, $y) ;
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

use List::MoreUtils qw(first_value) ;

sub left_button_pressed
{
my ($self, $event) = @_;

my($x, $y) = @{$event->{COORDINATES}} ;

if($event->{TYPE} eq '2button-press')
	{
	my @element_over = grep { $self->is_over_element($_, $x, $y) } reverse @{$self->{ELEMENTS}} ;
	
	if(@element_over)
		{
		my $selected_element = $element_over[0] ;
		$self->edit_element($selected_element) ;
		$self->update_display();
		}
	
	return 1 ;
	}

if($event->{BUTTON} == 1) 
	{
	my $modifiers = $event->{MODIFIERS} ;
	
	my ($first_element) = first_value {$self->is_over_element($_, $x, $y)} reverse @{$self->{ELEMENTS}} ;
	
	print "mod: $modifiers'\n" ;
	if ($modifiers eq 'C00')
		{
		if(defined $first_element)
			{
			$self->run_actions_by_name('Copy to clipboard', ['Insert from clipboard', 0, 0])  ;
			}
		}
	else
		{
		if(defined $first_element)
			{
			 if ($modifiers eq '00S')
				{
				$self->select_elements_flip($first_element) ;
				}
			else
				{
				unless($self->is_element_selected($first_element))
					{
					# make the element under cursor the only selected element
					$self->select_elements(0, @{$self->{ELEMENTS}}) ;
					$self->select_elements(1, $first_element) ;
					}
				}
			}
		else
			{
			# deselect all
			$self->deselect_all_elements()  if ($modifiers eq '000')  ;
			}
		}
	
	$self->{SELECTION_RECTANGLE} = {START_X => $x , START_Y => $y} ;
	
	$self->update_display();
	}
	
if($event->{BUTTON} == 2) 
	{
	$self->{SELECTION_RECTANGLE} = {START_X => $x , START_Y => $y} ;
	
	$self->update_display();
	}
  
if($event->{BUTTON} == 3) 
	{
	$self->display_popup_menu($event) ; # display_popup_menu is handled by derived Asciio
	}

# $self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub toggle_mouse
{
my ($self) = @_;

$self->{MOUSE_TOGGLE} ^= 1 ;
$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub mouse_move
{
my ($self, $offsets) = @_;
my ($x_offset, $y_offset) = @{$offsets} ;

$self->{MOUSE_X} += $x_offset ;
$self->{MOUSE_Y} += $y_offset ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------
sub mouse_left_click
{
my ($self ) = @_;

# use Data::TreeDumper ; print DumpTree \@_ ;

if($self->{MOUSE_TOGGLE})
	{
	App::Asciio::button_press_event
		(
		$self,
		{
		BUTTON => 1,
		COORDINATES => [ $self->{MOUSE_X}, $self->{MOUSE_Y} ], 
		KEY_NAME => -1,
		MODIFIERS => '000',
		STATE => '',
		TYPE => 'button-press'
		},
		) ;
	}
}

#----------------------------------------------------------------------------------------------

sub mouse_shift_left_click
{
my ($self ) = @_;

if($self->{MOUSE_TOGGLE})
	{
	App::Asciio::button_press_event
		(
		$self,
		{
		BUTTON => 1,
		COORDINATES => [ $self->{MOUSE_X}, $self->{MOUSE_Y} ], 
		KEY_NAME => -1,
		MODIFIERS => '00S',
		STATE => '',
		TYPE => 'button-press'
		},
		) ;
	}
}

#----------------------------------------------------------------------------------------------

sub mouse_ctl_left_click
{
my ($self ) = @_;

if($self->{MOUSE_TOGGLE})
	{
	App::Asciio::button_press_event
		(
		$self,
		{
		BUTTON => 1,
		COORDINATES => [ $self->{MOUSE_X}, $self->{MOUSE_Y} ], 
		KEY_NAME => -1,
		MODIFIERS => 'C00',
		STATE => '',
		TYPE => 'button-press'
		},
		) ;
	}
}

#----------------------------------------------------------------------------------------------

sub mouse_alt_left_click
{
my ($self ) = @_;

if($self->{MOUSE_TOGGLE})
	{
	App::Asciio::button_press_event
		(
		$self,
		{
		BUTTON => 1,
		COORDINATES => [ $self->{MOUSE_X}, $self->{MOUSE_Y} ], 
		KEY_NAME => -1,
		MODIFIERS => '0A0',
		STATE => '',
		TYPE => 'button-press'
		},
		) ;
	}
}

#----------------------------------------------------------------------------------------------

sub mouse_right_click
{
my ($self) = @_;

$self->display_popup_menu($self->{EVENT}) ; # display_popup_menu is handled by derived Asciio
}

#----------------------------------------------------------------------------------------------

sub mouse_drag_left()
{
my ($self) = @_ ;

App::Asciio::motion_notify_event
	(
	$self,
	{
	BUTTON => 1,
	COORDINATES => [ $self->{MOUSE_X} - 1 , $self->{MOUSE_Y} ], 
	KEY_NAME => -1,
	MODIFIERS => '00S',
	STATE => "dragging-button1",
	TYPE => 'button-press'
	},
	) ;
}

#----------------------------------------------------------------------------------------------

sub mouse_drag_right()
{
my ($self) = @_ ;

App::Asciio::motion_notify_event
	(
	$self,
	{
	BUTTON => 1,
	COORDINATES => [ $self->{MOUSE_X} + 1 , $self->{MOUSE_Y} ], 
	KEY_NAME => -1,
	MODIFIERS => '000',
	STATE => "dragging-button1",
	TYPE => 'button-press'
	},
	) ;
}

#----------------------------------------------------------------------------------------------

sub mouse_drag_up()
{
my ($self) = @_ ;

App::Asciio::motion_notify_event
	(
	$self,
	{
	BUTTON => 1,
	COORDINATES => [ $self->{MOUSE_X}, $self->{MOUSE_Y} - 1 ], 
	KEY_NAME => -1,
	MODIFIERS => '000',
	STATE => "dragging-button1",
	TYPE => 'button-press'
	},
	) ;


}

#----------------------------------------------------------------------------------------------

sub mouse_drag_down()
{
my ($self) = @_ ;

App::Asciio::motion_notify_event
	(
	$self,
	{
	BUTTON => 1,
	COORDINATES => [ $self->{MOUSE_X} , $self->{MOUSE_Y} + 1 ], 
	KEY_NAME => -1,
	MODIFIERS => '000',
	STATE => "dragging-button1",
	TYPE => 'button-press'
	},
	) ;
}

#----------------------------------------------------------------------------------------------

sub mouse_on_element_id
{
my ($self) = @_ ;

my $id = $self->display_edit_dialog('element id', '') ;
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

