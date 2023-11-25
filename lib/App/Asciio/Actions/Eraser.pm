package App::Asciio::Actions::Eraser ;

use strict ; use warnings ;

use App::Asciio::Actions::Mouse ;

#----------------------------------------------------------------------------------------------

sub eraser_enter
{
my ($self) = @_ ;

$self->change_cursor('dot') ;
}

#----------------------------------------------------------------------------------------------

sub eraser_escape
{
my ($self) = @_ ;

$self->change_cursor('left_ptr') ;
}

sub erase_elements
{
my ($self, $event) = @_ ;
my ($x, $y) = @{$event->{COORDINATES}}[0, 1] ;

if($self->{PREVIOUS_X} != $x || $self->{PREVIOUS_Y} != $y)
	{
	my @elements = grep { $self->is_over_element($_, $x, $y) } reverse @{$self->{ELEMENTS}} ;
	
	if(@elements)
		{
		$self->create_undo_snapshot() ;
		$self->delete_elements(@elements) ;
		
		$self->update_display();
		}
	}

App::Asciio::Actions::Mouse::mouse_motion($self, $event) ;
}

#----------------------------------------------------------------------------------------------

1 ;

