package LibAvoidRenderer ;

use strict ;
use warnings ;
use Cairo ;

use Exporter 'import' ;
our @EXPORT_OK = qw(
	parse_graph_input
	parse_graph_output
	parse_color_config
	calculate_render_parameters
	render_png
	render_svg
	render_to_cairo
	) ;

our @DEFAULT_COLORS =
	(
	[0.20, 0.60, 0.86],
	[0.40, 0.76, 0.65],
	[1.00, 0.74, 0.53],
	[0.99, 0.55, 0.38],
	[0.90, 0.54, 0.76],
	[0.70, 0.51, 0.86],
	[0.38, 0.76, 0.99],
	[0.55, 0.90, 0.41],
	[1.00, 0.85, 0.18],
	[0.90, 0.35, 0.35],
	[0.47, 0.71, 0.84],
	[0.80, 0.52, 0.25],
	[0.74, 0.74, 0.13],
	[0.58, 0.40, 0.74],
	[0.35, 0.80, 0.80],
	[0.96, 0.51, 0.19],
	) ;

our $DEFAULT_PORT_COLOR       = [0.90, 0.30, 0.30] ;
our $DEFAULT_EDGE_COLOR       = [0.20, 0.50, 0.80] ;
our $DEFAULT_CLUSTER_COLOR    = [0.75, 0.75, 0.75] ;
our $DEFAULT_BACKGROUND_COLOR = [1.00, 1.00, 1.00] ;

# ------------------------------------------------------------------------------

sub parse_graph_input
{
my ($input_text) = @_ ;

my %graph =
	(
	nodes           => {},
	ports           => {},
	edges           => [],
	clusters        => {},
	options         => {},
	penalties       => {},
	routing_options => {},
	) ;

my $in_graph = 0 ;

foreach my $line (split /\n/, $input_text)
	{
	$line =~ s/^\s+|\s+$//g ;
	next if $line eq '' ;
	next if $line =~ /^#/ ;
	
	my $uc_line = uc($line) ;
	
	if ($uc_line eq 'GRAPH')
		{
		$in_graph = 1 ;
		next ;
		}
	
	if ($uc_line eq 'GRAPHEND')
		{
		$in_graph = 0 ;
		next ;
		}
	
	if ($uc_line =~ /^OPTION\s+(\S+)\s+(.+)$/i)
		{
		$graph{options}{$1} = $2 ;
		next ;
		}
	
	if ($uc_line =~ /^PENALTY\s+(\S+)\s+(.+)$/i)
		{
		$graph{penalties}{$1} = $2 ;
		next ;
		}
	
	if ($uc_line =~ /^ROUTINGOPTION\s+(\S+)\s+(.+)$/i)
		{
		$graph{routing_options}{$1} = $2 ;
		next ;
		}
	
	if ($in_graph)
		{
		if ($uc_line =~ /^NODE\s+(\d+)\s+([\d.\-]+)\s+([\d.\-]+)\s+([\d.\-]+)\s+([\d.\-]+)\s+(\d+)\s+(\d+)$/i)
			{
			my ($id, $x1, $y1, $x2, $y2, $incoming, $outgoing) = ($1, $2, $3, $4, $5, $6, $7) ;
			$graph{nodes}{$id} =
				{
				id       => $id,
				x1       => $x1,
				y1       => $y1,
				x2       => $x2,
				y2       => $y2,
				incoming => $incoming,
				outgoing => $outgoing,
				ports    => [],
				} ;
			}
		elsif ($uc_line =~ /^PORT\s+(\d+)\s+(\d+)\s+(\S+)\s+([\d.\-]+)\s+([\d.\-]+)$/i)
			{
			my ($port_id, $node_id, $side, $x, $y) = ($1, $2, $3, $4, $5) ;
			$graph{ports}{$port_id} =
				{
				id      => $port_id,
				node_id => $node_id,
				side    => $side,
				x       => $x,
				y       => $y,
				} ;
			push @{$graph{nodes}{$node_id}{ports}}, $port_id ;
			}
		elsif ($uc_line =~ /^(PEDGEP|PEDGE|EDGEP|EDGE)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)$/i)
			{
			my ($edge_type, $edge_id, $src_node, $tgt_node, $src_port, $tgt_port) = ($1, $2, $3, $4, $5, $6) ;
			push @{$graph{edges}},
				{
				type      => uc($edge_type),
				id        => $edge_id,
				src_node  => $src_node,
				tgt_node  => $tgt_node,
				src_port  => $src_port,
				tgt_port  => $tgt_port,
				} ;
			}
		elsif ($uc_line =~ /^CLUSTER\s+(\d+)\s+([\d.\-]+)\s+([\d.\-]+)\s+([\d.\-]+)\s+([\d.\-]+)$/i)
			{
			my ($id, $x1, $y1, $x2, $y2) = ($1, $2, $3, $4, $5) ;
			$graph{clusters}{$id} =
				{
				id => $id,
				x1 => $x1,
				y1 => $y1,
				x2 => $x2,
				y2 => $y2,
				} ;
			}
		}
	}

