
use List::MoreUtils qw(any minmax first_value) ;
use Readonly ;

use App::Asciio::stripes::section_wirl_arrow ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Quick link' => ['00S-button_press-1', \&quick_link] ,
	#~ 'C00-button_release' => ['', ] ,
	#~ 'C00-motion_notify' =>['', ] ,
	) ;


#----------------------------------------------------------------------------------------------

Readonly my $PREFERED_DIRECTION => 'right-down' ; # or 'down-right' ;

#----------------------------------------------------------------------------------------------

sub quick_link
{
my ($self, $event) = @_ ;

$self->create_undo_snapshot() ;

if($event->{BUTTON} == 1) 
	{
	my ($x, $y) = @{$event->{COORDINATES}} ;
	my ($destination_element) = first_value {$self->is_over_element($_, $x, $y)} reverse @{$self->{ELEMENTS}} ;
	
	if($destination_element)
		{
		connect_to_destination_element($self, $destination_element, $x, $y) ;
		}
	else
		{
		# user clicked in void or un-linkable object
		no_destination_element($self, $x, $y) ;
		}
	}
	
#~ if($event->type eq '2button-press')
	#~ {
	#~ }

#~ if($event->button == 3) 
	#~ {
	#~ }
}

#----------------------------------------------------------------------------------------------

sub no_destination_element
{
my ($self, $x, $y) = @_ ;

my $new_box = $self->add_new_element_named('stencils/asciio/box', $x, $y) ;
connect_to_destination_element($self, $new_box, $x, $y) ;
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
