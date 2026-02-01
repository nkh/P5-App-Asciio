
#!/usr/bin/env perl
use strict;
use warnings;
use JSON::MaybeXS;
use Getopt::Long qw(GetOptions :config no_ignore_case bundling);
use List::Util qw(min max);

my %opt = (
    # feature toggles (default: enabled)
    no_constraint_colors  => 0,
    no_fixed_highlighting => 0,
    no_source_sink        => 0,
    no_edge_labels        => 0,
    no_routing_metadata   => 0,
    no_grid               => 0,
    no_clusters           => 0,
    no_bbox               => 0,
    no_obstacles          => 0,

    # custom colors
    color_align_vertical   => undef,
    color_align_horizontal => undef,
    color_order_left_right => undef,
    color_order_top_bottom => undef,
    color_fixed            => undef,
    color_source           => undef,
    color_sink             => undef,
    color_grid             => undef,
    color_bbox             => undef,
    color_cluster          => undef,
    color_page_bounds      => undef,

    # opacity
    cluster_opacity => 0.15,
    grid_opacity    => 0.08,
);

my $output_file;

GetOptions(
    "o|output=s"            => \$output_file,

    "no-constraint-colors"  => \$opt{no_constraint_colors},
    "no-fixed-highlighting" => \$opt{no_fixed_highlighting},
    "no-source-sink"        => \$opt{no_source_sink},
    "no-edge-labels"        => \$opt{no_edge_labels},
    "no-routing-metadata"   => \$opt{no_routing_metadata},
    "no-grid"               => \$opt{no_grid},
    "no-clusters"           => \$opt{no_clusters},
    "no-bbox"               => \$opt{no_bbox},
    "no-obstacles"          => \$opt{no_obstacles},

    "color-align-vertical=s"   => \$opt{color_align_vertical},
    "color-align-horizontal=s" => \$opt{color_align_horizontal},
    "color-order-left-right=s" => \$opt{color_order_left_right},
    "color-order-top-bottom=s" => \$opt{color_order_top_bottom},
    "color-fixed=s"            => \$opt{color_fixed},
    "color-source=s"           => \$opt{color_source},
    "color-sink=s"             => \$opt{color_s
ink},
    "color-grid=s"             => \$opt{color_grid},
    "color-bbox=s"             => \$opt{color_bbox},
    "color-cluster=s"          => \$opt{color_cluster},
    "color-page-bounds=s"      => \$opt{color_page_bounds},

    "cluster-opacity=f"        => \$opt{cluster_opacity},
    "grid-opacity=f"           => \$opt{grid_opacity},
) or die "Unknown option. Usage: layout_viewer_html_svg.pl [options] [-o output.html]\n";

# defaults (overridable by CLI)
my %colors = (
    align_vertical      => $opt{color_align_vertical}      // '#d0e0ff',
    align_horizontal    => $opt{color_align_horizontal}    // '#d0ffd0',
    order_left_right    => $opt{color_order_left_right}    // '#ffe0b0',
    order_top_bottom    => $opt{color_order_top_bottom}    // '#e0b0ff',
    fixed               => $opt{color_fixed}               // '#ff0000',
    source              => $opt{color_source}              // '#00aa00',
    sink                => $opt{color_sink}                // '#0000aa',
    grid                => $opt{color_grid}                // '#cccccc',
    bbox                => $opt{color_bbox}                // '#000000',
    cluster             => $opt{color_cluster}             // '#ff00ff',
    page_bounds         => $opt{color_page_bounds}         // '#444444',
);

my %features = (
    constraint_colors  => !$opt{no_constraint_colors},
    fixed_highlighting => !$opt{no_fixed_highlighting},
    source_sink        => !$opt{no_source_sink},
    edge_labels        => !$opt{no_edge_labels},
    routing_metadata   => !$opt{no_routing_metadata},
    grid               => !$opt{no_grid},
    clusters           => !$opt{no_clusters},
    bbox               => !$opt{no_bbox},
    obstacles          => !$opt{no_obstacles},
);

my %opacity = (
    cluster => $opt{cluster_opacity},
    grid    => $opt{grid_opacity},
);

# Read JSON from STDIN
my $json_text = do { local $/; <STDIN> };
die "No input\n" unless defined $json_text && length $json_text;

my $json = JSON::MaybeXS->new(utf8 => 1);
my $resp = eval { $json->decode($json_text) };
die "Invalid JSON on STDIN: $@\n" if $@ || ref $resp ne 'HASH';

my $nodes       = $resp->{nodes}       || [];
my $edges       = $resp->{edges}       || [];
my $constraints = $resp->{constraints} || {};
my $metadata    = $resp->{metadata}    || {};
my $engine      = $metadata->{engine}  || {};

# Compute bounds
my ($min_x, $min_y, $max_x, $max_y);

