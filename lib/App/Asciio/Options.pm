
package App::Asciio ;

$|++ ;

use strict;
use warnings;

use Data::TreeDumper ;
use Getopt::Long ;

#-----------------------------------------------------------------------------

sub ParseSwitches
{
my ($self, $switches_to_parse, $ignore_error) = @_ ;

my $asciio_config = {} ;

Getopt::Long::Configure('no_auto_abbrev', 'no_ignore_case', 'require_order') ;

my @flags = Get_GetoptLong_Data($asciio_config) ;

local @ARGV = $switches_to_parse->@* ;

# tweek option parsing so we can mix switches with targets
my $contains_switch ;
my @targets ;

do
	{
	while(@ARGV && $ARGV[0] !~ /^-/)
		{
		push @targets, shift @ARGV ;
		}
	
	$contains_switch = @ARGV ;
	
	local $SIG{__WARN__} = sub { print STDERR $_[0] unless $ignore_error ; } ;
	
	unless(GetOptions(@flags))
		{
		return(0, "Try perl asciio -h.", $asciio_config, @ARGV) unless $ignore_error;
		}
	}
while($contains_switch) ;

if($asciio_config->{HELP})
	{
	print STDERR "Asciio options:\n" ;
	
	my @flags_and_help = GetSwitches($asciio_config) ;
	
	my $flag_element_counter = 0 ;
	my @getoptlong_data ;
	
	for (my $i = 0 ; $i < @flags_and_help; $i += 4)
		{
		my ($flag, $help) = ($flags_and_help[$i], $flags_and_help[$i + 2]) ;
		printf STDERR "\t%-30s\t%s\n", $flag, $help ;
		}
	
	exit(1) ;
	}

$asciio_config->{TARGETS} = \@targets ;

return(1, '', $asciio_config) ;
}

#-------------------------------------------------------------------------------

sub Get_GetoptLong_Data
{
my $asciio_config = shift || die 'Missing argument.' ;

my @flags_and_help = GetSwitches($asciio_config) ;

my $flag_element_counter = 0 ;
my @getoptlong_data ;

for (my $i = 0 ; $i < @flags_and_help; $i += 4)
	{
	my ($flag, $variable) = ($flags_and_help[$i], $flags_and_help[$i + 1]) ;
	push @getoptlong_data, ($flag, $variable)  ;
	}

return(@getoptlong_data) ;
}

#-------------------------------------------------------------------------------

sub GetSwitches
{
my $asciio_config = shift || {} ;

$asciio_config->{SETUP_PATHS} = [] ;
$asciio_config->{BINDING_FILES} = [] ;

my @flags_and_help =
	(
	'b'                         => \$asciio_config->{TEXT_TO_ASCIIO_BOX_INPUT},
		'put the input in a boxed element',
		'',
	
	'text_separator=s'          => \$asciio_config->{TEXT_TO_ASCIIO_SEPARATOR},
		'put the input in a boxed element',
		'',
	
	'display_setup_information' => \$asciio_config->{DISPLAY_SETUP_INFORMATION},
		'show which setup files are used.',
		'',
	
	'show_binding_override'     => \$asciio_config->{SHOW_BINDING_OVERRIDE},
		"display binding overrides in terminal",
		'',
	
	'setup_path=s'              => $asciio_config->{SETUP_PATHS},
		'sets the root of the setup directory.',
		'',
	
	'scripts_path=s'            => \$asciio_config->{SCRIPTS_PATH},
		'location of scripts.',
		'',
	
	's|script=s'                => \$asciio_config->{SCRIPT},
		'script to be run at Asciio start.',
		'',
	
	'p|web_port=s'              => \$asciio_config->{WEB_PORT},
		'port for web server.',
		'',
	
	'debug_fd=i'                => \$asciio_config->{DEBUG_FD},
		'debug file descriptor number.',
		'',
	
	'add_binding=s'             => $asciio_config->{BINDING_FILES},
		'add bindings to the document',
		'',
	
	'reset_bindings'            => \$asciio_config->{RESET_BINDINGS},
		'remove bindings from the document',
		'',
	
	'dump_bindings'             => \$asciio_config->{DUMP_BINDINGS},
		'dumps the bindings found in the document',
		'',
	
	'dump_binding_names'        => \$asciio_config->{DUMP_BINDING_NAMES},
		'dumps the name of the bindings found in the document',
		'',
	
	'help|h'                    => \$asciio_config->{HELP},
		'display asciio options',
		'',
	) ;
	
return(@flags_and_help) ;
}

#-----------------------------------------------------------------------------

1 ;

