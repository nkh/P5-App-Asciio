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

my %menu_map = (
	triangle_up => [
		[ 'normal', 'triangle_up_normal' ],
		[ 'dot',    'triangle_up_dot'    ],
	],
	triangle_down => [
		[ 'normal', 'triangle_down_normal' ],
		[ 'dot',    'triangle_down_dot'    ],
	],
	rhombus => [
		[ 'normal',                  'rhombus_normal' ],
		[ 'normal_with_filler_star', 'rhombus_normal_with_filler_star' ],
		[ 'unicode_slash',           'rhombus_unicode_slash' ],
		[ 'sparseness',              'rhombus_sparseness' ],
	],
	ellipse => [
		[ 'normal',                  'ellipse_normal' ],
		[ 'normal_with_filler_star', 'ellipse_normal_with_filler_star' ],
	],
);

for my $class_name (keys %menu_map)
	{
	if (@selected_elements == 1 && ("App::Asciio::stripes::$class_name" eq ref $element))
		{
		for my $entry (@{ $menu_map{$class_name} })
			{
			my ($label, $attribute) = @$entry ;
			push @context_menu_entries, [
				"/box attribute/$label",
				\&App::Asciio::Actions::ElementAttributes::change_attributes,
				[ $class_name, $attribute ],
				];
			}
		}
	}

return @context_menu_entries ;
}

#----------------------------------------------------------------------------------------------

1 ;