return \%graph ;
}

# ------------------------------------------------------------------------------

sub parse_graph_output
{
my ($output_text) = @_ ;

my %layout =
	(
	edges => {},
	) ;

my $in_layout = 0 ;

foreach my $line (split /\n/, $output_text)
	{
	$line =~ s/^\s+|\s+$//g ;
	next if $line eq '' ;
	next if $line =~ /^#/ ;
	
	my $uc_line = uc($line) ;
	
	if ($uc_line eq 'LAYOUT')
		{
		$in_layout = 1 ;
		next ;
		}
	
	if ($uc_line eq 'DONE')
		{
		$in_layout = 0 ;
		next ;
		}
	
	if ($in_layout && $line =~ /^EDGE\s+(\d+)=(.+)$/i)
		{
		my ($edge_id, $route_str) = ($1, $2) ;
		my @coords = split /\s+/, $route_str ;
		my @points ;
		for (my $i = 0; $i < @coords; $i += 2)
			{
			push @points, { x => $coords[$i], y => $coords[$i+1] } ;
			}
		$layout{edges}{$edge_id} = \@points ;
		}
	}

return \%layout ;
}

# ------------------------------------------------------------------------------

sub parse_color_config
{
my ($config_text) = @_ ;

my %colors ;

foreach my $line (split /\n/, $config_text)
	{
	$line =~ s/^\s+|\s+$//g ;
	next if $line eq '' ;
	next if $line =~ /^#/ ;
	
	if ($line =~ /^node\s+(\d+)\s+(.+)$/i)
		{
		my ($node_id, $color_spec) = ($1, $2) ;
		$colors{node}{$node_id} = parse_color_spec($color_spec) ;
		}
	elsif ($line =~ /^default\s+(.+)$/i)
		{
		$colors{node}{default} = parse_color_spec($1) ;
		}
	elsif ($line =~ /^port\s+(.+)$/i)
		{
		$colors{port} = parse_color_spec($1) ;
		}
	elsif ($line =~ /^edge\s+(.+)$/i)
		{
		$colors{edge} = parse_color_spec($1) ;
		}
	elsif ($line =~ /^cluster\s+(.+)$/i)
		{
		$colors{cluster} = parse_color_spec($1) ;
		}
	elsif ($line =~ /^background\s+(.+)$/i)
		{
		$colors{background} = parse_color_spec($1) ;
		}
	}

return \%colors ;
}

# ------------------------------------------------------------------------------

