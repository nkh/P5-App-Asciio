
# LibAvoidRenderer.pm
package LibAvoidRenderer;
use strict;
use warnings;
use Exporter 'import';
use JSON::MaybeXS;
use List::Util qw(min max);
use SVG;
use GD;

our @EXPORT_OK = qw(
    parse_json_graph
    parse_color_config
    parse_color_spec
    render_svg
    render_png
    render_ascii
);

# -----------------------------
# JSON parsing
# -----------------------------

sub parse_json_graph {
    my ($text) = @_;
    my $json = JSON::MaybeXS->new(utf8 => 1);
    my $data = $json->decode($text);
    return $data;
}

# -----------------------------
# Color config
# -----------------------------

sub parse_color_config {
    my ($text) = @_;
    my %cfg;
    for my $line (split /\n/, $text) {
        $line =~ s/#.*$//;
        next unless $line =~ /\S/;
        if ($line =~ /^\s*([a-zA-Z0-9_]+)\s*=\s*(\S+)\s*$/) {
            $cfg{$1} = parse_color_spec($2);
        }
    }
    return \%cfg;
}

sub parse_color_spec {
    my ($spec) = @_;
    $spec =~ s/^\s+//;
    $spec =~ s/\s+$//;
    return $spec;
}

# -----------------------------
# Internal helpers
# -----------------------------

sub _compute_bounds {
    my ($graph, $layout) = @_;
    my $nodes = $layout->{nodes} || $graph->{nodes} || [];
    my ($min_x, $min_y, $max_x, $max_y);
    for my $n (@$nodes) {
        my $x = $n->{x} // 0;
        my $y = $n->{y} // 0;
        my $w = $n->{width}  // 0;
        my $h = $n->{height} // 0;
        $min_x = defined $min_x ? min($min_x, $x - $w/2) : $x - $w/2;
        $min_y = defined $min_y ? min($min_y, $y - $h/2) : $y - $h/2;
        $max_x = defined $max_x ? max($max_x, $x + $w/2) : $x + $w/2;
        $max_y = defined $max_y ? max($max_y, $y + $h/2) : $y + $h/2;
    }
    $min_x //= 0;
    $min_y //= 0;
    $max_x //= 0;
    $max_y //= 0;
    return ($min_x, $min_y, $max_x, $max_y);
}

sub _resolve_colors {
    my ($opts) = @_;
    my $c = $opts->{colors} || {};
    return {
        background => $c->{background} // '#ffffff',
        node_fill  => $c->{node_fill}  // '#e0e0ff',
        node_stroke=> $c->{node_stroke}// '#000000',
        edge_stroke=> $c->{edge_stroke}// '#000000',
    };
}

# -----------------------------
# SVG rendering
# -----------------------------

sub render_svg {
    my ($graph, $layout, $outfile, %opts) = @_;

    my ($min_x, $min_y, $max_x, $max_y) = _compute_bounds($graph, $layout);
    my $border = $opts{border} // 10;
    my $width  = ($max_x - $min_x) + 2 * $border;
    my $height = ($max_y - $min_y) + 2 * $border;

    if ($opts{canvas_width} && $opts{canvas_height} && !$opts{no_scale}) {
        $width  = $opts{canvas_width};
        $height = $opts{canvas_height};
    }

    my $svg = SVG->new(width => $width, height => $height);
    my $colors = _resolve_colors(\%opts);

    $svg->rectangle(
        x      => 0,
        y      => 0,
        width  => $width,
        height => $height,
        style  => { fill => $colors->{background} },
    );

    my $nodes = $layout->{nodes} || $graph->{nodes} || [];
    my $edges = $layout->{edges} || $graph->{edges} || [];

    my $scale = 1.0;
    if ($opts{scale}) {
        $scale = $opts{scale};
    } elsif (!$opts{no_scale} && $opts{canvas_width} && $opts{canvas_height}) {
        my $sx = $opts{canvas_width}  / (($max_x - $min_x) || 1);
        my $sy = $opts{canvas_height} / (($max_y - $min_y) || 1);
        $scale = $sx < $sy ? $sx : $sy;
    }

    my $tx = sub { ($_[0] - $min_x) * $scale + $border };
    my $ty = sub { ($_[0] - $min_y) * $scale + $border };

    for my $e (@$edges) {
        my $route = $e->{route} || [];
        next unless @$route >= 2;
        my @points;
        for my $p (@$route) {
            my ($x, $y) = ref $p eq 'ARRAY' ? @$p : ($p->{x}, $p->{y});
            push @points, $tx->($x), $ty->($y);
        }
        $svg->polyline(
            points => \@points,
            style  => {
                fill   => 'none',
                stroke => $colors->{edge_stroke},
            },
        );
    }

    for my $n (@$nodes) {
        my $x = $n->{x} // 0;
        my $y = $n->{y} // 0;
        my $w = $n->{width}  // 0;
        my $h = $n->{height} // 0;
        my $cx = $tx->($x);
        my $cy = $ty->($y);
        my $rw = $w * $scale;
        my $rh = $h * $scale;

        $svg->rectangle(
            x      => $cx - $rw/2,
            y      => $cy - $rh/2,
            width  => $rw,
            height => $rh,
            style  => {
                fill   => $colors->{node_fill},
                stroke => $colors->{node_stroke},
            },
        );

        if ($opts{show_node_ids} && defined $n->{id}) {
            $svg->text(
                x     => $cx,
                y     => $cy,
                style => {
                    'text-anchor' => 'middle',
                    'dominant-baseline' => 'middle',
                    'font-size' => 10,
                    fill        => '#000000',
                },
            )->cdata($n->{id});
        }
    }

    open my $out, '>', $outfile or die "Cannot write $outfile: $!";
    print {$out} $svg->xmlify;
    close $out;
}

