
package App::Asciio::Actions::Asciio ;

use strict ; use warnings ;

use App::Asciio::Actions::Git ;

#----------------------------------------------------------------------------------------------

sub context_menu
{
my ($self, $popup_x, $popup_y) = @_ ;

my @selected_elements = $self->get_selected_elements(1) ;
my $element = $selected_elements[0] ;

my @context_menu_entries ;

push @context_menu_entries, [ '/Git/' . $_, \&App::Asciio::Actions::Git::set_default_connector, $_ ] for @{$self->{GIT_MODE_CONNECTOR_CHAR_LIST}} ;

push @context_menu_entries, 
	[ '/Asciio/Git/use dash arrow',     \&App::Asciio::Actions::Git::set_default_arrow, 'angled_arrow_dash'    ] ,
	[ '/Asciio/Git/use unicode arrow',  \&App::Asciio::Actions::Git::set_default_arrow, 'angled_arrow_unicode' ] ;

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
			$element->is_autoconnect_enabled() ? '/disable autoconnection' :  '/enable autoconnection', 
			
			sub 
				{
				$self->create_undo_snapshot() ;
				$element->enable_autoconnect(! $element->is_autoconnect_enabled()) ;
				$self->update_display() ;
				}
			] ;
		
		$element->is_border_connection_allowed()
			? push @context_menu_entries, ["/disable border connection", sub { $element->allow_border_connection(0) ; }]
			: push @context_menu_entries, ["/enable border connection",  sub { $element->allow_border_connection(1) ; }] ;
		
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
			[ '/make ASCII',   \&make_selection_unicode, 0 ],
			[ '/make Unicode', \&make_selection_unicode, 1 ] ;
		}
	}

return @context_menu_entries ;
}

#----------------------------------------------------------------------------------------------

sub make_selection_unicode
{
my ($asciio, $unicode) = @_ ;

$asciio->create_undo_snapshot() ;

for ($asciio->get_selected_elements(1))
	{
	if($_->isa('App::Asciio::stripes::editable_box2'))
		{
		App::Asciio::Boxes::change_type($asciio, { ELEMENT => $_, TYPE => $unicode ? 'unicode' : 'dash'}, 0)
		}
	elsif($_->isa('App::Asciio::stripes::section_wirl_arrow'))
		{
		App::Asciio::Arrows::change_type($asciio, { ELEMENT => $_, TYPE => $unicode ? 'unicode' : 'dash'}, 0)
		}
	elsif($_->isa('App::Asciio::stripes::angled_arrow'))
		{
		App::Asciio::Arrows::change_type($asciio, { ELEMENT => $_, TYPE => $unicode ? 'angled_arrow_unicode' : 'angled_arrow_dash' }, 0)
		}
	#elsif
		# || 'App::Asciio::stripes::rhombus' eq ref $element
		# || 'App::Asciio::stripes::ellipse' eq ref $element
		# || 'App::Asciio::stripes::triangle_down' eq ref $element
		# || 'App::Asciio::stripes::triangle_up' eq ref $element)
	
	delete $_->{CACHE} ;
	}

$asciio->update_display() ;
}

#----------------------------------------------------------------------------------------------

1 ;