sub parse_color_spec
{
my ($spec) = @_ ;

$spec =~ s/^\s+|\s+$//g ;

if ($spec =~ /^#([0-9a-fA-F]{6})$/)
	{
	my $hex = $1 ;
	my $r   = hex(substr($hex, 0, 2)) / 255.0 ;
	my $g   = hex(substr($hex, 2, 2)) / 255.0 ;
	my $b   = hex(substr($hex, 4, 2)) / 255.0 ;
	return [$r, $g, $b] ;
	}
elsif ($spec =~ /^rgb\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)$/i)
	{
	return [$1 / 255.0, $2 / 255.0, $3 / 255.0] ;
	}
elsif (lc($spec) eq 'transparent')
	{
	return 'transparent' ;
	}
else
	{
	my %named_colors =
		(
		navy            => [0.00, 0.00, 0.50],
		darkblue        => [0.00, 0.00, 0.55],
		darkgreen       => [0.00, 0.39, 0.00],
		darkred         => [0.55, 0.00, 0.00],
		darkorange      => [1.00, 0.55, 0.00],
		purple          => [0.50, 0.00, 0.50],
		brown           => [0.55, 0.27, 0.07],
		teal            => [0.00, 0.50, 0.50],
		darkcyan        => [0.00, 0.55, 0.55],
		olive           => [0.50, 0.50, 0.00],
		darkolivegreen  => [0.33, 0.42, 0.18],
		indigo          => [0.29, 0.00, 0.51],
		maroon          => [0.50, 0.00, 0.00],
		darkslateblue   => [0.28, 0.24, 0.55],
		darkmagenta     => [0.55, 0.00, 0.55],
		darkgoldenrod   => [0.72, 0.53, 0.04],
		darkslategray   => [0.18, 0.31, 0.31],
		midnightblue    => [0.10, 0.10, 0.44],
		sienna          => [0.63, 0.32, 0.18],
		skyblue         => [0.53, 0.81, 0.92],
		lightcoral      => [0.94, 0.50, 0.50],
		mediumseagreen  => [0.24, 0.70, 0.44],
		gold            => [1.00, 0.84, 0.00],
		coral           => [1.00, 0.50, 0.31],
		orchid          => [0.85, 0.44, 0.84],
		mediumturquoise => [0.28, 0.82, 0.80],
		limegreen       => [0.20, 0.80, 0.20],
		) ;
	my $lc_spec = lc($spec) ;
	return $named_colors{$lc_spec} if exists $named_colors{$lc_spec} ;
	return [0.00, 0.00, 0.00] ;
	}
}

# ------------------------------------------------------------------------------

sub calculate_bounds
{
my ($graph, $layout) = @_ ;

my $min_x = 1e9 ;
my $min_y = 1e9 ;
my $max_x = -1e9 ;
my $max_y = -1e9 ;

foreach my $node_id (keys %{$graph->{nodes}})
	{
	my $node = $graph->{nodes}{$node_id} ;
	$min_x = $node->{x1} if $node->{x1} < $min_x ;
	$min_y = $node->{y1} if $node->{y1} < $min_y ;
	$max_x = $node->{x2} if $node->{x2} > $max_x ;
	$max_y = $node->{y2} if $node->{y2} > $max_y ;
	}

foreach my $port_id (keys %{$graph->{ports}})
	{
	my $port = $graph->{ports}{$port_id} ;
	my $node = $graph->{nodes}{$port->{node_id}} ;
	my $abs_x = $port->{x} + $node->{x1} ;
	my $abs_y = $port->{y} + $node->{y1} ;
	$min_x = $abs_x if $abs_x < $min_x ;
	$min_y = $abs_y if $abs_y < $min_y ;
	$max_x = $abs_x if $abs_x > $max_x ;
	$max_y = $abs_y if $abs_y > $max_y ;
	}

foreach my $edge_id (keys %{$layout->{edges}})
	{
	foreach my $point (@{$layout->{edges}{$edge_id}})
		{
		$min_x = $point->{x} if $point->{x} < $min_x ;
		$min_y = $point->{y} if $point->{y} < $min_y ;
		$max_x = $point->{x} if $point->{x} > $max_x ;
		$max_y = $point->{y} if $point->{y} > $max_y ;
		}
	}

foreach my $cluster_id (keys %{$graph->{clusters}})
	{
	my $cluster = $graph->{clusters}{$cluster_id} ;
	$min_x = $cluster->{x1} if $cluster->{x1} < $min_x ;
	$min_y = $cluster->{y1} if $cluster->{y1} < $min_y ;
	$max_x = $cluster->{x2} if $cluster->{x2} > $max_x ;
	$max_y = $cluster->{y2} if $cluster->{y2} > $max_y ;
	}

return ($min_x, $min_y, $max_x, $max_y) ;
}

