
package App::Asciio::Actions::Box ;

use strict ;
use warnings ;
use utf8 ;

#----------------------------------------------------------------------------------------------

use Scalar::Util ;

use App::Asciio::Boxes ':const' ;

use App::Asciio::stripes::exec_box ;

#----------------------------------------------------------------------------------------------

sub context_menu
{
my ($self, $popup_x, $popup_y) = @_ ;
my @context_menu_entries ;

my @selected_elements = $self->get_selected_elements(1) ;
my $element = $selected_elements[0] ;

if(@selected_elements == 1 && $element->isa('App::Asciio::stripes::editable_box2'))
	{
	push @context_menu_entries, [ '/box element', \&box_selected_element, { ELEMENT => $element} ] ;
	
	for 
		(qw(
		dash
		dot
		star
		math_parantheses
		unicode
		unicode_imaginary
		unicode_bold
		unicode_bold_imaginary
		unicode_double
		unicode_with_filler_type1
		unicode_with_filler_type2
		unicode_with_filler_type3
		unicode_with_filler_type4
		unicode_hollow_dot
		unicode_math_parantheses
		))
		{
		push @context_menu_entries, [
			"/box attribute/$_",
			\&App::Asciio::Actions::ElementAttributes::change_attributes,
			[ 'editable_box2', $_ ],
			] ;
		}
	}

return @context_menu_entries ;
}

#----------------------------------------------------------------------------------------------

sub box_selected_element
{
my ($self, $data) = @_ ;

$self->create_undo_snapshot() ;

my $element_type = $data->{ELEMENT}->get_box_type() ;
my ($title, $text) = $data->{ELEMENT}->get_text() ;

for (0 .. $#$element_type)
	{
	next if $_ == TITLE_SEPARATOR && $title eq '' ;
	
	$element_type->[$_][DISPLAY] = 1 ;
	}

$data->{ELEMENT}->set_box_type($element_type) ;

$self->delete_connections_containing($data->{ELEMENT}) if $self->is_connected($data->{ELEMENT}) ;

$self->call_hook('CANONIZE_CONNECTIONS', $self->{CONNECTIONS}, $self->get_character_size()) ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub image_box_change
{
my ($self, $operation, $factor_step) = @_ ; 

$self->create_undo_snapshot() ;

my @selected_elements = $self->get_selected_elements(1) ;

for my $element (grep { ref($_) eq 'App::Asciio::GTK::Asciio::stripes::image_box' } @selected_elements)
	{
	if    ($operation eq 'gray_scale') { $element->switch_images($factor_step) ; } 
	elsif ($operation eq 'alpha')      { $element->switch_images(undef, $factor_step) ; } 
	elsif ($operation eq 'default')    { $element->switch_images() ; }
	}

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub image_box_change_gray_scale
{
my ($self, $gray_scale_factor_step) = @_ ; 

image_box_change($self, 'gray_scale', $gray_scale_factor_step) ;
}

#----------------------------------------------------------------------------------------------

sub image_box_change_alpha
{
my ($self, $alpha_factor_step) = @_ ; 

image_box_change($self, 'alpha', $alpha_factor_step) ;
}

#----------------------------------------------------------------------------------------------

sub image_box_revert_to_default_image
{
my ($self) = @_ ; 

image_box_change($self, 'default') ;
}

#----------------------------------------------------------------------------------------------

1 ;

