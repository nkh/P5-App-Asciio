
package App::Asciio::Actions::Asciio ;

use strict ; use warnings ;

use App::Asciio::Actions::Git ;
use Clone ;

#----------------------------------------------------------------------------------------------

sub context_menu
{
my ($self, $popup_x, $popup_y) = @_ ;

my @selected_elements = $self->get_selected_elements(1) ;
my $element = $selected_elements[0] ;

my @context_menu_entries ;

if(@selected_elements == 1)
	{
	if 
		(
		$element->isa('App::Asciio::stripes::editable_box2')
		|| 'App::Asciio::stripes::rhombus' eq ref $element
		|| 'App::Asciio::stripes::ellipse' eq ref $element
		|| 'App::Asciio::stripes::triangle_down' eq ref $element
		|| 'App::Asciio::stripes::triangle_up' eq ref $element
		)
		{
		push @context_menu_entries,
			[ '/rotate text', sub { $element->rotate_text() ; $self->update_display() ; } ],
			[
			$element->is_autoconnect_enabled() ? '/disable connectors' :  '/enable connectors', 
			
			sub 
				{
				$self->create_undo_snapshot() ;
				$element->enable_autoconnect(! $element->is_autoconnect_enabled()) ;
				$self->update_display() ;
				}
			] ,
			[
			$element->is_optimize_enabled() ? '/disable optimize' :  '/enable optimize', 
			
			sub 
				{
				$self->create_undo_snapshot() ;
				$element->enable_optimize(! $element->is_optimize_enabled()) ;
				$self->update_display() ;
				}
			] ;
		
		$element->is_border_connection_allowed()
			? push @context_menu_entries, ["/disable connect inside borders", sub { $element->allow_border_connection(0) ; }]
			: push @context_menu_entries, 
				[
				"/connect inside borders",
				sub 
					{
					$self->create_undo_snapshot() ;
					$element->enable_autoconnect(0) ;
					$element->allow_border_connection(1) ;
					$self->update_display() ;
					}
				] ;
		
		$element->is_auto_shrink()
			? push @context_menu_entries, ["/disable auto shrink", sub { $element->flip_auto_shrink() ; }]
			: push @context_menu_entries, ["/enable auto shrink",  sub { $element->shrink() ; $element->flip_auto_shrink() ; }] ;
		}
	}
else
	{
	if(@selected_elements)
		{
		push @context_menu_entries,
			[ '/make ASCII',   \&App::Asciio::Actions::ElementAttributes::make_selection_unicode, 0 ],
			[ '/make Unicode', \&App::Asciio::Actions::ElementAttributes::make_selection_unicode, 1 ] ;
		}
	}

return @context_menu_entries ;
}

#----------------------------------------------------------------------------------------------

1 ;