# ------------------------------------------------------------------------------

sub calculate_render_parameters
{
my ($graph, $layout, %options) = @_ ;

my $border        = $options{border} // 10 ;
my $scale         = $options{scale} ;
my $canvas_width  = $options{canvas_width} ;
my $canvas_height = $options{canvas_height} ;
my $no_scale      = $options{no_scale} // 0 ;

my ($min_x, $min_y, $max_x, $max_y) = calculate_bounds($graph, $layout) ;

my $graph_width  = $max_x - $min_x ;
my $graph_height = $max_y - $min_y ;

if (!$no_scale && !defined $scale)
	{
	if (defined $canvas_width && defined $canvas_height)
		{
		my $available_width  = $canvas_width - 2 * $border ;
		my $available_height = $canvas_height - 2 * $border ;
		
		my $scale_x = $available_width / $graph_width ;
		my $scale_y = $available_height / $graph_height ;
		
		$scale = ($scale_x < $scale_y) ? $scale_x : $scale_y ;
		}
	else
		{
		$scale = 1.0 ;
		}
	}

$scale = 1.0 if $no_scale ;
$scale = 1.0 unless defined $scale ;

my $final_width  = int($graph_width * $scale + 2 * $border) ;
my $final_height = int($graph_height * $scale + 2 * $border) ;

return
	{
	min_x         => $min_x,
	min_y         => $min_y,
	max_x         => $max_x,
	max_y         => $max_y,
	graph_width   => $graph_width,
	graph_height  => $graph_height,
	scale         => $scale,
	border        => $border,
	canvas_width  => $final_width,
	canvas_height => $final_height,
	x_offset      => 0,
	y_offset      => 0,
	} ;
}

# ------------------------------------------------------------------------------

sub get_node_color
{
my ($node_id, $colors) = @_ ;

return $colors->{node}{$node_id} if exists $colors->{node}{$node_id} ;
return $colors->{node}{default} if exists $colors->{node}{default} ;

my $idx = $node_id % scalar(@DEFAULT_COLORS) ;
return $DEFAULT_COLORS[$idx] ;
}

# ------------------------------------------------------------------------------

