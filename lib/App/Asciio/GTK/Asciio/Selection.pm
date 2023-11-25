
package App::Asciio::GTK::Asciio ;

use strict ; use warnings ;

use App::Asciio::ZBuffer ;


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
sub mouse_polygon_selection_switch
{
my ($self) = @_ ;

if(@{$self->{SELECTION_POLYGON} // []} == 0)
	{
	$self->deselect_all_elements();

	my ($x, $y) = @{$self}{'MOUSE_X', 'MOUSE_Y'};
	$self->{SELECTION_POLYGON} = [[$x, $y]];
	}
else
	{
	$self->{SELECTION_POLYGON} = [];
	}
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
my ($self) = @_ ;

$self->deselect_all_elements() ;

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
		$self->select_elements(1, $element);
		}
	}
}

#----------------------------------------------------------------------------------------------

1 ;

