
package App::Asciio::GTK::Asciio ;

$|++ ;

use strict;
use warnings;

use Data::TreeDumper ;

use Glib ':constants';
use Gtk3 -init;

#------------------------------------------------------------------------------------------------------

sub display_popup_menu
{
my ($self, $event) = @_;

my ($popup_x, $popup_y) = @{$self}{'MOUSE_X', 'MOUSE_Y'} ;

my @menu_items ;

for my $element (@{$self->{ELEMENT_TYPES}})
	{
	(my $name_with_underscore = $element->{NAME}) =~ s/_/__/g ;
	
	push @menu_items, [ "/$name_with_underscore", undef , insert_generator($self, $element, $popup_x, $popup_y), 0 , '<Item>', undef] ;
	}

for my $menu_entry (@{$self->get_context_menu_entries($popup_x, $popup_y)})
	{
	my ($name, $sub, $data) = @{$menu_entry} ;
	(my $name_with_underscore = $name) =~ s/_/__/g ;
	
	push @menu_items, [ $name_with_underscore, undef , $self->menu_entry_wrapper($sub, $data), 0, '<Item>', undef],
	}

push @menu_items, 
	(
	['/File/open',     undef , sub { $self->run_actions_by_name('Open') ; },      0 , '<Item>', undef],
	['/File/save',     undef , sub { $self->run_actions_by_name('Save') ; },      0 , '<Item>', undef],
	['/File/save as',  undef , sub { $self->run_actions_by_name(['Save', 1]) ; }, 0 , '<Item>', undef],
	) ;

if($self->get_selected_elements(1) == 1)
	{
	push @menu_items, [ '/File/save stencil', undef , $self->menu_entry_wrapper(\&App::Asciio::save_stencil), 0 , '<Item>', undef ] ;
	}

my $menu = Gtk3::Menu->new() ;

insert_menu_items($menu, \@menu_items) ;

$menu->popup(undef, undef, undef, undef, $event->{BUTTON}, $event->{TIME}) ;
}

sub insert_menu_items
{
my ($root, $menu_entry_definitions) = @_ ;

my %menus ;

for my $menu_entry_definition (map { $_->[0] } sort { $a->[1] cmp $b->[1] } map { [$_, $_->[0]] } @$menu_entry_definitions)
	{
	my ($path, undef, $sub, undef, $item) = @$menu_entry_definition ;
	
	$path =~ s~^/~~ or die "Menu path '$path' doesn't start at root" ;
	my @path_elements = split m~/~, $path ;
	my $name = pop @path_elements ;
	
	my $container = $root ;
	
	for my $path_element (@path_elements)
		{
		if(exists $menus{$path_element})
			{
			$container = $menus{$path_element} ;
			}
		else
			{
			my $menu = Gtk3::Menu->new() ;
			$menu->show() ;
			$menus{$path_element} = $menu ;
			
			my $menu_item = Gtk3::MenuItem->new_with_label($path_element);
			$menu_item->show() ;
			$menu_item->set_submenu($menu) ;
			
			$container->append($menu_item) ;
			$container = $menu 
			}
		}
	
	my $menu_item=Gtk3::MenuItem->new($name) ;
	$menu_item->signal_connect('activate' => $sub);
	$menu_item->show() ;
	
	$container->append($menu_item) ;
	}
}

sub insert_generator 
{ 
my ($self, $element, $x, $y) = @_ ; 

return sub
	{
	my $new_element = $self->add_new_element_of_type($element, $x, $y) ;
	$self->deselect_all_elements() ;
	$self->select_elements(1, $new_element) ;
	$self->update_display();
	} ;
}

sub menu_entry_wrapper
{
my ($self, $sub, $data) = @_ ; 

return sub { $sub->($self, $data) ; } ;
}

#------------------------------------------------------------------------------------------------------

sub get_context_menu_entries
{
my ($self, $popup_x, $popup_y) = @_ ;
my @context_menu_entries ;

for my $context_menu_handler
	(
	map {$self->{ACTIONS}{$_}}
		grep { defined $self->{ACTIONS}{$_}{CONTEXT_MENU_SUB} }
			sort keys %{$self->{ACTIONS}}
	)
	{
	# print STDERR "Adding context menu from action '$context_menu_handler->{NAME}'.\n" ;
	
	if(defined $context_menu_handler->{CONTEXT_MENU_ARGUMENTS})
		{
		push @context_menu_entries, 
			$context_menu_handler->{CONTEXT_MENU_SUB}->
				(
				$self,
				$context_menu_handler->{CONTEXT_MENU_ARGUMENTS},
				$popup_x, $popup_y,
				) ;
		}
	else
		{
		push @context_menu_entries, $context_menu_handler->{CONTEXT_MENU_SUB}->($self, $popup_x, $popup_y) ;
		}
	}
	
return \@context_menu_entries ;
}

#------------------------------------------------------------------------------------------------------

1 ;
