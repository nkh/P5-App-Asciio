
package App::Asciio::GTK::Asciio ;

use base qw(App::Asciio) ;

# $|++ ;

use strict;
use warnings;

use Glib ':constants';
use Gtk3 -init;
use Pango ;

use List::Util qw(min) ;

# nkh: don't think any of these are needed
	# :QQ: If you disable these, the right-click menu of the mouse will not pop up normally.
	#		The strange thing is that no compilation errors or warnings are generated when running,
	#		but the function is not normal.
use App::Asciio::GTK::Asciio::stripes::editable_exec_box;
use App::Asciio::GTK::Asciio::stripes::editable_box2;
use App::Asciio::GTK::Asciio::stripes::rhombus;
use App::Asciio::GTK::Asciio::stripes::ellipse;

use App::Asciio::GTK::Asciio::stripes::editable_arrow2;
use App::Asciio::GTK::Asciio::stripes::wirl_arrow ;
use App::Asciio::GTK::Asciio::stripes::angled_arrow ;
use App::Asciio::GTK::Asciio::stripes::section_wirl_arrow ;

use App::Asciio::GTK::Asciio::Dialogs ;
use App::Asciio::GTK::Asciio::Menues ;
use App::Asciio::GTK::Asciio::DnD ;
use App::Asciio::GTK::Asciio::Selection ;

use App::Asciio::Cross ;
use App::Asciio::String ;
use App::Asciio::Markup ;
use App::Asciio::ZBuffer ;

our $VERSION = '0.02' ;

#-----------------------------------------------------------------------------

=head1 NAME 

=cut

