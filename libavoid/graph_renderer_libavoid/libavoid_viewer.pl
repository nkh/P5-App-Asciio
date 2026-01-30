#!/usr/bin/env perl
use strict;
use warnings;
use Gtk3 -init ;
use Glib qw(TRUE FALSE) ;
use Cairo ;
use Getopt::Long ;
use FindBin ;
use lib $FindBin::Bin ;
use LibAvoidRenderer qw(parse_graph_input parse_graph_output parse_color_config calculate_render_parameters render_to_cairo) ;

sub show_help
{
print <<'END_HELP' ;
Usage: libavoid_viewer.pl <input_file> <layout_file> [options]

Options:
  -h, --help              Show this help message
  --border N              Border size in pixels (default: 10)
  --scale FACTOR          Initial scale factor
  --canvas WIDTHxHEIGHT   Initial canvas size
  --no-scale              Disable auto-scaling
  --colors FILE           Color configuration file
  --show-node-ids         Display node IDs inside nodes
  --antialias             Enable antialiasing
  --background COLOR      Background color
  --watch                 Auto-reload files when changed

Keyboard shortcuts:
  +          Zoom in (scale by 1.5)
  -          Zoom out (scale by 1/1.5)
  0          Reset to auto-fit zoom
  f          Fit to window
  q          Quit
  Arrow keys Scroll view (h/j/k/l also work)

Mouse controls:
  Click+Drag  Pan view
END_HELP
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
my $background     = undef ;
my $watch          = 0 ;

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
	'background=s'  => \$background,
	'watch'         => \$watch,
	) or die "Error in command line arguments\n" ;

show_help() if $help ;

if (@ARGV != 2)
	{
	print STDERR "Error: Missing required arguments\n\n" ;
	show_help() ;
	}

my ($input_file, $layout_file) = @ARGV ;

if (defined $scale && defined $canvas)
	{
	die "Error: Cannot specify both --scale and --canvas\n" ;
	}

my %base_options =
	(
	border        => $border,
	show_node_ids => $show_node_ids,
	no_scale      => $no_scale,
	antialias     => $antialias,
	) ;

if (defined $scale)
	{
	$base_options{scale} = $scale ;
	}

if (defined $canvas)
	{
	if ($canvas =~ /^(\d+)x(\d+)$/i)
		{
		$base_options{canvas_width}  = $1 ;
		$base_options{canvas_height} = $2 ;
		}
	else
		{
		die "Error: Canvas must be in format WIDTHxHEIGHT (e.g., 800x600)\n" ;
		}
	}

my $graph ;
my $layout ;
my $colors         = {} ;
my $params ;
my $current_scale ;
my $initial_scale ;
my $drag_start_x ;
my $drag_start_y ;
my $drag_offset_x  = 0 ;
my $drag_offset_y  = 0 ;
my $is_dragging    = 0 ;
my $scrolled_window ;

sub load_files
{
open my $input_fh, '<', $input_file or die "Cannot read $input_file: $!" ;
my $input_text = do { local $/; <$input_fh> } ;
close $input_fh ;

open my $layout_fh, '<', $layout_file or die "Cannot read $layout_file: $!" ;
my $layout_text = do { local $/; <$layout_fh> } ;
close $layout_fh ;

$graph  = parse_graph_input($input_text) ;
$layout = parse_graph_output($layout_text) ;

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

$params        = calculate_render_parameters($graph, $layout, %base_options) ;
$current_scale = $params->{scale} ;
$initial_scale = $current_scale ;
}

load_files() ;

my $window = Gtk3::Window->new('toplevel') ;
$window->set_title('LibAvoid Graph Viewer') ;
$window->set_default_size(800, 600) ;
$window->signal_connect(destroy => sub { Gtk3::main_quit ; }) ;

$scrolled_window = Gtk3::ScrolledWindow->new ;
$scrolled_window->set_policy('automatic', 'automatic') ;

my $drawing_area = Gtk3::DrawingArea->new ;

$drawing_area->add_events
	(
	[
	'button-press-mask',
	'button-release-mask',
	'pointer-motion-mask',
	]
	) ;

$drawing_area->signal_connect
	(
	draw => sub
		{
		my ($widget, $cr) = @_ ;
		
		my $allocation      = $widget->get_allocation ;
		my $viewport_width  = $allocation->{width} ;
		my $viewport_height = $allocation->{height} ;
		
		my %render_opts =
			(
			%base_options,
			scale  => $current_scale,
			colors => $colors,
			) ;
		
		my $current_params = calculate_render_parameters($graph, $layout, %render_opts) ;
		
		my $render_width  = $current_params->{canvas_width} ;
		my $render_height = $current_params->{canvas_height} ;
		
		my $x_offset = $drag_offset_x ;
		my $y_offset = $drag_offset_y ;
		
		if ($render_width < $viewport_width)
			{
			$x_offset += ($viewport_width - $render_width) / 2 ;
			}
		
		if ($render_height < $viewport_height)
			{
			$y_offset += ($viewport_height - $render_height) / 2 ;
			}
		
		$current_params->{x_offset} = $x_offset ;
		$current_params->{y_offset} = $y_offset ;
		
		render_to_cairo
			(
			$graph,
			$layout,
			$cr,
			params        => $current_params,
			colors        => $colors,
			show_node_ids => $show_node_ids,
			antialias     => $antialias,
			) ;
		
		return FALSE ;
		}
	) ;

