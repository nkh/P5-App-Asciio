
package App::Asciio::GTK::Asciio::HelpWidget;

use Glib qw(TRUE FALSE);

sub new
{
my ($class, $tab_manager) = @_ ;

my $scrolled = Gtk3::ScrolledWindow->new() ;
$scrolled->set_policy('automatic', 'automatic') ;

my $textview = Gtk3::TextView->new() ;
$textview->set_editable(FALSE) ;
$textview->set_cursor_visible(FALSE) ;
$textview->set_wrap_mode('word') ;
$textview->set_left_margin(10) ;
$textview->set_right_margin(10) ;
$textview->set_top_margin(10) ;
$textview->set_bottom_margin(10) ;

my $buffer = $textview->get_buffer() ;

my $help_text = <<'END_HELP';
KEYBOARD SHORTCUTS
==================

TAB MANAGEMENT

NAVIGATION

REORDERING
Left arrow     Move current tab to previous position
Right arrow    Move current tab to next position

DISPLAY

OTHER
h              Show this help tab
q              Quit the application

USAGE
=====

Click on a tab to give it focus, then use keyboard shortcuts.

HELP TAB SHORTCUTS
==================
END_HELP

$buffer->set_text($help_text) ;

$scrolled->add($textview) ;

$textview->set_can_focus(TRUE) ;
$textview->add_events(['key-press-mask']) ;

$textview->signal_connect
	(
	'key-press-event' => sub
		{
		my ($widget, $event) = @_ ;
		my $keyval  = $event->keyval() ;
		my $keyname = Gtk3::Gdk::keyval_name($keyval) ;
		
		if ($keyname eq 'minus' || $keyname eq 'KP_Subtract')
			{
			$tab_manager->delete_current_tab() ;
			return TRUE ;
			}
		elsif ($keyname eq 'q')
			{
			$tab_manager->quit_application() ;
			return TRUE ;
			}
		
		return FALSE ;
		}
	) ;

my $self = bless
	{
	widget   => $scrolled,
	textview => $textview,
	}, $class ;

return $self ;
}

# ----------------------------------------------------------------------------

sub get_widget
{
my ($self) = @_ ;
return $self->{widget} ;
}

# ----------------------------------------------------------------------------

sub grab_focus
{
my ($self) = @_ ;
$self->{textview}->grab_focus() ;
}

# ----------------------------------------------------------------------------

1 ;
