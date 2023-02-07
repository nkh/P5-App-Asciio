
package App::Asciio::stripes::exec_box ;

use strict;
use warnings;

use IO::Prompter;
 
#-----------------------------------------------------------------------------

sub display_box_edit_dialog
{
my ($self, $title, $text) = @_ ;

my $rows = $self->{BOX_TYPE} ;

print "\e[2J\e[H\e[?25h" ;

my $input = prompt "new title: ", -default => $title ;
if($input)
	{
	$input =~ s/\r$// ;
	$input =~ s/\\n/\n/g ;
	$title = "$input" ;
	}
else
	{
	$title = undef ;
	}

my $title_separator = $self->{BOX_TYPE}[1] ;
$title_separator->[0] = prompt "title_sepearator [y/n]: ", -y1 ;

$input = prompt "new command: ", -default => $text ;
if($input)
	{$input =~ s/\r$// ;
	$input =~ s/\\n/\n/g ;
	$text = "$input" ;
	}
else
	{
	$text = undef ;
	}

print "\e[?25l" ; # hide cursor

return($text, $title) ;
}

#-----------------------------------------------------------------------------

1 ;