# -----------------------------
# PNG rendering (via GD)
# -----------------------------

sub render_png {
    my ($graph, $layout, $outfile, %opts) = @_;

    my ($min_x, $min_y, $max_x, $max_y) = _compute_bounds($graph, $layout);
    my $border = $opts{border} // 10;
    my $width  = int(($max_x - $min_x) + 2 * $border) || 1;
    my $height = int(($max_y - $min_y) + 2 * $border) || 1;

    if ($opts{canvas_width} && $opts{canvas_height} && !$opts{no_scale}) {
        $width  = $opts{canvas_width};
        $height = $opts{canvas_height};
    }

    my $img = GD::Image->new($width, $height, $opts{transparent} ? 1 : 0);
    my $colors = _resolve_colors(\%opts);

    my $bg = $img->colorAllocate(_gd_color($img, $colors->{background}));
    $img->filledRectangle(0, 0, $width-1, $height-1, $bg);

    my $node_fill   = $img->colorAllocate(_gd_color($img, $colors->{node_fill}));
    my $node_stroke = $img->colorAllocate(_gd_color($img, $colors->{node_stroke}));
    my $edge_stroke = $img->colorAllocate(_gd_color($img, $colors->{edge_stroke}));

    my $nodes = $layout->{nodes} || $graph->{nodes} || [];
    my $edges = $layout->{edges} || $graph->{edges} || [];

    my $scale = 1.0;
    if ($opts{scale}) {
        $scale = $opts{scale};
    } elsif (!$opts{no_scale} && $opts{canvas_width} && $opts{canvas_height}) {
        my $sx = $opts{canvas_width}  / (($max_x - $min_x) || 1);
        my $sy = $opts{canvas_height} / (($max_y - $min_y) || 1);
        $scale = $sx < $sy ? $sx : $sy;
    }

    my $tx = sub { int(($_[0] - $min_x) * $scale + $border + 0.5) };
    my $ty = sub { int(($_[0] - $min_y) * $scale + $border + 0.5) };

    for my $e (@$edges) {
        my $route = $e->{route} || [];
        next unless @$route >= 2;
        for (my $i = 0; $i < @$route - 1; $i++) {
            my ($x1, $y1) = ref $route->[$i]     eq 'ARRAY' ? @{$route->[$i]}     : ($route->[$i]{x},     $route->[$i]{y});
            my ($x2, $y2) = ref $route->[$i + 1] eq 'ARRAY' ? @{$route->[$i + 1]} : ($route->[$i + 1]{x}, $route->[$i + 1]{y});
            $img->line($tx->($x1), $ty->($y1), $tx->($x2), $ty->($y2), $edge_stroke);
        }
    }

    for my $n (@$nodes) {
        my $x = $n->{x} // 0;
        my $y = $n->{y} // 0;
        my $w = $n->{width}  // 0;
        my $h = $n->{height} // 0;
        my $cx = $tx->($x);
        my $cy = $ty->($y);
        my $rw = int($w * $scale + 0.5);
        my $rh = int($h * $scale + 0.5);

        my $x1 = $cx - int($rw/2);
        my $y1 = $cy - int($rh/2);
        my $x2 = $cx + int($rw/2);
        my $y2 = $cy + int($rh/2);

        $img->filledRectangle($x1, $y1, $x2, $y2, $node_fill);
        $img->rectangle($x1, $y1, $x2, $y2, $node_stroke);
    }

    open my $out, '>', $outfile or die "Cannot write $outfile: $!";
    binmode $out;
    print {$out} $img->png;
    close $out;
}

