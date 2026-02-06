
use strict;
use warnings;

#------------------------------------------------------------------------------------------------------

package App::Asciio::Utils::Scripting ;

sub run_external_script
{
my ($asciio, $file) = @_ ;

use App::Asciio::Scripting ;
use App::Asciio::Utils::Animation ;

$file //= $asciio->get_file_name() ;

if(defined $file && $file ne '')
	{
	print STDERR "Asciio: script file: '$file'\n" ;
	
	$App::Asciio::Scripting::script_asciio = $asciio ;
	
	unless (my $return = do $file)
		{
		warn "Asciio: error running script $file: $@" if $@ ;
		# warn "couldn't do $file: $!"    unless defined $return ;
		# warn "couldn't run $file"       unless $return ;
		}
	
	$asciio->update_display() ;
	}
}

#------------------------------------------------------------------------------------------------------

1 ;


