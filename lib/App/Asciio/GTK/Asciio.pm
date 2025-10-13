
package App::Asciio::GTK::Asciio ;

use base qw(App::Asciio) ;

$|++ ;

use strict;
use warnings;

use Glib ':constants';
use Gtk3 -init;
use Pango ;
use utf8 ;

use List::Util qw(min max) ;
use File::Basename ;
use Module::Util qw(find_installed) ;
use Clone ;

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
use App::Asciio::GTK::Asciio::Find ;

use App::Asciio::Cross ;
use App::Asciio::String ;
use App::Asciio::Markup ;
use App::Asciio::ZBuffer ;

our $VERSION = '0.01' ;

#-----------------------------------------------------------------------------

=head1 NAME 

=cut

sub new
{
my ($class, $window, $width, $height, $notebook, $old_self, $asciio_argv) = @_ ;

my $self = App::Asciio::new($class) ;
$self->{UI} = 'GUI' ;

bless $self, $class ;

$self->{SCROLL_BAR_POSITION} = [0, 0] ;
$self->{asciio_argv} = Clone::clone($asciio_argv) ;

my $label_num ;
if(defined $old_self)
	{
	$label_num = $old_self->get_new_tab_num() ;
	}
else
	{
	$label_num = $self->get_new_tab_num() ;
	}

my $label = Gtk3::Label->new($label_num);
$label->set_can_focus(FALSE);

my $scwin = Gtk3::ScrolledWindow->new();
$scwin->set_policy('always', 'always');

my $drawing_area = Gtk3::DrawingArea->new;
$drawing_area->set_can_focus(1) ;


$self->connect_event('key_press_event',      'key_press_event',      \&key_press_event,                 $drawing_area) ;
$self->connect_event('motion_notify_event',  'motion_notify_event',  \&motion_notify_event,             $drawing_area) ;
$self->connect_event('button_press_event',   'button_press_event',   \&button_press_event,              $drawing_area) ;
$self->connect_event('button_release_event', 'button_release_event', \&button_release_event,            $drawing_area) ;
$self->connect_event('configure_event',      'configure_event',      sub { $self->update_display() ; }, $drawing_area) ;
$self->connect_event('h_value_changed',      'value_changed',        sub { $self->update_display() ; }, $scwin->get_hadjustment()) ;
$self->connect_event('v_value_changed',      'value_changed',        sub { $self->update_display() ; }, $scwin->get_vadjustment()) ;
$self->connect_event('delete_event',         'delete_event',         \&delete_event,                    $window) ;


$scwin->add_events(['GDK_SCROLL_MASK']) ;

$self->connect_event('scroll_event', 'scroll_event', \&mouse_scroll_event, $scwin) ;

$self->{widget}      = $drawing_area ;
$self->{root_window} = $window ;
$self->{sc_window}   = $scwin ;
$self->{notebook}    = $notebook ;
$self->{label}       = $label ;

$self->connect_event('draw', 'draw', \&expose_event, $drawing_area) ;

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


$self->{TAB_LABEL_NAME} = $label_num ;
$self->{TAB_LABEL_NUM} = $label_num ;

$scwin->add_with_viewport($drawing_area);
$notebook->append_page($scwin, $label);
$notebook->set_show_tabs(TRUE) ;

my ($command_line_switch_parse_ok, $command_line_parse_message, $asciio_config)
	= $self->ParseSwitches([@{$self->{asciio_argv}}], 0) ;

die "Error: '$command_line_parse_message'!" unless $command_line_switch_parse_ok ;

my %object_override ; 
if(defined $asciio_config->{DEBUG_FD})
	{
	open my $fh, ">&=", $asciio_config->{DEBUG_FD} or die "can't open fd $asciio_config->{DEBUG_FD}: $!\n" ; 
	$fh->autoflush(1) ;
	%object_override = (WARN => sub { print $fh "@_" }, ACTION_VERBOSE => sub { print $fh "$_[0]\n" ; } ) ;
	}
else
	{
	%object_override = (WARN => sub { print STDERR "@_" }, ACTION_VERBOSE => sub { print STDERR "$_[0]\n" ; } ) ;
	}

my $setup_paths = [] ;

if(@{$asciio_config->{SETUP_PATHS}})
	{
	$setup_paths = $asciio_config->{SETUP_PATHS} ;
	}
else
	{
	my ($basename, $path, $ext) = File::Basename::fileparse(find_installed('App::Asciio'), ('\..*')) ;
	my $setup_path = $path . $basename . '/setup/' ;
	
	$setup_paths = 
		[
		$setup_path . 'setup.ini', 
		$setup_path . 'GTK/setup.ini', 
		$ENV{HOME} . '/.config/Asciio/Asciio.ini',
		] ;
	}

$self->setup($setup_paths, \%object_override) ;

my ($character_width, $character_height) = $self->get_character_size() ;

$self->{widget}->set_size_request($self->{CANVAS_WIDTH} * $character_width, $self->{CANVAS_HEIGHT} * $character_height);
$self->set_modified_state(0) ;

$self->setup_dnd($window) ;

push @{$self->{asciios}}, $self ;

$self->connect_event('switch-page',    'switch-page',    \&page_switch_event, $notebook) ;
$self->connect_event('focus_in_event', 'focus_in_event', \&focus_in_event,    $drawing_area) ;

return($self) ;
}