my $update_size = sub
{
my %render_opts =
	(
	%base_options,
	scale  => $current_scale,
	colors => $colors,
	) ;

my $current_params = calculate_render_parameters($graph, $layout, %render_opts) ;

$drawing_area->set_size_request($current_params->{canvas_width}, $current_params->{canvas_height}) ;
$drawing_area->queue_draw ;
} ;

my $fit_to_window = sub
{
my $allocation      = $scrolled_window->get_allocation ;
my $viewport_width  = $allocation->{width} ;
my $viewport_height = $allocation->{height} ;

my %fit_opts =
	(
	%base_options,
	canvas_width  => $viewport_width,
	canvas_height => $viewport_height,
	) ;

my $fit_params = calculate_render_parameters($graph, $layout, %fit_opts) ;
$current_scale = $fit_params->{scale} ;
$drag_offset_x = 0 ;
$drag_offset_y = 0 ;
$update_size->() ;
} ;

my $scroll_step = 20 ;

$window->signal_connect
	(
	'key-press-event' => sub
		{
		my ($widget, $event) = @_ ;
		my $keyval  = $event->keyval ;
		my $keyname = Gtk3::Gdk::keyval_name($keyval) ;
		
		if ($keyname eq 'plus' || $keyname eq 'KP_Add')
			{
			$current_scale *= 1.5 ;
			$update_size->() ;
			return TRUE ;
			}
		elsif ($keyname eq 'minus' || $keyname eq 'KP_Subtract')
			{
			$current_scale /= 1.5 ;
			$update_size->() ;
			return TRUE ;
			}
		elsif ($keyname eq '0' || $keyname eq 'KP_0')
			{
			$current_scale = $initial_scale ;
			$drag_offset_x = 0 ;
			$drag_offset_y = 0 ;
			$update_size->() ;
			return TRUE ;
			}
		elsif ($keyname eq 'f' || $keyname eq 'F')
			{
			$fit_to_window->() ;
			return TRUE ;
			}
		elsif ($keyname eq 'q' || $keyname eq 'Q')
			{
			Gtk3::main_quit ;
			return TRUE ;
			}
		elsif ($keyname eq 'Left' || $keyname eq 'h')
			{
			my $hadj = $scrolled_window->get_hadjustment ;
			$hadj->set_value($hadj->get_value - $scroll_step) ;
			return TRUE ;
			}
		elsif ($keyname eq 'Right' || $keyname eq 'l')
			{
			my $hadj = $scrolled_window->get_hadjustment ;
			$hadj->set_value($hadj->get_value + $scroll_step) ;
			return TRUE ;
			}
		elsif ($keyname eq 'Up' || $keyname eq 'k')
			{
			my $vadj = $scrolled_window->get_vadjustment ;
			$vadj->set_value($vadj->get_value - $scroll_step) ;
			return TRUE ;
			}
		elsif ($keyname eq 'Down' || $keyname eq 'j')
			{
			my $vadj = $scrolled_window->get_vadjustment ;
			$vadj->set_value($vadj->get_value + $scroll_step) ;
			return TRUE ;
			}
		
		return FALSE ;
		}
	) ;

$drawing_area->signal_connect
	(
	'button-press-event' => sub
		{
		my ($widget, $event) = @_ ;
		
		if ($event->button == 1)
			{
			$is_dragging  = 1 ;
			$drag_start_x = $event->x ;
			$drag_start_y = $event->y ;
			return TRUE ;
			}
		
		return FALSE ;
		}
	) ;

$drawing_area->signal_connect
	(
	'button-release-event' => sub
		{
		my ($widget, $event) = @_ ;
		
		if ($event->button == 1)
			{
			$is_dragging = 0 ;
			return TRUE ;
			}
		
		return FALSE ;
		}
	) ;

$drawing_area->signal_connect
	(
	'motion-notify-event' => sub
		{
		my ($widget, $event) = @_ ;
		
		if ($is_dragging)
			{
			my $dx = $event->x - $drag_start_x ;
			my $dy = $event->y - $drag_start_y ;
			
			$drag_offset_x += $dx ;
			$drag_offset_y += $dy ;
			
			$drag_start_x = $event->x ;
			$drag_start_y = $event->y ;
			
			$widget->queue_draw ;
			return TRUE ;
			}
		
		return FALSE ;
		}
	) ;

if ($watch)
	{
	my $last_input_mtime  = (stat $input_file)[9] ;
	my $last_layout_mtime = (stat $layout_file)[9] ;
	
	Glib::Timeout->add
		(
		1000,
		sub
			{
			my $input_mtime  = (stat $input_file)[9] ;
			my $layout_mtime = (stat $layout_file)[9] ;
			
			if ($input_mtime != $last_input_mtime || $layout_mtime != $last_layout_mtime)
				{
				eval
					{
					load_files() ;
					$update_size->() ;
					} ;
				
				if ($@)
					{
					warn "Error reloading files: $@" ;
					}
				else
					{
					$last_input_mtime  = $input_mtime ;
					$last_layout_mtime = $layout_mtime ;
					}
				}
			
			return TRUE ;
			}
		) ;
	}

$update_size->() ;

$scrolled_window->add($drawing_area) ;
$window->add($scrolled_window) ;
$window->show_all ;

Gtk3::main ;
