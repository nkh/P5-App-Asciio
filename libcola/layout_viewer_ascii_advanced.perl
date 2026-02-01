
#!/usr/bin/env perl
use strict;
use warnings;
use JSON::MaybeXS;
use List::Util qw(min max);
use Getopt::Long qw(GetOptions);

my $RESET   = "\e[0m";
my $FG_NODE = "\e[38;5;15m";
my $BG_NODE = "\e[48;5;19m";
my $FG_EDGE = "\e[38;5;226m";
my $FG_DIFF = "\e[38;5;196m";

my $follow      = 0;
my $follow_diff = 0;

GetOptions(
    "follow"      => \$follow,
    "follow-diff" => \$follow_diff,
) or die "Usage: $0 [--follow] [--follow-diff]\n";

my $json = JSON::MaybeXS->new(utf8 => 1);

sub trunc1 {
    my ($v) = @_;
    return int($v * 10) / 10;
}

sub gcd {
    my ($a, $b) = @_;
    ($a, $b) = (abs($a), abs($b));
    ($a, $b) = ($b, $a % $b) while $b;
    return $a;
}

sub compute_scale_factor {
    my ($resp) = @_;
    my @vals;

    my $nodes = $resp->{nodes} || [];
    my $edges = $resp->{edges} || [];

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
        my $t = trunc1($v);
        my $frac = $t - int($t);
        my $f10 = int($frac * 10 + 1e-9);

        my $needed_k;
        if ($f10 == 0) {
            $needed_k = 1;
        } else {
            my $g = gcd($f10, 10);
            $needed_k = 10 / $g;
        }

        $global_k = $needed_k if $needed_k > $global_k;
    }

    die "precision limit exceeded (requires finer than 0.1 units)\n"
        if $global_k > 10;

    return $global_k;
}

