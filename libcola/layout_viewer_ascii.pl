
#!/usr/bin/env perl
use strict;
use warnings;
use JSON::MaybeXS;
use List::Util qw(min max);

# Config
my $TERM_WIDTH  = 80;
my $TERM_HEIGHT = 24;
my $MARGIN_COLS = 2;
my $MARGIN_ROWS = 2;

# Read JSON from STDIN
my $json_text = do { local $/; <STDIN> };
die "No input\n" unless defined $json_text && length $json_text;

my $json = JSON::MaybeXS->new(utf8 => 1);
my $resp = eval { $json->decode($json_text) };
die "Invalid JSON: $@\n" if $@ || ref $resp ne 'HASH';

my $nodes    = $resp->{nodes}    || [];
my $edges    = $resp->{edges}    || [];
my $metadata = $resp->{metadata} || {};
my $engine   = $metadata->{engine} || {};

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
$max_x //= 100;
$max_y //= 100;

# Pad a bit
my $pad = 10;
$min_x -= $pad;
$min_y -= $pad;
$max_x += $pad;
$max_y += $pad;

my $world_w = $max_x - $min_x || 1;
my $world_h = $max_y - $min_y || 1;

# Grid size (leave room for margins and legend)
my $cols = $TERM_WIDTH  - $MARGIN_COLS;
my $rows = $TERM_HEIGHT - $MARGIN_ROWS;

$cols = 10 if $cols < 10;
$rows = 5  if $rows < 5;

# Create buffer
my @buf;
for my $r (0 .. $rows-1) {
    $buf[$r] = [ (' ') x $cols ];
}

sub put_char {
    my ($cx, $cy, $ch) = @_;
    return if $cx < 0 || $cx >= $cols || $cy < 0 || $cy >= $rows;
    $buf[$cy][$cx] = $ch;
}

sub world_to_cell {
    my ($x, $y) = @_;
    my $nx = ($x - $min_x) / $world_w;
    my $ny = ($y - $min_y) / $world_h;
    my $cx = int($nx * ($cols - 1));
    my $cy = int($ny * ($rows - 1));
    return ($cx, $cy);
}

# Index nodes by id
my %node_by_id = map { $_->{id} => $_ } @$nodes;

# Draw nodes as small boxes with label center
for my $n (@$nodes) {
    my $id = $n->{id};
    my $x  = $n->{x} // 0;
    my $y  = $n->{y} // 0;

    my ($cx, $cy) = world_to_cell($x, $y);

    # Simple 3x3 box
    for my $dy (-1 .. 1) {
        for my $dx (-1 .. 1) {
            my $ch = ($dx == 0 && $dy == 0) ? '+' : '#';
            put_char($cx + $dx, $cy + $dy, $ch);
        }
    }

    # Label (first char of id) just above
    if (defined $id && length $id) {
        my $ch = substr($id, 0, 1);
        put_char($cx, $cy - 2, $ch);
    }
}

# Draw edges as straight ASCII lines between node centers
for my $e (@$edges) {
    my $src = $node_by_id{$e->{source}} or next;
    my $dst = $node_by_id{$e->{target}} or next;

    my ($sx, $sy) = world_to_cell($src->{x}, $src->{y});
    my ($dx, $dy) = world_to_cell($dst->{x}, $dst->{y});

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
        my $ch;
        if (abs($dx - $sx) > abs($dy - $sy)) {
            $ch = '-';
        } elsif (abs($dy - $sy) > abs($dx - $sx)) {
            $ch = '|';
        } else {
            $ch = '/';
        }
        put_char($cx, $cy, $ch);
    }
}

# Print buffer
for my $r (0 .. $rows-1) {
    print ' ' x $MARGIN_COLS;
    print join('', @{$buf[$r]}), "\n";
}

# Legend / metadata
print "\n";
print "Nodes: ", scalar(@$nodes), "  Edges: ", scalar(@$edges), "\n";
if (%$engine) {
    print "Engine: ";
    print "layout=${\($engine->{layout_time_ms})}ms "   if defined $engine->{layout_time_ms};
    print "routing=${\($engine->{routing_time_ms})}ms " if defined $engine->{routing_time_ms};
    print "mode=$engine->{routing_mode} "               if defined $engine->{routing_mode};
    print "\n";
}
