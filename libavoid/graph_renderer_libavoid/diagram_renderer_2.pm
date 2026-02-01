#!/usr/bin/env perl
# diagram-renderer.pl
use strict;
use warnings;
use Getopt::Long;
use FindBin;
use lib $FindBin::Bin;

use LibAvoidRenderer qw(
    parse_json_graph
    parse_color_config
    parse_color_spec
    render_png
    render_svg
    render_ascii
);

sub show_help
{
    print "Usage:\n";
    print "  $0 [--json] <input> <layout_or_output> <output>\n";
    print "\n";
    print "Modes:\n";
    print "  Two-file mode (legacy):\n";
    print "      $0 input.json layout.json output.svg\n";
    print "\n";
    print "  Single JSON mode:\n";
    print "      $0 --json combined.json output.svg\n";
    print "\n";
    print "Options:\n";
    print "  -h, --help              Show this help message\n";
    print "  --json                  Use a single JSON file containing graph+layout\n";
    print "  --border N              Border size in pixels (default: 10)\n";
    print "  --scale FACTOR          Scale factor for rendering\n";
    print "  --canvas WxH            Canvas size (auto-scales to fit)\n";
    print "  --no-scale              Disable auto-scaling (render at 1:1)\n";
    print "  --colors FILE           Color configuration file\n";
    print "  --show-node-ids         Display node IDs inside nodes\n";
    print "  --antialias             Enable antialiasing\n";
    print "  --transparent           PNG with transparent background\n";
    print "  --background COLOR      Background color (#RRGGBB or name)\n";
    print "\n";
    print "Output formats:\n";
    print "  .svg                    SVG renderer\n";
    print "  .png                    PNG renderer\n";
    print "  .txt/.asc/.ascii        ASCII renderer\n";
    exit 0;
}

my $help           = 0;
my $use_json       = 0;
my $border         = 10;
my $scale          = undef;
my $canvas         = undef;
my $colors_file    = undef;
my $show_node_ids  = 0;
my $no_scale       = 0;
my $antialias      = 0;
my $transparent    = 0;
my $background     = undef;

GetOptions(
    'h|help'        => \$help,
    'json'          => \$use_json,
    'border=i'      => \$border,
    'scale=f'       => \$scale,
    'canvas=s'      => \$canvas,
    'colors=s'      => \$colors_file,
    'show-node-ids' => \$show_node_ids,
    'no-scale'      => \$no_scale,
    'antialias'     => \$antialias,
    'transparent'   => \$transparent,
    'background=s'  => \$background,
) or die "Error in command line arguments\n";

show_help() if $help;

if ($use_json) {
    die "Error: --json requires exactly 2 arguments: <json> <output>\n"
        unless @ARGV == 2;
} else {
    die "Error: Two-file mode requires 3 arguments: <input> <layout> <output>\n"
        unless @ARGV == 3;
}

my ($input_file, $layout_file, $output_file);
my ($graph, $layout);

if ($use_json) {
    ($input_file, $output_file) = @ARGV;

    open my $fh, '<', $input_file or die "Cannot read $input_file: $!";
    my $json_text = do { local $/; <$fh> };
    close $fh;

    my $data = parse_json_graph($json_text);
    die "JSON missing 'graph' key\n"  unless exists $data->{graph};
    die "JSON missing 'layout' key\n" unless exists $data->{layout};

    $graph  = $data->{graph};
    $layout = $data->{layout};
} else {
    ($input_file, $layout_file, $output_file) = @ARGV;

    open my $in_fh, '<', $input_file or die "Cannot read $input_file: $!";
    my $input_text = do { local $/; <$in_fh> };
    close $in_fh;

    open my $lay_fh, '<', $layout_file or die "Cannot read $layout_file: $!";
    my $layout_text = do { local $/; <$lay_fh> };
    close $lay_fh;

    $graph  = parse_json_graph($input_text);
    $layout = parse_json_graph($layout_text);
}

my %render_options = (
    border        => $border,
    show_node_ids => $show_node_ids,
    no_scale      => $no_scale,
    antialias     => $antialias,
    transparent   => $transparent,
);

