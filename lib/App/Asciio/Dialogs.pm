
package App::Asciio ;
$|++ ;

use strict;
use warnings;

use Data::TreeDumper ;

#-----------------------------------------------------------------------------

sub get_color_from_user
{
my ($self, $previous_color) = @_ ;

return [1, 0, 0]  ;
}

#-----------------------------------------------------------------------------

sub show_dump_window
{
my ($self, $data, $title, @dumper_setup) = @_ ;

print DumpTree $data, $title, @dumper_setup ;
}

#-----------------------------------------------------------------------------

sub display_message_modal
{
my ($self, $message) = @_ ;

print $message ;
}

#-----------------------------------------------------------------------------

sub display_yes_no_cancel_dialog
{
my ($self, $title, $text) = @_ ;

print "$title\n$text\n" ;

print "Yes/No/Cancel\n" ;
my $answer = <STDIN> ;
chomp ($answer) ;

return $answer ;
}

#-----------------------------------------------------------------------------

sub display_quit_dialog
{
my ($self, $title, $text) = @_ ;

print "$title\n$text\n" ;
print "Yes/No/Cancel\n" ;

my $answer = <STDIN> ;
chomp ($answer) ;

return $answer ;
}

sub display_edit_dialog
{
my ($self, $title, $text) = @_ ;

print "$title\n$text\n" ;

my $answer = <STDIN> ;
chomp ($answer) ;

return $answer ;
}

#-----------------------------------------------------------------------------

sub get_file_name
{
my ($self, $type) = @_ ;

print "get_file_name:\n" ;

my $answer = <STDIN> ;
chomp ($answer) ;

return $answer ;
}

#-----------------------------------------------------------------------------

1 ;
