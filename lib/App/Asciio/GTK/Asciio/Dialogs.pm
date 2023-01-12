
package App::Asciio::GTK::Asciio ;
$|++ ;

use strict;
use warnings;

use Data::TreeDumper ;
# use Data::TreeDumper::Renderer::GTK ;

#-----------------------------------------------------------------------------

sub get_color_from_user
{
my ($self, $previous_color) = @_ ;

my $color = Gtk3::Gdk::Color->new (@{$previous_color});
my $dialog = Gtk3::ColorSelectionDialog->new ("Changing color");

my $colorsel = $dialog->colorsel;

$colorsel->set_previous_color ($color);
$colorsel->set_current_color ($color);
$colorsel->set_has_palette (TRUE);

my $response = $dialog->run;

if ($response eq 'ok') 
	{
	$color = $colorsel->get_current_color;
	}

$dialog->destroy;

return [$color->red, $color->green , $color->blue]  ;
}

#-----------------------------------------------------------------------------

sub show_dump_window
{
# my ($self, $data, $title, @dumper_setup) = @_ ;

# my $treedumper = Data::TreeDumper::Renderer::GTK->new
# 				(
# 				data => $data,
# 				title => $title,
# 				dumper_setup => {@dumper_setup}
# 				);
		
# $treedumper->modify_font(Gtk3::Pango::FontDescription->from_string ('monospace'));
# $treedumper->collapse_all;

# # some boilerplate to get the widget onto the screen...
# my $window = Gtk3::Window->new;

# my $scroller = Gtk3::ScrolledWindow->new;
# $scroller->add ($treedumper);

# $window->add ($scroller);
# $window->set_default_size(640, 1000) ;
# $window->show_all;
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
	'info' ,
	'close' ,
	$message ,
	) ;

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
$dialog->vbox->add ($label);
$label->show;

my $result = $dialog->run() ;

$dialog->destroy ;

return $result ;
}

#-----------------------------------------------------------------------------

sub display_quit_dialog
{
my ($self, $title, $text) = @_ ;

my $window = new Gtk3::Window() ;

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

sub add_button_with_icon {
	# code by Muppet
        my ($dialog, $text, $stock_id, $response_id) = @_;

        my $button = create_button ($text, $stock_id);
        $button->show;

        $dialog->add_action_widget ($button, $response_id);
}

#
# Create a button with a stock icon but with non-stock text.
#
sub create_button {
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

sub display_edit_dialog
{
my ($self, $title, $text) = @_ ;

$text ='' unless defined $text ;

my $window = new Gtk3::Window() ;

my $dialog = Gtk3::Dialog->new($title, $window, 'destroy-with-parent')  ;
$dialog->set_default_size (300, 150);
$dialog->add_button ('gtk-ok' => 'ok');

my $textview = Gtk3::TextView->new;
my $buffer = $textview->get_buffer;
$buffer->insert ($buffer->get_end_iter, $text);

$dialog->get_content_area->add ($textview) ;
$textview->show;

#
# Set up the dialog such that Ctrl+Return will activate the "ok"  response. Muppet
#
#~ my $accel = Gtk3::AccelGroup->new;
#~ $accel->connect
		#~ (
		#~ Gtk3::Gdk->keyval_from_name ('Return'), ['control-mask'], [],
                #~ sub { $dialog->response ('ok'); }
		#~ );
		
#~ $dialog->add_accel_group ($accel);

$dialog->run() ;

my $new_text =  $textview->get_buffer->get_text($buffer->get_start_iter, $buffer->get_end_iter, TRUE) ;

$dialog->destroy ;

return $new_text
}

#-----------------------------------------------------------------------------

sub get_file_name
{
my ($self, $type) = @_ ;

my $file_name = '' ;

my $file_chooser = Gtk3::FileChooserDialog->new 
				(
				$type, undef, $type,
				'gtk-cancel' => 'cancel', 'gtk-ok' => 'ok'
				);

$file_name = $file_chooser->get_filename if ('ok' eq $file_chooser->run) ;
	
$file_chooser->destroy;

return $file_name ;
}


#-----------------------------------------------------------------------------

1 ;