if (defined $scale) {
    $render_options{scale} = $scale;
}

if (defined $canvas) {
    if ($canvas =~ /^(\d+)x(\d+)$/i) {
        $render_options{canvas_width}  = $1;
        $render_options{canvas_height} = $2;
    } else {
        die "Error: Canvas must be WIDTHxHEIGHT\n";
    }
}

my $colors = {};

if (defined $colors_file && -f $colors_file) {
    open my $cfh, '<', $colors_file or die "Cannot read $colors_file: $!";
    my $colors_text = do { local $/; <$cfh> };
    close $cfh;
    $colors = parse_color_config($colors_text);
}

if (defined $background) {
    $colors->{background} = parse_color_spec($background);
}

$render_options{colors} = $colors;

if ($output_file =~ /\.png$/i) {

    render_png($graph, $layout, $output_file, %render_options);
    print "PNG rendered to $output_file\n";

}
elsif ($output_file =~ /\.svg$/i) {

    render_svg($graph, $layout, $output_file, %render_options);
    print "SVG rendered to $output_file\n";

}
elsif ($output_file =~ /\.(txt|asc|ascii)$/i) {

    render_ascii($graph, $layout, $output_file, %render_options);
    print "ASCII rendered to $output_file\n";

}
else {
    die "Error: Output file must be .png, .svg, .txt, .asc, or .ascii\n";
}

__END__

=head1 NAME

diagram-renderer.pl - Render graph layouts as SVG, PNG, or ASCII

=head1 SYNOPSIS

Two-file mode (legacy):

  diagram-renderer.pl input.json layout.json output.svg
  diagram-renderer.pl input.json layout.json output.png

Single JSON mode:

  diagram-renderer.pl --json combined.json output.svg
  diagram-renderer.pl --json combined.json output.png
  diagram-renderer.pl --json combined.json output.txt

=head1 DESCRIPTION

This application renders graph layouts using the LibAvoidRenderer module.
It supports two input modes:

=over 4

=item * Two-file mode (legacy)

The first file contains the graph description.
The second file contains the layout output.
Both must be valid JSON in the format used by the GTK3 viewer.

=item * Single JSON mode (--json)

A single JSON file contains both:

  {
      "graph":  { ... },
      "layout": { ... }
  }

This is the same structure used by the Perl GTK3 viewer.

=back

The output format is determined by the extension of the output file:

=over 4

=item * .svg – Render using the SVG renderer

=item * .png – Render using the PNG renderer

=item * .txt, .asc, .ascii – Render using the ASCII renderer

=back

All rendering options (scaling, canvas size, colors, antialiasing, etc.)
apply to all renderers unless otherwise noted.

=head1 OPTIONS

=over 4

=item B<--json>

Use a single JSON file containing both graph and layout.

=item B<--border N>

Border size in pixels (default: 10).

=item B<--scale FACTOR>

Apply a fixed scale factor.

=item B<--canvas WIDTHxHEIGHT>

Render into a fixed canvas size.

=item B<--no-scale>

Disable auto-scaling.

=item B<--colors FILE>

Load a color configuration file.

=item B<--show-node-ids>

Display node IDs inside nodes.

=item B<--antialias>

Enable antialiasing (PNG only).

=item B<--transparent>

Render PNG with transparent background.

=item B<--background COLOR>

Override background color (SVG/PNG).

=item B<-h>, B<--help>

Show help.

=back

=head1 ASCII RENDERER

When the output filename ends in .txt, .asc, or .ascii,
the ASCII renderer is used.

The ASCII renderer:

=over 4

=item *

Uses precision-bounded scaling: all coordinates are truncated to one decimal place.

=item *

Determines the minimal integer scaling factor (1–10) that converts all coordinates to integers.

=item *

Fails if more than 0.1 precision would be required.

=item *

Creates an “infinite” ASCII canvas sized directly from the graph extents.

=item *

Draws nodes as 3x3 blocks and edges as ASCII lines.

=back

=head1 AUTHOR

nadim

=cut
