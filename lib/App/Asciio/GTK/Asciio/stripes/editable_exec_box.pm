
package App::Asciio::stripes::exec_box ;
use parent qw/App::Asciio::stripes::editable_box2/ ;

use App::Asciio::GTK::Asciio::Boxfuncs ;

use strict;
use warnings;

use Glib qw(TRUE FALSE);

#-----------------------------------------------------------------------------

sub display_box_edit_dialog
{
my ($self, $title, $text, $asciio) = @_ ;

my $rows = $self->{BOX_TYPE} ;

my $window = new Gtk3::Window() ;

my $dialog = Gtk3::Dialog->new('Box attributes', $window, 'destroy-with-parent')  ;
$dialog->set_position("mouse");
$dialog->set_border_width(0);
$dialog->set_default_size(450, 305);
$dialog->add_button('gtk-ok' => 'ok');

my $vbox = Gtk3::VBox->new(FALSE, 5);
$vbox->add(Gtk3::Label->new (""));

my $treeview = Gtk3::TreeView->new_with_model(create_model($rows));
$treeview->set_rules_hint(TRUE);
$treeview->get_selection->set_mode('single');
add_columns($treeview, $rows);

$vbox->add($treeview);

# box title
my $titleview = Gtk3::TextView->new;
$titleview->modify_font(Pango::FontDescription->from_string ($asciio->get_font_as_string()));
my $title_buffer = $titleview->get_buffer ;
$title_buffer->insert($title_buffer->get_end_iter, $title);

$vbox->add($titleview);

$titleview->show();

# box text 
my $textview = Gtk3::TextView->new;
$textview->modify_font(Pango::FontDescription->from_string ($asciio->get_font_as_string()));

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
my $new_title =  $titleview->get_buffer->get_text($title_buffer->get_start_iter, $title_buffer->get_end_iter, TRUE) ;

$dialog->destroy ;

return($new_text, $new_title) ;
}

#-----------------------------------------------------------------------------

1 ;
