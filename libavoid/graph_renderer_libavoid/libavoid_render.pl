#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long ;
use FindBin ;
use lib $FindBin::Bin ;
use LibAvoidRenderer qw(parse_graph_input parse_graph_output parse_color_config render_png render_svg) ;

sub show_help
{
print "Usage: $0 <input_file> <layout_file> <output_file> [options]\n" ;
print "\n" ;
print "Options:\n" ;
print "  -h, --help              Show this help message\n" ;
print "  --border N              Border size in pixels (default: 10)\n" ;
print "  --scale FACTOR          Scale factor for rendering\n" ;
print "  --canvas WIDTHxHEIGHT   Canvas size (auto-scales to fit)\n" ;
print "  --no-scale              Disable auto-scaling (render at 1:1)\n" ;
print "  --colors FILE           Color configuration file\n" ;
print "  --show-node-ids         Display node IDs inside nodes\n" ;
print "  --antialias             Enable antialiasing (smoother rendering)\n" ;
print "  --transparent           PNG with transparent background\n" ;
print "  --background COLOR      Background color (e.g., white, #FFFFFF)\n" ;
print "\n" ;
print "Note: Only one of --scale or --canvas can be specified\n" ;
print "      By default, diagrams are auto-scaled to fit with border\n" ;
exit 0 ;
}

my $help           = 0 ;
my $border         = 10 ;
my $scale          = undef ;
my $canvas         = undef ;
my $colors_file    = undef ;
my $show_node_ids  = 0 ;
my $no_scale       = 0 ;
my $antialias      = 0 ;
my $transparent    = 0 ;
my $background     = undef ;

GetOptions
	(
	'h|help'        => \$help,
	'border=i'      => \$border,
	'scale=f'       => \$scale,
	'canvas=s'      => \$canvas,
	'colors=s'      => \$colors_file,
	'show-node-ids' => \$show_node_ids,
	'no-scale'      => \$no_scale,
	'antialias'     => \$antialias,
	'transparent'   => \$transparent,
	'background=s'  => \$background,
	) or die "Error in command line arguments\n" ;

show_help() if $help ;

if (@ARGV != 3)
	{
	print STDERR "Error: Missing required arguments\n\n" ;
	show_help() ;
	}

my ($input_file, $layout_file, $output_file) = @ARGV ;

if (defined $scale && defined $canvas)
	{
	die "Error: Cannot specify both --scale and --canvas\n" ;
	}

if ($no_scale && (defined $scale || defined $canvas))
	{
	die "Error: Cannot use --no-scale with --scale or --canvas\n" ;
	}

open my $input_fh, '<', $input_file or die "Cannot read $input_file: $!" ;
my $input_text = do { local $/; <$input_fh> } ;
close $input_fh ;

open my $layout_fh, '<', $layout_file or die "Cannot read $layout_file: $!" ;
my $layout_text = do { local $/; <$layout_fh> } ;
close $layout_fh ;

my $graph  = parse_graph_input($input_text) ;
my $layout = parse_graph_output($layout_text) ;

my %render_options =
	(
	border        => $border,
	show_node_ids => $show_node_ids,
	no_scale      => $no_scale,
	antialias     => $antialias,
	transparent   => $transparent,
	) ;

if (defined $scale)
	{
	$render_options{scale} = $scale ;
	}

if (defined $canvas)
	{
	if ($canvas =~ /^(\d+)x(\d+)$/i)
		{
		$render_options{canvas_width}  = $1 ;
		$render_options{canvas_height} = $2 ;
		}
	else
		{
		die "Error: Canvas must be in format WIDTHxHEIGHT (e.g., 800x600)\n" ;
		}
	}

my $colors = {} ;
if (defined $colors_file && -f $colors_file)
	{
	open my $colors_fh, '<', $colors_file or die "Cannot read $colors_file: $!" ;
	my $colors_text = do { local $/; <$colors_fh> } ;
	close $colors_fh ;
	$colors = parse_color_config($colors_text) ;
	}

if (defined $background)
	{
	require LibAvoidRenderer ;
	$colors->{background} = LibAvoidRenderer::parse_color_spec($background) ;
	}

$render_options{colors} = $colors ;

if ($output_file =~ /\.png$/i)
	{
	render_png
		(
		$graph,
		$layout,
		$output_file,
		%render_options,
		) ;
	print "PNG rendered to $output_file\n" ;
	}
elsif ($output_file =~ /\.svg$/i)
	{
	render_svg
		(
		$graph,
		$layout,
		$output_file,
		%render_options,
		) ;
	print "SVG rendered to $output_file\n" ;
	}
else
	{
	die "Error: Output file must be .png or .svg\n" ;
	}