#-----------------------------------------------------------------------------

sub connect_event 
	{
	my ($self, $event_name, $gtk_event_name, $handler, $widget) = @_;
	$self->{event_handlers}{$event_name} =
		{
		handler_id => $widget->signal_connect($gtk_event_name => $handler, $self),
		handler_widget => $widget
		} ;
	}

#-----------------------------------------------------------------------------

sub DESTROY
{
my ($self) = @_;
# print "asciio($self) object is being destroyed.\n" ;
}

#-----------------------------------------------------------------------------

sub delete_event
{
my ($window, $event, $self) = @_;

my $answer = 'yes';

my $should_save ;

my $current_page_num = $self->{notebook}->get_current_page() ;

return if($self->{TAB_LABEL_NUM} != $current_page_num) ;

for my $asciio (@{$self->{asciios}})
	{
	$should_save++ if $asciio->get_modified_state() ;
	}

if($should_save) 
	{
	$answer = $self->display_quit_dialog('asciio', ' ' x 25 . "Document is modified!\n\nAre you sure you want to quit and lose your changes?\n") ;
	}

if($answer eq 'save_and_quit')
	{
	my @saved_result = $self->run_actions_by_name('Save') ;
	$answer = 'cancel' if(! defined $saved_result[0][0] || $saved_result[0][0] eq '') ;
	}

return $answer eq 'cancel';
}

#-----------------------------------------------------------------------------

sub get_new_tab_num
{
my ($self) = @_ ;

return (defined $self->{asciios}) ? @{$self->{asciios}} : 0 ;
}

#-----------------------------------------------------------------------------

sub add_tab
{
my ($self) = @_ ;

# get the current active tab index
my $current_page = $self->{notebook}->get_current_page();


my $new_asciio = new App::Asciio::GTK::Asciio($self->{root_window}, 50, 25, $self->{notebook}, $self, $self->{asciio_argv}) ;

# move the new tab to after the current active tab
$new_asciio->{notebook}->reorder_child($new_asciio->{notebook}->get_nth_page(-1), $current_page + 1);
splice(@{$self->{asciios}}, $current_page + 1, 0, $new_asciio) ;
$self->update_all_asciios_ref() ;

$new_asciio->set_modified_state(1) ;

$new_asciio->set_title($self->{TITLE}) ;

# make the new tab the active tab
$new_asciio->{notebook}->set_current_page($current_page + 1) ;

$new_asciio->{root_window}->show_all() ;

$new_asciio->update_display() ;

return $new_asciio ;
}

