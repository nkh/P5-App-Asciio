
package App::Asciio::GTK::Asciio ;

use base qw(App::Asciio) ;

use strict;
use warnings;

use Glib ':constants';
use Gtk3 -init;
use Pango ;

use List::Util qw(min) ;

use App::Asciio::GTK::Asciio::Selection ;
use App::Asciio::GTK::Asciio::Pen ;
use App::Asciio::GTK::Asciio::Find ;
use App::Asciio::GTK::Asciio::stripes::image_box ;

use App::Asciio::Cross ;
use App::Asciio::Markup ;
use App::Asciio::String ;
use App::Asciio::ZBuffer ;

our $VERSION = '0.10' ;

#-----------------------------------------------------------------------------

sub new
{
my ($class, $window, $width, $height, $sc_window) = @_ ;

my $self = App::Asciio::new($class) ;
bless $self, $class ;

$self->{UI} = 'GUI' ;

$window->signal_connect(key_press_event => \&key_press_event, $self) ;
$window->signal_connect(motion_notify_event => \&motion_notify_event, $self) ;
$window->signal_connect(button_press_event => \&button_press_event, $self) ;
$window->signal_connect(button_release_event => \&button_release_event, $self) ;
$window->signal_connect(configure_event => sub { $self->update_display() ; }) ;

$sc_window->get_hadjustment()->signal_connect(value_changed => sub { $self->update_display() ; }) ;
$sc_window->get_vadjustment()->signal_connect(value_changed => sub { $self->update_display() ; }) ;
$sc_window->add_events(['GDK_SCROLL_MASK']) ;
$sc_window->signal_connect(scroll_event => \&mouse_scroll_event, $self) ;

my $drawing_area = Gtk3::DrawingArea->new ;

$self->{widget}      = $drawing_area ;
$self->{ROOT_WINDOW} = $window ;
$self->{SC_WINDOW}   = $sc_window ;

$drawing_area->signal_connect(draw => \&expose_event, $self);

$drawing_area->set_events
		([qw/
		exposure-mask
		leave-notify-mask
		button-press-mask
		button-release-mask
		pointer-motion-mask
		key-press-mask
		key-release-mask
		/]);

return($self) ;
}

#-----------------------------------------------------------------------------

sub destroy
{
my ($self) = @_;

$self->{widget}->get_toplevel()->destroy() ;
}

#-----------------------------------------------------------------------------

sub set_font
{
my ($self, $font_family, $font_size) = @_;

$self->SUPER::set_font($font_family, $font_size) ;
}

#-----------------------------------------------------------------------------

sub stop_updating_display  { my ($self) = @_ ; $self->{NO_UPDATE_DISPLAY} = 1 ; }
sub start_updating_display { my ($self) = @_ ; $self->{NO_UPDATE_DISPLAY} = 0 ; $self->update_display() }

sub update_display 
{
my ($self) = @_;

if (!$self->{NO_UPDATE_DISPLAY})
	{
	$self->SUPER::update_display() ;
	
	my $widget = $self->{widget} ;
	$widget->queue_draw_area(0, 0, $widget->get_allocated_width, $widget->get_allocated_height);
	}
}

#-----------------------------------------------------------------------------

sub expose_event
{
my ($widget, $gc, $self) = @_;

my ($widget_width, $widget_height)       = ($widget->get_allocated_width(), $widget->get_allocated_height()) ;
my ($window_width, $window_height)       = ($widget_width, $widget_height) ; #$self->{ROOT_WINDOW}->get_size() ;
my ($character_width, $character_height) = $self->get_character_size() ;
my ($v_value, $h_value)                  = ($self->{SC_WINDOW}->get_vadjustment()->get_value(), $self->{SC_WINDOW}->get_hadjustment()->get_value()) ;
my $grid_width                           = (int ($window_width / $character_width) + 2)   * $character_width ;
my $grid_height                          = (int ($window_height / $character_height) + 2) * $character_height ;

my $expose_data =
	{
	gc               => $gc,
	
	character_height => $character_height,
	character_width  => $character_width,
	font_description => Pango::FontDescription->from_string($self->get_font_as_string()),
	grid_height      => $grid_height,
	grid_width       => $grid_width,
	scroll_h_value   => $h_value,
	scroll_v_value   => $v_value,
	viewport         => $self->get_viewport_info($window_width, $window_height, $h_value, $v_value, $character_width, $character_height),
	widget_height    => $widget_height,
	widget_width     => $widget_width,
	} ;

$self->draw_asciio($expose_data) ;
}

sub draw_asciio
{
my ($self, $expose_data) = @_ ;

$expose_data->{gc}->set_line_width(1) ;

$self->draw_background_and_grid    ($expose_data) ;
$self->draw_elements               ($expose_data) ;
$self->draw_cross_overlays         ($expose_data) ;
$self->draw_overlay                ($expose_data) ;
$self->draw_ruler_lines            ($expose_data) if $self->{DISPLAY_RULERS} ;
$self->draw_connections            ($expose_data) ;
$self->draw_new_connection         ($expose_data) ;
$self->draw_selection              ($expose_data) ;
$self->display_mouse_cursor        ($expose_data) if $self->{MOUSE_TOGGLE} ;
$self->draw_hint_lines             ($expose_data) if $self->{DRAW_HINT_LINES} ;
$self->display_bindings_completion ($expose_data) if $self->{BINDINGS_COMPLETION} ;
$self->draw_pen_mapping_help       ($expose_data) ;
$self->draw_find_highlight         ($expose_data) ;

return TRUE ;
}

