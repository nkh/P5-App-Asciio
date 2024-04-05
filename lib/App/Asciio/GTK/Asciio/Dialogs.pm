
package App::Asciio::GTK::Asciio ;
$|++ ;

use strict;
use warnings;

use Data::TreeDumper ;
use Data::TreeDumper::Renderer::GTK ;
use List::Util qw(max) ;

use App::Asciio::String ;

#-----------------------------------------------------------------------------

sub get_color_from_user
{
my ($self, $previous_color) = @_ ;

my $color = Gtk3::Gdk::Color->new (map { $_ * 65535 } @{$previous_color});
my $dialog = Gtk3::ColorSelectionDialog->new ("Changing color");

my $colorsel = $dialog->get_color_selection;

$colorsel->set_previous_color($color);
$colorsel->set_current_color($color);
$colorsel->set_has_palette(TRUE);

my $response = $dialog->run;

if ($response eq 'ok') 
	{
	$color = $colorsel->get_current_color;
	}

$dialog->destroy;

return [$color->red / 65535, $color->green / 65535, $color->blue / 65535]  ;
}

#-----------------------------------------------------------------------------

sub show_dump_window
{
my ($self, $data, $title, @dumper_setup) = @_ ;

my $window = new Gtk3::Window() ;

my $dialog = Gtk3::Dialog->new($title, $window, 'destroy-with-parent')  ;
$dialog->set_default_size(600, 800);

my $vbox = Gtk3::VBox->new(FALSE, 5);
$vbox->pack_start(Gtk3::Label->new (""), FALSE, FALSE, 0);
$vbox->add(Gtk3::Label->new (""));

# tree
my $treedumper = Data::TreeDumper::Renderer::GTK->new
				(
				data => $data,
				dumper_setup => {@dumper_setup}
				);

$treedumper->collapse_all;
$treedumper->set_hexpand(TRUE) ;
$treedumper->set_vexpand(TRUE) ;

my $scroller = Gtk3::ScrolledWindow->new();
$scroller->set_hexpand(TRUE) ;
$scroller->set_vexpand(TRUE) ;
$scroller->add($treedumper);

$vbox->add ($scroller) ;
$treedumper->show() ;
$scroller->show();
$vbox->show() ;

$dialog->get_content_area()->add($vbox) ;

$dialog->run() ;
$dialog->destroy ;
}


#-----------------------------------------------------------------------------

sub display_message_modal
{
my ($self, $message) = @_ ;

my $window = new Gtk3::Window() ;

my $dialog = Gtk3::MessageDialog->new 
	(
	$window,
	'destroy-with-parent' ,
	'other' ,
	'close' ,
	$message ,
	) ;

$dialog->modify_font(Pango::FontDescription->from_string($self->get_font_as_string()));

$dialog->signal_connect(response => sub { $dialog->destroy ; 1 }) ;
$dialog->run() ;
}

#-----------------------------------------------------------------------------

sub display_yes_no_cancel_dialog
{
my ($self, $title, $text) = @_ ;

my $window = new Gtk3::Window() ;

my $dialog = Gtk3::Dialog->new($title, $window, 'destroy-with-parent')  ;
$dialog->set_default_size (300, 150);
$dialog->add_button ('gtk-yes' => 'yes');
$dialog->add_button ('gtk-no' => 'no');
$dialog->add_button ('gtk-cancel' => 'cancel');

my $label = Gtk3::Label->new($text);
$dialog->get_content_area->add ($label);
$label->show;

my $result = $dialog->run() ;

$dialog->destroy ;

return $result ;
}

#-----------------------------------------------------------------------------

sub display_quit_dialog
{
my ($self, $title, $text) = @_ ;

my $window = Gtk3::Window->new() ;

my $dialog = Gtk3::Dialog->new($title, $window, 'destroy-with-parent')  ;
$dialog->set_default_size (300, 150);

add_button_with_icon ($dialog, 'Continue editing', 'gtk-cancel' => 'cancel');
add_button_with_icon ($dialog, 'Save and Quit', 'gtk-save' => 999);
add_button_with_icon ($dialog, 'Quit and lose changes', 'gtk-ok' => 'ok');

my $label = Gtk3::Label->new($text);
$label->show;

$dialog->get_content_area->add ($label);

my $result = $dialog->run() ;
$result = 'save_and_quit' if "$result" eq "999" ;

$dialog->destroy ;

return $result ;
}

sub add_button_with_icon
{
# code by Muppet
my ($dialog, $text, $stock_id, $response_id) = @_;

my $button = create_button ($text, $stock_id);
$button->show;

$dialog->add_action_widget ($button, $response_id);
}

sub create_button
{
# code by Muppet
my ($text, $stock_id) = @_;

my $button = Gtk3::Button->new ();

#
# This setup is cribbed from gtk_button_construct_child()
# in gtkbutton.c.  It does not handle all the details like
# left-to-right ordering and alignment and such, as in the
# real button code.
#
my $image = Gtk3::Image->new_from_stock ($stock_id, 'button');
my $label = Gtk3::Label->new ($text); # accepts mnemonics
$label->set_mnemonic_widget ($button);

my $hbox = Gtk3::HBox->new ();
$hbox->pack_start ($image, FALSE, FALSE, 0);
$hbox->pack_start ($label, FALSE, FALSE, 0);

$hbox->show_all ();

$button->add ($hbox);

return $button;
}

#-----------------------------------------------------------------------------

