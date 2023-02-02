
package App::Asciio::Text::Asciio ;
$|++ ;

use strict;
use warnings;

use Data::TreeDumper ;
use Data::TreeDumper::Renderer::GTK ;

#-----------------------------------------------------------------------------

sub get_color_from_user
{
my ($self, $previous_color) = @_ ;

return ;
# my $color = map { $_ * 65535 } @{$previous_color};
# my $dialog = ColorDialog->new ("Changing color");

# my $colorsel = $dialog->get_color_selection;

# $colorsel->set_previous_color($color);
# $colorsel->set_current_color($color);
# $colorsel->set_has_palette(TRUE);

# my $response = $dialog->run;

# if ($response eq 'ok') 
# 	{
# 	$color = $colorsel->get_current_color;
# 	}

# $dialog->destroy;

# return [$color->red / 65535, $color->green / 65535, $color->blue / 65535]  ;
}

#-----------------------------------------------------------------------------

sub show_dump_window
{
my ($self, $data, $title, @dumper_setup) = @_ ;

return ;

# my $window = new Gtk3::Window() ;

# my $dialog = Gtk3::Dialog->new($title, $window, 'destroy-with-parent')  ;
# $dialog->set_default_size(600, 800);

# my $vbox = Gtk3::VBox->new(FALSE, 5);
# $vbox->pack_start(Gtk3::Label->new (""), FALSE, FALSE, 0);
# $vbox->add(Gtk3::Label->new (""));

# # tree
# my $treedumper = Data::TreeDumper::Renderer::GTK->new
# 				(
# 				data => $data,
# 				dumper_setup => {@dumper_setup}
# 				);
# $treedumper->collapse_all;
# $treedumper->set_hexpand(TRUE) ;
# $treedumper->set_vexpand(TRUE) ;

# my $scroller = Gtk3::ScrolledWindow->new();
# $scroller->set_hexpand(TRUE) ;
# $scroller->set_vexpand(TRUE) ;
# $scroller->add($treedumper);

# $vbox->add ($scroller) ;
# $treedumper->show() ;
# $scroller->show();
# $vbox->show() ;

# $dialog->get_content_area()->add($vbox) ;

# $dialog->run() ;
# $dialog->destroy ;
}


#-----------------------------------------------------------------------------

sub display_message_modal
{
my ($self, $message) = @_ ;

return ;

# my $window = new Gtk3::Window() ;

# my $dialog = Gtk3::MessageDialog->new 
# 	(
# 	$window,
# 	'destroy-with-parent' ,
# 	'info' ,
# 	'close' ,
# 	$message ,
# 	) ;

# $dialog->signal_connect(response => sub { $dialog->destroy ; 1 }) ;
# $dialog->run() ;
}

#-----------------------------------------------------------------------------

sub display_yes_no_cancel_dialog
{
my ($self, $title, $text) = @_ ;

return ;
# my $window = new Gtk3::Window() ;

# my $dialog = Gtk3::Dialog->new($title, $window, 'destroy-with-parent')  ;
# $dialog->set_default_size (300, 150);
# $dialog->add_button ('gtk-yes' => 'yes');
# $dialog->add_button ('gtk-no' => 'no');
# $dialog->add_button ('gtk-cancel' => 'cancel');

# my $label = Gtk3::Label->new($text);
# $dialog->get_content_area->add ($label);
# $label->show;

# my $result = $dialog->run() ;

# $dialog->destroy ;

# return $result ;
}

#-----------------------------------------------------------------------------

sub display_quit_dialog
{
my ($self, $title, $text) = @_ ;

return ;

# my $window = Gtk3::Window->new() ;

# my $dialog = Gtk3::Dialog->new($title, $window, 'destroy-with-parent')  ;
# $dialog->set_default_size (300, 150);

# add_button_with_icon ($dialog, 'Continue editing', 'gtk-cancel' => 'cancel');
# add_button_with_icon ($dialog, 'Save and Quit', 'gtk-save' => 999);
# add_button_with_icon ($dialog, 'Quit and lose changes', 'gtk-ok' => 'ok');

# my $label = Gtk3::Label->new($text);
# $label->show;

# $dialog->get_content_area->add ($label);

# my $result = $dialog->run() ;
# $result = 'save_and_quit' if "$result" eq "999" ;

# $dialog->destroy ;

# return $result ;
}


#-----------------------------------------------------------------------------

sub display_edit_dialog
{
my ($self, $title, $text) = @_ ;

$text ='' unless defined $text ;

return ;

# my $window = new Gtk3::Window() ;

# my $dialog = Gtk3::Dialog->new($title, $window, 'destroy-with-parent')  ;
# $dialog->set_default_size (300, 150);
# $dialog->add_button ('gtk-ok' => 'ok');

# my $textview = Gtk3::TextView->new;
# my $buffer = $textview->get_buffer;
# $buffer->insert ($buffer->get_end_iter, $text);

# $dialog->get_content_area->add ($textview) ;
# $textview->show;


# # Set up the dialog such that Ctrl+Return will activate the "ok"  response. Muppet

# # my $accel = Gtk3::AccelGroup->new;
# # $accel->connect
# #       (
# #       Gtk3::Gdk->keyval_from_name ('Return'), ['control-mask'], [],
# #       sub { $dialog->response ('ok'); }
# #       );
      
# # $dialog->add_accel_group ($accel);

# $dialog->run() ;

# my $new_text =  $textview->get_buffer->get_text($buffer->get_start_iter, $buffer->get_end_iter, TRUE) ;

# $dialog->destroy ;

# return $new_text
}

#-----------------------------------------------------------------------------

sub get_file_name
{
my ($self, $type) = @_ ;

my $file_name = '' ;

return ;

# my $file_chooser = Gtk3::FileChooserDialog->new 
# 				(
# 				$type, undef, $type,
# 				'gtk-cancel' => 'cancel', 'gtk-ok' => 'ok'
# 				);

# $file_name = $file_chooser->get_filename if ('ok' eq $file_chooser->run) ;
	
# $file_chooser->destroy;

# return $file_name ;
}


#-----------------------------------------------------------------------------

1 ;
