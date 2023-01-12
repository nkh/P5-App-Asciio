
package App::Asciio::stripes::editable_box2 ;

use base App::Asciio::stripes::single_stripe ;

use strict;
use warnings;

use Glib ':constants';
use Gtk3 -init;
use Glib qw(TRUE FALSE);

#-----------------------------------------------------------------------------

sub display_box_edit_dialog
{
my ($self, $title, $text) = @_ ;

my $rows = $self->{BOX_TYPE} ;
	
my $window = new Gtk3::Window() ;

my $dialog = Gtk3::Dialog->new('Box attributes', $window, 'destroy-with-parent')  ;
$dialog->set_default_size (450, 305);
$dialog->add_button ('gtk-ok' => 'ok');

my $vbox = Gtk3::VBox->new (FALSE, 5);

$vbox->pack_start (Gtk3::Label->new (""),
		 FALSE, FALSE, 0);

my $sw = Gtk3::ScrolledWindow->new;
$sw->set_shadow_type ('etched-in');
$sw->set_policy ('automatic', 'automatic');
$vbox->pack_start ($sw, TRUE, TRUE, 0);

# create model
my $model = create_model ($rows);

# create tree view
my $treeview = Gtk3::TreeView->new_with_model ($model);
$treeview->set_rules_hint (TRUE);
$treeview->get_selection->set_mode ('single');

add_columns($treeview, $rows);

$sw->add($treeview);

# title
my $titleview = Gtk3::TextView->new;
#$titleview->modify_font (Gtk3::Pango::FontDescription->from_string ('monospace 10'));
my $title_buffer = $titleview->get_buffer ;
$title_buffer->insert ($title_buffer->get_end_iter, $title);

$vbox->add ($titleview);
$titleview->show;

# text 
my $textview = Gtk3::TextView->new;
#$textview->modify_font (Gtk3::Pango::FontDescription->from_string ('monospace 10'));

my $text_buffer = $textview->get_buffer;
$text_buffer->insert ($text_buffer->get_end_iter, $text);

$vbox->add ($textview) ;
$textview->show() ;

# Focus and select, code by Tian
$text_buffer->select_range($text_buffer->get_start_iter, $text_buffer->get_end_iter);
$textview->grab_focus() ;

$treeview->show() ;
$vbox->show() ;
$sw->show() ;

$dialog->run() ;

my $new_text =  $textview->get_buffer->get_text($text_buffer->get_start_iter, $text_buffer->get_end_iter, TRUE) ;
my $new_title =  $titleview->get_buffer->get_text($title_buffer->get_start_iter, $title_buffer->get_end_iter, TRUE) ;

$dialog->destroy ;

return($new_text, $new_title) ;
}

#-----------------------------------------------------------------------------

sub create_model 
{
my ($rows) = @_ ;

my $model = Gtk3::ListStore->new(qw/Glib::Boolean Glib::String  Glib::String Glib::String Glib::String Glib::Boolean/);

foreach my $row (@{$rows}) 
	{
	my $iter = $model->append;

	my $column = 0 ;
	$model->set ($iter, map {$column++, $_} @{$row}) ;
	}

return $model;
}

#-----------------------------------------------------------------------------

sub add_columns 
{
my ($treeview, $rows) = @_ ;
my $model = $treeview->get_model;

# column for fixed toggles
my $renderer = Gtk3::CellRendererToggle->new;
$renderer->signal_connect (toggled => \&display_toggled, [$model, $rows]) ;

my $column = Gtk3::TreeViewColumn->new_with_attributes 
			(
			'show',
			$renderer,
			active => 0
			) ;
			
$column->set_sizing('fixed') ;
$column->set_fixed_width(70) ;
$treeview->append_column($column) ;

# column for row titles
my $row_renderer = Gtk3::CellRendererText->new;
$row_renderer->set_data (column => 1);

$treeview->insert_column_with_attributes(-1, '', $row_renderer, text => 1) ;

#~ $column->set_sort_column_id (COLUMN_NUMBER);

my $current_column = 2 ;
for my $column_title('left', 'body', 'right')
	{
	my $renderer = Gtk3::CellRendererText->new;
	$renderer->signal_connect (edited => \&cell_edited, [$model, $rows]);
	$renderer->set_data (column => $current_column );

	$treeview->insert_column_with_attributes 
				(
				-1, $column_title, $renderer,
				text => $current_column,
				editable => 5, 
				);
				
	$current_column++ ;
	}
}

#-----------------------------------------------------------------------------

sub cell_edited 
{
my ($cell, $path_string, $new_text, $model_and_rows) = @_;

my ($model, $rows) = @{$model_and_rows} ;

my $path = Gtk3::TreePath->new_from_string ($path_string);
my $column = $cell->get_data ("column");
my $iter = $model->get_iter($path);
my $row = ($path->get_indices)[0];

$rows->[$row][$column] = $new_text ;

$model->set($iter, $column, $new_text);
}

#-----------------------------------------------------------------------------

sub display_toggled 
{
my ($cell, $path_string, $model_and_rows) = @_;

my ($model, $rows) = @{$model_and_rows} ;

my $column = $cell->get_data ('column');
my $path = Gtk3::TreePath->new ($path_string) ;
my $iter = $model->get_iter ($path);
my $display = $model->get($iter, 0);

$rows->[$path_string][$column] = $display ^ 1 ;

$model->set ($iter, 0, $display ^ 1);
}

#-----------------------------------------------------------------------------

#~ sub add_item {
  #~ my ($button, $model) = @_;

  #~ push @articles, {
	#~ number => 0,
	#~ product => "Description here",
	#~ editable => TRUE,
  #~ };

  #~ my $iter = $model->append;
  #~ $model->set ($iter,
               #~ COLUMN_NUMBER, $articles[-1]{number},
               #~ COLUMN_PRODUCT, $articles[-1]{product},
               #~ COLUMN_EDITABLE, $articles[-1]{editable});
#~ }

#~ sub remove_item {
  #~ my ($widget, $treeview) = @_;
  #~ my $model = $treeview->get_model;
  #~ my $selection = $treeview->get_selection;

  #~ my $iter = $selection->get_selected;
  #~ if ($iter) {
      #~ my $path = $model->get_path ($iter);
      #~ my $i = ($path->get_indices)[0];
      #~ $model->remove ($iter);

      #~ splice @articles, $i;
  #~ }
#~ }

#-----------------------------------------------------------------------------

1 ;
