
#!/usr/bin/env perl
use strict;
use warnings;
use JSON::MaybeXS;
use Getopt::Long qw(GetOptions :config no_ignore_case bundling);
use List::Util qw(min max);

# ============================================================
# STRICT OPTION PARSING
# ============================================================

my %opt = (
    # feature toggles
    no_constraint_colors  => 0,
    no_fixed_highlighting => 0,
    no_source_sink        => 0,
    no_edge_labels        => 0,
    no_routing_metadata   => 0,
    no_grid               => 0,
    no_obstacles          => 0,
    no_bbox               => 0,
    no_clusters           => 0,
    no_page_bounds        => 0,

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

GetOptions(
    "no-constraint-colors"  => \$opt{no_constraint_colors},
    "no-fixed-highlighting" => \$opt{no_fixed_highlighting},
    "no-source-sink"        => \$opt{no_source_sink},
    "no-edge-labels"        => \$opt{no_edge_labels},
    "no-routing-metadata"   => \$opt{no_routing_metadata},
    "no-grid"               => \$opt{no_grid},
    "no-obstacles"          => \$opt{no_obstacles},
    "no-bbox"               => \$opt{no_bbox},
    "no-clusters"           => \$opt{no_clusters},
    "no-page-bounds"        => \$opt{no_page_bounds},

    "color-align-vertical=s"   => \$opt{color_align_vertical},
    "color-align-horizontal=s" => \$opt{color_align_horizontal},
    "color-order-left-right=s" => \$opt{color_order_left_right},
    "color-order-top-bottom=s" => \$opt{color_order_top_bottom},
    "color-fixed=s"            => \$opt{color_fixed},
    "color-source=s"           => \$opt{color_source},
    "color-sink=s"             => \$opt{color_sink},
    "color-grid=s"             => \$opt{color_grid},
    "color-bbox=s"             => \$opt{color_bbox},
    "color-cluster=s"          => \$opt{color_cluster},
    "color-page-bounds=s"      => \$opt{color_page_bounds},

    "cluster-opacity=f" => \$opt{cluster_opacity},
    "grid-opacity=f"    => \$opt{grid_opacity},
) or die "Unknown option. Use --help for usage.\n";

# ============================================================
# DEFAULT COLORS (overridden by CLI)
# ============================================================

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

# ============================================================
# READ JSON FROM STDIN
# ============================================================

my $json_text = do { local $/; <STDIN> };
die "No input\n" unless defined $json_text && length $json_text;

my $json = JSON::MaybeXS->new(utf8 => 1);
my $data = eval { $json->decode($json_text) };
die "Invalid JSON: $@\n" if $@;

# ============================================================
# EXTRACT BASIC DATA
# ============================================================

my $nodes       = $data->{nodes}      || [];
my $edges       = $data->{edges}      || [];
my $constraints = $data->{constraints} || {};
my $metadata    = $data->{metadata}   || {};

# ============================================================
# CLASSIFY NODES BASED ON CONSTRAINTS
# ============================================================

my %node_info;

for my $n (@$nodes) {
    $node_info{$n->{id}} = {
        align_vertical   => 0,
        align_horizontal => 0,
        order_left_right => 0,
        order_top_bottom => 0,
        fixed            => 0,
        source           => 0,
        sink             => 0,
        clusters         => [],
    };
}

# Alignment
if ($constraints->{align_vertical}) {
    for my $id (@{$constraints->{align_vertical}}) {
        $node_info{$id}{align_vertical} = 1 if exists $node_info{$id};
    }
}
if ($constraints->{align_horizontal}) {
    for my $id (@{$constraints->{align_horizontal}}) {
        $node_info{$id}{align_horizontal} = 1 if exists $node_info{$id};
    }
}

# Ordering
if ($constraints->{order_left_to_right}) {
    for my $id (@{$constraints->{order_left_to_right}}) {
        $node_info{$id}{order_left_right} = 1 if exists $node_info{$id};
    }
}
if ($constraints->{order_top_to_bottom}) {
    for my $id (@{$constraints->{order_top_to_bottom}}) {
        $node_info{$id}{order_top_bottom} = 1 if exists $node_info{$id};
    }
}

# Fixed nodes
if ($constraints->{fixed}) {
    for my $id (@{$constraints->{fixed}}) {
        $node_info{$id}{fixed} = 1 if exists $node_info{$id};
    }
}

# Clusters
if ($constraints->{clusters}) {
    for my $cl (@{$constraints->{clusters}}) {
        my $cid = $cl->{id} // "cluster";
        for my $nid (@{$cl->{nodes}}) {
            push @{$node_info{$nid}{clusters}}, $cid if exists $node_info{$nid};
        }
    }
}

# Source/sink detection
my (%in, %out);
for my $e (@$edges) {
    $out{$e->{source}}++;
    $in{$e->{target}}++;
}
for my $id (keys %node_info) {
    $node_info{$id}{source} = 1 if !$in{$id}  && $out{$id};
    $node_info{$id}{sink}   = 1 if !$out{$id} && $in{$id};
}

# ============================================================
# COMPUTE BOUNDS
# ============================================================

my ($min_x, $min_y, $max_x, $max_y);
for my $n (@$nodes) {
    my ($x, $y, $w, $h) = ($n->{x}, $n->{y}, $n->{width}, $n->{height});
    $min_x = defined $min_x ? min($min_x, $x - $w/2) : $x - $w/2;
    $min_y = defined $min_y ? min($min_y, $y - $h/2) : $y - $h/2;
    $max_x = defined $max_x ? max($max_x, $x + $w/2) : $x + $w/2;
    $max_y = defined $max_y ? max($max_y, $y + $h/2) : $y + $h/2;
}

my $pad = 20;
$min_x -= $pad;
$min_y -= $pad;
$max_x += $pad;
$max_y += $pad;

my $width  = $max_x - $min_x;
my $height = $max_y - $min_y;

# ============================================================
# BEGIN SVG OUTPUT
# ============================================================

print <<"SVG";
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg"
     width="$width"
     height="$height"
     viewBox="$min_x $min_y $width $height"
     font-family="sans-serif"
     font-size="12">
SVG

# ============================================================
# GRID OVERLAY
# ============================================================

if (!$opt{no_grid} && $constraints->{grid}) {
    my $g     = $constraints->{grid};
    my $color = $colors{grid};
    my $op    = $opt{grid_opacity};

    print qq{<g id="grid" stroke="$color" stroke-opacity="$op" stroke-width="0.5">\n};
    for (my $x = int($min_x / $g) * $g; $x <= $max_x; $x += $g) {
        print qq{  <line x1="$x" y1="$min_y" x2="$x" y2="$max_y" />\n};
    }
    for (my $y = int($min_y / $g) * $g; $y <= $max_y; $y += $g) {
        print qq{  <line x1="$min_x" y1="$y" x2="$max_x" y2="$y" />\n};
    }
    print "</g>\n";
}

# ============================================================
# PAGE BOUNDS
# ============================================================

if (!$opt{no_page_bounds} && $constraints->{page_bounds}) {
    my $c      = $constraints;
    my $left   = $c->{page_left}   // -500;
    my $right  = $c->{page_right}  //  500;
    my $top    = $c->{page_top}    //  500;
    my $bottom = $c->{page_bottom} // -500;
    my $color  = $colors{page_bounds};

    print qq{
<rect id="page_bounds"
      x="$left" y="$bottom"
      width="@{[$right-$left]}"
      height="@{[$top-$bottom]}"
      fill="none"
      stroke="$color"
      stroke-dasharray="5,5"
      stroke-width="1"/>
};
}

# ============================================================
# CLUSTERS
# ============================================================

if (!$opt{no_clusters} && $constraints->{clusters}) {
    my $op    = $opt{cluster_opacity};
    my $color = $colors{cluster};

    print qq{<g id="clusters" fill="$color" fill-opacity="$op" stroke="$color" stroke-width="1">\n};

    for my $cl (@{$constraints->{clusters}}) {
        my @ids = @{$cl->{nodes}};
        my ($cx1, $cy1, $cx2, $cy2);

        for my $nid (@ids) {
            my ($x, $y, $w, $h);
            for my $n (@$nodes) {
                next unless $n->{id} eq $nid;
                ($x, $y, $w, $h) = ($n->{x}, $n->{y}, $n->{width}, $n->{height});
                last;
            }
            my $lx = $x - $w/2;
            my $rx = $x + $w/2;
            my $by = $y - $h/2;
            my $ty = $y + $h/2;

            $cx1 = defined $cx1 ? min($cx1, $lx) : $lx;
            $cy1 = defined $cy1 ? min($cy1, $by) : $by;
            $cx2 = defined $cx2 ? max($cx2, $rx) : $rx;
            $cy2 = defined $cy2 ? max($cy2, $ty) : $ty;
        }

        print qq{
  <rect x="$cx1" y="$cy1"
        width="@{[$cx2-$cx1]}"
        height="@{[$cy2-$cy1]}"
        rx="8" ry="8"/>
};
    }

    print "</g>\n";
}

# ============================================================
# BOUNDING BOX
# ============================================================

if (!$opt{no_bbox}) {
    my $color = $colors{bbox};
    print qq{
<rect id="bbox"
      x="$min_x" y="$min_y"
      width="$width" height="$height"
      fill="none"
      stroke="$color"
      stroke-dasharray="4,4"
      stroke-width="1"/>
};
}

# ============================================================
# EDGES
# ============================================================

print qq{<g id="edges" stroke="#333" stroke-width="1.5" fill="none">\n};

for my $e (@$edges) {
    my $src   = $e->{source};
    my $dst   = $e->{target};
    my $route = $e->{route} || [];
    my @pts   = map { [ $_->[0], $_->[1] ] } @$route;

    next unless @pts >= 2;

    my $d = "M $pts[0][0] $pts[0][1]";
    for my $i (1 .. $#pts) {
        $d .= " L $pts[$i][0] $pts[$i][1]";
    }

    print qq{  <path d="$d">\n    <title>Edge $src → $dst</title>\n  </path>\n};

    if (!$opt{no_edge_labels}) {
        my $mid = int(@pts / 2);
        my ($mx, $my) = @{$pts[$mid]};
        my $label = "$src → $dst";

        if (!$opt{no_routing_metadata}) {
            my $turns = @pts - 1;
            $label .= " ($turns bends)";
        }

        print qq{
  <text x="$mx" y="@{[$my - 4]}" text-anchor="middle" fill="#555">$label</text>
};
    }
}

print "</g>\n";

# ============================================================
# NODES
# ============================================================

print qq{<g id="nodes">\n};

for my $n (@$nodes) {
    my ($id, $x, $y, $w, $h) = ($n->{id}, $n->{x}, $n->{y}, $n->{width}, $n->{height});
    my $info = $node_info{$id};

    my $fill = '#f5f5ff';
    if (!$opt{no_constraint_colors}) {
        if ($info->{align_vertical})      { $fill = $colors{align_vertical}; }
        elsif ($info->{align_horizontal}) { $fill = $colors{align_horizontal}; }
        elsif ($info->{order_left_right}) { $fill = $colors{order_left_right}; }
        elsif ($info->{order_top_bottom}) { $fill = $colors{order_top_bottom}; }
    }

    my $stroke = '#333';
    my $sw     = 1;

    if (!$opt{no_fixed_highlighting} && $info->{fixed}) {
        $stroke = $colors{fixed};
        $sw     = 2;
    }
    elsif (!$opt{no_source_sink}) {
        if ($info->{source}) {
            $stroke = $colors{source};
            $sw     = 2;
        }
        elsif ($info->{sink}) {
            $stroke = $colors{sink};
            $sw     = 2;
        }
    }

    my @tags;
    push @tags, 'align_vertical'   if $info->{align_vertical};
    push @tags, 'align_horizontal' if $info->{align_horizontal};
    push @tags, 'order_left_right' if $info->{order_left_right};
    push @tags, 'order_top_bottom' if $info->{order_top_bottom};
    push @tags, 'fixed'            if $info->{fixed};
    push @tags, 'source'           if $info->{source};
    push @tags, 'sink'             if $info->{sink};
    push @tags, map { "cluster:$_" } @{$info->{clusters}};

    my $tooltip = "Node $id";
    $tooltip .= " (" . join(", ", @tags) . ")" if @tags;

    print qq{
  <g>
    <rect x="@{[$x-$w/2]}" y="@{[$y-$h/2]}"
          width="$w" height="$h"
          rx="4" ry="4"
          fill="$fill"
          stroke="$stroke"
          stroke-width="$sw"/>
    <text x="$x" y="@{[$y+4]}" text-anchor="middle" fill="#000">$id</text>
    <title>$tooltip</title>
  </g>
};
}

print "</g>\n";

print "</svg>\n";

__END__

=head1 NAME

visualize_static_svg.pl - Static SVG visualizer for layout engine output

=head1 SYNOPSIS

  cat response.json | visualize_static_svg.pl > graph.svg

  # Disable constraint-based coloring
  cat response.json | visualize_static_svg.pl --no-constraint-colors > graph.svg

  # Custom colors
  cat response.json | visualize_static_svg.pl \
      --color-align-vertical=#88bbff \
      --color-fixed=#ff4444 \
      > graph.svg

  # Disable overlays
  cat response.json | visualize_static_svg.pl \
      --no-grid --no-bbox --no-clusters > graph.svg

=head1 DESCRIPTION

This script reads a JSON layout engine response from STDIN and produces
a static SVG visualization of the graph.

It understands the echoed C<constraints> block and uses it to:

=over 4

=item * Color nodes by constraint groups (alignment, ordering)

=item * Highlight fixed nodes and source/sink roles

=item * Draw optional overlays (grid, clusters, page bounds, bounding box)

=item * Add simple edge labels with routing metadata

=item * Add SVG C<< <title> >> tooltips for nodes and edges

=back

The output is a pure static SVG file with no JavaScript and no external
dependencies.

=head1 INPUT FORMAT

The script expects a JSON object with at least:

=over 4

=item * C<nodes> - array of nodes with C<id>, C<x>, C<y>, C<width>, C<height>

=item * C<edges> - array of edges with C<source>, C<target>, optional C<route>

=item * C<constraints> - echoed constraints from the layout engine

=item * Optional C<metadata> - echoed metadata from the layout engine

=back

=head1 CONSTRAINTS INTERPRETATION

The script looks at the C<constraints> object and interprets:

=over 4

=item * C<align_vertical> - list of node ids in vertical alignment

=item * C<align_horizontal> - list of node ids in horizontal alignment

=item * C<order_left_to_right> - list of node ids ordered left-to-right

=item * C<order_top_to_bottom> - list of node ids ordered top-to-bottom

=item * C<fixed> - list of node ids that are fixed

=item * C<clusters> - array of clusters with C<id> and C<nodes>

=item * C<grid> - grid spacing for optional grid overlay

=item * C<page_bounds> and related fields for page rectangle

=back

=head1 FEATURES

=head2 Constraint-based coloring

By default, nodes are colored based on the first matching constraint:

=over 4

=item * C<align_vertical> - light blue

=item * C<align_horizontal> - light green

=item * C<order_left_to_right> - light orange

=item * C<order_top_to_bottom> - light purple

=back

This can be disabled with C<--no-constraint-colors>.

=head2 Fixed / source / sink highlighting

By default:

=over 4

=item * Fixed nodes - red border

=item * Sources (outgoing edges, no incoming) - green border

=item * Sinks (incoming edges, no outgoing) - blue border

=back

Fixed highlighting can be disabled with C<--no-fixed-highlighting>.
Source/sink highlighting can be disabled with C<--no-source-sink>.

=head2 Overlays

The script can draw:

=over 4

=item * Grid (C<--no-grid> to disable)

=item * Clusters (C<--no-clusters> to disable)

=item * Page bounds (C<--no-page-bounds> to disable)

=item * Global bounding box (C<--no-bbox> to disable)

=back

=head2 Edge labels and routing metadata

If edge routes are present, the script can label edges with:

=over 4

=item * C<source → target>

=item * Optional number of bends (segments - 1)

=back

Edge labels can be disabled with C<--no-edge-labels>.
Routing metadata can be disabled with C<--no-routing-metadata>.

=head2 Tooltips

Nodes and edges include SVG C<< <title> >> elements with basic
information (id, roles, constraints). These show up as native tooltips
in most SVG viewers and browsers.

=head1 OPTIONS

=over 4

=item B<--no-constraint-colors>

Disable coloring nodes by constraint groups.

=item B<--no-fixed-highlighting>

Disable special border for fixed nodes.

=item B<--no-source-sink>

Disable special border for source/sink nodes.

=item B<--no-edge-labels>

Disable edge labels.

=item B<--no-routing-metadata>

Disable routing metadata in edge labels.

=item B<--no-grid>

Disable grid overlay.

=item B<--no-obstacles>

Reserved for future use (obstacle visualization).

=item B<--no-bbox>

Disable global bounding box rectangle.

=item B<--no-clusters>

Disable cluster overlays.

=item B<--no-page-bounds>

Disable page bounds rectangle.

=item B<--color-align-vertical=#RRGGBB>

Custom color for C<align_vertical> nodes.

=item B<--color-align-horizontal=#RRGGBB>

Custom color for C<align_horizontal> nodes.

=item B<--color-order-left-right=#RRGGBB>

Custom color for C<order_left_to_right> nodes.

=item B<--color-order-top-bottom=#RRGGBB>

Custom color for C<order_top_to_bottom> nodes.

=item B<--color-fixed=#RRGGBB>

Custom border color for fixed nodes.

=item B<--color-source=#RRGGBB>

Custom border color for source nodes.

=item B<--color-sink=#RRGGBB>

Custom border color for sink nodes.

=item B<--color-grid=#RRGGBB>

Custom color for grid lines.

=item B<--color-bbox=#RRGGBB>

Custom color for bounding box.

=item B<--color-cluster=#RRGGBB>

Custom color for cluster overlays.

=item B<--color-page-bounds=#RRGGBB>

Custom color for page bounds rectangle.

=item B<--cluster-opacity=FLOAT>

Opacity for cluster overlays (default 0.15).

=item B<--grid-opacity=FLOAT>

Opacity for grid lines (default 0.08).

=back

=head1 EXIT STATUS

Returns 0 on success. Dies on:

=over 4

=item * Unknown command-line options

=item * Invalid JSON input

=item * Missing or malformed required fields

=back

=head1 AUTHOR

You.

=head1 LICENSE

Same as your project.

=cut
