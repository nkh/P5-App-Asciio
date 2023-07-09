
package App::Asciio::Actions::Git ;

#----------------------------------------------------------------------------------------------

use strict ;
use warnings ;

use List::MoreUtils qw(first_value) ;

#----------------------------------------------------------------------------------------------
{

my $git_connector_char = '*' ;

sub set_default_connector { my ($self, $char) = @_ ; $git_connector_char = $char ; }

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
	my $new_connector = $self->add_new_element_named('Asciio/connector2', $x, $y) ;
	$new_connector->set_text('', $git_connector_char) ;
	connect_to_destination_element($self, $new_connector, $x, $y) ;
	}
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
				connect_from_connector($self,  $element, $source_connections[0], $destination_element, $destination_connection) ;
				}
			else
				{
				connect_from_arrow($self,  $element, $destination_element, $destination_connection) ;
				}
			}
		
		$self->select_elements(0, @selected_elements) ;
		$self->select_elements(1, $destination_element) ;
		}
	else
		{
		$self->select_elements(1, $destination_element) ;
		}
	
	$self->update_display() ; # will also canonize the connections
	}
}

#----------------------------------------------------------------------------------------------
{

my $git_arrow =
	[
		# name: start, body, connection, body_2, end, vertical, diagonal_connection
		['origin'     , '*',  '?', '?', '?', '?', '?', '?', 1],
		['up'         , "'",  '|', '?', '?', '.', '?', '?', 1],
		['down'       , '.',  '|', '?', '?', "'", '?', '?', 1],
		['left'       , '-',  '-', '?', '?', '-', '?', '?', 1],
		['right'      , '-',  '-', '?', '?', '-', '?', '?', 1],
		['up-left'    , "'", '\\', '.', '-', '-', '|', "'", 1],
		['left-up'    , '-', '\\', "'", '-', '.', '|', "'", 1],
		['down-left'  , '.',  '/', "'", '-', '-', '|', "'", 1],
		['left-down'  , '-',  '/', '.', '-', "'", '|', "'", 1],
		['up-right'   , "'",  '/', '.', '-', '-', '|', "'", 1],
		['right-up'   , '-',  '/', "'", '-', '.', '|', "'", 1],
		['down-right' , '.', '\\', "'", '-', '-', '|', "'", 1],
		['right-down' , '-', '\\', '.', '-', "'", '|', "'", 1],
	] ;

sub set_default_arrow { my ($self, $type) = @_ ; $git_arrow = App::Asciio::Arrows::clone($type) ; }

#----------------------------------------------------------------------------------------------

sub connect_from_connector
{
my ($self,  $element, $source_connection, $destination_element, $destination_connection) = @_ ;

my $angled_arrow = new App::Asciio::stripes::angled_arrow
					({
					END_X => ($destination_element->{X} + $destination_connection->{X})
							 - ($element->{X} + $source_connection->{X}),
					
					END_Y => ($destination_element->{Y} + $destination_connection->{Y})
							- ($element->{Y} + $source_connection->{Y}),
					
					DIRECTION => $element->{Y} < $destination_element->{Y} ? 'down-right' : 'up-right',
					ALLOW_DIAGONAL_LINES => 0,
					EDITABLE => 1,
					RESIZABLE => 1,
					}) ;

$angled_arrow->set_arrow_type($git_arrow) ;
$angled_arrow->enable_autoconnect(0) ;

$self->add_element_at_no_connection
	(
	$angled_arrow, 
	$element->{X} + $source_connection->{X},
	$element->{Y} + $source_connection->{Y} + 1,
	) ;

$self->add_connections
	({
	CONNECTED => $angled_arrow,
	CONNECTOR => $angled_arrow->get_named_connection('start'),
	CONNECTEE => $element,
	CONNECTION => $source_connection,
	}) ;

$self->add_connections
	({
	CONNECTED => $angled_arrow,
	CONNECTOR => $angled_arrow->get_named_connection('end'),
	CONNECTEE => $destination_element,
	CONNECTION => $destination_connection,
	}) ;

$self->move_elements_to_back($angled_arrow) ;
}

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

1 ;

