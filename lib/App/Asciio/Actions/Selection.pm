
package App::Asciio::Actions::Selection ;

use strict ; use warnings ;
use List::Util qw(max) ;
use List::MoreUtils qw(any) ;

use App::Asciio::Actions::Mouse ;

my $select_type = 1 ;
my @last_points ;

#----------------------------------------------------------------------------------------------
sub interpolate 
{
my ($x0, $y0, $x1, $y1) = @_;
my @points = @last_points;
my $point_offset = 0;

my ($dx, $dy) = ($x1 - $x0, $y1 - $y0) ;
my $steps = max(abs($dx), abs($dy));

for(my $i = 0; $i <= $steps; $i++)
	{
	my $t = $steps == 0 ? 0 : ($i / $steps);
	my ($x, $y) = (int($x0 + $dx * $t), int($y0 + $dy * $t)) ;
	
	next if any { $_->[0] == $x && $_->[1] == $y } @points ;
	
	if (!@points
		|| $y != $points[$#points][1]
		|| abs($x - $points[$#points][0]) >= 1)
		{
		push @points, [$x, $y];
		$point_offset++;
		}
	}
return @points ;
}

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

sub select_motion_with_group
{
my ($self, $event) = @_ ;
select_motion($self, $event, 0) ;
}


sub select_motion_ignore_group
{
my ($self, $event) = @_ ;
select_motion($self, $event, 1) ;
}

#----------------------------------------------------------------------------------------------

sub select_motion
{
my ($self, $event, $is_ignore_group) = @_ ;
my ($x, $y) = @{$event->{COORDINATES}}[0, 1] ;
($self->{PREVIOUS_X}, $self->{PREVIOUS_Y}) = ($self->{MOUSE_X}, $self->{MOUSE_Y}) ;
($self->{MOUSE_X}, $self->{MOUSE_Y}) = ($x, $y) ;

if($event->{STATE} eq 'dragging-button1' && ($self->{PREVIOUS_X} != $x || $self->{PREVIOUS_Y} != $y))
	{
	my @points = interpolate($self->{PREVIOUS_X}, $self->{PREVIOUS_Y}, $x, $y) ;
	for my $point (@points)
		{
		next if any { $_->[0] == $point->[0] && $_->[1] == $point->[1]} @last_points ;
		($self->{MOUSE_X}, $self->{MOUSE_Y}) = @$point ;
		select_elements($self, $is_ignore_group) ;
		}
	@last_points = @points ;
	}
if($event->{STATE} ne 'dragging-button1')
	{
	@last_points = ([$self->{MOUSE_X}, $self->{MOUSE_Y}]) ;
	$self->update_display ;
	}
}
#----------------------------------------------------------------------------------------------
sub select_elements
{
my ($self, $is_ignore_group) = @_ ;
my @elements = grep { $self->is_over_element($_, $self->{MOUSE_X}, $self->{MOUSE_Y})} reverse @{$self->{ELEMENTS}} ;

if(@elements)
	{
	# It will be slower here
	# $self->create_undo_snapshot() ;

	if($is_ignore_group)
		{
		map { $_->{SELECTED} =  ($select_type) ? ++$self->{SELECTION_INDEX} : 0 } @elements;
		}
	else
		{
		$self->select_elements($select_type, @elements) ;
		}
	@last_points = ([$self->{MOUSE_X}, $self->{MOUSE_Y}]) ;
	$self->update_display() ;
	}
}


#----------------------------------------------------------------------------------------------

1 ;

