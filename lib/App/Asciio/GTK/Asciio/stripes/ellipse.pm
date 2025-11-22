
package App::Asciio::stripes::ellipse ;

use base App::Asciio::stripes::stripes ;
use App::Asciio::GTK::Asciio::Boxfuncs ;
use App::Asciio::String ;

use strict;
use warnings;

use Pango ;
use Glib qw(TRUE FALSE);
use List::Util qw(max) ;

#-----------------------------------------------------------------------------

sub create_model_for_ellipse
{
my ($rows) = @_ ;

my $model = Gtk3::ListStore->new(qw/Glib::Boolean Glib::String Glib::String Glib::String Glib::String Glib::String Glib::String Glib::String Glib::String Glib::Boolean/);

foreach my $row (@{$rows}) 
	{
	my $iter = $model->append;
	
	my $column = 0 ;
	$model->set($iter, map {$column++, $_} @{$row}) ;
	}

return $model;
}

#-----------------------------------------------------------------------------

sub on_focus_out_event
{
my ($self, $event, $window) = @_;
$self->response(1) ;
}

#-----------------------------------------------------------------------------

sub display_box_edit_dialog
{
my ($self, $text, undef, $asciio, $X, $Y, $text_x, $text_y) = @_ ;
if(($asciio->{EDIT_TEXT_INLINE} != 0) && (defined $X) && (defined $Y))
	{
	return $self->display_box_edit_dialog_for_mini_edit_mode($text, undef, $asciio, $X, $Y, $text_x, $text_y) ;
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

my $dialog = Gtk3::Dialog->new('Ellipse attributes', $window, 'destroy-with-parent')  ;
$dialog->set_position("mouse");
$dialog->set_border_width(0);
$dialog->set_default_size(450, 605);
$dialog->add_button('gtk-ok' => 'ok');

my $vbox = Gtk3::Box->new( 'vertical', 8 );
# my $vbox = Gtk3::VBox->new(FALSE, 5);
$vbox->add(Gtk3::Label->new (""));

my $treeview = Gtk3::TreeView->new_with_model(create_model_for_ellipse($rows));
$treeview->set_rules_hint(TRUE);
$treeview->get_selection->set_mode('single');
add_columns($treeview, $rows, 'no show', 9, 'default', 'bottom', 'low', 'middle', 'high', 'fix', 'single');

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
my ($self, $text, undef, $asciio, $X, $Y, $text_x, $text_y) = @_ ;

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

my $text_width = max(map {unicode_length $_} @text_lines);
my $text_heigh = @text_lines;
$text_width = max($text_width, 3) ;
$text_heigh =max($text_heigh, 3) ;

my ($character_width, $character_height) = $asciio->get_character_size() ;
my ($root_x, $root_y) = $asciio->{ROOT_WINDOW}->get_window()->get_origin() ;
my ($v_value, $h_value) = ($asciio->{SC_WINDOW}->get_vadjustment()->get_value(), $asciio->{SC_WINDOW}->get_hadjustment()->get_value());

my $window = new Gtk3::Window() ;

my $dialog = Gtk3::Dialog->new('Ellips attributes', $window, 'destroy-with-parent')  ;
$dialog->set_default_size($text_width, $text_heigh);
$dialog->set_border_width(0);
$dialog->set_decorated(0);
$dialog->move($root_x+(($X+$text_x)*$character_width)-$h_value, $root_y+(($Y+$text_y)*$character_height)-$v_value);

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

$dialog->add_events('GDK_FOCUS_CHANGE_MASK') ;
$dialog->signal_connect(focus_out_event => \&on_focus_out_event, $window) ;

$dialog->run() ;

my $new_text =  $textview->get_buffer->get_text($text_buffer->get_start_iter, $text_buffer->get_end_iter, TRUE) ;

$dialog->destroy ;

return $new_text ;
}


#-----------------------------------------------------------------------------

1 ;