for my $n (@$nodes) {
    my $x = $n->{x} // 0;
    my $y = $n->{y} // 0;
    my $w = $n->{width}  // 60;
    my $h = $n->{height} // 40;

    $min_x = defined $min_x ? min($min_x, $x - $w/2) : $x - $w/2;
    $min_y = defined $min_y ? min($min_y, $y - $h/2) : $y - $h/2;
    $max_x = defined $max_x ? max($max_x, $x + $w/2) : $x + $w/2;
    $max_y = defined $max_y ? max($max_y, $y + $h/2) : $y + $h/2;
}

for my $e (@$edges) {
    my $route = $e->{route} || [];
    for my $p (@$route) {
        my ($x, $y) = ref $p eq 'ARRAY' ? @$p : ($p->{x}, $p->{y});
        next unless defined $x && defined $y;
        $min_x = defined $min_x ? min($min_x, $x) : $x;
        $min_y = defined $min_y ? min($min_y, $y) : $y;
        $max_x = defined $max_x ? max($max_x, $x) : $x;
        $max_y = defined $max_y ? max($max_y, $y) : $y;
    }
}

$min_x //= 0;
$min_y //= 0;
$max_x //= 800;
$max_y //= 600;

my $pad = 20;
$min_x -= $pad;
$min_y -= $pad;
$max_x += $pad;
$max_y += $pad;

my $width  = $max_x - $min_x;
my $height = $max_y - $min_y;

my %node_by_id = map { $_->{id} => $_ } @$nodes;

sub esc {
    my ($s) = @_;
    return '' unless defined $s;
    $s =~ s/&/&amp;/g;
    $s =~ s/</&lt;/g;
    $s =~ s/>/&gt;/g;
    $s =~ s/"/&quot;/g;
    return $s;
}

# Simple classification for source/sink (for initial roles)
my (%in, %out);
for my $e (@$edges) {
    $out{$e->{source}}++;
    $in{$e->{target}}++;
}

# Engine info summary
my @info_bits;
push @info_bits, "layout: $engine->{layout_time_ms} ms"   if defined $engine->{layout_time_ms};
push @info_bits, "routing: $engine->{routing_time_ms} ms" if defined $engine->{routing_time_ms};
push @info_bits, "nodes: $engine->{node_count}"           if defined $engine->{node_count};
push @info_bits, "edges: $engine->{edge_count}"           if defined $engine->{edge_count};
push @info_bits, "turns: $engine->{total_turns}"          if defined $engine->{total_turns};
push @info_bits, "routing: $engine->{routing_mode}"       if defined $engine->{routing_mode};

my $engine_info_str = esc(join(" · ", @info_bits));

# JSON blobs for JS
my $constraints_json = $json->encode($constraints);
my $engine_json      = $json->encode($engine);
my $config_json      = $json->encode({
    colors   => \%colors,
    features => \%features,
    opacity  => \%opacity,
});

my $html = <<"HTML";
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Layout Engine Viewer</title>
<link rel="stylesheet" href="viewer.css">
</head>
<body>
<div id="toolbar">
  <div class="left">
    <button id="fitBtn">Fit</button>
    <button id="zoomInBtn">+</button>
    <button id="zoomOutBtn">−</button>
    <label><input type="checkbox" id="toggleNodes" checked> Nodes</label>
    <label><input type="checkbox" id="toggleEdges" checked> Edges</label>
    <label><input type="checkbox" id="toggleGrid" @{[$features{grid} ? 'checked' : '']}> Grid</label>
    <label><input type="checkbox" id="toggleClusters" @{[$features{clusters} ? 'checked' : '']}> Clusters</label>
    <label><input type="checkbox" id="toggleBBox" @{[$features{bbox} ? 'checked' : '']}> BBox</label>
  </div>
  <div class="right">
    <span id="engine-info">$engine_info_str</span>
  </div>
</div>
<div id="container">
<svg id="graph"
     xmlns="http://www.w3.org/2000/svg"
     width="$width"
     height="$height"
     viewBox="$min_x $min_y $width $height"
     font-family="sans-serif"
     font-size="12">
  <defs>
    <marker id="arrow" viewBox="0 0 10 10" refX="10" refY="5"
            markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 0 L 10 5 L 0 10 z" fill="#333" />
    </marker>
  </defs>

  <g id="layer-grid" class="layer-grid"></g>
  <g id="layer-clusters" class="layer-clusters"></g>
  <g id="layer-bbox" class="layer-bbox"></g>
  <g id="layer-obstacles" class="layer-obstacles"></g>

  <g id="layer-edges" class="layer-edges" stroke="#333" stroke-width="1.5" fill="none">
HTML