sub render_to_cairo
{
my ($graph, $layout, $cr, %options) = @_ ;

my $params        = $options{params} // calculate_render_parameters($graph, $layout, %options) ;
my $colors        = $options{colors} // {} ;
my $show_node_ids = $options{show_node_ids} // 0 ;
my $antialias     = $options{antialias} // 0 ;

my $scale    = $params->{scale} ;
my $border   = $params->{border} ;
my $min_x    = $params->{min_x} ;
my $min_y    = $params->{min_y} ;
my $x_offset = $params->{x_offset} ;
my $y_offset = $params->{y_offset} ;

my $bg_color = $colors->{background} // $DEFAULT_BACKGROUND_COLOR ;

if ($bg_color eq 'transparent')
	{
	$cr->set_source_rgba(0, 0, 0, 0) ;
	}
else
	{
	$cr->set_source_rgb(@$bg_color) ;
	}
$cr->paint ;

if ($antialias)
	{
	$cr->set_antialias('default') ;
	$cr->set_font_options
		(
		my $font_options = Cairo::FontOptions->create
		) ;
	$font_options->set_antialias('subpixel') ;
	}
else
	{
	$cr->set_antialias('none') ;
	}

my $line_width = 1.0 * $scale ;
$line_width = 0.5 if $line_width < 0.5 ;
$cr->set_line_width($line_width) ;

my $cluster_color = $colors->{cluster} // $DEFAULT_CLUSTER_COLOR ;
$cr->set_source_rgb(@$cluster_color) ;
foreach my $cluster_id (keys %{$graph->{clusters}})
	{
	my $cluster = $graph->{clusters}{$cluster_id} ;
	my $x       = ($cluster->{x1} - $min_x) * $scale + $border + $x_offset ;
	my $y       = ($cluster->{y1} - $min_y) * $scale + $border + $y_offset ;
	my $w       = ($cluster->{x2} - $cluster->{x1}) * $scale ;
	my $h       = ($cluster->{y2} - $cluster->{y1}) * $scale ;
	$cr->rectangle($x, $y, $w, $h) ;
	$cr->stroke ;
	}

foreach my $node_id (keys %{$graph->{nodes}})
	{
	my $node  = $graph->{nodes}{$node_id} ;
	my $x     = ($node->{x1} - $min_x) * $scale + $border + $x_offset ;
	my $y     = ($node->{y1} - $min_y) * $scale + $border + $y_offset ;
	my $w     = ($node->{x2} - $node->{x1}) * $scale ;
	my $h     = ($node->{y2} - $node->{y1}) * $scale ;
	
	my $color = get_node_color($node_id, $colors) ;
	$cr->set_source_rgb(@$color) ;
	$cr->rectangle($x, $y, $w, $h) ;
	$cr->fill_preserve ;
	
	$cr->set_source_rgb(0, 0, 0) ;
	$cr->set_line_width($line_width) ;
	$cr->stroke ;
	
	if ($show_node_ids && $w > 15 && $h > 15)
		{
		$cr->set_source_rgb(0, 0, 0) ;
		$cr->select_font_face("Sans", 'normal', 'normal') ;
		my $font_size = 10 * $scale ;
		$font_size = 8 if $font_size < 8 ;
		$cr->set_font_size($font_size) ;
		
		my $text    = "$node_id" ;
		my $extents = $cr->text_extents($text) ;
		
		if ($extents->{width} < $w - 4 && $extents->{height} < $h - 4)
			{
			my $text_x = $x + ($w - $extents->{width}) / 2 - $extents->{x_bearing} ;
			my $text_y = $y + ($h - $extents->{height}) / 2 - $extents->{y_bearing} ;
			
			$cr->move_to($text_x, $text_y) ;
			$cr->show_text($text) ;
			}
		}
	}

my $port_color = $colors->{port} // $DEFAULT_PORT_COLOR ;
$cr->set_source_rgb(@$port_color) ;
foreach my $port_id (keys %{$graph->{ports}})
	{
	my $port  = $graph->{ports}{$port_id} ;
	my $node  = $graph->{nodes}{$port->{node_id}} ;
	my $abs_x = $port->{x} + $node->{x1} ;
	my $abs_y = $port->{y} + $node->{y1} ;
	my $x     = ($abs_x - $min_x) * $scale + $border + $x_offset ;
	my $y     = ($abs_y - $min_y) * $scale + $border + $y_offset ;
	my $size  = 4 * $scale ;
	$size = 2 if $size < 2 ;
	$cr->rectangle($x - $size/2, $y - $size/2, $size, $size) ;
	$cr->fill ;
	}

my $edge_color = $colors->{edge} // $DEFAULT_EDGE_COLOR ;
$cr->set_source_rgb(@$edge_color) ;
$cr->set_line_width($line_width) ;
foreach my $edge_id (keys %{$layout->{edges}})
	{
	my @points = @{$layout->{edges}{$edge_id}} ;
	if (@points > 0)
		{
		my $x = ($points[0]{x} - $min_x) * $scale + $border + $x_offset ;
		my $y = ($points[0]{y} - $min_y) * $scale + $border + $y_offset ;
		$cr->move_to($x, $y) ;
		for (my $i = 1; $i < @points; $i++)
			{
			$x = ($points[$i]{x} - $min_x) * $scale + $border + $x_offset ;
			$y = ($points[$i]{y} - $min_y) * $scale + $border + $y_offset ;
			$cr->line_to($x, $y) ;
			}
		$cr->stroke ;
		}
	
	if (@points >= 2)
		{
		my $last        = $points[-1] ;
		my $second_last = $points[-2] ;
		my $x           = ($last->{x} - $min_x) * $scale + $border + $x_offset ;
		my $y           = ($last->{y} - $min_y) * $scale + $border + $y_offset ;
		my $dx          = $last->{x} - $second_last->{x} ;
		my $dy          = $last->{y} - $second_last->{y} ;
		my $len         = sqrt($dx * $dx + $dy * $dy) ;
		if ($len > 0)
			{
			$dx /= $len ;
			$dy /= $len ;
			my $arrow_len = 5 * $scale ;
			$cr->move_to($x, $y) ;
			$cr->line_to($x - $arrow_len * $dx - $arrow_len * $dy / 2, $y - $arrow_len * $dy + $arrow_len * $dx / 2) ;
			$cr->move_to($x, $y) ;
			$cr->line_to($x - $arrow_len * $dx + $arrow_len * $dy / 2, $y - $arrow_len * $dy - $arrow_len * $dx / 2) ;
			$cr->stroke ;
			}
		}
	}
}

