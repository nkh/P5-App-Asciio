
#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use JSON::MaybeXS;
use List::Util qw(shuffle);
use Data::Dumper;

# ------------------------------------------------------------
# Command-line options
# ------------------------------------------------------------
my %opts = (
    nodes       => undef,   # number of nodes
    edges       => undef,   # number of edges
    routing     => undef,   # routing mode
    constraints => [],      # forced constraints
    seed        => undef,   # RNG seed
    json        => 0,       # JSON output mode
);

GetOptions(
    "nodes=i"        => \$opts{nodes},
    "edges=i"        => \$opts{edges},
    "routing=s"      => \$opts{routing},
    "constraint=s@"  => \$opts{constraints},
    "seed=i"         => \$opts{seed},
    "json!"          => \$opts{json},
) or die "Invalid arguments\n";

# ------------------------------------------------------------
# Seed RNG
# ------------------------------------------------------------
srand($opts{seed}) if defined $opts{seed};

# ------------------------------------------------------------
# Random helpers
# ------------------------------------------------------------
my @routing_modes = qw(straight polyline orthogonal orthogonal_compact);

my @constraint_types = (
    "grid_mode",
    "node_spacing",
    "align_horizontal",
    "align_vertical",
    "order_left_to_right",
    "order_top_to_bottom",
    "fixed",
    "routing_padding",
    "routing_grid",
);

sub random_routing {
    return $routing_modes[ rand @routing_modes ];
}

sub random_constraint {
    return $constraint_types[ rand @constraint_types ];
}

# ------------------------------------------------------------
# Generate nodes
# ------------------------------------------------------------
my $node_count = $opts{nodes} // (10 + int(rand(40)));  # 10–50 nodes
my @nodes;
for my $i (1 .. $node_count) {
    push @nodes, { id => "N$i" };
}

# ------------------------------------------------------------
# Generate edges
# ------------------------------------------------------------
my $edge_count = $opts{edges} // int($node_count * 0.6); # ~60% density
my @edges;

for (1 .. $edge_count) {
    my $src = "N" . (1 + int(rand($node_count)));
    my $dst = "N" . (1 + int(rand($node_count)));
    next if $src eq $dst;
    push @edges, { source => $src, target => $dst };
}

# ------------------------------------------------------------
# Constraint value generator
# ------------------------------------------------------------
sub generate_constraint_value {
    my ($type, $nodes) = @_;

    if ($type eq "grid_mode") {
        return (qw(none snap attract min_spacing))[ rand 4 ];
    }
    if ($type eq "node_spacing") {
        return 20 + int(rand(80));
    }
    if ($type eq "align_horizontal") {
        return [ map { $_->{id} } splice(@$nodes, 0, int(@$nodes/4)) ];
    }
    if ($type eq "align_vertical") {
        return [ map { $_->{id} } splice(@$nodes, 0, int(@$nodes/4)) ];
    }
    if ($type eq "order_left_to_right") {
        return [ map { $_->{id} } shuffle(@$nodes)[0 .. 4] ];
    }
    if ($type eq "order_top_to_bottom") {
        return [ map { $_->{id} } shuffle(@$nodes)[0 .. 4] ];
    }
    if ($type eq "fixed") {
        return [ map { $_->{id} } shuffle(@$nodes)[0 .. 2] ];
    }
    if ($type eq "routing_padding") {
        return 5 + int(rand(20));
    }
    if ($type eq "routing_grid") {
        return 10 + int(rand(40));
    }

    return undef;
}

# ------------------------------------------------------------
# Generate constraints
# ------------------------------------------------------------
my %constraints;

# Routing mode
$constraints{routing} = $opts{routing} // random_routing();

# Forced constraints from CLI
for my $c (@{ $opts{constraints} }) {
    $constraints{$c} = generate_constraint_value($c, \@nodes);
}

# Randomly add 1–4 constraints
my $random_constraint_count = 1 + int(rand(4));
for (1 .. $random_constraint_count) {
    my $c = random_constraint();
    next if exists $constraints{$c}; # avoid duplicates
    $constraints{$c} = generate_constraint_value($c, \@nodes);
}

# ------------------------------------------------------------
# Build final request structure
# ------------------------------------------------------------
my $request = {
    id          => "generated_" . int(rand(1_000_000)),
    nodes       => \@nodes,
    edges       => \@edges,
    constraints => \%constraints,
};

# ------------------------------------------------------------
# Output
# ------------------------------------------------------------
if ($opts{json}) {
    my $encoder = JSON::MaybeXS->new(utf8 => 1, canonical => 1, pretty => 1);
    print $encoder->encode($request);
    exit 0;
}

# Default: Perl structure
$Data::Dumper::Terse  = 1;
$Data::Dumper::Indent = 1;
print Dumper($request);

exit 0;