#-----------------------------------------------------------------------------

sub copy_tab
{
my ($self) = @_ ;

my $serialized_self = $self->serialize_self() ;

my $new_asciio = $self->add_tab() ;

$new_asciio->load_self(get_sereal_decoder()->decode($serialized_self)) ;

$new_asciio->set_modified_state(1) ;

$new_asciio->update_display() ;
}


#-----------------------------------------------------------------------------

sub update_all_asciios_ref
{
my ($self) = @_ ;

my $label_cnt = 0 ;

for my $asciio (@{$self->{asciios}})
	{
	@{$asciio->{asciios}} = @{$self->{asciios}} ;
	$asciio->{TAB_LABEL_NUM} = $label_cnt++ ;
	}

$self->disable_all_switch_focus_event() ;
$self->enable_all_switch_focus_event();
}

#-----------------------------------------------------------------------------

sub disable_all_switch_focus_event
{
my ($self) = @_ ;

for my $asciio (@{$self->{asciios}})
	{
	$asciio->{notebook}->signal_handler_disconnect($asciio->{event_handlers}{"switch-page"}{handler_id}) ;
	$asciio->{widget}->signal_handler_disconnect($asciio->{event_handlers}{"focus_in_event"}{handler_id}) ;
	}
}

#-----------------------------------------------------------------------------

sub enable_all_switch_focus_event
{
my ($self) = @_ ;

for my $asciio (@{$self->{asciios}})
	{
	$asciio->connect_event('switch-page', 'switch-page', \&page_switch_event, $asciio->{notebook}) ;
	$asciio->connect_event('focus_in_event', 'focus_in_event', \&focus_in_event, $asciio->{widget}) ;
	}
}

#-----------------------------------------------------------------------------

sub disconnect_all_events
{
my ($self) = @_ ;

foreach my $event_key (keys %{$self->{event_handlers}})
	{
	my $event = $self->{event_handlers}{$event_key};
	$event->{handler_widget}->signal_handler_disconnect($event->{handler_id}) ;
	}
}

#-----------------------------------------------------------------------------

sub delete_tab
{
my ($self, $is_delete_without_warning) = @_ ;

# if there is only one tab left and deletion is not allowed
my $total_pages = $self->{notebook}->get_n_pages();

return if($total_pages == 1) ;

unless($is_delete_without_warning)
    {
    my $user_answer = $self->display_yes_no_cancel_dialog('asciio', 'The deletion operation will lose all data on the current tab page. Are you sure you want to continue?') ;
    return if($user_answer ne 'yes') ;
    }

my $page_num = $self->{notebook}->get_current_page();

$self->disconnect_all_events() ;

my $next_asciio = $self->switch_tab(1) ;

@{$self->{asciios}} = () ;

my $current_page = $next_asciio->{notebook}->get_nth_page($page_num) ;
$next_asciio->{notebook}->remove_page($page_num) ;

$current_page->destroy() ;

splice(@{$next_asciio->{asciios}}, $page_num, 1) ;

$next_asciio->update_all_asciios_ref() ;

$next_asciio->set_modified_state(1) ;

$next_asciio->{root_window}->show_all() ;

return $next_asciio ;
}

#-----------------------------------------------------------------------------

sub change_current_tab_lable_name
{
my ($self, $tab_name) = @_ ;

my $current_page_index = $self->{notebook}->get_current_page();
my $current_page = $self->{notebook}->get_nth_page($current_page_index);

my $new_tab_lable_name = (defined $tab_name) ? $tab_name : $self->display_edit_dialog("input a new name", '', $self, undef, undef, undef, undef, 300, 100);

if($new_tab_lable_name ne '')
	{
	$self->{label}->set_text($new_tab_lable_name) ;
	$self->{TAB_LABEL_NAME} = $new_tab_lable_name ;
	}
}

