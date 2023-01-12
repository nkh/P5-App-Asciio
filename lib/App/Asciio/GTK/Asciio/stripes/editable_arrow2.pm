
package App::Asciio::stripes::editable_arrow2 ;

use base App::Asciio::stripes::stripes ;

use strict;
use warnings;

use Glib ':constants';
use Gtk3 -init;
use Glib qw(TRUE FALSE);

sub display_box_edit_dialog
{
my ($self) = @_ ;

my $rows = $self->{ARROW_TYPE} ;
my $window = new Gtk3::Window() ;

my $dialog = Gtk3::Dialog->new('Arrow attributes', $window, 'destroy-with-parent')  ;
$dialog->set_default_size (220, 270);
$dialog->add_button ('gtk-ok' => 'ok');

#~ my $vbox = $dialog->vbox ;
my $dialog_vbox = $dialog->vbox ;

my $vbox = Gtk3::VBox->new (FALSE, 5);
$dialog_vbox->pack_start ($vbox, TRUE, TRUE, 0);

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

$treeview->show() ;
$vbox->show() ;
$sw->show() ;

$dialog->run() ;

$dialog->destroy ;
}

#-----------------------------------------------------------------------------

sub create_model 
{
my ($rows) = @_ ;

my $model = Gtk3::ListStore->new(qw/Glib::String Glib::String  Glib::String  Glib::String Glib::Boolean/);

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

# column for row titles
my $row_renderer = Gtk3::CellRendererText->new;
$row_renderer->set_data (column => 0);

$treeview->insert_column_with_attributes
			(
			-1, '', $row_renderer,
			text => 0,
			) ;
my $column = $treeview->get_column(0) ;
$column->set_sizing('fixed') ;
$column->set_fixed_width(80) ;

my $current_column = 1 ;
for my $column_title('start', 'body', 'end')
	{
	my $renderer = Gtk3::CellRendererText->new;
	$renderer->signal_connect (edited => \&cell_edited, [$model, $rows]);
	$renderer->set_data (column => $current_column );

	$treeview->insert_column_with_attributes 
				(
				-1, $column_title, $renderer,
				text => $current_column,
				editable => 4, 
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

1 ;
