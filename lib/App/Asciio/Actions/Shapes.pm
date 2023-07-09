package App::Asciio::Actions::Shapes ;

use strict ; use warnings ;

use App::Asciio::Boxes ':const' ;

#----------------------------------------------------------------------------------------------

sub context_menu
{
my ($self, $popup_x, $popup_y) = @_ ;
my @context_menu_entries ;

my @selected_elements = $self->get_selected_elements(1) ;
my $element = $selected_elements[0] ;

if (@selected_elements == 1 && ('App::Asciio::stripes::triangle_up' eq ref $element))
	{
	push @context_menu_entries, 
		[ '/box type/normal',                  \&App::Asciio::Boxes::change_type, { ELEMENT => $element, TYPE => 'triangle_up_normal' }              ], 
		[ '/box type/dot',                     \&App::Asciio::Boxes::change_type, { ELEMENT => $element, TYPE => 'triangle_up_dot' }                 ] ;
	}

if (@selected_elements == 1 && ('App::Asciio::stripes::triangle_down' eq ref $element))
	{
	push @context_menu_entries, 
		[ '/box type/normal',                  \&App::Asciio::Boxes::change_type, { ELEMENT => $element, TYPE => 'triangle_down_normal' }            ], 
		[ '/box type/dot',                     \&App::Asciio::Boxes::change_type, { ELEMENT => $element, TYPE => 'triangle_down_dot' }               ] ;
	}

if(@selected_elements == 1 && 'App::Asciio::stripes::rhombus' eq ref $element)
	{
	push @context_menu_entries, 
		[ '/box type/normal',                  \&App::Asciio::Boxes::change_type, { ELEMENT => $element, TYPE => 'rhombus_normal' }                  ], 
		[ '/box type/normal_with_filler_star', \&App::Asciio::Boxes::change_type, { ELEMENT => $element, TYPE => 'rhombus_normal_with_filler_star' } ], 
		[ '/box type/unicode_slash',           \&App::Asciio::Boxes::change_type, { ELEMENT => $element, TYPE => 'rhombus_unicode_slash' }           ], 
		[ '/box type/sparseness',              \&App::Asciio::Boxes::change_type, { ELEMENT => $element, TYPE => 'rhombus_sparseness' }              ] ;
	}
if(@selected_elements == 1 && 'App::Asciio::stripes::ellipse' eq ref $element)
	{
	push @context_menu_entries, 
		[ '/box type/normal',                  \&App::Asciio::Boxes::change_type, { ELEMENT => $element, TYPE => 'ellipse_normal' }                  ], 
		[ '/box type/normal_with_filler_star', \&App::Asciio::Boxes::change_type, { ELEMENT => $element, TYPE => 'ellipse_normal_with_filler_star' } ] ;
	}

return @context_menu_entries ;
}

#----------------------------------------------------------------------------------------------

1 ;

