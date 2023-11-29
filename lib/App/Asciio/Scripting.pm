
package App::Asciio::Scripting ;

require Exporter ;
@ISA = qw(Exporter) ;
@EXPORT = qw(
	update_display
	start_updating_display  
	stop_updating_display  

	create_undo_snapshot

	add
	add_type
	new_box
	new_text
	new_wirl_arrow

	delete_by_name
	delete_selected_elements
	move
	offset

	select_all_elements
	deselect_all_elements
	select_all_script_elements
	deselect_all_script_elements

	connect_elements
	optimize

	delete_all_ruler_lines
	add_ruler_line
	
	save_to
	to_ascii
	ascii_out
	
	optimize_connections
	get_canonizer
	set_connection
	add_connection
	move_named_connector
	) ;

use strict ; use warnings ;
use utf8 ;

use Module::Util qw(find_installed) ;
use File::Basename ;
use File::Slurp ;

use App::Asciio ;
use App::Asciio::Connections ;
use App::Asciio::Elements ;
use App::Asciio::Io ;
use App::Asciio::Options ;

use App::Asciio::stripes::angled_arrow ;
use App::Asciio::stripes::angled_arrow ;
use App::Asciio::stripes::section_wirl_arrow ;
use App::Asciio::stripes::stripes ;
use App::Asciio::stripes::wirl_arrow ;

use Digest::MD5 qw(md5_hex)  ;

use Data::TreeDumper ;
sub ddt { print DumpTree @_ ; }

#--------------------------------------------------------------------------------------------

{

my $script_asciio ; # make script non OO
my %name_to_element ;

#------------------------------------------------------------------------------------------------------

sub run_external_script_text
{
my ($asciio, $script, $show_script) = @_ ;

if(defined $script)
	{
	print "Asciio: script: " . md5_hex($script) . "\n" ;
	print "$script\n" if $show_script ;
	
	$script_asciio = $asciio ;
	
	eval $script ;
	
	$asciio->update_display() ;
	
	print "Asciio: error running script: $@ \n" if $@ ;
	}
}

sub run_external_script
{
my ($asciio, $file) = @_ ;

$file //= $asciio->get_file_name() ;

if(defined $file)
	{
	print "Asciio: script file: '$file'\n" ;
	
	$script_asciio = $asciio ;
	
	unless (my $return = do $file)
		{
		warn "Asciio: error running script $file: $@" if $@ ;
		# warn "couldn't do $file: $!"    unless defined $return ;
		# warn "couldn't run $file"       unless $return ;
		}
	
	$asciio->update_display() ;
	}
}

sub new_script_asciio
{
$script_asciio = App::Asciio->new() ;

my ($command_line_switch_parse_ok, $command_line_parse_message, $asciio_config)
	= $script_asciio->ParseSwitches([@ARGV], 0) ;

die "Error: '$command_line_parse_message'!" unless $command_line_switch_parse_ok ;

if(@{$asciio_config->{SETUP_PATHS}})
	{
	$script_asciio->setup($asciio_config->{SETUP_PATHS}) ;
	}
else
	{
	my ($basename, $path, $ext) = File::Basename::fileparse(find_installed('App::Asciio'), ('\..*')) ;
	$script_asciio->setup([$path . $basename . '/setup/setup.ini']) ;
	}
}

# initialize object when module is loaded
new_script_asciio() ;

#--------------------------------------------------------------------------------------------

sub stop_updating_display  
{ 
$script_asciio->stop_updating_display() ;
}

sub start_updating_display 
{ 
$script_asciio->start_updating_display() ;
}

sub create_undo_snapshot
{
$script_asciio->create_undo_snapshot() ;
}

sub add
{
my ($name, $element, $x, $y) = @_ ;

$name_to_element{$name} = $element ;
$script_asciio->add_element_at($element, $x, $y) ;
}

sub move
{
my ($name, $x, $y) = @_ ;

my $element = $name_to_element{$name} ;

@$element{'X', 'Y'} = ($x, $y) if defined $element && defined $x && defined $y ;
}

sub offset 
{
my ($name, $x_offset, $y_offset) = @_ ;

my $element = $name_to_element{$name} ;

@$element{'X', 'Y'} = ($element->{X} + $x_offset, $element->{Y} + $y_offset)
	if defined $element && defined $x_offset && defined $y_offset ;
}

sub delete_selected_elements
{
$script_asciio->delete_selected_elements() ;
}

sub delete_by_name 
{
my ($name) = @_ ;

my $element = $name_to_element{$name} ;

$script_asciio->delete_elements($element) ;
}

sub add_type
{
my ($name, $type, $x, $y) = @_ ;

$name_to_element{$name} = $script_asciio->add_new_element_named('Asciio/Boxes/process', $x, $y) ;
}

sub connect_elements
{
my ($element1_name, $element2_name, @args) = @_ ;

add_connection($script_asciio, @name_to_element{$element1_name, $element2_name}, @args) ;
}

sub select_elements
{
my ($state, @elements) = @_ ;
$script_asciio->select_elements($state, @name_to_element{@elements}) ;
}

sub select_all_elements          { $script_asciio->select_all_elements() ; }
sub select_all_script_elements   { $script_asciio->select_elements(1, values %name_to_element) ; }

sub deselect_all_elements        { $script_asciio->deselect_all_elements() ; }
sub deselect_all_script_elements { $script_asciio->select_elements(0, values %name_to_element) ; }

sub delete_all_ruler_lines       { delete $script_asciio->{RULER_LINES} ; } ;

sub add_ruler_line 
{
my ($axis, $position) = @_ ;

my $data ;

if($axis eq 'vertical')
	{
	$data = {TYPE => 'VERTICAL', POSITION => $position} ;
	}
else
	{
	$data = {TYPE => 'hORIZONTAL', POSITION => $position} ;
	}

$script_asciio->add_ruler_lines({NAME => 'from script', %{$data}}) ;
}

sub save_to                      { $script_asciio->save_with_type(undef, 'asciio', $_[0]) ; }
sub to_ascii                     { $script_asciio->transform_elements_to_ascii_buffer() ; }
sub ascii_out                    { print $script_asciio->transform_elements_to_ascii_buffer() ; }
sub optimize                     { $script_asciio->call_hook('CANONIZE_CONNECTIONS', $script_asciio->{CONNECTIONS}) ; }
}