#-----------------------------------------------------------------------------

sub get_tab_label_height
{
my ($self) = @_ ;
my $height = 0 ;
if ($self->{notebook}->get_show_tabs())
	{
	my $page_num = $self->{notebook}->get_current_page();
	my $tab_label = $self->{notebook}->get_tab_label($self->{notebook}->get_nth_page($page_num));
	my $allocation = $tab_label->get_allocation();
	$height = $allocation->{height} + $allocation->{y} ;
	}
return $height ;
}

#-----------------------------------------------------------------------------

sub show_all_tabs
{
my ($self) = @_ ;

$self->{notebook}->set_show_tabs(TRUE) ;
$self->set_label_focus(FALSE) ;
}

#-----------------------------------------------------------------------------

sub hide_all_tabs
{
my ($self) = @_ ;

$self->{notebook}->set_show_tabs(FALSE) ;
$self->set_label_focus(FALSE) ;
}

#-----------------------------------------------------------------------------

sub set_label_focus
{
my ($self, $is_focus) = @_ ;

$self->{notebook}->set_can_focus(FALSE) ;
$self->{notebook}->set_scrollable(TRUE) ;

for my $asciio (@{$self->{asciios}})
	{
	my $current_page_index = $asciio->{notebook}->get_current_page();
	my $current_page = $asciio->{notebook}->get_nth_page($current_page_index);
	my $label = $asciio->{notebook}->get_tab_label($current_page);

	$label->set_can_focus($is_focus);
	$asciio->{widget}->set_can_focus(TRUE);
	}
}

#-----------------------------------------------------------------------------

sub switch_specific_tab
{
my ($self, $tab_label_num) = @_ ;

my $total_pages = $self->{notebook}->get_n_pages();
my $page_num = $self->{notebook}->get_current_page();

$self->{notebook}->set_current_page($tab_label_num) ;
return $self->{asciios}[$tab_label_num] ;
}

#-----------------------------------------------------------------------------

sub switch_tab
{
my ($self, $step) = @_ ;

my $total_pages = $self->{notebook}->get_n_pages();
my $page_num = $self->{notebook}->get_current_page();

$self->{notebook}->set_current_page(($page_num + $step) % $total_pages) ;
return $self->{asciios}[($page_num + $step) % $total_pages] ;
}

#-----------------------------------------------------------------------------

sub move_tab_page_forward
{
my ($self) = @_ ;
}

#-----------------------------------------------------------------------------

sub move_tab_page_back
{
my ($self) = @_ ;
}


#-----------------------------------------------------------------------------

sub destroy
{
my ($self) = @_;

$self->{root_window}->destroy() ;
}

#-----------------------------------------------------------------------------

sub set_modified_state
{
my ($self, $state) = @_ ;
$self->SUPER::set_modified_state($state) ; 

$self->set_title($self->{TITLE}) ;
}

#-----------------------------------------------------------------------------

sub set_title
{
my ($self, $title) = @_;

$self->SUPER::set_title($title) ;

if(defined $title)
	{
	$self->{root_window}->set_title($self->{MODIFIED} 
												? '* ' . $title . ' - asciio' 
												: $title . ' - asciio') ;
	}
}

#-----------------------------------------------------------------------------

sub set_font
{
my ($self, $font_family, $font_size) = @_;

$self->SUPER::set_font($font_family, $font_size) ;
}

#-----------------------------------------------------------------------------

