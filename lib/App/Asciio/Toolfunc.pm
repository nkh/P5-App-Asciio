
package App::Asciio::Toolfunc ;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(physical_length write_file_utf8 make_vertical_text create_model add_columns);

use strict;
use warnings;
use Encode;
use utf8;

use Glib ':constants';
use Gtk3 -init;


#~ cnt number of cjk characters
#~ chinese u3400-u4db5 u4e00-u9fa5 
#~ Japanese u0800-u4e00(Japanese language is temporarily not supported because some symbols are in the Japanese range)
#~ Korean uac00-ud7ff
# ，ff0c 。3002！FF01？ff1f《300a》300b【3010】3011
our $EXPR_STR = qr/[\x{3400}-\x{4db5}]|[\x{4e00}-\x{9fa5}]|[\x{ac00}-\x{d7ff}]|\x{ff0c}|\x{3002}|\x{ff01}|\x{ff1f}|\x{300a}|\x{300b}|\x{3010}|\x{3011}/;

#-----------------------------------------------------------------------------

sub physical_length {
	my $convert = $_[0] ;
	return length($convert) + ($convert =~ s/$EXPR_STR/x/g) ;
}

#-----------------------------------------------------------------------------

sub write_file_utf8 {
	my ($name, $content) = @_ ;
	open my $fh, '>:encoding(utf8)', $name or die "couldn't create '$name': $!" ;
	print $fh $content ;
	close $fh ;
}

#-----------------------------------------------------------------------------

sub make_vertical_text
{
my ($text) = @_ ;

my @lines = map{[split '', $_]} split "\n", $text ;

my $vertical = '' ;
my $found_character = 1 ;
my $index = 0 ;

while($found_character)
	{
	my $line ;
	$found_character = 0 ;
	
	for(@lines)
		{
		if(defined $_->[$index])
			{
			$line.= $_->[$index] ;
			$found_character++ ;
			}
		else
			{
			$line .= ' ' ;
			}
		}
	
	$line =~ s/\s+$//; 
	$vertical .= "$line\n" if $found_character ;
	$index++ ;
	}

return $vertical ;
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
	$model->set($iter, map {$column++, $_} @{$row}) ;
	}

return $model;
}

#-----------------------------------------------------------------------------

sub add_columns 
{
my ($treeview, $rows, $no_show_flag) = @_ ;
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



1 ;