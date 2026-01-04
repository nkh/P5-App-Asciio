
package App::Asciio::Actions::Debug ;

use strict ; use warnings ;

#----------------------------------------------------------------------------------------------

use List::Util qw(min max sum) ;

#----------------------------------------------------------------------------------------------

sub dump_self
{
my ($self) = @_ ;

my $size = sum(map { length } @{$self->{DO_STACK}}) || 0 ;

local $self->{DO_STACK} = scalar(@{$self->{DO_STACK}})  . " [$size]";

#~ print STDERR Data::TreeDumper::DumpTree $self ;
$self->show_dump_window($self, 'asciio') ;
}

#----------------------------------------------------------------------------------------------

sub dump_selected_elements
{
my ($self) = @_ ;

#~ print STDERR Data::TreeDumper::DumpTree [$self->get_selected_elements(1)] ;
$self->show_dump_window([$self->get_selected_elements(1)], 'asciio selected elements') ;
}

#----------------------------------------------------------------------------------------------

sub dump_all_elements
{
my ($self) = @_ ;

#~ print STDERR Data::TreeDumper::DumpTree $self->{ELEMENTS} ;
$self->show_dump_window($self->{ELEMENTS}, 'asciio elements') ;
}

#----------------------------------------------------------------------------------------------

use App::Asciio::FindAndReplace ;

sub test
{
my ($self) = @_ ;

my @matching = $self->get_elements_matching($App::Asciio::FIND_IN_TITLE | $App::Asciio::FIND_IN_TEXT, qr/nadim/, $self->get_selected_elements(0)) ;

if(@matching)
	{
	$self->create_undo_snapshot() ;
	
	$self->select_elements(1, @matching) ;
	$self->update_display() ;
	
	my $replacements = $self->replace_in_title_and_text(qr/nadim/, 'Helena', @matching) ;
	print "replacements: $replacements\n" ;
	}
}

sub xtest
{
my ($self) = @_ ;

$self->create_undo_snapshot() ;
$self->run_actions_by_name(['Insert', 0, 0, 'insert_error.asciio']) ;
$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

1 ;

