
package App::Asciio::GTK::Asciio ;

use strict ; use warnings ;

use App::Asciio::ZBuffer ;


my %elements_selection_status ;


#-----------------------------------------------------------------------------

sub all_points_in_polygon
{
my ($points, $polygon) = @_;

for my $point (@$points)
	{
	return 0 unless point_in_polygon($point, $polygon);
	}

return 1;
}

#-----------------------------------------------------------------------------

# determine whether the point is inside the polygon through the ray method
# https://en.wikipedia.org/wiki/Point_in_polygon
sub point_in_polygon 
{
	my ($point, $polygon) = @_;

	my ($point_x, $point_y) = @$point;
	my $is_inside = 0;
	my $vertex_num = scalar(@$polygon);

	for (my $current_index = 0, my $previous_index = $vertex_num - 1; 
		$current_index < $vertex_num; 
		$previous_index = $current_index++) 
		{
		my ($current_vertex_x, $current_vertex_y) = @{$polygon->[$current_index]};
		my ($previous_vertex_x, $previous_vertex_y) = @{$polygon->[$previous_index]};

		if ((($current_vertex_y > $point_y) != ($previous_vertex_y > $point_y)) &&
			($point_x < ($previous_vertex_x - $current_vertex_x) * ($point_y - $current_vertex_y) / 
						($previous_vertex_y - $current_vertex_y) + $current_vertex_x)) 
			{
			$is_inside = !$is_inside;
			}
		}

return $is_inside;
}

#----------------------------------------------------------------------------------------------

sub polygon_selection_enter
{
my ($self) = @_ ;

$self->change_cursor('dot') ;
%elements_selection_status = () ;

}

#----------------------------------------------------------------------------------------------

sub polygon_selection_escape
{
my ($self) = @_ ;

$self->{SELECTION_POLYGON} = [] ;
$self->change_cursor('left_ptr') ;

}

#----------------------------------------------------------------------------------------------

sub draw_polygon_selection
{
my ($self, $gc, $character_width, $character_height) = @_ ;

if(@{$self->{SELECTION_POLYGON}//[]} > 0)
	{
    $gc->set_source_rgb(@{$self->get_color('selection_rectangle')});
    
    $gc->move_to($self->{SELECTION_POLYGON}[0][0] * $character_width, $self->{SELECTION_POLYGON}[0][1] * $character_height);
    for my $point (@{$self->{SELECTION_POLYGON}})
		{
		$gc->line_to($point->[0] * $character_width, $point->[1] * $character_height);
		}
	# draw solid line
    $gc->stroke();

    $gc->set_dash(0, 1, 4);
    $gc->move_to($self->{SELECTION_POLYGON}[0][0] * $character_width, $self->{SELECTION_POLYGON}[0][1] * $character_height);
    $gc->line_to($self->{SELECTION_POLYGON}[-1][0] * $character_width, $self->{SELECTION_POLYGON}[-1][1] * $character_height);
    $gc->close_path();
    
	# draw dotted line
    $gc->stroke();
    $gc->set_dash(0);
	}
}

#-----------------------------------------------------------------------------
sub polygon_selection
{
my ($self, $select_type) = @_ ;

for my $element (@{$self->{ELEMENTS}})
	{
	unless(exists $element->{CACHE}{COORDINATES})
		{
		my @coordinates = map { [split ';'] } keys %{App::Asciio::ZBuffer->new(0, $element)->{coordinates}};
		@coordinates = map{ [reverse @$_]} @coordinates;
		$element->{CACHE}{COORDINATES} = \@coordinates;
		}
	if(all_points_in_polygon($element->{CACHE}{COORDINATES}, $self->{SELECTION_POLYGON}))
		{
		$self->select_elements($select_type, $element);
		$elements_selection_status{$element} = 1 ;
		}
	else
		{
		if(exists($elements_selection_status{$element}))
			{
			$self->select_elements(!$select_type, $element);
			delete $elements_selection_status{$element} ;
			}
		}
	}
}

#----------------------------------------------------------------------------------------------

sub polygon_selection_motion
{
my ($self, $select_type, $event) = @_;

my ($x, $y) = @{$event->{COORDINATES}}[0,1] ;

($self->{PREVIOUS_X}, $self->{PREVIOUS_Y}) = ($self->{MOUSE_X}, $self->{MOUSE_Y}) ;
($self->{MOUSE_X}, $self->{MOUSE_Y}) = ($x, $y) ;

if($event->{STATE} eq 'dragging-button1' && ($self->{PREVIOUS_X} != $x || $self->{PREVIOUS_Y} != $y))
	{
	if(@{$self->{SELECTION_POLYGON} // []} == 0)
		{
		%elements_selection_status = () ;
		$self->{SELECTION_POLYGON} = [[$x, $y]];
		$self->change_cursor($select_type == 1 ? "dot" : "tcross") ;
		}
	else
		{
		push @{$self->{SELECTION_POLYGON}}, [$x, $y] ;
		$self->polygon_selection($select_type) ;
		}
	}

if($event->{STATE} ne 'dragging-button1')
	{
	$self->{SELECTION_POLYGON} = [] ;
	}
}

#----------------------------------------------------------------------------------------------

sub polygon_selection_button_release
{
my ($self, $event) = @_ ;

$self->{SELECTION_POLYGON} = [] ;
$self->change_cursor('dot') ;
}

#----------------------------------------------------------------------------------------------

1 ;