sub switch_gtk_popup_box_type
{
my ($self) = @_ ;
$self->{EDIT_TEXT_INLINE} ^= 1 ;
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
my ( $widget, $gc, $self ) = @_;

$gc->set_line_width(1);


my ($character_width, $character_height) = $self->get_character_size() ;
my ($widget_width, $widget_height) = ($widget->get_allocated_width(), $widget->get_allocated_height()) ;

# my $zbuffer = App::Asciio::ZBuffer->new(1, $self->{ELEMENTS}->@*) ;

# while( my($coordinate, $elements) = each $zbuffer->{intersecting_elements}->%*) 
# 	{ 
# 	use App::Asciio::ZBuffer ;
# 	use Data::TreeDumper ; 

# 	my $neighbors = $zbuffer->get_neighbors_stack($coordinate) ; 
# 	print STDERR DumpTree { stack => $elements, neighbors => $neighbors }, $coordinate ; 
# 	} 

my ($windows_width, $windows_height) = $self->{root_window}->get_size() ;
my ($v_value, $h_value) = ($self->{sc_window}->get_vadjustment()->get_value(), $self->{sc_window}->get_hadjustment()->get_value()) ;
my ($start_x, $end_x, $start_y, $end_y) = 
	(
	int($h_value / $character_width - 2),
	int(($h_value + $windows_width) / $character_width + 2),
	int($v_value / $character_height - 2),
	int(($v_value + $windows_height) / $character_height + 2)
	) ;

my $grid_background_color = $self->get_color('background') ;
my $grid_color = $self->get_color('grid') ;
my $grid2_color = $self->get_color('grid_2') ;

my $grid_width = (int($windows_width / $character_width) + 2) * $character_width ;
my $grid_height = (int($windows_height / $character_height) + 2) * $character_height ;
my $grid_cache_key = $grid_width . '-' . $grid_height . ($grid_background_color // undef) . '-' . ($grid_color // undef) . '-' . ($grid2_color // undef) ;
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

# draw elements
my $element_index = 0 ;
$self->{seen_elements} = undef ;

my %seen_elements_hash ;

my $font_description = Pango::FontDescription->from_string($self->get_font_as_string()) ;

for my $element (@{$self->{ELEMENTS}})
	{
	$element_index++ ;
	unless(exists $element->{CACHE}{ZBUFFER}{COORDINATES_BOUNDARIES})
		{
		my @coordinates = map {[split ';']} keys %{App::Asciio::ZBuffer->new(0, $element)->{coordinates}} ;
		
		my @x = map {$_->[1]} @coordinates;
		my @y = map {$_->[0]} @coordinates;
		
		$element->{CACHE}{ZBUFFER}{COORDINATES_BOUNDARIES} = [min(@x), max(@x), min(@y), max(@y)] ;
		}
	
	unless(($element->{CACHE}{ZBUFFER}{COORDINATES_BOUNDARIES}->[0] > $end_x)
		|| ($element->{CACHE}{ZBUFFER}{COORDINATES_BOUNDARIES}->[1] < $start_x)
		|| ($element->{CACHE}{ZBUFFER}{COORDINATES_BOUNDARIES}->[2] > $end_y)
		|| ($element->{CACHE}{ZBUFFER}{COORDINATES_BOUNDARIES}->[3] < $start_y))
		{
		$element->gui_draw($self, $element_index, $gc, $font_description, $character_width, $character_height) ;
		push @{$self->{seen_elements}}, $element ;
		}
	}

@seen_elements_hash{@{$self->{seen_elements}}} = () if (defined $self->{seen_elements}) ;

$self->draw_cross_overlays($gc, $self->{seen_elements}, $character_width, $character_height) if $self->{USE_CROSS_MODE} ;
$self->draw_overlay($gc, $widget_width, $widget_height, $character_width, $character_height) ;
$self->draw_find_keywords_highlight($gc, $character_width, $character_height) ;

# draw ruler lines
for my $line (@{$self->{RULER_LINES}})
	{
	$gc->set_source_rgb(@{$self->get_color('ruler_line')});
	
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
	}
$gc->stroke() ;

# draw connections
my (%connected_connections, %connected_connectors) ;

for my $connection (@{$self->{CONNECTIONS}})
	{
	my $draw_connection ;
	my $connector  ;
	next unless(exists $seen_elements_hash{$connection->{CONNECTED}}) ;
	
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
			? @{$self->{seen_elements}}
			: grep {$self->is_over_element($_, $self->{MOUSE_X}, $self->{MOUSE_Y}, 1)} @{$self->{seen_elements}}
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
	
# draw selection rectangle
if(defined $self->{SELECTION_RECTANGLE}{END_X})
	{
	my $start_x = $self->{SELECTION_RECTANGLE}{START_X} * $character_width ;
	my $start_y = $self->{SELECTION_RECTANGLE}{START_Y} * $character_height ;
	my $width = ($self->{SELECTION_RECTANGLE}{END_X} - $self->{SELECTION_RECTANGLE}{START_X}) * $character_width ;
	my $height = ($self->{SELECTION_RECTANGLE}{END_Y} - $self->{SELECTION_RECTANGLE}{START_Y}) * $character_height; 
	
	if($width < 0)
		{
		$width *= -1 ;
		$start_x -= $width ;
		}
		
	if($height < 0)
		{
		$height *= -1 ;
		$start_y -= $height ;
		}
		
	$gc->set_source_rgb(@{$self->get_color('selection_rectangle')}) ;
	$gc->rectangle($start_x, $start_y, $width, $height) ;
	$gc->stroke() ;
	
	delete $self->{SELECTION_RECTANGLE}{END_X} ;
	}

$self->draw_polygon_selection($gc, $character_width, $character_height) ;

if ($self->{MOUSE_TOGGLE})
	{
	my $emulation_mouse_type = $self->{SIMULATE_MOUSE_TYPE} // 'rectangle' ;

	my $start_x = $self->{MOUSE_X} * $character_width ;
	my $start_y = $self->{MOUSE_Y} * $character_height ;
	
	$gc->set_source_rgba(@{$self->get_color('mouse_rectangle')});

	if($emulation_mouse_type eq 'rectangle')
		{
		$gc->rectangle($start_x, $start_y, $character_width, $character_height) ;
		$gc->fill() ;
		$gc->stroke() ;
		}
	elsif($emulation_mouse_type eq 'right_triangle')
		{
		$gc->move_to($start_x, $start_y);
		$gc->line_to($start_x + $character_width, $start_y + $character_height / 2);
		$gc->line_to($start_x, $start_y + $character_height);
		$gc->close_path();
		$gc->fill() ;
		$gc->stroke() ;
		}
	elsif($emulation_mouse_type eq 'down_triangle')
		{
		$gc->move_to($start_x + $character_width / 2, $start_y + $character_height);
		$gc->line_to($start_x, $start_y);
		$gc->line_to($start_x + $character_width, $start_y);
		$gc->close_path();
		$gc->fill() ;
		$gc->stroke() ;
		}
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

App::Asciio::Actions::Pen::pen_show_mapping_help($self, $gc, $character_width, $character_height) ;

$self->set_modified_state($self->{MODIFIED}) ;

return TRUE;
}

#-----------------------------------------------------------------------------

sub display_bindings_completion
{
my ($self, $gc, $character_width, $character_height) = @_ ;

if ($self->{USE_BINDINGS_COMPLETION} && defined $self->{BINDINGS_COMPLETION})
	{
	my ($font_character_width, $font_character_height) = (9, 21) ;
	
	$gc->set_source_rgb(@{$self->get_color('hint_background')}) ;
	
	my ($width, $height) = ($self->{BINDINGS_COMPLETION_LENGTH} * $font_character_width, $font_character_height * $self->{BINDINGS_COMPLETION}->@*) ;
	
	my ($window_width, $window_height) = $self->{root_window}->get_size() ;
	my ($scroll_bar_x, $scroll_bar_y)  = ($self->{sc_window}->get_hadjustment()->get_value(), $self->{sc_window}->get_vadjustment()->get_value()) ;
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
	my $font_description = Pango::FontDescription->from_string("$self->{FONT_FAMILY} 11") ;
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
my ($self, $gc, $seen_elements, $character_width, $character_height) = @_ ;

my $zbuffer = App::Asciio::ZBuffer->new(1, @{$seen_elements}) ;

my ($default_background_color, $default_foreground_color) = (
	$self->get_color('element_background'), $self->get_color('element_foreground')) ;

for (App::Asciio::Cross::get_cross_mode_overlays($zbuffer, $self->{USE_CROSS_MODE}))
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
		$_->gui_draw($self, $element_index, $gc, $font_description, $character_width, $character_height) ;
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
		
		$color_set .= $strip_background_color . $strip_foreground_color ;
		
		for my $line (split /\n/, $strip->{TEXT})
			{
			$line = "$line-$element" if $self->{NUMBERED_OBJECTS} ; # don't share rendering with other objects
			
			unless (exists $self->{CACHE}{STRIPS}{$color_set}{$line})
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
				
				$self->{CACHE}{STRIPS}{$color_set}{$line} = $surface ; # keep reference
				}
			
			my $strip_rendering = $self->{CACHE}{STRIPS}{$color_set}{$line} ;
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
sub mouse_scroll_event   
{ 
my (undef, $event, $self) = @_ ; $self->SUPER::mouse_scroll_event($self->create_mouse_scroll_event($event)) ; 

}

#-----------------------------------------------------------------------------
sub update_focus_in_event
{
my ($self, $is_need_focus_in) = @_ ;

for my $asciio (@{$self->{asciios}})
	{
	$asciio->{is_need_focus_in} = $is_need_focus_in;
	}
}

#-----------------------------------------------------------------------------
sub page_switch_event
{
my ($notebook, $page, $page_num, $self) = @_ ;

$self->update_focus_in_event(1) ;

if(defined $self->{CURRENT_ACTIONS}{ESCAPE_KEYS} && $self->{CURRENT_ACTIONS}{ESCAPE_KEYS}->@*)
	{
	# Exit key group
	# :TODO: These functions calls shouldn't be here and are hardcoded here
	$self->run_actions_by_name('find escape') ;
	$self->run_actions_by_name('Selection escape') ;
	$self->run_actions_by_name('Polygon selection escape') ;
	$self->run_actions_by_name('Eraser escape') ;
	$self->run_actions_by_name('clone escape') ;
	$self->run_actions_by_name('pen escape') ;
	$self->{ACTION_VERBOSE}->("\e[33m[$self->{CURRENT_ACTIONS}{NAME}] leaving\e[m") if $self->{ACTION_VERBOSE} ; 
	$self->{CURRENT_ACTIONS} = $self->{ACTIONS} ;
	}

# only set the scroll bar when the current page and the page to be switched are the same, or only record
if($self->{TAB_LABEL_NUM} == $page_num)
	{
	my $scwin = $page->get_child() ;
	my $widget = $scwin->get_child() ;
	my $root_window = $notebook->get_toplevel() ;

	# here must first get the scroll bar position, and then grab_focus
	$self->{SCROLL_BAR_POSITION} = [$self->{sc_window}->get_hadjustment()->get_value(), $self->{sc_window}->get_vadjustment()->get_value()] ;

	$widget->grab_focus() ;
	$root_window->show_all() ;
	}
}

#-----------------------------------------------------------------------------
sub focus_in_event
{
my ($widget, $event, $self) = @_ ;

if($self->{is_need_focus_in})
	{
	my $scwin = $widget->get_parent() ;
	my $position = delete $self->{FIRST_SCROLL_BAR_POSITION} // $self->{SCROLL_BAR_POSITION} ;
	
	$scwin->get_hadjustment()->set_value($position->[0]);
	$scwin->get_vadjustment()->set_value($position->[1]);
	$self->update_focus_in_event(0) ;
	}
}

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
		$asciio_event->{STATE} = "dragging-button3" if $event->state() >= "button3-mask" ;
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
my ($self) = @_ ;
	
if(exists $self->{USER_CHARACTER_WIDTH})
	{
	return ($self->{USER_CHARACTER_WIDTH}, $self->{USER_CHARACTER_HEIGHT}) ;
	}
else
	{
	unless (exists $self->{CACHE}{CHARACTER_SIZE})
		{
		my $surface = Cairo::ImageSurface->create('argb32', 100, 100);
		my $gc = Cairo::Context->create($surface);
		my $layout = Pango::Cairo::create_layout($gc) ;
		
		my $font_description = Pango::FontDescription->from_string($self->{FONT_FAMILY} . ' ' . $self->{FONT_SIZE}) ;
		$layout->set_font_description($font_description) ;
		$layout->set_text('M') ;
		
		$self->{CACHE}{CHARACTER_SIZE} = [$layout->get_pixel_size()] ;
		}
	
	return @{ $self->{CACHE}{CHARACTER_SIZE} } ;
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

{

my %custom_sursor_cache ;

sub change_custom_cursor
{
my ($self, $cursor_name) = @_ ;

unless(exists $custom_sursor_cache{$cursor_name})
	{
	my $display = $self->{widget}->get_display() ;
	my $pixbuf ;

	eval
		{
		$pixbuf = Gtk3::Gdk::Pixbuf->new_from_file($self->{CUSTOM_MOUSE_CURSORS}->{$cursor_name});
		};
	if ($@)
		{
		print STDERR "can not set custom cursor with $cursor_name :$@\n" ;
		return ;
		}
	$custom_sursor_cache{$cursor_name} = Gtk3::Gdk::Cursor->new_from_pixbuf($display, $pixbuf, 0, 0);
	}
$self->{widget}->get_parent_window()->set_cursor($custom_sursor_cache{$cursor_name}) ;
}
}

#-----------------------------------------------------------------------------

sub hide_cursor { my ($self) = @_ ; $self->change_cursor('blank-cursor') ; }

#-----------------------------------------------------------------------------

sub show_cursor { my ($self) = @_ ; $self->change_cursor('left_ptr') ; }
    
#-----------------------------------------------------------------------------
sub load_all_self
{
my ($self, $new_self) = @_ ;

my @asciios = (ref($new_self) eq 'ARRAY') ? @{$new_self} : ($new_self);

# Start operation from TAB 0
$self = $self->switch_specific_tab(0) ;
my $new_asciio = $self->switch_tab(1) ;
for my $index (0 .. scalar @{$self->{asciios}} - 2)
	{
	$new_asciio = $new_asciio->delete_tab(1) ;
	}

# The first TAB must be displayed here, and the order of the last tab pages is correct.
$self->{root_window}->show_all() ;

my $decoder = get_sereal_decoder() ;

$new_asciio = $self ;

my $is_not_first_self = 0 ;

for my $asciio (@asciios)
	{
	if($is_not_first_self++)
		{
		$new_asciio = $new_asciio->add_tab() ;
		}

	my $deserialization_self = (ref($new_self) eq 'ARRAY') ? $decoder->decode($asciio) : $asciio ;
	$new_asciio->load_self($deserialization_self);

	# when a tab is added, the focus_in event of the current tab page 
	# cannot be triggered in time because the event processing function is just mounted.
	# The coordinates saved for the first time in page_switch_event are incorrect.
	$new_asciio->{FIRST_SCROLL_BAR_POSITION} //= [$new_asciio->{SCROLL_BAR_POSITION}->[0] // 0, $new_asciio->{SCROLL_BAR_POSITION}->[1] // 0] ;		

	$new_asciio->change_current_tab_lable_name($deserialization_self->{TAB_LABEL_NAME} // '0') ;

	$new_asciio->invalidate_rendering_cache();
	}

return $new_asciio->switch_tab(1) ;
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