# Edges
for my $e (@$edges) {
    my $src_id = $e->{source};
    my $dst_id = $e->{target};
    my $src = $node_by_id{$src_id};
    my $dst = $node_by_id{$dst_id};

    my @points;
    if ($e->{route} && @{$e->{route}}) {
        for my $p (@{$e->{route}}) {
            if (ref $p eq 'ARRAY') {
                push @points, [ $p->[0], $p->[1] ];
            } else {
                push @points, [ $p->{x}, $p->{y} ];
            }
        }
    } elsif ($src && $dst) {
        my $sx = $src->{x};
        my $sy = $src->{y};
        my $dx = $dst->{x};
        my $dy = $dst->{y};
        @points = ( [ $sx, $sy ], [ $dx, $dy ] );
    } else {
        next;
    }

    my $d = "M $points[0]->[0] $points[0]->[1]";
    for my $i (1 .. $#points) {
        $d .= " L $points[$i]->[0] $points[$i]->[1]";
    }

    my $turns = @points >= 2 ? @points - 1 : 0;
    my $label = "$src_id → $dst_id";
    $label .= " ($turns bends)" if $turns && $features{routing_metadata};

    my $tooltip = "Edge $src_id → $dst_id";
    $tooltip .= "\\nturns: $turns" if $turns && $features{routing_metadata};
    $tooltip .= "\\npoints: " . scalar(@points);

    $html .= qq{
    <g class="edge-group">
      <path class="edge" d="$d" marker-end="url(#arrow)" data-tooltip="} . esc($tooltip) . qq{" />
};
    if ($features{edge_labels}) {
        my $mid = int(@points / 2);
        my ($mx, $my) = @{$points[$mid]};
        $html .= qq{
      <text class="edge-label" x="$mx" y="@{[$my - 4]}" text-anchor="middle" fill="#555">$label</text>
};
    }
    $html .= "    </g>\n";
}

$html .= <<"HTML_NODES";
  </g>

  <g id="layer-nodes" class="layer-nodes">
HTML_NODES

# Nodes
for my $n (@$nodes) {
    my $id = $n->{id};
    my $x  = $n->{x} // 0;
    my $y  = $n->{y} // 0;
    my $w  = $n->{width}  // 60;
    my $h  = $n->{height} // 40;

    my @roles;
    push @roles, 'source' if $out{$id} && !$in{$id};
    push @roles, 'sink'   if $in{$id} && !$out{$id};

    my $tooltip = "Node $id";
    $tooltip .= "\\nrole: " . join(", ", @roles) if @roles;
    $tooltip .= "\\nposition: ($x, $y)";
    $tooltip .= "\\nsize: ${w}×${h}";

    $html .= qq{
    <g class="node" data-node-id="} . esc($id) . qq{" data-tooltip="} . esc($tooltip) . qq{">
      <rect class="node-rect"
            x="@{[$x - $w/2]}" y="@{[$y - $h/2]}"
            width="$w" height="$h"
            rx="4" ry="4"/>
      <text class="node-label" x="$x" y="@{[$y + 4]}" text-anchor="middle">$id</text>
    </g>
};
}

$html .= <<"HTML_END_SVG";
  </g>
</svg>
</div>
<div id="tooltip"></div>

<script>
window.LAYOUT_VIEWER_DATA = {
  constraints: $constraints_json,
  engine: $engine_json
};
window.LAYOUT_VIEWER_CONFIG = $config_json;
</script>
<script src="viewer.js"></script>
</body>
</html>
HTML_END_SVG

if ($output_file) {
    open my $fh, ">:encoding(UTF-8)", $output_file
        or die "Cannot write to $output_file: $!\n";
    print $fh $html;
    close $fh;
} else {
    print $html;
}

__END__

=head1 NAME

layout_viewer_html_svg.pl - Extended interactive HTML+SVG viewer for layout engine output

=head1 SYNOPSIS

  cat response.json | layout_viewer_html_svg.pl > graph.html
  cat response.json | layout_viewer_html_svg.pl -o graph.html

=head1 DESCRIPTION

Reads a JSON layout engine response from STDIN and produces an HTML page
with an inline SVG graph, referencing external C<viewer.css> and C<viewer.js>.

Supports:

=over 4

=item * Zoom, pan, fit-to-view

=item * Tooltips for nodes and edges

=item * Constraint-aware coloring

=item * Fixed/source/sink highlighting

=item * Layer toggles (nodes, edges, grid, clusters, bbox)

=item * Routing grid, clusters, and bounding box overlays

=item * User-controlled colors and feature toggles via CLI

=back

=head1 OPTIONS

Same semantics as the static SVG visualizer:

=over 4

=item B<-o>, B<--output> I<FILE>

Write HTML to I<FILE> instead of STDOUT.

=item B<--no-constraint-colors>

Disable constraint-based node coloring.

=item B<--no-fixed-highlighting>

Disable fixed-node highlighting.

=item B<--no-source-sink>

Disable source/sink highlighting.

=item B<--no-edge-labels>

Disable edge labels.

=item B<--no-routing-metadata>

Disable routing metadata in labels/tooltips.

=item B<--no-grid>, B<--no-clusters>, B<--no-bbox>, B<--no-obstacles>

Disable respective overlays.

=item B<--color-...>, B<--cluster-opacity>, B<--grid-opacity>

Override default colors and opacities.

=back

=cut