#--------------------------------------------------------------------------------------------

sub new_text
{
my (@arguments_to_constructor) = @_ ;

use App::Asciio::stripes::editable_box2 ;

my $element = new App::Asciio::stripes::editable_box2
			({
			TEXT_ONLY => 'box',
			TITLE => '',
			EDITABLE => 1,
			RESIZABLE => 1,
			@arguments_to_constructor,
			}) ;

my $box_type = $element->get_box_type() ;
my ($title, $text) = $element->get_text() ;

use Readonly ;

Readonly my $TITLE_SEPARATOR => 1 ;
Readonly my $DISPLAY => 0 ;

for (0 .. $#$box_type)
	{
	next if $_ == $TITLE_SEPARATOR && $title eq '' ;
	
	$box_type->[$_][$DISPLAY] = 0 ;
	}

$element->set_box_type($box_type) ;
$element->shrink() ;

return $element ;
}

#-----------------------------------------------------------------------------------------------------------

sub new_box
{
my (@arguments_to_constructor) = @_ ;

use App::Asciio::stripes::editable_box2 ;

new App::Asciio::stripes::editable_box2
				({
				TEXT_ONLY => 'box',
				TITLE => '',
				EDITABLE => 1,
				RESIZABLE => 1,
				@arguments_to_constructor,
				}) ;
}

#-----------------------------------------------------------------------------------------------------------

sub new_wirl_arrow 
{
my @points = @_ ;

@points = ([5, 5, 'downright']) unless @points ;

new App::Asciio::stripes::section_wirl_arrow
	({
	POINTS => [@points],
	DIRECTION => '',
	ALLOW_DIAGONAL_LINES => 0,
	EDITABLE => 1,
	RESIZABLE => 1,
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
my ($basename, $path, $ext) = File::Basename::fileparse(find_installed('App::Asciio'), ('\..*')) ;
my $setup = $path . $basename . "/setup" ;

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
	CODE_FROM_FILE => $setup . '/hooks/canonize_connections.pl' ,
	) ;
}
# ~/nadim/devel/repositories/perl_modules/P5-App-Asciio/setup/hooks/canonize_connections.pl"
#--------------------------------------------------------------------------------------------

1 ;
