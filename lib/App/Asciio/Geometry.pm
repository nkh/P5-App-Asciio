
package App::Asciio::Geometry ;

use strict ;
use warnings ;

use List::Util qw(max) ;
use List::MoreUtils qw(any) ;

use Exporter 'import';
our @EXPORT_OK = qw(
	point_in_polygon
	interpolate
	) ;

#-----------------------------------------------------------------------------

# determine whether the point is inside the polygon through the ray method
# https://en.wikipedia.org/wiki/Point_in_polygon
sub point_in_polygon 
{
my ($point, $polygon) = @_;

my ($point_x, $point_y) = @$point;
my $is_inside = 0;
my $vertex_num = scalar(@$polygon);

for
	(
	my $current_index = 0, my $previous_index = $vertex_num - 1; 
	$current_index < $vertex_num; 
	$previous_index = $current_index++
	) 
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
# interpolate($x0, $y0, $x1, $y1, $x_threshold, $y_threshold, $existing_points)
#
# Generate integer points along the line from (x0,y0) to (x1,y1).
# DDA-style: steps = max(|dx|,|dy|), t = i/steps, then round to int.
#
# Parameters:
#   $x0,$y0,$x1,$y1  : line endpoints (integers)
#   $existing_points : optional arrayref of existing points (appended to, duplicates skipped)
#   $x_threshold     : The abscissa threshold means that coordinates are 
#						generated only when the abscissa difference exceeds the threshold.
#						Can be a value or a sub
#   $y_threshold     : The ordinate threshold means that coordinates are
#						generated only when the ordinate difference exceeds the threshold.
#						Can be a value or a sub
#
# Returns:
#   list of [$x,$y] points
#
# Reference:
#   Digital differential analyzer (graphics algorithm)
#   https://en.wikipedia.org/wiki/Digital_differential_analyzer_(graphics_algorithm)
sub interpolate
{
my ($x0, $y0, $x1, $y1, $x_threshold, $y_threshold, $existing_points) = @_ ;

$x_threshold ||= 1 ;
$y_threshold ||= 1 ;
my @points = $existing_points ? @$existing_points : () ;

my $step_index = 0 ;

my ($dx, $dy) = ($x1 - $x0, $y1 - $y0) ;
my $steps = max(abs($dx), abs($dy)) ;

for(my $i = 0; $i <= $steps; $i++)
	{
	my $t = $steps == 0 ? 0 : ($i / $steps) ;
	my ($x, $y) = (int($x0 + $dx * $t), int($y0 + $dy * $t)) ;
	
	# Remove duplicate points
	next if any { $_->[0] == $x && $_->[1] == $y } @points ;

	my $x_threshold_value = ref $x_threshold eq 'CODE' ? $x_threshold->($step_index) : $x_threshold ;
	my $y_threshold_value = ref $y_threshold eq 'CODE' ? $y_threshold->($step_index) : $y_threshold ;
	
	if (!@points
		|| abs($y - $points[-1][1]) >= $y_threshold_value
		|| abs($x - $points[-1][0]) >= $x_threshold_value)
		{
		push @points, [$x, $y] ;
		$step_index++ ;
		}
	}
return @points ;
}

#-----------------------------------------------------------------------------

1 ;
