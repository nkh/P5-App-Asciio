
package App::Asciio::Actions::Selection ;

use strict ; use warnings ;
use List::MoreUtils qw(any) ;

use App::Asciio::Geometry qw(interpolate) ;
use App::Asciio::Actions::Mouse ;

use constant
	{
	SELECT   => 1,
	DESELECT => 0,
	} ;

my $select_type = SELECT ;
my @existing_points ;

#----------------------------------------------------------------------------------------------

sub selection_mode_flip
{
my ($self) = @_ ;

$select_type ^= 1 ;

$self->change_cursor(($select_type == SELECT) ? 'dot' : 'tcross') ;
}

#----------------------------------------------------------------------------------------------

sub selection_enter
{
my ($self) = @_ ;

$select_type = SELECT ;
$self->change_cursor('dot') ;
}

#----------------------------------------------------------------------------------------------

sub selection_escape
{
my ($self) = @_ ;

$self->change_cursor('left_ptr') ;
}

#----------------------------------------------------------------------------------------------

sub select_motion
{
my ($self, $event) = @_ ;
my ($x, $y) = @{$event->{COORDINATES}}[0, 1] ;
($self->{PREVIOUS_X}, $self->{PREVIOUS_Y}) = ($self->{MOUSE_X}, $self->{MOUSE_Y}) ;
($self->{MOUSE_X}, $self->{MOUSE_Y}) = ($x, $y) ;

if($event->{STATE} eq 'dragging-button1' && ($self->{PREVIOUS_X} != $x || $self->{PREVIOUS_Y} != $y))
	{
	my @points = interpolate($self->{PREVIOUS_X}, $self->{PREVIOUS_Y}, $x, $y, 1, 1, \@existing_points) ;
	for my $point (@points)
		{
		next if any { $_->[0] == $point->[0] && $_->[1] == $point->[1]} @existing_points ;
		($self->{MOUSE_X}, $self->{MOUSE_Y}) = @$point ;
		select_elements($self) ;
		}
	@existing_points = @points ;
	}
if($event->{STATE} ne 'dragging-button1')
	{
	@existing_points = ([$self->{MOUSE_X}, $self->{MOUSE_Y}]) ;
	$self->update_display ;
	}
}
#----------------------------------------------------------------------------------------------
sub select_elements
{
my ($self) = @_ ;
my @elements = grep { $self->is_over_element($_, $self->{MOUSE_X}, $self->{MOUSE_Y})} reverse @{$self->{ELEMENTS}} ;

if(@elements)
	{
	# It will be slower here
	# $self->create_undo_snapshot() ;

	$self->select_elements($select_type, @elements) ;
	@existing_points = ([$self->{MOUSE_X}, $self->{MOUSE_Y}]) ;
	$self->update_display() ;
	}
}


#----------------------------------------------------------------------------------------------

1 ;


