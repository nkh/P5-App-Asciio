
package App::Asciio::stripes::editable_box2 ;
use parent qw/App::Asciio::stripes::single_stripe/ ;

use strict;
use warnings;

use IO::Prompter;
use File::Slurp ;
use File::Temp ;
 
#-----------------------------------------------------------------------------

sub display_box_edit_dialog
{
my ($self, $title, $text, $asciio) = @_ ;

my $title_separator = $self->{BOX_TYPE}[1] ;

if(defined $asciio->{DIALOGS}{BOX_EDIT})
	{
	my $file = File::Temp->new()->filename ;
	
	write_file($file, "$title\n\n" . ($title_separator->[0] // 0) . "\n\n$text\n") ;
	
	system "$asciio->{DIALOGS}{BOX_EDIT} $file" ;
	my $user_input = read_file $file ;
	
	($title, $title_separator->[0], $text) = split /\n\n\n?/, $user_input ;
	
	}
else
	{
	print "\e[2J\e[H\e[?25h" ;
	
	my $input = prompt "old title: $title\nnew title: ", -default => $title ;
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
	
	$title_separator->[0] = prompt "title_sepearator [y/n]: ", -y1 ;
	
	$input = prompt "old text: $text\nnew text: ", -default => $text ;
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
	}

return($text, $title) ;
}

#-----------------------------------------------------------------------------

1 ;
