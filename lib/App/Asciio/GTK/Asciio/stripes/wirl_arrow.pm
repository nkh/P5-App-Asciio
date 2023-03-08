
package App::Asciio::stripes::wirl_arrow ;
use parent qw/App::Asciio::stripes::stripes/ ;

use strict;
use warnings;

use Glib ':constants';
use Gtk3 -init;
use Glib qw(TRUE FALSE);

#-----------------------------------------------------------------------------

sub display_arrow_edit_dialog
{
my ($self) = @_ ;

my $rows = $self->{ARROW_TYPE} ;
my $window = new Gtk3::Window() ;

my $dialog = Gtk3::Dialog->new('Arrow attributes', $window, 'destroy-with-parent')  ;
$dialog->set_default_size(450, 505);
$dialog->add_button('gtk-ok' => 'ok');

my $vbox = Gtk3::VBox->new (FALSE, 5);
$vbox->pack_start(Gtk3::Label->new (""), FALSE, FALSE, 0);

my $treeview = Gtk3::TreeView->new_with_model(create_model($rows));
$treeview->set_rules_hint(TRUE);
$treeview->get_selection->set_mode('single');

add_columns($treeview, $rows);

$vbox->add($treeview);

$treeview->show() ;
$vbox->show() ;

$dialog->get_content_area()->add($vbox) ;
$dialog->run() ;

$dialog->destroy ;
}

#-----------------------------------------------------------------------------

sub create_model 
{
my ($rows) = @_ ;

my $model = Gtk3::ListStore->new(qw/Glib::String Glib::String Glib::String  Glib::String  Glib::String Glib::String Glib::Boolean/);

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
$column->set_fixed_width(120) ;

my $current_column = 1 ;
for my $column_title('start', 'body', 'connection', 'body_2', 'end')
	{
	my $renderer = Gtk3::CellRendererText->new;
	$renderer->signal_connect (edited => \&cell_edited, [$model, $rows]);
	$renderer->set_data (column => $current_column );
	
	$treeview->insert_column_with_attributes 
				(
				-1, $column_title, $renderer,
				text => $current_column,
				editable => 6, 
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
