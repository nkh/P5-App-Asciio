
package App::Asciio::GTK::Asciio::TabbedAsciio ;

use Gtk3 -init;
use Glib::Object::Introspection;

use Glib qw(TRUE FALSE);
use Pango ;

use parent qw/ App::Asciio::GTK::Asciio / ;
use Data::TreeDumper ;

use Glib::Object::Subclass Gtk3::DrawingArea::,
	signals =>
		{
		copy_tab             => { param_types => ['Glib::Scalar'], return_type => undef },
		delete_tab           => { param_types => [], return_type => undef },
		focus_tab            => { param_types => ['Glib::Int'], return_type => undef },
		show_help_tab        => { param_types => [], return_type => undef },
		last_tab             => { param_types => [], return_type => undef },
		move_tab_left        => { param_types => [], return_type => undef },
		move_tab_right       => { param_types => [], return_type => undef },
		new_tab              => { param_types => ['Glib::Scalar'], return_type => undef },
		next_tab             => { param_types => [], return_type => undef },
		previous_tab         => { param_types => [], return_type => undef },
		quit                 => { param_types => [], return_type => undef },
		toggle_tab_labels    => { param_types => [], return_type => undef },
		toggle_toolbar       => { param_types => [], return_type => undef },
		# send_to_asciio       => { param_types => ['Glib::Int', 'Glib::String', 'Glib::Scalar'], return_type => undef },
		# asciio_message       => { param_types => ['Glib::Scalar'], return_type => undef },
		# get_storage_keys     => { param_types => [], return_type => undef },
		# get_storage_value    => { param_types => ['Glib::String'], return_type => undef },
		# set_storage_value    => { param_types => ['Glib::String', 'Glib::Scalar'], return_type => undef },
		# get_all_asciios      => { param_types => [], return_type => undef },
		# storage_keys_result  => { param_types => ['Glib::Scalar'], return_type => undef },
		# storage_value_result => { param_types => ['Glib::Scalar'], return_type => undef },
		# all_asciios_result   => { param_types => ['Glib::Scalar'], return_type => undef },
		# rename               => { param_types => ['Glib::String'], return_type => undef },
		} ;

# ----------------------------------------------------------------------------

sub INIT_INSTANCE
{
my ($self) = @_ ;

$self->set_events
  	([qw/
  	exposure-mask
  	leave-notify-mask
  	button-press-mask
  	button-release-mask
  	pointer-motion-mask
  	key-press-mask
  	key-release-mask
  	/]);

$self->set_can_focus(TRUE) ;

$self->{tab_signals} = 
	{
	map { $_ => 1 } qw/
			copy_tab
			delete_tab
			focus_tab
			show_help_tab
			last_tab
			move_tab_left
			move_tab_right
			new_tab
			next_tab
			previous_tab
			quit
			toggle_tab_labels
			toggle_toolbar
			/
	} ;

$self->signal_connect
	(
	draw => sub
		{
		my ($widget, $cr) = @_ ;
		$self->on_draw($widget, $cr) ;
		return FALSE ;
		}
	) ;

$self->signal_connect(motion_notify_event => sub { my ($widget, $event) = @_ ; App::Asciio::GTK::Asciio::motion_notify_event(undef, $event, $self) ; return TRUE ; } ) ;

$self->signal_connect
	(
	'button-press-event' => sub
		{
		my ($widget, $event) = @_ ;
		$widget->grab_focus() ;
		App::Asciio::GTK::Asciio::button_press_event(undef, $event, $self) ;
		return TRUE ;
		}
	) ;

$self->signal_connect(button_release_event => sub { my ($widget, $event) = @_ ; App::Asciio::GTK::Asciio::button_release_event(undef, $event, $self) ; return TRUE ; } ) ;

$self->signal_connect
	(
	'key-press-event' => sub
		{
		my ($widget, $event) = @_ ;
		
		App::Asciio::GTK::Asciio::key_press_event(undef, $event, $self) ;
		
		return TRUE ;
		}
	) ;
}


# ----------------------------------------------------------------------------

sub new
{
my ($class, $base, $asciio_data) = @_ ;

my $self = $class->SUPER::new() ;

use Module::Util qw(find_installed) ;
use File::Basename ;

my $asciio = App::Asciio::new($class) ;
$asciio->{UI} = 'GUI' ;
$asciio->{widget} = $self ;

my ($command_line_switch_parse_ok, $command_line_parse_message, $asciio_config)
	= $asciio->ParseSwitches([@ARGV], 0) ;

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

$asciio->{DISPLAY_SETUP_INFORMATION}++ if $asciio_config->{DISPLAY_SETUP_INFORMATION} ;

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

$asciio->setup($setup_paths, \%object_override) ;

if(defined $asciio_config->{TARGETS}[0])
	{
	$asciio->run_actions_by_name(['Open', $asciio_config->{TARGETS}[0]]) ;
	
	delete $asciio->{BINDINGS_COMPLETION} ;
	
	# $window->set_default_size(@{$asciio->{WINDOW_SIZE}})  if defined $asciio->{WINDOW_SIZE} ;
	}

App::Asciio::setup_embedded_bindings($asciio, $asciio_config) ;

$self->show_all();

my ($character_width, $character_height) = $asciio->get_character_size() ;

$self->set_size_request($asciio->{CANVAS_WIDTH} * $character_width, $asciio->{CANVAS_HEIGHT} * $character_height);
$asciio->set_modified_state(0) ;

if(defined $asciio_config->{SCRIPT})
	{
	require App::Asciio::Scripting ;
	
	App::Asciio::Utils::Scripting::run_external_script($asciio, $asciio_config->{SCRIPT}) ;
	}

# $asciio->setup_dnd($window) ;

$self->{$_} = $asciio->{$_} for keys %{$asciio} ;

return $self ;
}

# ----------------------------------------------------------------------------

sub on_draw
{
my ($self, $widget, $gc) = @_ ;

my ($widget_width, $widget_height)       = ($widget->get_allocated_width(), $widget->get_allocated_height()) ;
my ($window_width, $window_height)       = ($widget_width, $widget_height) ; #$self->{ROOT_WINDOW}->get_size() ;
my ($character_width, $character_height) = $self->get_character_size() ;
# my ($v_value, $h_value)                  = ($self->{SC_WINDOW}->get_vadjustment()->get_value(), $self->{SC_WINDOW}->get_hadjustment()->get_value()) ;
my ($v_value, $h_value)                  = (0, 0) ;
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

return TRUE ;
}


# ----------------------------------------------------------------------------

1 ;