# ------------------------------------------------------------------------------

sub render_png
{
my ($graph, $layout, $filename, %options) = @_ ;

my $params      = calculate_render_parameters($graph, $layout, %options) ;
my $transparent = $options{transparent} // 0 ;

my $surface = Cairo::ImageSurface->create('argb32', $params->{canvas_width}, $params->{canvas_height}) ;
my $cr      = Cairo::Context->create($surface) ;

if (!$transparent)
	{
	my $colors   = $options{colors} // {} ;
	my $bg_color = $colors->{background} // $DEFAULT_BACKGROUND_COLOR ;
	
	if ($bg_color ne 'transparent')
		{
		$cr->set_source_rgb(@$bg_color) ;
		$cr->paint ;
		}
	}

render_to_cairo
	(
	$graph,
	$layout,
	$cr,
	params => $params,
	%options,
	) ;

$surface->write_to_png($filename) ;
}

# ------------------------------------------------------------------------------

sub render_svg
{
my ($graph, $layout, $filename, %options) = @_ ;

my $params        = calculate_render_parameters($graph, $layout, %options) ;
my $colors        = $options{colors} // {} ;
my $show_node_ids = $options{show_node_ids} // 0 ;

my $scale  = $params->{scale} ;
my $border = $params->{border} ;
my $min_x  = $params->{min_x} ;
my $min_y  = $params->{min_y} ;
my $width  = $params->{canvas_width} ;
my $height = $params->{canvas_height} ;

open my $fh, '>', $filename or die "Cannot write to $filename: $!" ;

print $fh qq{<?xml version="1.0" encoding="UTF-8"?>\n} ;
print $fh qq{<svg xmlns="http://www.w3.org/2000/svg" width="$width" height="$height">\n} ;

my $bg_color = $colors->{background} // $DEFAULT_BACKGROUND_COLOR ;
if ($bg_color ne 'transparent')
	{
	my $fill = sprintf("rgb(%d,%d,%d)", $bg_color->[0]*255, $bg_color->[1]*255, $bg_color->[2]*255) ;
	print $fh qq{<rect width="$width" height="$height" fill="$fill"/>\n} ;
	}

my $cluster_color  = $colors->{cluster} // $DEFAULT_CLUSTER_COLOR ;
my $cluster_stroke = sprintf("rgb(%d,%d,%d)", $cluster_color->[0]*255, $cluster_color->[1]*255, $cluster_color->[2]*255) ;
my $line_width     = 1.0 * $scale ;
$line_width = 0.5 if $line_width < 0.5 ;

foreach my $cluster_id (keys %{$graph->{clusters}})
	{
	my $cluster = $graph->{clusters}{$cluster_id} ;
	my $x       = ($cluster->{x1} - $min_x) * $scale + $border ;
	my $y       = ($cluster->{y1} - $min_y) * $scale + $border ;
	my $w       = ($cluster->{x2} - $cluster->{x1}) * $scale ;
	my $h       = ($cluster->{y2} - $cluster->{y1}) * $scale ;
	print $fh qq{<rect x="$x" y="$y" width="$w" height="$h" fill="none" stroke="$cluster_stroke" stroke-width="$line_width"/>\n} ;
	}

foreach my $node_id (keys %{$graph->{nodes}})
	{
	my $node       = $graph->{nodes}{$node_id} ;
	my $x          = ($node->{x1} - $min_x) * $scale + $border ;
	my $y          = ($node->{y1} - $min_y) * $scale + $border ;
	my $w          = ($node->{x2} - $node->{x1}) * $scale ;
	my $h          = ($node->{y2} - $node->{y1}) * $scale ;
	
	my $color      = get_node_color($node_id, $colors) ;
	my $fill_color = sprintf("rgb(%d,%d,%d)", $color->[0]*255, $color->[1]*255, $color->[2]*255) ;
	
	print $fh qq{<rect x="$x" y="$y" width="$w" height="$h" fill="$fill_color" stroke="black" stroke-width="$line_width"/>\n} ;
	
	if ($show_node_ids && $w > 15 && $h > 15)
		{
		my $font_size = 10 * $scale ;
		$font_size = 8 if $font_size < 8 ;
		my $text_x = $x + $w / 2 ;
		my $text_y = $y + $h / 2 + $font_size / 3 ;
		print $fh qq{<text x="$text_x" y="$text_y" font-family="Sans" font-size="$font_size" text-anchor="middle" fill="black">$node_id</text>\n} ;
		}
	}

my $port_color = $colors->{port} // $DEFAULT_PORT_COLOR ;
my $port_fill  = sprintf("rgb(%d,%d,%d)", $port_color->[0]*255, $port_color->[1]*255, $port_color->[2]*255) ;

foreach my $port_id (keys %{$graph->{ports}})
	{
	my $port  = $graph->{ports}{$port_id} ;
	my $node  = $graph->{nodes}{$port->{node_id}} ;
	my $abs_x = $port->{x} + $node->{x1} ;
	my $abs_y = $port->{y} + $node->{y1} ;
	my $x     = ($abs_x - $min_x) * $scale + $border ;
	my $y     = ($abs_y - $min_y) * $scale + $border ;
	my $size  = 4 * $scale ;
	$size = 2 if $size < 2 ;
	print $fh qq{<rect x="} . ($x - $size/2) . qq{" y="} . ($y - $size/2) . qq{" width="$size" height="$size" fill="$port_fill"/>\n} ;
	}

my $edge_color  = $colors->{edge} // $DEFAULT_EDGE_COLOR ;
my $edge_stroke = sprintf("rgb(%d,%d,%d)", $edge_color->[0]*255, $edge_color->[1]*255, $edge_color->[2]*255) ;

foreach my $edge_id (keys %{$layout->{edges}})
	{
	my @points = @{$layout->{edges}{$edge_id}} ;
	my $path   = "M " ;
	for (my $i = 0; $i < @points; $i++)
		{
		my $x = ($points[$i]{x} - $min_x) * $scale + $border ;
		my $y = ($points[$i]{y} - $min_y) * $scale + $border ;
		$path .= "$x $y " ;
		$path .= "L " if $i < @points - 1 ;
		}
	print $fh qq{<path d="$path" fill="none" stroke="$edge_stroke" stroke-width="$line_width"/>\n} ;
	
	if (@points >= 2)
		{
		my $last        = $points[-1] ;
		my $second_last = $points[-2] ;
		my $x           = ($last->{x} - $min_x) * $scale + $border ;
		my $y           = ($last->{y} - $min_y) * $scale + $border ;
		my $dx          = $last->{x} - $second_last->{x} ;
		my $dy          = $last->{y} - $second_last->{y} ;
		my $len         = sqrt($dx * $dx + $dy * $dy) ;
		if ($len > 0)
			{
			$dx /= $len ;
			$dy /= $len ;
			my $arrow_len = 5 * $scale ;
			my $x1        = $x - $arrow_len * $dx - $arrow_len * $dy / 2 ;
			my $y1        = $y - $arrow_len * $dy + $arrow_len * $dx / 2 ;
			my $x2        = $x - $arrow_len * $dx + $arrow_len * $dy / 2 ;
			my $y2        = $y - $arrow_len * $dy - $arrow_len * $dx / 2 ;
			print $fh qq{<path d="M $x $y L $x1 $y1 M $x $y L $x2 $y2" fill="none" stroke="$edge_stroke" stroke-width="$line_width"/>\n} ;
			}
		}
	}

print $fh qq{</svg>\n} ;
close $fh ;
}

1 ;
