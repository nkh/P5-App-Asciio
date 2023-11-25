
package App::Asciio::Actions::Selection ;

use strict ; use warnings ;

use App::Asciio::Actions::Mouse ;

my $select_type = 1 ;

#----------------------------------------------------------------------------------------------

sub selection_mode_flip
{
my ($self) = @_ ;

$select_type ^= 1 ;

$self->change_cursor($select_type ? 'dot' : 'tcross') ;
}

#----------------------------------------------------------------------------------------------

sub selection_enter
{
my ($self) = @_ ;

$select_type = 1 ;
$self->change_cursor('dot') ;
}

#----------------------------------------------------------------------------------------------

sub selection_escape
{
my ($self) = @_ ;

$self->change_cursor('left_ptr') ;
}

#----------------------------------------------------------------------------------------------

sub select_elements
{
my ($self, $event) = @_ ;
my ($x, $y) = @{$event->{COORDINATES}}[0, 1] ;

if($self->{PREVIOUS_X} != $x || $self->{PREVIOUS_Y} != $y)
	{
	my @elements = grep { $self->is_over_element($_, $x, $y) } reverse @{$self->{ELEMENTS}} ;
	
	if(@elements)
		{
		$self->create_undo_snapshot() ;
		$self->select_elements($select_type, @elements) ;
		
		$self->update_display();
		}
	}

App::Asciio::Actions::Mouse::mouse_motion($self, $event) ;
}

#----------------------------------------------------------------------------------------------

1 ;

