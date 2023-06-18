
package App::Asciio::stripes::rhombus ;

use base App::Asciio::stripes::stripes ;
use App::Asciio::GTK::Asciio::Boxfuncs ;
use App::Asciio::Toolfunc ;

use strict;
use warnings;

use Pango ;
use Glib qw(TRUE FALSE);
use List::Util qw(max) ;

#-----------------------------------------------------------------------------

sub display_box_edit_dialog
{
my ($self, $text, undef, $asciio, $X, $Y) = @_ ;
my $gtk_popup_box_type = get_gtk_popup_box_type();
if(($gtk_popup_box_type != 0) && (defined $X) && (defined $Y))
	{
	return $self->display_box_edit_dialog_for_mini_edit_mode($text, undef, $asciio, $X, $Y) ;
	}
else
	{
	return $self->display_box_edit_dialog_for_normal_mode($text, undef, $asciio) ;
	}
}


#-----------------------------------------------------------------------------

sub display_box_edit_dialog_for_normal_mode
{
my ($self, $text, undef, $asciio) = @_ ;

my $rows = $self->{BOX_TYPE} ;

my $window = new Gtk3::Window() ;

my $dialog = Gtk3::Dialog->new('Box attributes', $window, 'destroy-with-parent')  ;
$dialog->set_position("mouse");
$dialog->set_border_width(0);
$dialog->set_default_size(450, 605);
$dialog->add_button('gtk-ok' => 'ok');

my $vbox = Gtk3::VBox->new(FALSE, 5);
$vbox->add(Gtk3::Label->new (""));

my $treeview = Gtk3::TreeView->new_with_model(create_model($rows));
$treeview->set_rules_hint(TRUE);
$treeview->get_selection->set_mode('single');
add_columns($treeview, $rows, 'no show');

$vbox->add($treeview);

# box text 
my $textview = Gtk3::TextView->new;
$textview->modify_font(Pango::FontDescription->from_string($asciio->get_font_as_string()));

my $text_buffer = $textview->get_buffer;
$text_buffer->insert($text_buffer->get_end_iter, $text);

my $text_scroller = Gtk3::ScrolledWindow->new();
$text_scroller->set_hexpand(TRUE);
$text_scroller->set_vexpand(TRUE);
$text_scroller->add($textview);
$vbox->add($text_scroller);

$textview->show();
$text_scroller->show();

#Focus and select, code by Tian
$text_buffer->select_range($text_buffer->get_start_iter, $text_buffer->get_end_iter);
$textview->grab_focus() ;

$treeview->show() ;
$vbox->show() ;

$dialog->get_content_area()->add($vbox) ;
$dialog->run() ;

my $new_text =  $textview->get_buffer->get_text($text_buffer->get_start_iter, $text_buffer->get_end_iter, TRUE) ;

$dialog->destroy ;

return $new_text ;
}

#-----------------------------------------------------------------------------


sub display_box_edit_dialog_for_mini_edit_mode
{
my ($self, $text, undef, $asciio, $X, $Y) = @_ ;

$text ='' unless defined $text ;
my @text_lines ;
if($text)
	{
	@text_lines = split("\n", $text) ;
	}
else
	{
	@text_lines = ('') ;
	}

my $text_width = max(map {usc_length $_} @text_lines);
my $text_heigh = @text_lines;
$text_width = max($text_width, 3) ;
$text_heigh =max($text_heigh, 3) ;

my ($character_width, $character_height) = $asciio->get_character_size() ;
my ($root_x, $root_y) = $asciio->{root_window}->get_position();
my ($v_value, $h_value) = ($asciio->{sc_window}->get_vadjustment()->get_value(), $asciio->{sc_window}->get_hadjustment()->get_value());

my $window = new Gtk3::Window() ;

my $dialog = Gtk3::Dialog->new('Box attributes', $window, 'destroy-with-parent')  ;
$dialog->set_default_size($text_width, $text_heigh);
$dialog->set_border_width(0);
$dialog->set_decorated(0);
$dialog->move($root_x+($X*$character_width)-$h_value, $root_y+($Y*$character_height)-$v_value);

my $vbox = Gtk3::VBox->new(FALSE, 5);
$vbox->add(Gtk3::Label->new (""));

# box text 
my $textview = Gtk3::TextView->new;
$textview->modify_font(Pango::FontDescription->from_string($asciio->get_font_as_string()));

my $text_buffer = $textview->get_buffer;
$text_buffer->insert($text_buffer->get_end_iter, $text);


$vbox->add($textview);
$textview->show();

#Focus and select, code by Tian
$text_buffer->select_range($text_buffer->get_start_iter, $text_buffer->get_end_iter);
$textview->grab_focus() ;

$vbox->show() ;

$dialog->get_content_area()->add($vbox) ;
$dialog->run() ;

my $new_text =  $textview->get_buffer->get_text($text_buffer->get_start_iter, $text_buffer->get_end_iter, TRUE) ;

$dialog->destroy ;

return $new_text ;
}


#-----------------------------------------------------------------------------

1 ;