sub compute_bounds_trunc {
    my ($resp) = @_;
    my $nodes = $resp->{nodes} || [];
    my $edges = $resp->{edges} || [];

    my ($min_x, $min_y, $max_x, $max_y);

    for my $n (@$nodes) {
        my $x = trunc1($n->{x} // 0);
        my $y = trunc1($n->{y} // 0);
        my $w = trunc1($n->{width}  // 0);
        my $h = trunc1($n->{height} // 0);

        $min_x = defined $min_x ? min($min_x, $x - $w/2) : $x - $w/2;
        $min_y = defined $min_y ? min($min_y, $y - $h/2) : $y - $h/2;
        $max_x = defined $max_x ? max($max_x, $x + $w/2) : $x + $w/2;
        $max_y = defined $max_y ? max($max_y, $y + $h/2) : $y + $h/2;
    }

    for my $e (@$edges) {
        for my $p (@{$e->{route} || []}) {
            my ($x, $y) = ref $p eq 'ARRAY' ? @$p : ($p->{x}, $p->{y});
            next unless defined $x && defined $y;
            $x = trunc1($x);
            $y = trunc1($y);
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

sub world_to_cell_scaled {
    my ($x, $y, $min_x, $min_y, $k) = @_;
    my $tx = trunc1($x);
    my $ty = trunc1($y);
    my $cx = int( ($tx - $min_x) * $k + 0.5 );
    my $cy = int( ($ty - $min_y) * $k + 0.5 );
    return ($cx, $cy);
}

sub render_ascii_buffer {
    my ($resp) = @_;

    my $nodes    = $resp->{nodes}    || [];
    my $edges    = $resp->{edges}    || [];
    my $metadata = $resp->{metadata} || {};
    my $engine   = $metadata->{engine} || {};

    my $k = compute_scale_factor($resp);
    my ($min_x, $min_y, $max_x, $max_y) = compute_bounds_trunc($resp);

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
        my ($cx, $cy) = world_to_cell_scaled($n->{x}, $n->{y}, $min_x, $min_y, $k);

        for my $dy (-1 .. 1) {
            for my $dx (-1 .. 1) {
                my $rx = $cx + $dx;
                my $ry = $cy + $dy;
                next if $rx < 0 || $rx >= $cols || $ry < 0 || $ry >= $rows;
                my $ch = ($dx == 0 && $dy == 0) ? '+' : '#';
                $buf[$ry][$rx] = $ch;
            }
        }

        if (defined $id && length $id) {
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

        my ($sx, $sy) = world_to_cell_scaled($src->{x}, $src->{y}, $min_x, $min_y, $k);
        my ($dx, $dy) = world_to_cell_scaled($dst->{x}, $dst->{y}, $min_x, $min_y, $k);

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

    return (\@buf, $legend);
}

sub print_buffer_colored {
    my ($buf, $legend) = @_;
    my $rows = @$buf;
    my $cols = @{$buf->[0]} if $rows;

    for my $r (0 .. $rows-1) {
        my $line = '';
        for my $c (0 .. $cols-1) {
            my $ch = $buf->[$r][$c];
            if ($ch eq '+' || $ch eq '#') {
                $line .= $BG_NODE . $FG_NODE . $ch . $RESET;
            } elsif ($ch eq '-' || $ch eq '|' || $ch eq '/') {
                $line .= $FG_EDGE . $ch . $RESET;
            } else {
                $line .= $ch;
            }
        }
        print $line, "\n";
    }
    print $legend, "\n";
}

sub print_buffer_diff {
    my ($buf, $prev_buf, $legend) = @_;
    my $rows = @$buf;
    my $cols = @{$buf->[0]} if $rows;

    for my $r (0 .. $rows-1) {
        my $line = '';
        for my $c (0 .. $cols-1) {
            my $ch = $buf->[$r][$c];
            my $prev_ch = ($prev_buf && $r < @$prev_buf && $c < @{$prev_buf->[$r]})
                ? $prev_buf->[$r][$c]
                : ' ';
            my $colored;
            if ($ch ne $prev_ch) {
                $colored = $FG_DIFF . $ch . $RESET;
            } elsif ($ch eq '+' || $ch eq '#') {
                $colored = $BG_NODE . $FG_NODE . $ch . $RESET;
            } elsif ($ch eq '-' || $ch eq '|' || $ch eq '/') {
                $colored = $FG_EDGE . $ch . $RESET;
            } else {
                $colored = $ch;
            }
            $line .= $colored;
        }
        print $line, "\n";
    }
    print $legend, "\n";
}

sub read_next_frame {
    my @lines;
    while (defined(my $line = <STDIN>)) {
        chomp $line;
        last if $line eq '---';
        push @lines, $line;
    }
    return unless @lines;
    return join("\n", @lines);
}

if (!$follow && !$follow_diff) {
    my $json_text = do { local $/; <STDIN> };
    die "No input\n" unless defined $json_text && length $json_text;
    my $resp = $json->decode($json_text);
    my ($buf, $legend) = render_ascii_buffer($resp);
    print_buffer_colored($buf, $legend);
    exit;
}

$| = 1;
my $prev_text = '';
my $prev_buf;

while (1) {
    my $json_text = read_next_frame();
    last unless defined $json_text;

    if ($json_text eq $prev_text) {
        next;
    }
    $prev_text = $json_text;

    my $resp = eval { $json->decode($json_text) };
    next if $@;

    print "\e[2J\e[H";

    my ($buf, $legend) = render_ascii_buffer($resp);

    if ($follow_diff && $prev_buf) {
        print_buffer_diff($buf, $prev_buf, $legend);
    } else {
        print_buffer_colored($buf, $legend);
    }

    $prev_buf = $buf;
}

__END__

=head1 NAME

layout_viewer_ascii.pl – Precision‑aware ASCII graph viewer with follow and diff modes

=head1 SYNOPSIS

  # Single frame
  cat response.json | layout_viewer_ascii.pl

  # Multiple frames separated by '---'
  producer | layout_viewer_ascii.pl --follow

  # Same, but highlight changed cells
  producer | layout_viewer_ascii.pl --follow-diff

=head1 DESCRIPTION

This script renders a graph as ASCII art using an “infinite” canvas sized
directly from the graph’s world coordinates. It supports follow mode,
diff highlighting, ANSI coloring, and a precision‑bounded scaling system
that guarantees integer grid placement without rasterization.

=head1 PRECISION AND SCALING

All coordinates (node positions, sizes, and route points) are first
truncated to one decimal place. The script then determines the minimal
integer multiplier C<k> (1 ≤ k ≤ 10) such that:

  truncated_value * k

is an integer for all values.

If no such multiplier ≤ 10 exists, rendering fails with a precision
error. This enforces a maximum allowed precision of 0.1 units.

The ASCII grid is then constructed with:

  cols = (max_x - min_x) * k + 1
  rows = (max_y - min_y) * k + 1

ensuring exact integer placement of all features.

=head1 FOLLOW MODE

In C<--follow> mode, the script reads multiple JSON documents from STDIN,
each separated by a line containing only:

  ---

The screen is cleared and redrawn only when the JSON changes.

=head1 FOLLOW + DIFF MODE

In C<--follow-diff> mode, changed cells are highlighted in red. Unchanged
nodes and edges retain their normal ANSI coloring.

=head1 ANSI COLORING

Nodes are drawn as 3×3 blocks using a blue background and white
foreground. Edges use yellow. Diff changes use red.

=head1 LIMITATIONS

This viewer is intended for debugging and inspection. Extremely large
graphs may produce very large ASCII output.

=head1 AUTHOR

nadim

=cut