sub _gd_color {
    my ($img, $spec) = @_;
    if ($spec =~ /^#?([0-9a-fA-F]{6})$/) {
        my $hex = $1;
        my $r = hex substr($hex, 0, 2);
        my $g = hex substr($hex, 2, 2);
        my $b = hex substr($hex, 4, 2);
        return ($r, $g, $b);
    }
    return (255, 255, 255);
}

# -----------------------------
# ASCII rendering
# -----------------------------

sub _trunc1 {
    my ($v) = @_;
    return int($v * 10) / 10;
}

sub _gcd {
    my ($a, $b) = @_;
    ($a, $b) = (abs($a), abs($b));
    ($a, $b) = ($b, $a % $b) while $b;
    return $a;
}

sub _compute_scale_factor_ascii {
    my ($layout) = @_;
    my @vals;

    my $nodes = $layout->{nodes} || [];
    my $edges = $layout->{edges} || [];

    for my $n (@$nodes) {
        push @vals, $n->{x}, $n->{y}, $n->{width}, $n->{height};
    }
    for my $e (@$edges) {
        for my $p (@{$e->{route} || []}) {
            my ($x, $y) = ref $p eq 'ARRAY' ? @$p : ($p->{x}, $p->{y});
            push @vals, $x, $y if defined $x && defined $y;
        }
    }

    my $global_k = 1;

    for my $v (@vals) {
        next unless defined $v;
        my $t = _trunc1($v);
        my $frac = $t - int($t);
        my $f10 = int($frac * 10 + 1e-9);

        my $needed_k;
        if ($f10 == 0) {
            $needed_k = 1;
        } else {
            my $g = _gcd($f10, 10);
            $needed_k = 10 / $g;
        }

        $global_k = $needed_k if $needed_k > $global_k;
    }

    die "precision limit exceeded (requires finer than 0.1 units)\n"
        if $global_k > 10;

    return $global_k;
}

