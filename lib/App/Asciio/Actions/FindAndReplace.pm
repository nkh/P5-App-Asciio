
package App::Asciio::Actions::FindAndReplace ;
use App::Asciio::FindAndReplace ;

use warnings ; use strict ;
use utf8;

use App::Asciio::ZBuffer ;
use App::Asciio::Actions::Unsorted ;
use App::Asciio::GTK::Asciio ;
use App::Asciio::String ;
use App::Asciio::Actions::ElementsManipulation ;

#----------------------------------------------------------------------------------------------

sub get_regexp
{
my $regexp = App::Asciio::GTK::Asciio::get_user_text('regexp') ;
return unless defined $regexp && $regexp ne '' ;

eval { qr/$regexp/ } ;
if($@)
	{
	print STDERR "Error: $@\n" ;
	return ;
	}
else
	{
	return qr/$regexp/ ;
	}
}

#----------------------------------------------------------------------------------------------

sub get_replacement
{
return App::Asciio::GTK::Asciio::get_user_text('replacement') ;
}

#----------------------------------------------------------------------------------------------

sub search
{
my ($self, $regexp) = @_ ;

delete $self->{ACTIONS_STORAGE}{find} ; 

my @matching = $self->get_elements_matching($App::Asciio::FIND_IN_TITLE | $App::Asciio::FIND_IN_TEXT, $regexp, $self->{ELEMENTS}->@*) ;

$self->{ACTIONS_STORAGE}{find}{regexp}        = $regexp ;
$self->{ACTIONS_STORAGE}{find}{current}       = 0 ;
$self->{ACTIONS_STORAGE}{find}{matches_array} = \@matching ;

my $index = 0 ;
$self->{ACTIONS_STORAGE}{find}{matches}{$_} = $index++ for @matching ; 

App::Asciio::Actions::ElementsManipulation::temporary_move_element_to_front
	(
	$self,
	$self->{ACTIONS_STORAGE}{find}{matches_array}[$self->{ACTIONS_STORAGE}{find}{current}],
	) ;
}

#----------------------------------------------------------------------------------------------

sub new_search
{
my ($self, $all) = @_ ;

$self->update_display() ;

my $regexp = get_regexp() ;

return unless(defined $regexp && $regexp ne '') ;

search($self, $regexp) ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub replace
{
my ($self, $all) = @_ ;

my ($regexp, $replacement) = (get_regexp(), get_replacement()) ;

return unless(defined $regexp && $regexp ne '' && defined $replacement && $replacement ne '') ;

delete $self->{ACTIONS_STORAGE}{find} ; 

#todo: decide what to search in, selected, not selected, both
my @matching = $self->get_elements_matching
			(
			$App::Asciio::FIND_IN_TITLE | $App::Asciio::FIND_IN_TEXT,
			$regexp,
			$self->{ELEMENTS}->@*
			) ;

if(@matching)
	{
	$self->create_undo_snapshot() ;
	
	$self->select_elements(1, @matching) ;
	$self->update_display() ;
	
	my $replacements = $self->replace_in_title_and_text($regexp, $replacement, @matching) ;
	print STDERR "replacements: $replacements\n" ;
	}

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub next      
{
my ($self) = @_ ;

return unless defined $self->{ACTIONS_STORAGE}{find}{matches_array} ;

$self->{ACTIONS_STORAGE}{find}{current} = $self->{ACTIONS_STORAGE}{find}{current} >= $#{ $self->{ACTIONS_STORAGE}{find}{matches_array} } 
						? 0
						: $self->{ACTIONS_STORAGE}{find}{current} + 1 ;

App::Asciio::Actions::ElementsManipulation::temporary_move_element_to_front
	(
	$self,
	$self->{ACTIONS_STORAGE}{find}{matches_array}[$self->{ACTIONS_STORAGE}{find}{current}],
	) ;

App::Asciio::Actions::Unsorted::scroll_to_element($self, $self->{ACTIONS_STORAGE}{find}{matches_array}[$self->{ACTIONS_STORAGE}{find}{current}]) ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub previous  
{
my ($self) = @_ ;

return unless defined $self->{ACTIONS_STORAGE}{find}{matches_array} ;

$self->{ACTIONS_STORAGE}{find}{current} = $self->{ACTIONS_STORAGE}{find}{current} <= 0 
						? $#{ $self->{ACTIONS_STORAGE}{matches_array} }
						: $self->{ACTIONS_STORAGE}{find}{current} - 1 ;

App::Asciio::Actions::ElementsManipulation::temporary_move_element_to_front
	(
	$self,
	$self->{ACTIONS_STORAGE}{find}{matches_array}[$self->{ACTIONS_STORAGE}{find}{current}],
	) ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub zoom
{
my ($self, $type) = @_ ;

if ( 0 == $type)
	{
	App::Asciio::Actions::Unsorted::zoom_extents
						(
						$self,
						$self->{ACTIONS_STORAGE}{find}{matches_array}->@*,
						) ;
	}
else
	{
	App::Asciio::Actions::Unsorted::zoom($self, $type) ;
	}
}

#----------------------------------------------------------------------------------------------

sub select
{
my ($self, $add) = @_ ;

if('all' eq $add)
	{
	$self->select_elements(1, $self->{ACTIONS_STORAGE}{find}{matches_array}->@*) ;
	}
else
	{
	$self->deselect_all_elements unless $add ;
	$self->select_elements(1, $self->{ACTIONS_STORAGE}{find}{matches_array}[$self->{ACTIONS_STORAGE}{find}{current}]) ;
	}

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub clear
{
my ($self) = @_ ;

delete $self->{ACTIONS_STORAGE}{find} ; 

App::Asciio::Actions::ElementsManipulation::move_temporary_back($self) ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------
1 ;

