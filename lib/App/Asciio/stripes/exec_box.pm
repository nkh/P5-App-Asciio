
package App::Asciio::stripes::exec_box ;
use utf8;
use Encode;

use base App::Asciio::stripes::editable_box2 ;

use strict;
use warnings;

use List::Util qw(min max) ;
use Readonly ;
use Clone ;

#-----------------------------------------------------------------------------

Readonly my $DEFAULT_BOX_TYPE => 
	[
	[1, 'top', '.', '-', '.', 1, ],
	[0, 'title separator', '|', '-', '|', 1, ],
	[1, 'body separator', '| ', '|', ' |', 1, ], 
	[1, 'bottom', '\'', '-', '\'', 1, ],
	]  ;

Readonly my $NO_BORDER => 
	[
	[0, 'top', '.', '-', '.', 1, ],
	[0, 'title separator', '|', '-', '|', 1, ],
	[0, 'body separator', '| ', '|', ' |', 1, ], 
	[0, 'bottom', '\'', '-', '\'', 1, ],
	]  ;

sub new
{
my ($class, $element_definition) = @_ ;

my $self = bless  {}, __PACKAGE__ ;

my $box = $element_definition->{NO_BORDER} ? Clone::clone($NO_BORDER) : $element_definition->{BOX_TYPE} // Clone::clone($DEFAULT_BOX_TYPE) ;

App::Asciio::stripes::editable_box2::setup
	(
	$self,
	$element_definition->{TEXT_ONLY},
	$element_definition->{TITLE},
	$box,
	1, 1,
	$element_definition->{RESIZABLE},
	$element_definition->{EDITABLE},
	$element_definition->{AUTO_SHRINK},
	) ;

return $self ;
}

#-----------------------------------------------------------------------------

sub set_text
{
my ($self, $title, $text) = @_ ;

print "Set_text $title, $text\n" ;
my $command = $self->{COMMAND} = $text ;
my $output = 'command failed' ;

if(defined $command && $command ne '')
	{
	(my $command_stderr_redirected = $command) =~ s/$/ 2>&1/gsm ;
	$output = `$command_stderr_redirected` ;

	if($?)
		{
		$output = '' unless defined $output ;
		$output = "Can't execute '$command':\noutput:\n$output\nerror:\n$! [$?]" ;
		}
	}
else
	{
	$output = 'no command' ;
	}

print "cmd $command -> $output\n" ;

$output = decode("utf-8", $output) ;
$output =~ s/\r//g;

App::Asciio::stripes::editable_box2::setup
	(
	$self,
	$output,
	$title,
	$self->{BOX_TYPE},
	$self->{WIDTH},
	$self->{HEIGHT},
	$self->{RESIZABLE},
	$self->{EDITABLE},
	$self->{AUTO_SHRINK},
	) ;
}

#-----------------------------------------------------------------------------

sub edit
{
my ($self, $asciio) = @_ ;

return unless $self->{EDITABLE} ;

my $text = $self->{TEXT_ONLY} ;

($text, my $title) = $self->display_box_edit_dialog($self->{TITLE}, $self->{COMMAND} // '') ;

my $tab_as_space = $self->{TAB_AS_SPACES} || (' ' x 3) ;

$text =~ s/\t/$tab_as_space/g ;
$title=~ s/\t/$tab_as_space/g ;

$self->set_text($title, $text) ;
}

#-----------------------------------------------------------------------------

sub rotate_text
{
# can't rotate ;
}

#-----------------------------------------------------------------------------

1 ;
