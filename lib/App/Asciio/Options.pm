
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

@ARGV = @{$switches_to_parse} ;

# tweek option parsing so we can mix switches with targets
my $contains_switch ;
my @targets ;

do
	{
	while(@ARGV && $ARGV[0] !~ /^-/)
		{
		#~ print "target => $ARGV[0] \n" ;
		push @targets, shift @ARGV ;
		}
		
	$contains_switch = @ARGV ;
	
	local $SIG{__WARN__} = sub {print STDERR $_[0] unless $ignore_error ;} ;
			
	unless(GetOptions(@flags))
		{
		return(0, "Try perl asciio -h.", $asciio_config, @ARGV) unless $ignore_error;
		}
	}
while($contains_switch) ;

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

my @flags_and_help =
	(
	'setup_path=s'                          => $asciio_config->{SETUP_PATHS},
		'Sets the root of the setup directory.',
		'',
		
	's|script=s'                            => \$asciio_config->{SCRIPT},
		'script to be run at Asciio start.',
		'',
		
	'p|web_port=s'                              => \$asciio_config->{WEB_PORT},
		'port for web server.',
		'',
	) ;
	
return(@flags_and_help) ;
}

#-----------------------------------------------------------------------------

1 ;