sub _compute_bounds_trunc_ascii {
    my ($layout) = @_;
    my $nodes = $layout->{nodes} || [];
    my $edges = $layout->{edges} || [];

    my ($min_x, $min_y, $max_x, $max_y);

    for my $n (@$nodes) {
        my $x = _trunc1($n->{x} // 0);
        my $y = _trunc1($n->{y} // 0);
        my $w = _trunc1($n->{width}  // 0);
        my $h = _trunc1($n->{height} // 0);

        $min_x = defined $min_x ? min($min_x, $x - $w/2) : $x - $w/2;
        $min_y = defined $min_y ? min($min_y, $y - $h/2) : $y - $h/2;
        $max_x = defined $max_x ? max($max_x, $x + $w/2) : $x + $w/2;
        $max_y = defined $max_y ? max($max_y, $y + $h/2) : $y + $h/2;
    }

    for my $e (@$edges) {
        for my $p (@{$e->{route} || []}) {
            my ($x, $y) = ref $p eq 'ARRAY' ? @$p : ($p->{x}, $p->{y});
            next unless defined $x && defined $y;
            $x = _trunc1($x);
            $y = _trunc1($y);
            $min_x = defined $min_x ? min($min_x, $x) : $x;
            $min_y = defined $min_y ? min($min_y, $y) : $y;
            $max_x = defined $max_x ? max($max_x, $x) : $x;
            $max_y = defined $max_y ? max($max_y, $y) : $y;
        }
    }

    $min_x //= 0;
    $min_y //= 0;
    $max_x //= 0;
    $max_y //= 0;

    return ($min_x, $min_y, $max_x, $max_y);
}

sub _world_to_cell_scaled_ascii {
    my ($x, $y, $min_x, $min_y, $k) = @_;
    my $tx = _trunc1($x);
    my $ty = _trunc1($y);
    my $cx = int( ($tx - $min_x) * $k + 0.5 );
    my $cy = int( ($ty - $min_y) * $k + 0.5 );
    return ($cx, $cy);
}

sub render_ascii {
    my ($graph, $layout, $outfile, %opts) = @_;

    my $nodes  = $layout->{nodes} || $graph->{nodes} || [];
    my $edges  = $layout->{edges} || $graph->{edges} || [];
    my $meta   = $layout->{metadata} || $graph->{metadata} || {};
    my $engine = $meta->{engine} || {};

    my $k = _compute_scale_factor_ascii($layout);
    my ($min_x, $min_y, $max_x, $max_y) = _compute_bounds_trunc_ascii($layout);

    my $cols = int( ($max_x - $min_x) * $k ) + 1;
    my $rows = int( ($max_y - $min_y) * $k ) + 1;
    $cols = 1 if $cols < 1;
    $rows = 1 if $rows < 1;

    my @buf;
    for my $r (0 .. $rows-1) {
        $buf[$r] = [ (' ') x $cols ];
    }

    my %node_by_id = map { $_->{id} => $_ } @$nodes;

    for my $n (@$nodes) {
        my $id = $n->{id};
        my ($cx, $cy) = _world_to_cell_scaled_ascii($n->{x}, $n->{y}, $min_x, $min_y, $k);

        for my $dy (-1 .. 1) {
            for my $dx (-1 .. 1) {
                my $rx = $cx + $dx;
                my $ry = $cy + $dy;
                next if $rx < 0 || $rx >= $cols || $ry < 0 || $ry >= $rows;
                my $ch = ($dx == 0 && $dy == 0) ? '+' : '#';
                $buf[$ry][$rx] = $ch;
            }
        }

        if ($opts{show_node_ids} && defined $id && length $id) {
            my $ch = substr($id, 0, 1);
            my $ry = $cy - 2;
            my $rx = $cx;
            if ($ry >= 0 && $ry < $rows && $rx >= 0 && $rx < $cols) {
                $buf[$ry][$rx] = $ch;
            }
        }
    }

    for my $e (@$edges) {
        my $src = $node_by_id{$e->{source}} or next;
        my $dst = $node_by_id{$e->{target}} or next;

        my ($sx, $sy) = _world_to_cell_scaled_ascii($src->{x}, $src->{y}, $min_x, $min_y, $k);
        my ($dx, $dy) = _world_to_cell_scaled_ascii($dst->{x}, $dst->{y}, $min_x, $min_y, $k);

        my $x = $sx;
        my $y = $sy;
        my $steps = max(abs($dx - $sx), abs($dy - $sy)) || 1;
        my $step_x = ($dx - $sx) / $steps;
        my $step_y = ($dy - $sy) / $steps;

        for (1 .. $steps) {
            $x += $step_x;
            $y += $step_y;
            my $cx = int($x + 0.5);
            my $cy = int($y + 0.5);
            next if $cx < 0 || $cx >= $cols || $cy < 0 || $cy >= $rows;
            my $ch;
            if (abs($dx - $sx) > abs($dy - $sy)) {
                $ch = '-';
            } elsif (abs($dy - $sy) > abs($dx - $sx)) {
                $ch = '|';
            } else {
                $ch = '/';
            }
            $buf[$cy][$cx] = $ch if $buf[$cy][$cx] eq ' ';
        }
    }

    my $legend = sprintf "Nodes: %d  Edges: %d  scale=%d",
        scalar(@$nodes), scalar(@$edges), $k;
    if (%$engine) {
        my @bits;
        push @bits, "layout=$engine->{layout_time_ms}ms"   if defined $engine->{layout_time_ms};
        push @bits, "routing=$engine->{routing_time_ms}ms" if defined $engine->{routing_time_ms};
        push @bits, "mode=$engine->{routing_mode}"         if defined $engine->{routing_mode};
        $legend .= "  Engine: " . join(' ', @bits) if @bits;
    }

    open my $out, '>', $outfile or die "Cannot write $outfile: $!";
    for my $r (0 .. $rows-1) {
        my $line = join('', @{$buf[$r]});
        print {$out} $line, "\n";
    }
    print {$out} $legend, "\n";
    close $out;
}

1;

__END__

=head1 NAME

LibAvoidRenderer - JSON-based graph rendering to SVG, PNG, and ASCII

=head1 SYNOPSIS

  use LibAvoidRenderer qw(
      parse_json_graph
      parse_color_config
      parse_color_spec
      render_svg
      render_png
      render_ascii
  );

=head1 DESCRIPTION

LibAvoidRenderer provides a small rendering layer for graph layouts
described in JSON. It can render to SVG, PNG, or ASCII, using a common
graph+layout structure compatible with the Perl GTK3 viewer.

=head1 FUNCTIONS

=head2 parse_json_graph($text)

Decode a JSON string into a Perl data structure.

=head2 parse_color_config($text)

Parse a simple key=value color configuration file.

=head2 parse_color_spec($spec)

Normalize a color specification (e.g. "#RRGGBB" or a name).

=head2 render_svg($graph, $layout, $outfile, %opts)

Render the given graph/layout as an SVG file.

=head2 render_png($graph, $layout, $outfile, %opts)

Render the given graph/layout as a PNG file.

=head2 render_ascii($graph, $layout, $outfile, %opts)

Render the given graph/layout as ASCII art.

=head1 AUTHOR

nadim

=cut
