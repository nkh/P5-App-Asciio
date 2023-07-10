
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
		unicode_bold
		unicode_double_line
		unicode_with_filler_type1
		unicode_with_filler_type2
		unicode_with_filler_type3
		unicode_with_filler_type4
		unicode_hollow_dot
		unicode_math_parantheses
		))
		{
		push @context_menu_entries, [ "/box type/$_", \&App::Asciio::Boxes::change_type, { ELEMENT => $element, TYPE => $_ } ] ,
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

1 ;

