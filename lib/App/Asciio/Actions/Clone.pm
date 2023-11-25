
package App::Asciio::Actions::Clone ;

use App::Asciio::Actions::Elements ;

use strict ; use warnings ;

my $clone_element_to_insert  ;
my $clone_element_overlay ;

sub clone_set_overlay
{
my ($asciio, $element_definition) = @_ ;

my $element_name = $element_definition->[0] ;
my $element_index = $asciio->{ELEMENT_TYPES_BY_NAME}{$element_name} ;

if(defined $element_index)
	{
	$clone_element_to_insert = $element_definition ;
	
	$clone_element_overlay = Clone::clone($asciio->{ELEMENT_TYPES}[$element_index]) ;
	$asciio->set_element_position($clone_element_overlay, $asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) ;
	
	$asciio->update_display ;
	}
}

sub clone_get_overlay
{
my ($asciio, $UI_type, $gc, $widget_width, $widget_height, $character_width, $character_height) = @_ ;

# # we can draw directly
# if($UI_type eq 'GUI')
# 	{
# 	my $surface = Cairo::ImageSurface->create('argb32', 50, 50) ;
# 	my $gco = Cairo::Context->create($surface) ;
	
# 	my $background_color = $asciio->get_color('cross_filler_background') ;
# 	$gco->set_source_rgb(@$background_color) ;
	
# 	$gco->rectangle(0, 0, $character_width, $character_height) ;
# 	$gco->fill() ;
	
# 	$gc->set_source_surface($surface, ($asciio->{MOUSE_X} - 1 ) * $character_width, ($asciio->{MOUSE_Y} - 1) * $character_height);
# 	$gc->paint() ; 
# 	}

$asciio->set_element_position($clone_element_overlay, $asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) ;
$clone_element_overlay
}

sub clone_enter
{
my ($asciio) = @_ ;

my $stripes_group = App::Asciio::Actions::ElementsManipulation::create_stripes_group_from_selected_elements($asciio, 0, 1) ;

if($stripes_group)
	{
	App::Asciio::Actions::Clipboard::copy_to_clipboard($asciio) ;
	
	$clone_element_to_insert = 'SELECTION' ;
	$clone_element_overlay = $stripes_group ;
	
	$asciio->set_element_position($stripes_group, $asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) ;
	}
else
	{
	clone_set_overlay($asciio, ['Asciio/box', 0]) ;
	}

$asciio->hide_cursor ;

$asciio->set_overlays_sub(\&clone_get_overlay) ;

$asciio->update_display ;
}

sub clone_escape { my ($asciio) = @_ ; $asciio->set_overlays_sub(undef) ; $asciio->show_cursor ; $asciio->update_display ; }
sub clone_mouse_motion { my ($asciio, $event) = @_ ; App::Asciio::Actions::Mouse::mouse_motion($asciio, $event) ; $asciio->update_display() ; }

sub clone_add_element
{
my ($asciio) = @_ ;

if($clone_element_to_insert eq 'SELECTION')
	{
	App::Asciio::Actions::Clipboard::insert_from_clipboard($asciio) ;
	}
else
	{
	App::Asciio::Actions::Elements::add_element($asciio, $clone_element_to_insert) ;
	}
}

#----------------------------------------------------------------------------------------------

1 ;

