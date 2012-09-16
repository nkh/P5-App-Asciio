
use strict;
use warnings;
use lib qw(lib lib/stripes) ;

#--------------------------------------------------------------------------------------------

sub new_box
{
my (@arguments_to_constructor) = @_ ;

use App::Asciio::stripes::editable_box2 ;

my $box = new App::Asciio::stripes::editable_box2
				({
				TEXT_ONLY => 'box',
				TITLE => '',
				EDITABLE => 1,
				RESIZABLE => 1,
				@arguments_to_constructor,
				}) ;
				
return($box) ;
}

#-----------------------------------------------------------------------------------------------------------

sub new_wirl_arrow 
{
my (@arguments) = @_ ;

use App::Asciio::stripes::section_wirl_arrow ;
my $arrow = new App::Asciio::stripes::section_wirl_arrow
					({
					POINTS => [[5, 5, 'downright']],
					DIRECTION => '',
					ALLOW_DIAGONAL_LINES => 0,
					EDITABLE => 1,
					RESIZABLE => 1,
					@arguments,
					}) ;
}

#--------------------------------------------------------------------------------------------

sub add_connection
{
my ($self, $source_element, $destination_element, $hint, @arguments_to_constructor) = @_ ;

$hint ||= 'right-down' ;

my @destination_connections = grep {$_->{NAME} ne 'resize'} $destination_element->get_connection_points() ;
my $destination_connection = $destination_connections[0] ;

my @source_connections = grep {$_->{NAME} ne 'resize'} $source_element->get_connection_points() ;
my $source_connection = $source_connections[0] ;

my $new_element = new App::Asciio::stripes::section_wirl_arrow
					({
					POINTS => 
						[
							[
							    ($destination_element->{X} + $destination_connection->{X})
							  - ($source_element->{X} + $source_connection->{X}) ,
							
							    ($destination_element->{Y} + $destination_connection->{Y})
							 -  ($source_element->{Y} + $source_connection->{Y}) ,
							 
							$hint,
							]
						],
						
					DIRECTION => $hint,
					ALLOW_DIAGONAL_LINES => 0,
					EDITABLE => 1,
					RESIZABLE => 1,
					@arguments_to_constructor,
					}) ;
					
# let check_connection do the job of optimizing

@$new_element{'X', 'Y'} = ($source_element->{X} + $source_connection->{X}, $source_element->{Y} + $source_connection->{Y}) ;

$self->add_elements($new_element) ;
}

#--------------------------------------------------------------------------------------------

sub move_named_connector
{
my ($connected, $connector_name, $connectee, $connection_name) = @_ ;

do { die "Invalid argument to 'move_named_connector'!\n" unless defined $_}  for (@_) ;
die "Invalid number of arguments to 'move_named_connector'!\n" unless @_ == 4 ;
	
my $connector = $connected->get_named_connection($connector_name) ;
my $connection = $connectee->get_named_connection($connection_name) ;

if(defined $connector && defined $connection)
	{
	my $connector_x = $connected->{X} + $connector->{X} ;
	my $connector_y = $connected->{Y} + $connector->{Y} ;
	
	my $connection_x = $connectee->{X} + $connection->{X} ;
	my $connection_y = $connectee->{Y} + $connection->{Y} ;
	
	my $connector_x_offset = $connection_x - $connector_x ;
	my $connector_y_offset = $connection_y - $connector_y ;

	my ($x_offset, $y_offset, $width, $height, $new_connector) = 
		$connected->move_connector
			(
			$connector_name,
			$connector_x_offset, $connector_y_offset
			) ;
			
	$connected->{X} += $x_offset ;
	$connected->{Y} += $y_offset ;
	
	return 
		{
		CONNECTED => $connected,
		CONNECTOR =>$new_connector,
		CONNECTEE => $connectee,
		CONNECTION => $connection,
		} ;
	}
else
	{
	return ;
	}
}

#-----------------------------------------------------------------------------------------------------------

sub optimize_connections
{
my ($self) = @_;
$self->call_hook('CANONIZE_CONNECTIONS', $self->{CONNECTIONS}) ;
}

#--------------------------------------------------------------------------------------------

sub get_canonizer
{
my $context = new Eval::Context() ;

$context->eval
	(
	REMOVE_PACKAGE_AFTER_EVAL => 0, # VERY IMPORTANT as we return code references that will cease to exist otherwise
	PRE_CODE => <<'EOC' ,
use strict;
use warnings;

sub register_hooks
{
return \&canonize_connections ;
}

EOC
	CODE_FROM_FILE => 'setup/hooks/canonize_connections.pl' ,
	) ;
}


#--------------------------------------------------------------------------------------------

1 ;