#-----------------------------------------------------------------------------

sub draw_pen_mapping_help
{
my ($self, $expose_data) = @_ ;
App::Asciio::GTK::Asciio::Pen::pen_show_mapping_help($self, $expose_data->{gc}) ;
}

#-----------------------------------------------------------------------------

sub draw_find_highlight
{
my ($self, $expose_data) = @_ ;
App::Asciio::GTK::Asciio::Find::draw_find_keywords_highlight($self, $expose_data->{gc}, $expose_data->{character_width}, $expose_data->{character_height}) ;
}

#-----------------------------------------------------------------------------

sub draw_background_and_grid
{
my ($self, $expose_data) = @_ ;

my ($gc, $grid_width, $grid_height, $scroll_h_value, $scroll_v_value, $character_width, $character_height, $widget_width, $widget_height)
	= @{$expose_data}{qw/ gc grid_width grid_height scroll_h_value scroll_v_value character_width character_height widget_width widget_height /} ;

my ($background_and_grid_rendering, $draw_start_x, $draw_start_y, $grid_cache_key) ;

if($self->{GTK_MEMORY_OVER_SPEED})
	{
	$grid_cache_key = "$grid_width-$grid_height-" . ($self->get_color('background') // '') . '-' . ($self->get_color('grid') // '') . '-' . ($self->get_color('grid_2') // '') ;
	$background_and_grid_rendering = $self->{CACHE}{BACKGROUND_AND_GRID}{$grid_cache_key} ;
	($draw_start_x, $draw_start_y) = (int($scroll_h_value / $character_width) * $character_width, int($scroll_v_value / $character_height) * $character_height) ;
	}
else
	{
	($grid_width, $grid_height) = ($widget_width, $widget_height) ;
	$background_and_grid_rendering = $self->{CACHE}{BACKGROUND_AND_GRID} ;
	($draw_start_x, $draw_start_y) = (0, 0) ;
	}

unless (defined $background_and_grid_rendering)
	{
	delete $self->{CACHE}{BACKGROUND_AND_GRID} ;
	my $surface = Cairo::ImageSurface->create('argb32', $grid_width, $grid_height) ;
	my $gc = Cairo::Context->create($surface) ;
	
	$gc->set_source_rgb(@{$self->get_color('background')});
	$gc->rectangle(0, 0, $grid_width, $grid_height);
	$gc->fill;
	
	if($self->{DISPLAY_GRID})
		{
		$gc->set_line_width(1) ;
		
		for my $horizontal (0 .. ($grid_height/$character_height) + 1)
			{
			my $color = ($horizontal % 10 == 0 and $self->{DISPLAY_GRID2}) ? 'grid_2' : 'grid' ;
			$gc->set_source_rgb(@{$self->get_color($color)});
			
			$gc->move_to(0,  $horizontal * $character_height);
			$gc->line_to($grid_width, $horizontal * $character_height);
			$gc->stroke;
			}
		
		for my $vertical(0 .. ($grid_width/$character_width) + 1)
			{
			my $color = ($vertical % 10 == 0 and $self->{DISPLAY_GRID2}) ? 'grid_2' : 'grid' ;
			$gc->set_source_rgb(@{$self->get_color($color)});
			
			$gc->move_to($vertical * $character_width, 0) ;
			$gc->line_to($vertical * $character_width, $grid_height);
			$gc->stroke;
			}
		}
		
	if($self->{GTK_MEMORY_OVER_SPEED})
		{
		$background_and_grid_rendering = $self->{CACHE}{BACKGROUND_AND_GRID}{$grid_cache_key} = $surface ;
		}
	else
		{
		$background_and_grid_rendering = $self->{CACHE}{BACKGROUND_AND_GRID} = $surface ;
		}
	}

$gc->set_source_surface($background_and_grid_rendering, $draw_start_x, $draw_start_y) ;
$gc->paint;
}

#-----------------------------------------------------------------------------

sub draw_cross_overlays
{
my ($self, $expose_data) = @_ ;

my ($gc, $character_width, $character_height, $viewport)
	= @{$expose_data}{qw/ gc character_width character_height viewport /} ;

my @cross_elements = grep { $_->is_crossover_enabled() } @{$viewport->{drawing_order}} ;
return unless @cross_elements ;

my $zbuffer = App::Asciio::ZBuffer->new(1, @cross_elements) ;

my ($default_background_color, $default_foreground_color) = (
	$self->get_color('element_background'), $self->get_color('element_foreground')) ;

for (App::Asciio::Cross::get_cross_mode_overlays($zbuffer))
	{
	my ($x, $y, $overlay, $background_color, $foreground_color) = @$_ ;
	
	$background_color //= $default_background_color ;
	$foreground_color //= $default_foreground_color ;
	
	my $cache_key = $background_color . $foreground_color . $overlay ;
	
	unless(exists $self->{CACHE}{CROSS_OVERLAY}{$cache_key})
		{
		my $surface = Cairo::ImageSurface->create('argb32', $character_width, $character_height) ;
		my $gco = Cairo::Context->create($surface) ;
		
		my $layout = Pango::Cairo::create_layout($gco) ;
		$layout->set_font_description(Pango::FontDescription->from_string($self->get_font_as_string())) ;
		
		$gco->set_source_rgb(@{$background_color});
		$gco->rectangle(0, 0, $character_width, $character_height) ;
		$gco->fill();
		
		$gco->set_source_rgb(@{$foreground_color});
		
		$layout->set_text($overlay) ;
		Pango::Cairo::show_layout($gco, $layout) ;
		
		$self->{CACHE}{CROSS_OVERLAY}{$cache_key} = $surface ;
		}
	
	$gc->set_source_surface($self->{CACHE}{CROSS_OVERLAY}{$cache_key}, $x * $character_width, $y * $character_height) ;
	$gc->paint ;
	}
}

#-----------------------------------------------------------------------------

sub draw_overlay
{
my ($self, $expose_data) = @_ ;

my ($gc, $character_width, $character_height, $widget_width, $widget_height)
	= @{$expose_data}{qw/ gc character_width character_height widget_width widget_height /} ;

my $surface = Cairo::ImageSurface->create('argb32', $character_width, $character_height) ;
my $gco = Cairo::Context->create($surface) ;

my $layout = Pango::Cairo::create_layout($gco) ;
my $font_description = Pango::FontDescription->from_string($self->get_font_as_string()) ;
$layout->set_font_description($font_description) ;

my $element_index = 0 ;

my @overlay_elements = $self->get_overlays('GUI', $gc, $widget_width, $widget_height, $character_width, $character_height) ;
for (@overlay_elements)
	{
	if(! defined $_)
		{
		print STDERR "GTK::Asciio: got undef\n" ;
		}
	elsif(ref $_ eq 'ARRAY')
		{
		my ($x, $y, $overlay, $background_color, $foreground_color) = @$_ ;
		
		$background_color //= $self->get_color('element_background');
		$foreground_color //= $self->get_color('element_foreground') ;
		
		$gco->set_source_rgb(@{$background_color});
		$gco->rectangle(0, 0, $character_width, $character_height) ;
		$gco->fill();
		
		$gco->set_source_rgb(@{$foreground_color});
		
		$layout->set_text($overlay) ;
		Pango::Cairo::show_layout($gco, $layout) ;
		
		$gc->set_source_surface($surface, $x * $character_width, $y * $character_height);
		$gc->paint;
		}
	elsif(ref($_) =~ /^App::Asciio::stripes/)
		{
		$self->draw_element($_, $element_index, $expose_data) ;
		$element_index++ ; # should overlay stripes have number?
		}
	else
		{
		print STDERR "GTK::Asciio: got someting else " . ref($_) . "\n" ;
		}
	}

# draw hint_lines
if(@overlay_elements and $self->{DRAW_HINT_LINES})
	{
	my ($xs, $ys, $xe, $ye, $has_extents) = $self->get_selected_elements_extents(@overlay_elements) ; 
	
	if($has_extents)
		{
		$gc->set_line_width(1);
		$gc->set_source_rgb(@{$self->get_color('hint_line2')});
		
		$gc->move_to($xs * $character_width, 0) ;
		$gc->line_to($xs * $character_width, $widget_height) ;
		
		$gc->move_to(0, $ys * $character_height) ;
		$gc->line_to($widget_width, $ys * $character_height);
		
		$gc->move_to($xe * $character_width, 0) ;
		$gc->line_to($xe * $character_width, $widget_height) ;
		
		$gc->move_to(0, $ye * $character_height) ;
		$gc->line_to($widget_width, $ye * $character_height);
		
		$gc->stroke() ;
		}
	}
}

#-----------------------------------------------------------------------------

sub draw_ruler_lines
{
my ($self, $expose_data) = @_ ;

my ($gc, $character_width, $character_height, $widget_width, $widget_height)
	= @{$expose_data}{qw/ gc character_width character_height widget_width widget_height /} ;

for my $line (@{$self->{RULER_LINES}})
	{
	my @rgb = exists $line->{COLOR} ? @{$line->{COLOR}} : @{$self->get_color('ruler_line')} ;
	$gc->set_source_rgb(@rgb) ;
	
	if($line->{TYPE} eq 'VERTICAL')
		{
		$gc->move_to($line->{POSITION} * $character_width, 0) ;
		$gc->line_to($line->{POSITION} * $character_width, $widget_height) ;
		}
	else
		{
		$gc->move_to(0, $line->{POSITION} * $character_height) ;
		$gc->line_to($widget_width, $line->{POSITION} * $character_height);
		}
	
	$gc->stroke() ;
	}
}

#-----------------------------------------------------------------------------

sub draw_connections
{
my ($self, $expose_data) = @_ ;

my ($gc, $character_width, $character_height, $viewport)
	= @{$expose_data}{qw/ gc character_width character_height viewport /} ;

my (%connected_connections, %connected_connectors) ;

for my $connection (@{$self->{CONNECTIONS}})
	{
	next unless exists $viewport->{elements_indexs}{$connection->{CONNECTED}} ;
	
	my $draw_connection ;
	my $connector  ;
	
	if($self->is_over_element($connection->{CONNECTED}, $self->{MOUSE_X}, $self->{MOUSE_Y}, 1))
		{
		$draw_connection++ ;
		
		$connector = $connection->{CONNECTED}->get_named_connection($connection->{CONNECTOR}{NAME}) ;
		$connected_connectors{$connection->{CONNECTED}}{$connector->{X}}{$connector->{Y}}++ ;
		}
		
	if($self->is_over_element($connection->{CONNECTEE}, $self->{MOUSE_X}, $self->{MOUSE_Y}, 1))
		{
		$draw_connection++ ;
		
		my $connectee_connection = $connection->{CONNECTEE}->get_named_connection($connection->{CONNECTION}{NAME}) ;
		
		if($connectee_connection)
			{
			$connected_connectors{$connection->{CONNECTEE}}{$connectee_connection->{X}}{$connectee_connection->{Y}}++ ;
			}
		}
		
	if($draw_connection)
		{
		$connector ||= $connection->{CONNECTED}->get_named_connection($connection->{CONNECTOR}{NAME}) ;
		
		unless (defined $self->{CACHE}{CONNECTION})
			{
			my $surface = Cairo::ImageSurface->create('argb32', $character_width, $character_height);
			
			my $gc = Cairo::Context->create($surface);
			$gc->set_line_width(1);
			$gc->set_source_rgb(@{$self->get_color('connection')});
			$gc->rectangle(0, 0, $character_width, $character_height);
			$gc->stroke() ;
			
			$self->{CACHE}{CONNECTION} = $surface ;
			}
		
		my $connection_rendering = $self->{CACHE}{CONNECTION} ;
		
		$gc->set_source_surface
			(
			$connection_rendering,
			($connector->{X} + $connection->{CONNECTED}{X}) * $character_width,
			($connector->{Y}  + $connection->{CONNECTED}{Y}) * $character_height,
			);
		
		$gc->paint;
		}
	}
	
# draw connectors and connection points
unless (defined $self->{CACHE}{CONNECTOR_POINT})
	{
	my $surface = Cairo::ImageSurface->create('argb32', $character_width, $character_height);
	
	my $gc = Cairo::Context->create($surface);
	$gc->set_line_width(1);
	$gc->set_source_rgb(@{$self->get_color('connector_point')});
	$gc->rectangle(0, 0, $character_width, $character_height);
	$gc->stroke() ;
	
	$self->{CACHE}{CONNECTOR_POINT} = $surface ;
	}
my $connector_point_rendering = $self->{CACHE}{CONNECTOR_POINT} ;

unless (defined $self->{CACHE}{CONNECTION_POINT})
	{
	my $surface = Cairo::ImageSurface->create('argb32', $character_width, $character_height);
	
	my $gc = Cairo::Context->create($surface);
	$gc->set_line_width(1);
	$gc->set_source_rgb(@{$self->get_color('connection_point')});
	$gc->rectangle($character_width/3, $character_height/3, $character_width/3, $character_height/3);
	$gc->stroke() ;
	
	$self->{CACHE}{CONNECTION_POINT} = $surface ;
	}
my $connection_point_rendering = $self->{CACHE}{CONNECTION_POINT} ;

unless (defined $self->{CACHE}{EXTRA_POINT})
	{
	my $surface = Cairo::ImageSurface->create('argb32', $character_width, $character_height);
	
	my $gc = Cairo::Context->create($surface);
	$gc->set_line_width(2);
	$gc->set_source_rgb(@{$self->get_color('extra_point')});
	$gc->rectangle(0, 0, $character_width, $character_height);
	$gc->stroke() ;
	$gc->set_line_width(1);
	
	$self->{CACHE}{EXTRA_POINT} = $surface ;
	}
my $extra_point_rendering = $self->{CACHE}{EXTRA_POINT} ;

for my $element (
		$self->{DISPLAY_ALL_CONNECTORS} 
			? @{$viewport->{drawing_order}}
			: grep { $self->is_over_element($_, $self->{MOUSE_X}, $self->{MOUSE_Y}, 1) } @{$viewport->{drawing_order}}
		)
	{
	for my $connector ($element->get_connector_points())
		{
		next if exists $connected_connectors{$element}{$connector->{X}}{$connector->{Y}} ;
		
		$gc->set_source_surface
			(
			$connector_point_rendering,
			($element->{X} + $connector->{X}) * $character_width, # can be additions
			($connector->{Y} + $element->{Y}) * $character_height,
			);
		
		$gc->paint;
		}
	
	for my $connection_point ($element->get_connection_points())
		{
		next if $element->{AUTOCONNECT_DISABLED} ;
		next if exists $connected_connections{$element}{$connection_point->{X}}{$connection_point->{Y}} ;
		
		$gc->set_source_surface
			(
			$connection_point_rendering,
			(($connection_point->{X} + $element->{X}) * $character_width), # can be additions
			(($connection_point->{Y} + $element->{Y}) * $character_height),
			);
		
		$gc->paint;
		}
	
	unless(defined $self->{DRAGGING} || (exists $element->{GROUP} and defined $element->{GROUP}[-1]))
	{
		for my $extra_point ($element->get_extra_points())
			{
			$gc->set_source_surface
				(
				$extra_point_rendering,
				(($extra_point->{X}  + $element->{X}) * $character_width), # can be additions
				(($extra_point->{Y}  + $element->{Y}) * $character_height),
				);
			
			$gc->paint;
			}
	}
	
	$gc->show_page;
	}
}

#-----------------------------------------------------------------------------

sub draw_new_connection
{
my ($self, $expose_data) = @_ ;

my ($gc, $character_width, $character_height)
	= @{$expose_data}{qw/ gc character_width character_height /} ;

for my $new_connection (@{$self->{NEW_CONNECTIONS}})
	{
	my $end_connection = $new_connection->{CONNECTED}->get_named_connection($new_connection->{CONNECTOR}{NAME}) ;
	
	$gc->set_source_rgb(@{$self->get_color('new_connection')});
	$gc->rectangle
		(
		($end_connection->{X} + $new_connection->{CONNECTED}{X}) * $character_width , # can be additions
		($end_connection->{Y} + $new_connection->{CONNECTED}{Y}) * $character_height ,
		$character_width, $character_height
		);
	}

$gc->stroke() ;

delete $self->{NEW_CONNECTIONS} ;
}

#----------------------------------------------------------------------------------------------

sub draw_selection
{
my ($self, $expose_data) = @_ ;

my ($gc, $character_width, $character_height)
	= @{$expose_data}{qw/ gc character_width character_height /} ;

if(defined $self->{SELECTION_RECTANGLE}{END_X})
	{
	$self->draw_rectangle_selection($gc, $character_width, $character_height) ;
	}
elsif(@{$self->{SELECTION_POLYGON}//[]} > 0)
	{
	$self->draw_polygon_selection($gc, $character_width, $character_height) ;
	}
}

#-----------------------------------------------------------------------------

sub display_mouse_cursor
{
my ($self, $expose_data) = @_ ;

my ($gc, $character_width, $character_height) = @{$expose_data}{qw/ gc character_width character_height /} ;

my $start_x = $self->{MOUSE_X} * $character_width ;
my $start_y = $self->{MOUSE_Y} * $character_height ;

$gc->set_source_rgba(@{$self->get_color('mouse_rectangle')}) ;

if(defined $self->{SIMULATE_MOUSE_TYPE})
	{
	App::Asciio::GTK::Asciio::Pen::pen_draw_mouse_cursor
		(
		$gc,
		$self->{SIMULATE_MOUSE_TYPE},
		$character_width, $character_height,
		$start_x, $start_y
		) ;
	}
else
	{
	$gc->rectangle($start_x, $start_y, $character_width, $character_height) ;
	$gc->fill() ;
	$gc->stroke() ;
	}
}

#-----------------------------------------------------------------------------

sub draw_hint_lines()
{
my ($self, $expose_data) = @_ ;

my ($gc, $character_width, $character_height, $widget_width, $widget_height)
	= @{$expose_data}{qw/ gc character_width character_height widget_width widget_height /} ;

my ($xs, $ys, $xe, $ye, $has_extents) = $self->get_selected_elements_extents() ; 

if($has_extents)
	{
	$gc->set_line_width(1);
	$gc->set_source_rgb(@{$self->get_color('hint_line')});
	
	$gc->move_to($xs * $character_width, 0) ;
	$gc->line_to($xs * $character_width, $widget_height) ;
	
	$gc->move_to(0, $ys * $character_height) ;
	$gc->line_to($widget_width, $ys * $character_height);
	
	$gc->move_to($xe * $character_width, 0) ;
	$gc->line_to($xe * $character_width, $widget_height) ;
	
	$gc->move_to(0, $ye * $character_height) ;
	$gc->line_to($widget_width, $ye * $character_height);
	
	$gc->stroke() ;
	}
}

#-----------------------------------------------------------------------------

sub display_bindings_completion
{
my ($self, $expose_data) = @_ ;

my ($gc, $character_width, $character_height )
	= @{$expose_data}{qw/ gc character_width character_height /} ;

$gc->set_source_rgb(@{$self->get_color('hint_background')}) ;

my ($font_character_width, $font_character_height) = $self->get_character_size($self->{FONT_FAMILY}, $self->{FONT_BINDINGS_SIZE}) ;

my ($width, $height) = ($self->{BINDINGS_COMPLETION_LENGTH} * $font_character_width, $font_character_height * $self->{BINDINGS_COMPLETION}->@*) ;
$width += $font_character_width / 2 ;

my ($window_width, $window_height) = ($self->get_allocated_width, $self->get_allocated_height);
my ($scroll_bar_x, $scroll_bar_y)  = (0, 0) ;

# my ($window_width, $window_height) = $self->{ROOT_WINDOW}->get_size() ;
# my ($scroll_bar_x, $scroll_bar_y)  = ($self->{SC_WINDOW}->get_hadjustment()->get_value(), $self->{SC_WINDOW}->get_vadjustment()->get_value()) ;
my $window_end                     = $window_width + $scroll_bar_x ;

my $start_x ;
if ( $window_end < ($self->{MOUSE_X} * $character_width) + $width)
	{
	$start_x = (($self->{MOUSE_X} + 1) * $character_width) - $width ; # place left
	}
else
	{
	$start_x = ($self->{MOUSE_X} + 1) * $character_width ;
	}

my $start_y = min($window_height + $scroll_bar_y - $height , ($self->{MOUSE_Y} + 1) * $character_height) ;

$gc->rectangle($start_x, $start_y, $width, $height) ;
$gc->fill() ;

my $surface = Cairo::ImageSurface->create('argb32', $width, $height) ;
my $gco = Cairo::Context->create($surface) ;

my $layout = Pango::Cairo::create_layout($gco) ;
my $font_description = Pango::FontDescription->from_string("$self->{FONT_FAMILY} $self->{FONT_BINDINGS_SIZE}") ;
$layout->set_font_description($font_description) ;

$layout->set_text(join "\n", $self->{BINDINGS_COMPLETION}->@*) ;
Pango::Cairo::show_layout($gco, $layout) ;

$gc->set_source_surface($surface, $start_x, $start_y) ;
$gc->paint;
}

#-----------------------------------------------------------------------------

sub draw_elements
{
my ($self, $expose_data) = @_ ;

for my $element (@{$expose_data->{viewport}{drawing_order}})
	{
	$self->draw_element
		(
		$element,
		$expose_data->{viewport}{elements_indexs}{$element},
		$expose_data,
		) ;
	}
}

# ------------------------------------------------------------------------------

sub draw_element
{
my ($self, $element, $element_index, $expose_data) = @_ ;

my ($gc, $font_description, $character_width, $character_height)
	= @{$expose_data}{qw/ gc font_description character_width character_height /} ;

if ($element->isa('App::Asciio::GTK::Asciio::stripes::image_box'))
	{
	$self->draw_image_box_element($element, $gc, $character_width, $character_height) ;
	}
else
	{
	$self->draw_stripe_element($element, $element_index, $gc, $font_description, $character_width, $character_height) ;
	}
}

# ------------------------------------------------------------------------------

sub draw_stripe_element
{
my ($self, $element, $element_index, $gc, $font_description, $character_width, $character_height) = @_ ;

my $is_selected = $element->{SELECTED} // 0 ;
$is_selected = 1 if $is_selected > 0 ;

my ($background_color, $foreground_color) = $self->get_element_colors($element) ;

my $color_set = $is_selected . '-'
		. ($background_color // 'undef') . '-' . ($foreground_color // 'undef') . '-' 
		. ($self->{OPAQUE_ELEMENTS} // 1) . '-' . ($self->{NUMBERED_OBJECTS} // 0) ; 

my $renderings = $element->{CACHE}{RENDERING}{$color_set} ;

unless (defined $renderings)
	{
	my @renderings ;
	
	my $stripes = $element->get_stripes() ;
	
	for my $strip (@{$stripes})
		{
		my $line_index = 0 ;
		
		my $strip_background_color = $background_color ;
		my $strip_foreground_color = $foreground_color ;
		
		unless ($is_selected)
			{
			$strip_background_color = $strip->{BACKGROUND} // $background_color ;
			$strip_foreground_color = $strip->{FOREGROUND} // $foreground_color ;
			}
		
		my $strip_color_set .= $strip_background_color . $strip_foreground_color ;
		
		for my $line (split /\n/, $strip->{TEXT})
			{
			$line = "$line-$element" if $self->{NUMBERED_OBJECTS} ; # don't share rendering with other objects
			
			unless (exists $self->{CACHE}{STRIPS}{$strip_color_set}{$line})
				{
				my $surface = Cairo::ImageSurface->create('argb32', $strip->{WIDTH} * $character_width, $character_height);
				
				my $gc = Cairo::Context->create($surface);
				$gc->set_source_rgba(@{$strip_background_color}, $self->{OPAQUE_ELEMENTS});
				$gc->rectangle(0, 0, $strip->{WIDTH} * $character_width, $character_height);
				$gc->fill();
				
				$gc->set_source_rgb(@{$strip_foreground_color});
				
				if($self->{NUMBERED_OBJECTS})
					{
					$gc->set_line_width(1);
					$gc->select_font_face($self->{FONT_FAMILY}, 'normal', 'normal');
					$gc->set_font_size($self->{FONT_SIZE});
					$gc->rectangle(0, 0, $strip->{WIDTH} * $character_width, $character_height);
					$gc->move_to(0, $character_height * 0.66) ;
					$gc->show_text($element_index);
					$gc->stroke;
					}
				else
					{
					my $layout = Pango::Cairo::create_layout($gc) ;
					
					$layout->set_font_description($font_description) ;
					
					$USE_MARKUP_CLASS->ui_show_markup_characters($layout, $self->{FONT_SIZE}, $line) ;
					
					Pango::Cairo::show_layout($gc, $layout);
					}
				
				$self->{CACHE}{STRIPS}{$strip_color_set}{$line} = $surface ; # keep reference
				}
			
			my $strip_rendering = $self->{CACHE}{STRIPS}{$strip_color_set}{$line} ;
			push @renderings, [$strip_rendering, $strip->{X_OFFSET}, $strip->{Y_OFFSET} + $line_index++] ;
			}
		}
	
	$renderings = $element->{CACHE}{RENDERING}{$color_set} = \@renderings ;
	}

for my $rendering (@$renderings)
	{
	$gc->set_source_surface
		(
		$rendering->[0],
		($element->{X} + $rendering->[1]) * $character_width, # can be single addition
		($element->{Y} + $rendering->[2]) * $character_height
		);
	
	$gc->paint;
	}
}

# ------------------------------------------------------------------------------

sub draw_image_box_element
{
my ($self, $element, $gc, $character_width, $character_height) = @_ ;

my $cache_key = $element->{WIDTH} . '-' . $element->{HEIGHT} . '-' . $character_width . $character_height ;
my $rendering = $element->{CACHE}{RENDERING}{$cache_key} ;

unless (defined $rendering)
	{
	delete $element->{CACHE}{RENDERING} ;
	$rendering = $element->{CACHE}{RENDERING}{$cache_key} = $element->prepare_scaled_pixbuf($character_width, $character_height) ;
	}

Gtk3::Gdk::cairo_set_source_pixbuf($gc, $rendering, $element->{X} * $character_width, $element->{Y} * $character_height) ;

$gc->paint() ;

if ($element->{SELECTED})
	{
	my $alpha = 0.15 ;
	my ($background_color, undef) = $self->get_element_colors($element) ;
	$gc->set_source_rgba(@{$background_color}, $alpha) ;
	$gc->rectangle
		(
		$element->{X} * $character_width,
		$element->{Y} * $character_height,
		$element->{WIDTH}  * $character_width,
		$element->{HEIGHT} * $character_height
		) ;
	$gc->fill() ;
	}
}

#-----------------------------------------------------------------------------

sub get_element_colors
{
my ($self, $element) = @_ ;

my ($background_color, $foreground_color) = $element->get_colors() ;

if($element->{SELECTED})
	{
	if(exists $element->{GROUP} and defined $element->{GROUP}[-1])
		{
		$background_color = $element->{GROUP}[-1]{GROUP_COLOR}[0]
		}
	else
		{
		$background_color = $self->get_color('selected_element_background') ;
		}
	}
else
	{
	unless (defined $background_color)
		{
		if(exists $element->{GROUP} and defined $element->{GROUP}[-1])
			{
			$background_color = $element->{GROUP}[-1]{GROUP_COLOR}[1]
			}
		else
			{
			$background_color = $self->get_color('element_background') ;
			}
		}
	}

$foreground_color //= $self->get_color('element_foreground') ;

return ($background_color, $foreground_color) ;
}

#-----------------------------------------------------------------------------

sub key_press_event      { my (undef, $event, $self) = @_ ; $self->SUPER::key_press_event($self->create_asciio_event($event)) ; }

sub button_release_event { my (undef, $event, $self) = @_ ; $self->SUPER::button_release_event($self->create_asciio_event($event)) ; }

sub button_press_event   { my (undef, $event, $self) = @_ ; $self->SUPER::button_press_event($self->create_asciio_event($event)) ; }

#-----------------------------------------------------------------------------

sub motion_notify_event
{
my (undef, $event, $self) = @_ ;

my $event_type = $event->type() ;

if
	(
	$event_type eq "motion-notify"
	|| ref $event eq "Gtk3::Gdk::EventButton" 
	)
	{
	my $COORDINATES = [$self->closest_character($event->get_coords())]  ;
	
	$self->start_dnd($event)
		if $self->{IN_DRAG_DROP} && $event_type eq "motion-notify" && $self->any_selected_elements() ;
	}

$self->SUPER::motion_notify_event($self->create_asciio_event($event)) ; 
}

sub mouse_scroll_event   { my (undef, $event, $self) = @_ ; $self->SUPER::mouse_scroll_event($self->create_mouse_scroll_event($event)) ; }

#-----------------------------------------------------------------------------

sub create_asciio_event
{
my ($self, $event) = @_ ;

my $event_type= $event->type() ;

my $asciio_event =
	{
	TIME        => $event->time(),
	TYPE        => "$event_type",
	STATE       => '',
	MODIFIERS   => get_key_modifiers($event),
	BUTTON      => -1,
	KEY_NAME    => -1,
	COORDINATES => [-1, -1],
	} ;

$asciio_event->{BUTTON} = $event->button() if ref $event eq 'Gtk3::Gdk::EventButton' ;

if
	(
	$event_type eq "motion-notify"
	|| ref $event eq "Gtk3::Gdk::EventButton" 
	)
	{
	$asciio_event->{COORDINATES} = [$self->closest_character($event->get_coords())]  ;
	
	if($event_type eq "motion-notify")
		{
		$asciio_event->{STATE} = "dragging-button1" if $event->state() >= "button1-mask" ;
		$asciio_event->{STATE} = "dragging-button2" if $event->state() >= "button2-mask" ;
		}
	}

$asciio_event->{KEY_NAME} = Gtk3::Gdk::keyval_name($event->keyval) if $event_type eq 'key-press' ;

return $asciio_event ;
}

#-----------------------------------------------------------------------------

sub create_mouse_scroll_event
{
my ($self, $event) = @_ ;

# windows => GDK_SCROLL_UP GDK_SCROLL_DOWN
# linux   => GDK_SCROLL_SMOOTH

my $asciio_mouse_scroll_event = 
	{
	MODIFIERS => get_key_modifiers($event),
	DIRECTION => 'scroll-' . ($event->direction ne 'smooth'
					? $event->direction
					: ($event->get_scroll_deltas())[1] < 0 ? 'up' : 'down'),
	} ;

return $asciio_mouse_scroll_event ;
}
#-----------------------------------------------------------------------------

sub get_key_modifiers
{
my ($event) = @_ ;

my $key_modifiers = $event->state() ;

my $modifiers = $key_modifiers =~ /control-mask/ ? 'C' : 0 ;
$modifiers   .= $key_modifiers =~ /mod1-mask/    ? 'A' : 0 ;
$modifiers   .= $key_modifiers =~ /shift-mask/   ? 'S' : 0 ;

return("$modifiers-") ;
}

#-----------------------------------------------------------------------------

sub get_character_size
{
my ($self, $font, $size) = @_ ;

$font //= $self->{FONT_FAMILY} ;
$size //= $self->{FONT_SIZE} ;

if(exists $self->{USER_CHARACTER_WIDTH})
	{
	return ($self->{USER_CHARACTER_WIDTH}, $self->{USER_CHARACTER_HEIGHT}) ;
	}
else
	{
	unless (exists $self->{CACHE}{CHARACTER_SIZE}{$font}{$size})
		{
		my $surface = Cairo::ImageSurface->create('argb32', 100, 100);
		my $gc = Cairo::Context->create($surface);
		my $layout = Pango::Cairo::create_layout($gc) ;
		
		my $font_description = Pango::FontDescription->from_string($font . ' ' . $size) ;
		
		$layout->set_font_description($font_description) ;
		$layout->set_text('M') ;
		
		$self->{CACHE}{CHARACTER_SIZE}{$font}{$size} = [$layout->get_pixel_size()] ;
		}
	
	return @{ $self->{CACHE}{CHARACTER_SIZE}{$font}{$size} } ;
	}
}

#-----------------------------------------------------------------------------

sub invalidate_rendering_cache
{
my ($self) = @_ ;

for my $element (@{$self->{ELEMENTS}}) 
	{
	delete $element->{CACHE} ;
	}

delete $self->{CACHE} ;
}

#-----------------------------------------------------------------------------

sub change_cursor
{
my ($self, $cursor_name) = @_ ;

my $display = $self->{widget}->get_display() ;

my $cursor = Gtk3::Gdk::Cursor->new_for_display($display, $cursor_name) ;

$self->{widget}->get_parent_window()->set_cursor($cursor) ;
}

#-----------------------------------------------------------------------------

sub hide_cursor { my ($self) = @_ ; $self->change_cursor('blank-cursor') ; }
sub show_cursor { my ($self) = @_ ; $self->change_cursor('left_ptr') ; }
    
#-----------------------------------------------------------------------------

sub get_viewport_info
{
my ($self, $window_width, $window_height, $h_value, $v_value, $character_width, $character_height) = @_;

my ($min_x, $max_x, $min_y, $max_y) = 
	(
	int ($h_value / $character_width - 2),
	int (($h_value + $window_width) / $character_width + 2),
	int ($v_value / $character_height - 2),
	int (($v_value + $window_height) / $character_height + 2)
	) ;

my (%elements_in_viewport, @elements_in_drawing_order) ;

my $element_index = 0 ;

for my $element (@{$self->{ELEMENTS}})
	{
	$element_index++ ;
	my ($emin_x, $emin_y, $emax_x, $emax_y) = @{ $element->{EXTENTS} } ;
	
	if 
		(
		   $emin_x + $element->{X} <= $max_x
		&& $emax_x + $element->{X} >= $min_x
		&& $emin_y + $element->{Y} <= $max_y
		&& $emax_y + $element->{Y} >= $min_y
		)
		{
		push @elements_in_drawing_order, $element ;
		$elements_in_viewport{$element} = $element_index;
		}
	}

return
	{ 
	min_x           => $min_x,
	max_x           => $max_x,
	min_y           => $min_y,
	max_y           => $max_y,
	elements_indexs => \%elements_in_viewport,
	drawing_order   => \@elements_in_drawing_order,
	} ;
}

#-----------------------------------------------------------------------------

=head1 DEPENDENCIES

gnome libraries, gtk, gtk-perl, perl

=head1 AUTHOR

	Khemir Nadim ibn Hamouda
	CPAN ID: NKH
	mailto:nadim@khemir.net

=head1 LICENSE AND COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=cut

#------------------------------------------------------------------------------------------------------

"GTK world domination!"  ;

