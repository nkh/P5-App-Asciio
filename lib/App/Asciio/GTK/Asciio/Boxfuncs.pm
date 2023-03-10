
package App::Asciio::GTK::Asciio::Boxfuncs ;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(create_model add_columns);

use strict;
use warnings;
use utf8;

use Glib ':constants';
use Gtk3 -init;

#-----------------------------------------------------------------------------

sub create_model 
{
my ($rows) = @_ ;

my $model = Gtk3::ListStore->new(qw/Glib::Boolean Glib::String  Glib::String Glib::String Glib::String Glib::Boolean/);

foreach my $row (@{$rows}) 
	{
	my $iter = $model->append;
	
	my $column = 0 ;
	$model->set($iter, map {$column++, $_} @{$row}) ;
	}

return $model;
}

#-----------------------------------------------------------------------------

sub add_columns 
{
my ($treeview, $rows, $no_show_flag, $editable_cnt, @column_titles) = @_ ;
my $model = $treeview->get_model;

# column for fixed toggles
my $renderer = Gtk3::CellRendererToggle->new;
$renderer->signal_connect (toggled => \&display_toggled, [$model, $rows]) ;

unless(defined $no_show_flag) {
my $column = Gtk3::TreeViewColumn->new_with_attributes 
			(
			'show',
			$renderer,
			active => 0
			) ;

$column->set_sizing('fixed') ;
$column->set_fixed_width(70) ;
$treeview->append_column($column) ;
}

# column for row titles
my $row_renderer = Gtk3::CellRendererText->new;
$row_renderer->set_data (column => 1);

$treeview->insert_column_with_attributes(-1, '', $row_renderer, text => 1) ;

my $current_column = 2 ;
unless(@column_titles)
{
	@column_titles = ('left', 'body', 'right') ;
}
unless($editable_cnt)
{
	$editable_cnt = 5;
}

for my $column_title(@column_titles)
	{
	my $renderer = Gtk3::CellRendererText->new;
	$renderer->signal_connect (edited => \&cell_edited, [$model, $rows]);
	$renderer->set_data (column => $current_column );
	
	$treeview->insert_column_with_attributes 
				(
				-1, $column_title, $renderer,
				text => $current_column,
				editable => $editable_cnt, 
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

1 ;