sub on_focus_out_event
{
my ($self, $event, $window) = @_;
$self->response(1) ;
}

#-----------------------------------------------------------------------------

sub display_edit_dialog
{
my ($self, $title, $text, $asciio, $X, $Y, $text_begin_x, $text_begin_y, $dialog_width, $dialog_height) = @_ ;
if(($asciio->{EDIT_TEXT_INLINE} != 0) && (defined $X) && (defined $Y))
	{
	return $self->display_edit_dialog_for_mini_edit_mode($title, $text, $asciio, $X, $Y, $text_begin_x, $text_begin_y) ;
	}
else
	{
	return $self->display_edit_dialog_for_normal_mode($title, $text, $asciio, $dialog_width, $dialog_height) ;
	}
}

#-----------------------------------------------------------------------------

sub display_edit_dialog_for_normal_mode
{
my ($self, $title, $text, $asciio, $width, $height) = @_ ;

$text ='' unless defined $text ;

my $window = new Gtk3::Window() ;

my $dialog = Gtk3::Dialog->new($title, $window, 'destroy-with-parent')  ;
$dialog->set_position("mouse");
$dialog->set_border_width(0);
$dialog->set_default_size ($width // 500, $height // 400);
$dialog->add_button ('gtk-ok' => 'ok');

my $vbox = Gtk3::VBox->new(FALSE, 5) ;
$vbox->pack_start(Gtk3::Label->new(""), FALSE, FALSE, 0) ;
$vbox->add(Gtk3::Label->new("")) ;

my $textview = Gtk3::TextView->new;
$textview->modify_font(Pango::FontDescription->from_string($asciio->get_font_as_string()));
my $buffer = $textview->get_buffer;
$buffer->insert ($buffer->get_end_iter, $text);

my $scroller = Gtk3::ScrolledWindow->new();
$scroller->set_hexpand(TRUE);
$scroller->set_vexpand(TRUE);
$scroller->add($textview);
$vbox->add($scroller);

$textview->show();
$scroller->show();
$vbox->show();

$dialog->get_content_area->add ($vbox) ;

$dialog->run() ;

my $new_text =  $textview->get_buffer->get_text($buffer->get_start_iter, $buffer->get_end_iter, TRUE) ;

$dialog->destroy ;

return $new_text
}

#-----------------------------------------------------------------------------

sub display_edit_dialog_for_mini_edit_mode
{
my ($self, $title, $text, $asciio, $X, $Y, $text_begin_x, $text_begin_y) = @_ ;

$text ='' unless defined $text ;
my @text_lines = ($text) ? split("\n", $text) : ('') ;

my $text_width = max(map {unicode_length($_)} @text_lines);
my $text_heigh = @text_lines;
$text_width = max($text_width, 3) ;
$text_heigh =max($text_heigh, 3) ;

my ($character_width, $character_height) = $asciio->get_character_size() ;
my ($root_x, $root_y) = $asciio->{root_window}->get_window()->get_origin() ;
$root_y += $asciio->get_tab_label_height() ;
my ($v_value, $h_value) = ($asciio->{sc_window}->get_vadjustment()->get_value(), $asciio->{sc_window}->get_hadjustment()->get_value());


my $window = new Gtk3::Window() ;

my $dialog = Gtk3::Dialog->new($title, $window, 'destroy-with-parent')  ;
$dialog->set_default_size ($text_width, $text_heigh);
$dialog->set_border_width(0);
$dialog->set_decorated(0);
$dialog->move($root_x+(($X+$text_begin_x)*$character_width)-$h_value, $root_y+(($Y+$text_begin_y)*$character_height)-$v_value);

my $vbox = Gtk3::VBox->new(FALSE, 5) ;
$vbox->pack_start(Gtk3::Label->new(""), FALSE, FALSE, 0) ;
$vbox->add(Gtk3::Label->new("")) ;

my $textview = Gtk3::TextView->new;
$textview->modify_font(Pango::FontDescription->from_string($asciio->get_font_as_string()));
my $buffer = $textview->get_buffer;
$buffer->insert ($buffer->get_end_iter, $text);

$vbox->add($textview);

$textview->show();
$vbox->show();

$dialog->get_content_area->add ($vbox) ;
$dialog->add_events('GDK_FOCUS_CHANGE_MASK') ;
$dialog->signal_connect(focus_out_event => \&on_focus_out_event, $window) ;

$dialog->run() ;

my $new_text =  $textview->get_buffer->get_text($buffer->get_start_iter, $buffer->get_end_iter, TRUE) ;

$dialog->destroy ;

return $new_text
}

#-----------------------------------------------------------------------------

sub get_file_name
{
my ($self, $title, $mode, $directory, $file_name) = @_ ;

my $file_chooser = Gtk3::FileChooserDialog->new
			(
			$title, undef, 'GTK_FILE_CHOOSER_ACTION_SAVE',
			'gtk-cancel' => 'cancel', 'gtk-ok' => 'ok'
			);

$file_chooser->set_current_name("untitled_document") ;
$file_chooser->set_current_folder($directory) if defined $directory ;
$file_chooser->set_create_folders(1) ;

$file_name //= '' ;
$file_name = $file_chooser->get_filename if ('ok' eq $file_chooser->run) ;

$file_chooser->destroy;
while(Gtk3::events_pending())
	{
	Gtk3::main_iteration() ;
	}

Encode::_utf8_on($file_name);
return $file_name ;
}

#-----------------------------------------------------------------------------

1 ;