sub new
{
my ($class, $window, $width, $height, $sc_window) = @_ ;

my $self = App::Asciio::new($class) ;
$self->{UI} = 'GUI' ;

bless $self, $class ;

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

sub set_title
{
my ($self, $title) = @_;

$self->SUPER::set_title($title) ;

$self->{widget}->get_toplevel()->set_title($title . ' - asciio') if defined $title ;
}

#-----------------------------------------------------------------------------

sub set_font
{
my ($self, $font_family, $font_size) = @_;

$self->SUPER::set_font($font_family, $font_size) ;
}

#-----------------------------------------------------------------------------

# nkh: this should not be in this file
	# :QQ: I have moved to lib/App/Asciio/Actions/Unsorted.pm
	#      and change the name to toggle_edit_inline
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

sub get_viewport_info
{
my ($self) = @_;

my ($windows_width, $windows_height)     = $self->{ROOT_WINDOW}->get_size() ;
my ($character_width, $character_height) = $self->get_character_size() ;
my ($v_value, $h_value)                  = ($self->{SC_WINDOW}->get_vadjustment()->get_value(), $self->{SC_WINDOW}->get_hadjustment()->get_value()) ;

my ($min_x, $max_x, $min_y, $max_y) = 
	(
	int ($h_value / $character_width - 2),
	int (($h_value + $windows_width) / $character_width + 2),
	int ($v_value / $character_height - 2),
	int (($v_value + $windows_height) / $character_height + 2)
	) ;

my $grid_width  = (int ($windows_width / $character_width) + 2)   * $character_width ;
my $grid_height = (int ($windows_height / $character_height) + 2) * $character_height ;

#       viewport                        grid size                  scroll bar
return ($min_x, $max_x, $min_y, $max_y, $grid_width, $grid_height, $v_value, $h_value)
}

#-----------------------------------------------------------------------------

sub expose_event
{
my ( $widget, $gc, $self ) = @_;

my $t0 = Time::HiRes::time() ;

$gc->set_line_width(1);

my ($character_width, $character_height) = $self->get_character_size() ;
my ($widget_width, $widget_height) = ($widget->get_allocated_width(), $widget->get_allocated_height()) ;

my 
	(
	$viewport_min_x, $viewport_max_x, $viewport_min_y, $viewport_max_y,
	$grid_width, $grid_height,
	$v_value, $h_value
	) = $self->get_viewport_info() ;


# nkh: I explain again why your computing of the grid cache is not right and what I believe should be done
# - changing any of the colors (background , grid and grid_2( which is a bad name I should change)
#     that ALREADY invalidates {CACHE}{GRID}
#
# - grid_width and grid_height change should not invalidate the {CACHE}{GRID}
#     what you need to do is get the screen size and compute the grid for it
#     if you have screen that is 1920 * 1420 then use that size
#     that is the maximum size the grid can ever have (if you don't have two screens and stretch the window over them)
#     cache the grid for the maximum size and use it WHATEVER the size of window
#
# - the two pint above make the calculation of $grid_cache_key unnecessary
# - if the colors don't change, the grid cache will only be computed ONCE for the whole run
#     - not every time the window size changes
#     - not every time the window is scrolled
	# :QQ: I believe you didn’t understand me this time. My current drawing starting point is no longer (0, 0), but the
	#		upper left corner of the current viewport. When the scroll bar is not at the origin, this coordinate is no
	#		longer (0, 0)
	#
	#		This is the following line of code. The drawing of the grid no longer starts from (0, 0).
	#		$gc->set_source_surface($grid_rendering, int($h_value / $character_width) * $character_width, int($v_value / $character_height) * $character_height);
	#
	#		So I don't need to draw the grid of the entire canvas, I just need to draw the grid of the viewport.
	#		So the conditions for cache update become grid width, grid height, grid background color, grid 1 color, grid 2 color, which are determined together, and they form the cache key.
	#
	#		My following line of code is correct.
	#		my $grid_cache_key = $grid_width . '-' . $grid_height . '-' . ($self->get_color('background') // '') . '-' . ($self->get_color('grid') // '') . '-' . ($self->get_color('grid_2') // '') ;
	#
	#		My whole purpose is to draw less, because with a 1920 * 1420 canvas, the current window that the user can see may only be 920 * 480
	#		Drawing less always improves speed a bit, especially within a large canvas.

my $grid_cache_key = $grid_width . '-' . $grid_height . '-' . ($self->get_color('background') // '') . '-' . ($self->get_color('grid') // '') . '-' . ($self->get_color('grid_2') // '') ;

my $grid_rendering = $self->{CACHE}{GRID}{$grid_cache_key} ;

unless (defined $grid_rendering)
	{
	delete $self->{CACHE}{GRID} ;
	my $surface = Cairo::ImageSurface->create('argb32', $grid_width, $grid_height);
	my $gc = Cairo::Context->create($surface);
		
	$gc->set_source_rgb(@{$self->get_color('background')});
	$gc->rectangle(0, 0, $grid_width, $grid_height);
	$gc->fill;
	
	if($self->{DISPLAY_GRID})
		{
		$gc->set_line_width(1);
		
		# nkh: use the screen size here instead for the grid size
		
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
		
	$grid_rendering = $self->{CACHE}{GRID}{$grid_cache_key} = $surface ;
	}

$gc->set_source_surface($grid_rendering, int($h_value / $character_width) * $character_width, int($v_value / $character_height) * $character_height);
$gc->paint;

my $t1 = Time::HiRes::time() ;

# draw elements
my $element_index = 0 ;
$self->{CACHE}{VISIBLE_ELEMENTS} = {
	DRAW_QUEUE  => [],	# Sequential array to ensure drawing order
	LOOKUP		=> {},	# Hash, quickly determine whether an element is visible
	};

my $font_description = Pango::FontDescription->from_string($self->get_font_as_string()) ;

for my $element (@{$self->{ELEMENTS}})
	{
	$element_index++ ;
	my ($min_x, $min_y, $max_x, $max_y) = @{ $element->{EXTENTS} } ;
	
	if 
		(
		   $min_x + $element->{X} <= $viewport_max_x
		&& $max_x + $element->{X} >= $viewport_min_x
		&& $min_y + $element->{Y} <= $viewport_max_y
		&& $max_y + $element->{Y} >= $viewport_min_y
		)
		{
		# :QQ: we must use arrays and not hashes, because the order of drawing elements cannot be messed up.
		#		Otherwise, when we pass $self->{CACHE}{VISIBLE_ELEMENTS} to other subs for processing later, the order will be confused.
		#		We can save the array and hash at the same time, so that the drawing order and filtering can be satisfied.
		#
		$self->draw_element($element, $element_index, $gc, $font_description, $character_width, $character_height) ;
		push @{ $self->{CACHE}{VISIBLE_ELEMENTS}{DRAW_QUEUE} }, $element ;
		$self->{CACHE}{VISIBLE_ELEMENTS}{LOOKUP}{$element}++;
		}
	}

$self->draw_cross_overlays($gc, $self->{CACHE}{VISIBLE_ELEMENTS}{DRAW_QUEUE}, $character_width, $character_height) if $self->{USE_CROSS_MODE} ;
$self->draw_overlay($gc, $widget_width, $widget_height, $character_width, $character_height) ;

# draw ruler lines
if($self->{DISPLAY_RULERS})
	{
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

# draw connections
my (%connected_connections, %connected_connectors) ;

for my $connection (@{$self->{CONNECTIONS}})
	{
	next unless exists $self->{CACHE}{VISIBLE_ELEMENTS}{LOOKUP}{$connection->{CONNECTED}} ;
	
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
			? @{$self->{CACHE}{VISIBLE_ELEMENTS}{DRAW_QUEUE}}
			: grep { $self->is_over_element($_, $self->{MOUSE_X}, $self->{MOUSE_Y}, 1) } @{$self->{CACHE}{VISIBLE_ELEMENTS}{DRAW_QUEUE}}
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

# draw new connections
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

# nkh: since you have added a Selection.pm module
# move the code below  and the call to  drawp_polygon_selection to the module
# add a draw_selection in it and call it here
	# :QQ: Okay, I've moved to lib\App\Asciio\GTK\Asciio\Selection.pm
	#		and named draw_rectangle_selection

$self->draw_rectangle_selection($gc, $character_width, $character_height) ;

$self->draw_polygon_selection($gc, $character_width, $character_height) ;

if ($self->{MOUSE_TOGGLE})
	{
	my $start_x = $self->{MOUSE_X} * $character_width ;
	my $start_y = $self->{MOUSE_Y} * $character_height ;
	
	$gc->set_source_rgb(@{$self->get_color('mouse_rectangle')}) ;
	$gc->rectangle($start_x, $start_y, $character_width, $character_height) ;
	$gc->fill() ;
	$gc->stroke() ;
	}

# draw hint_lines
if($self->{DRAW_HINT_LINES})
	{
	my ($xs, $ys, $xe, $ye) = $self->get_extent_box() ; 
	
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

$self->display_bindings_completion($gc, $character_width, $character_height) ;

my $t2 = Time::HiRes::time() ;
printf STDERR "grid draw time: %0.4f sec. all gui draw time: %0.4f sec.\n", $t1 - $t0, $t2 - $t0 ;

return TRUE;
}

#-----------------------------------------------------------------------------

sub display_bindings_completion
{
my ($self, $gc, $character_width, $character_height) = @_ ;

if ($self->{USE_BINDINGS_COMPLETION} && defined $self->{BINDINGS_COMPLETION})
	{
	$gc->set_source_rgb(@{$self->get_color('hint_background')}) ;
	
	my ($font_character_width, $font_character_height) = $self->get_character_size($self->{FONT_FAMILY}, $self->{FONT_BINDINGS_SIZE}) ;
	
	my ($width, $height) = ($self->{BINDINGS_COMPLETION_LENGTH} * $font_character_width, $font_character_height * $self->{BINDINGS_COMPLETION}->@*) ;
	$width += $font_character_width / 2 ;
	
	my ($window_width, $window_height) = $self->{ROOT_WINDOW}->get_size() ;
	my ($scroll_bar_x, $scroll_bar_y)  = ($self->{SC_WINDOW}->get_hadjustment()->get_value(), $self->{SC_WINDOW}->get_vadjustment()->get_value()) ;
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
	
	$gc->stroke() ;
	}
}

#-----------------------------------------------------------------------------

sub draw_cross_overlays
{
my ($self, $gc, $visible_elements, $character_width, $character_height) = @_ ;

my $zbuffer = App::Asciio::ZBuffer->new(1, @{$visible_elements}) ;

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
	
	$gc->set_source_surface($self->{CACHE}{CROSS_OVERLAY}{$cache_key}, $x * $character_width, $y * $character_height);
	$gc->paint;
	}
}

#-----------------------------------------------------------------------------

sub draw_overlay
{
my ($self, $gc, $widget_width, $widget_height, $character_width, $character_height) = @_ ;

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
		$self->draw_element($_, $element_index, $gc, $font_description, $character_width, $character_height) ;
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
	my ($xs, $ys, $xe, $ye) = $self->get_extent_box(@overlay_elements) ; 
	
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

# ------------------------------------------------------------------------------

sub draw_element
{
my ($self, $element, $element_index, $gc, $font_description, $character_width, $character_height) = @_ ;

my $is_selected = $element->{SELECTED} // 0 ;
$is_selected = 1 if $is_selected > 0 ;

my ($background_color, $foreground_color) =  $element->get_colors() ;

if($is_selected)
	{
	if(exists $element->{GROUP} and defined $element->{GROUP}[-1])
		{
		$background_color = $element->{GROUP}[-1]{GROUP_COLOR}[0]
		}
	else
		{
		$background_color = $self->get_color('selected_element_background');
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

#-----------------------------------------------------------------------------

sub button_release_event { my (undef, $event, $self) = @_ ; $self->SUPER::button_release_event($self->create_asciio_event($event)) ; }
sub button_press_event   { my (undef, $event, $self) = @_ ; $self->SUPER::button_press_event($self->create_asciio_event($event)) ; }

sub motion_notify_event  {

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

sub key_press_event      { my (undef, $event, $self) = @_ ; $self->SUPER::key_press_event($self->create_asciio_event($event)) ; }
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

#-----------------------------------------------------------------------------

sub show_cursor { my ($self) = @_ ; $self->change_cursor('left_ptr') ; }
    
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

