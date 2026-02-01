
#!/usr/bin/env raku
use JSON::Fast;

my Int $TERM-WIDTH  = 80;
my Int $TERM-HEIGHT = 24;
my Int $MARGIN-COLS = 2;
my Int $MARGIN-ROWS = 2;

my $json-text = $*IN.slurp;
die "No input\n" unless $json-text.chars;

my $resp = from-json $json-text;
die "JSON must be an object\n" unless $resp ~~ Hash;

my $nodes    = $resp<nodes>    // [];
my $edges    = $resp<edges>    // [];
my $metadata = $resp<metadata> // {};
my $engine   = $metadata<engine> // {};

my ($min-x, $min-y, $max-x, $max-y);

for @$nodes -> $n {
    my $x = $n<x> // 0;
    my $y = $n<y> // 0;
    my $w = $n<width>  // 60;
    my $h = $n<height> // 40;

    $min-x = $min-x.defined ?? $min-x min ($x - $w/2) !! ($x - $w/2);
    $min-y = $min-y.defined ?? $min-y min ($y - $h/2) !! ($y - $h/2);
    $max-x = $max-x.defined ?? $max-x max ($x + $w/2) !! ($x + $w/2);
    $max-y = $max-y.defined ?? $max-y max ($y + $h/2) !! ($y + $h/2);
}

for @$edges -> $e {
    my $route = $e<route> // [];
    for @$route -> $p {
        my ($x, $y) = $p ~~ Positional ?? ($p[0], $p[1]) !! ($p<x>, $p<y>);
        next unless $x.defined && $y.defined;
        $min-x = $min-x.defined ?? $min-x min $x !! $x;
        $min-y = $min-y.defined ?? $min-y min $y !! $y;
        $max-x = $max-x.defined ?? $max-x max $x !! $x;
        $max-y = $max-y.defined ?? $max-y max $y !! $y;
    }
}

$min-x //= 0;
$min-y //= 0;
$max-x //= 100;
$max-y //= 100;

my $pad = 10;
$min-x -= $pad;
$min-y -= $pad;
$max-x += $pad;
$max-y += $pad;

my $world-w = $max-x - $min-x || 1;
my $world-h = $max-y - $min-y || 1;

my $cols = $TERM-WIDTH  - $MARGIN-COLS;
my $rows = $TERM-HEIGHT - $MARGIN-ROWS;

$cols = 10 if $cols < 10;
$rows = 5  if $rows < 5;

my @buf = [ ' ' xx $cols ] xx $rows;

sub put-char(Int $cx, Int $cy, Str $ch) {
    return if $cx < 0 || $cx >= $cols || $cy < 0 || $cy >= $rows;
    @buf[$cy][$cx] = $ch;
}

sub world-to-cell(Num $x, Num $y --> List) {
    my $nx = ($x - $min-x) / $world-w;
    my $ny = ($y - $min-y) / $world-h;
    my $cx = Int($nx * ($cols - 1));
    my $cy = Int($ny * ($rows - 1));
    ($cx, $cy);
}

my %node-by-id = @$nodes.map({ .<id> => $_ }).Hash;

for @$nodes -> $n {
    my $id = $n<id>;
    my $x  = $n<x> // 0;
    my $y  = $n<y> // 0;

    my ($cx, $cy) = world-to-cell($x, $y);

    for -1 .. 1 -> $dy {
        for -1 .. 1 -> $dx {
            my $ch = ($dx == 0 && $dy == 0) ?? '+' !! '#';
            put-char($cx + $dx, $cy + $dy, $ch);
        }
    }

    if $id.defined && $id.chars {
        my $ch = $id.substr(0, 1);
        put-char($cx, $cy - 2, $ch);
    }
}

for @$edges -> $e {
    my $src = %node-by-id{$e<source>} // next;
    my $dst = %node-by-id{$e<target>} // next;

    my ($sx, $sy) = world-to-cell($src<x>, $src<y>);
    my ($dx, $dy) = world-to-cell($dst<x>, $dst<y>);

    my $x = $sx;
    my $y = $sy;
    my $steps = max(abs($dx - $sx), abs($dy - $sy)) || 1;
    my $step-x = ($dx - $sx) / $steps;
    my $step-y = ($dy - $sy) / $steps;

    for 1 .. $steps {
        $x += $step-x;
        $y += $step-y;
        my $cx = Int($x + 0.5);
        my $cy = Int($y + 0.5);
        my $ch;
        if abs($dx - $sx) > abs($dy - $sy) {
            $ch = '-';
        } elsif abs($dy - $sy) > abs($dx - $sx) {
            $ch = '|';
        } else {
            $ch = '/';
        }
        put-char($cx, $cy, $ch);
    }
}

for 0 ..^ $rows -> $r {
    print ' ' x $MARGIN-COLS;
    say @buf[$r].join;
}

say "";
say "Nodes: ", +@$nodes, "  Edges: ", +@$edges;
if $engine.elems {
    my @bits;
    @bits.push("layout={$engine<layout_time_ms>}ms")   if $engine<layout_time_ms>:exists;
    @bits.push("routing={$engine<routing_time_ms>}ms") if $engine<routing_time_ms>:exists;
    @bits.push("mode={$engine<routing_mode>}")         if $engine<routing_mode>:exists;
    say "Engine: ", @bits.join(' ') if @bits;
}
