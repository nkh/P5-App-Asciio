
package App::Asciio::Text ;

$|++ ;

use strict;
use warnings;

use Data::TreeDumper ;
use IO::Prompter ;

#------------------------------------------------------------------------------------------------------

sub display_popup_menu
{
my ($self, $event) = @_;

my ($popup_x, $popup_y) = @{$self}{'MOUSE_X', 'MOUSE_Y'} ;

my @menu_items ;

for my $element (@{$self->{ELEMENT_TYPES}})
	{
	(my $name_with_underscore = $element->{NAME}) =~ s/_/__/g ;
	$name_with_underscore = ucfirst $name_with_underscore ;
	
	push @menu_items, [ "/$name_with_underscore", undef , insert_generator($self, $element, $popup_x, $popup_y), 0 , '<Item>', undef],
	}

for my $menu_entry (@{$self->get_context_menu_entries($popup_x, $popup_y)})
	{
	my($name, $sub, $data) = @{$menu_entry} ;
	(my $name_with_underscore = $name) =~ s/_/__/g ;
	
	push @menu_items, [ $name_with_underscore, undef , $self->menu_entry_wrapper($sub, $data), 0, '<Item>', undef],
	}

push @menu_items, 
	(
	['/File/open',     undef , sub {$self->run_actions_by_name('Open') ;},      0 , '<Item>', undef],
	['/File/save',     undef , sub {$self->run_actions_by_name('Save') ;},      0 , '<Item>', undef],
	[ '/File/save as', undef , sub {$self->run_actions_by_name(['Save', 1]) ;}, 0 , '<Item>', undef],
	) ;

use App::Asciio::Io ;
if($self->get_selected_elements(1) == 1)
	{
	push @menu_items, [ '/File/save stencil', undef , $self->menu_entry_wrapper(\&App::Asciio::save_stencil), 0 , '<Item>', undef ] ;
	}

print "\e[2J\e[H\e[?25h" ;

my ($menu, $menu_lookup) = ({}, {}) ;

insert_menu_items($menu, \@menu_items, $menu_lookup) ;

my $result = prompt -1, 'popup menu ...', -menu => $menu, '> ';

if($result)
	{
	my $action = $menu_lookup->{"$result"} ;
	my (undef, undef, $sub) = @$action ;
	
	$sub->() ;
	}

$self->update_display() ;
}

sub insert_menu_items
{
my ($root, $menu_entry_definitions, $menu_lookup) = @_ ;

my $lookup_index = 0 ;

for my $menu_entry_definition (map { $_->[0] } sort { $a->[1] cmp $b->[1] } map { [$_, $_->[0]] } @$menu_entry_definitions)
	{
	$lookup_index++ ;
	
	my ($path, undef, $sub, undef, $item, undef) = @$menu_entry_definition ;
	
	$path =~ s~^/~~ or die "Menu path doesn't start at root" ;
	my @path_elements = split m~/~, $path ;
	my $name = pop @path_elements ;
	
	my $parent = my $container = $root ;
	my $last_path_element = $path_elements[-1] // $path ;
	
	for my $path_element (@path_elements)
		{
		last unless 'HASH' eq ref $container ;
		
		if(exists $container->{$path_element})
			{
			$parent = $container ;
			$container = $container->{$path_element} ;
			}
		else
			{
			$parent = $container ;
			$container = $container->{$path_element} = {} ;
			}
		}
	
	$menu_lookup->{"$name [$lookup_index]"} = $menu_entry_definition ;
	
	if('ARRAY' eq ref $parent->{$last_path_element})
		{
		push @{$parent->{$last_path_element}}, "$name [$lookup_index]"
		}
	elsif('HASH' eq ref $parent->{$last_path_element})
		{
		$parent->{$last_path_element} = [ "$name [$lookup_index]"] ;
		}
	else
		{
		$parent->{"$name [$lookup_index]"} = "$name [$lookup_index]" ;
		}
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
	map {$self->{CURRENT_ACTIONS}{$_}}
		grep 
			{
			'HASH' eq ref $self->{CURRENT_ACTIONS}{$_} # not a sub actions definition
			&& defined $self->{CURRENT_ACTIONS}{$_}{CONTEXT_MENU_SUB}
			} sort keys %{$self->{CURRENT_ACTIONS}}
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
	
return(\@context_menu_entries) ;
}

#------------------------------------------------------------------------------------------------------

1 ;
