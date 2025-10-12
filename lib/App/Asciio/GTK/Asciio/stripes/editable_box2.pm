
package App::Asciio::stripes::editable_box2 ;
use parent qw/App::Asciio::stripes::single_stripe/ ;

use App::Asciio::GTK::Asciio::Boxfuncs ;
use App::Asciio::String ;

use strict;
use warnings;

use Pango ;
use Glib qw(TRUE FALSE);
use List::Util qw(max) ;
use File::Slurp ;

#-----------------------------------------------------------------------------

sub on_focus_out_event
{
my ($self, $event, $window) = @_;
$self->response(1) ;
}

#-----------------------------------------------------------------------------

sub display_box_edit_dialog
{
my ($self, $title, $text, $asciio, $X, $Y, $text_begin_x, $text_begin_y, $title_separator_exist) = @_ ;

my ($new_text, $new_title) ;

if($asciio->{EDIT_TEXT_INLINE} && defined $X && defined $Y)
	{
	($new_text, $new_title) = $self->display_box_edit_dialog_inline_mode($title, $text, $asciio, $X, $Y, $text_begin_x, $text_begin_y, $title_separator_exist) ;
	}
else
	{
	($new_text, $new_title) = $self->display_box_edit_dialog_normal_mode($title, $text, $asciio) ;
	}

$self->save_on_edit($new_text, $new_title) ;

return($new_text, $new_title) ;
}

sub save_on_edit
{
my ($self, $new_text, $new_title) = @_ ;

write_file($self->{SAVE_ON_EDIT}, {binmode => ':utf8'}, "$new_title$new_text") if exists $self->{SAVE_ON_EDIT} ;
}

#-----------------------------------------------------------------------------

sub display_box_edit_dialog_normal_mode
{
my ($self, $title, $text, $asciio) = @_ ;

my $rows = $self->{BOX_TYPE} ;

my $window = new Gtk3::Window() ;

my $dialog = Gtk3::Dialog->new('Box attributes', $window, 'destroy-with-parent')  ;
$dialog->set_position("mouse");
$dialog->set_border_width(0);
$dialog->set_default_size(450, 500);
$dialog->add_button('gtk-ok' => 'ok');

my $vbox = Gtk3::Box->new( 'vertical', 8 );
$vbox->add(Gtk3::Label->new (""));

my $treeview = Gtk3::TreeView->new_with_model(create_model($rows));
$treeview->set_rules_hint(TRUE);
$treeview->get_selection->set_mode('single');
add_columns($treeview, $rows);

$vbox->add($treeview);

# box title
my $titleview = Gtk3::TextView->new;
$titleview->modify_font(Pango::FontDescription->from_string($asciio->get_font_as_string()));
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

sub display_box_edit_dialog_inline_mode
{
my ($self, $title, $text, $asciio, $X, $Y, $text_begin_x, $text_begin_y, $title_separator_exist) = @_ ;

$text ='' unless defined $text ;

my @text_lines = ($text) ? split("\n", $text) : ('') ;

my $text_width = max(map {unicode_length $_} @text_lines);
my $text_heigh = @text_lines;
$text_width = max($text_width, 3) ;
$text_heigh =max($text_heigh, 3) ;

$title ='' unless defined $title ;

my @title_lines = ($title) ? split("\n", $title) : ('') ;

my $title_width = max(map {unicode_length $_} @title_lines);
my $title_heigh = @title_lines;
$title_width = max($title_width, 3) ;
$title_heigh =max($title_heigh, 3) ;

my $final_width = max($title_width, $text_width) ;
my $final_heigh = $text_heigh + $title_heigh + 1;

my ($character_width, $character_height) = $asciio->get_character_size() ;
# need to exclude the influence of window decoration
my ($root_x, $root_y) = $asciio->{root_window}->get_window()->get_origin() ;
$root_y += $asciio->get_tab_label_height() ;

my ($v_value, $h_value) = ($asciio->{sc_window}->get_vadjustment()->get_value(), $asciio->{sc_window}->get_hadjustment()->get_value());


my $window = new Gtk3::Window() ;

my $dialog = Gtk3::Dialog->new('Box attributes', $window, 'destroy-with-parent')  ;
$dialog->set_default_size($final_width, $final_heigh);
$dialog->set_border_width(0);
$dialog->set_decorated(0);
$dialog->move($root_x+(($X+$text_begin_x)*$character_width)-$h_value, $root_y+(($Y+$text_begin_y)*$character_height)-$v_value);

my $vbox = Gtk3::VBox->new(FALSE, $character_height);
$vbox->add(Gtk3::Label->new (""));

my ($titleview, $title_buffer);
if($title_separator_exist)
	{
	# box title
	$titleview = Gtk3::TextView->new;
	$titleview->modify_font(Pango::FontDescription->from_string($asciio->get_font_as_string()));
	$title_buffer = $titleview->get_buffer ;
	$title_buffer->insert($title_buffer->get_end_iter, $title);
	
	$vbox->add($titleview);
	
	$titleview->show();
	}

# box text 
my $textview = Gtk3::TextView->new;
$textview->modify_font(Pango::FontDescription->from_string ($asciio->get_font_as_string()));

my $text_buffer = $textview->get_buffer;
$text_buffer->insert($text_buffer->get_end_iter, $text);

$vbox->add($textview);

$textview->show();

#Focus and select, code by Tian
$text_buffer->select_range($text_buffer->get_start_iter, $text_buffer->get_end_iter);
$textview->grab_focus() ;

$vbox->show() ;

$dialog->get_content_area()->add($vbox) ;

$dialog->add_events('GDK_FOCUS_CHANGE_MASK') ;
$dialog->signal_connect(focus_out_event => \&on_focus_out_event, $window) ;

$dialog->run() ;

my $new_text =  $textview->get_buffer->get_text($text_buffer->get_start_iter, $text_buffer->get_end_iter, TRUE) ;

my $new_title = ($title_separator_exist) 
					? $titleview->get_buffer->get_text($title_buffer->get_start_iter, $title_buffer->get_end_iter, TRUE) 
					: $title ;

$dialog->destroy ;

return($new_text, $new_title) ;
}

#-----------------------------------------------------------------------------

1 ;
