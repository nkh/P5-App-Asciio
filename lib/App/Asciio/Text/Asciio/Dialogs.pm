
package App::Asciio::Text ;
$|++ ;

use strict;
use warnings;

use Data::TreeDumper ;
use IO::Prompter ;
use Term::ANSIColor qw(colorvalid) ;

#-----------------------------------------------------------------------------

sub get_color_from_user
{
my ($self, $previous_color) = @_ ;

print "\e[2J\e[H\e[?25h" ;

my $color = prompt "ANSI color name:", -complete => [qw(on bold black  red  green  yellow  blue  magenta  cyan  white rgb ansi grey)], -default => '' ;
$color //= '' ;

$color = '' unless colorvalid($color) ;

return $color ;
}

#-----------------------------------------------------------------------------

sub show_dump_window
{
my ($self, $data, $title, @dumper_setup) = @_ ;

print "\e[2J\e[H\e[?25h" ;

print DumpTree $data, @dumper_setup ;
prompt 'press key to continue ...' ;
$self->update_display() ;
}


#-----------------------------------------------------------------------------

sub display_message_modal
{
my ($self, $message) = @_ ;

print "\e[2J\e[H\e[?25h" ;

print "$message\n" ;
$a = prompt -1, 'press key to continue ...' ;
$self->update_display() ;
}

#-----------------------------------------------------------------------------

sub display_yes_no_cancel_dialog
{
my ($self, $title, $text) = @_ ;

print "\e[2J\e[H\e[?25h" ;

my $result = prompt "$title [yes, no, cancel]:", -complete => ['yes', 'no', 'cancel'] ;

$self->update_display() ;

return $result ;
}

#-----------------------------------------------------------------------------

sub display_quit_dialog
{
my ($self, $title, $text) = @_ ;

print "\e[2J\e[H\e[?25h" ;

my @choices = ('continue editing', 'save and quit', 'quit and lose changes') ;

my $result = prompt $text, -number, -menu => \@choices, -1, -default => 'a', '>' ;

$result = 'save_and_quit' if $result eq 'save and quit' ;
$result = 'ok' if $result eq 'quit and lose changes' ;

$self->update_display() ;

return $result ;
}

#-----------------------------------------------------------------------------

sub display_edit_dialog
{
my ($self, $title, $text) = @_ ;

print "\e[2J\e[H\e[?25h" ;

my $result ;

my $input = prompt "$title:" ;
if($input)
	{
	$input =~ s/\r$// ;
	$input =~ s/\\n/\n/g ;
	$result = "$input" ;
	}
else
	{
	$result = $text ;
	}

$self->update_display() ;

return $result // '' ;
}

#-----------------------------------------------------------------------------

sub get_file_name
{
my ($self, $type) = @_ ; # type: save|open

print "\e[2J\e[H\e[?25h" ;

my $result = '' ;

my $input = prompt 'file name:', -complete => 'filenames' ;

if($input)
	{
	$input =~ s/\r$// ;
	$input =~ s/\\n/\n/g ;
	$result = "$input" ;
	}
else
	{
	$result = '' ;
	}

$self->update_display() ;

return $result ;
}


#-----------------------------------------------------------------------------

1 ;
