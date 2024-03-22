
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
		App::Asciio::Boxes::change_type($asciio, { ELEMENT => $_, TYPE => $unicode ? 'unicode' : 'dash'}, 0) ;
		}
	elsif($_->isa('App::Asciio::stripes::section_wirl_arrow'))
		{
		App::Asciio::Arrows::change_type($asciio, { ELEMENT => $_, TYPE => $unicode ? 'unicode' : 'dash'}, 0) ;
		}
	elsif($_->isa('App::Asciio::stripes::angled_arrow'))
		{
		App::Asciio::Arrows::change_type($asciio, { ELEMENT => $_, TYPE => $unicode ? 'angled_arrow_unicode' : 'angled_arrow_dash' }, 0) ;
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
sub elements_change_type
{
my ($asciio, $element_type, $element_class, $change_type_function, $use_ref, @elements) = @_ ;

$asciio->create_undo_snapshot() ;

my @elements_for_change_type = (@elements) ? @elements : $asciio->get_selected_elements(1) ;

for my $element (grep { $use_ref ? ref $_ eq $element_class : $_->isa($element_class) } @elements_for_change_type)
{
	$change_type_function->($asciio, { ELEMENT => $element, TYPE => $element_type }, 0) ;
	delete $element->{CACHE} ;
}

$asciio->update_display() ;
}

#----------------------------------------------------------------------------------------------
sub box_elements_change_type
{
my ($asciio, $element_type) = @_ ;
$asciio->{CACHE}{LAST_BOX_TYPE} = $element_type ;
elements_change_type($asciio, $element_type, 'App::Asciio::stripes::editable_box2', \&App::Asciio::Boxes::change_type, 0) ;
}

#----------------------------------------------------------------------------------------------
sub wirl_arrow_elements_change_type
{
my ($asciio, $element_type) = @_ ;
$asciio->{CACHE}{LAST_WIRL_ARROW_TYPE} = $element_type ;
elements_change_type($asciio, $element_type, 'App::Asciio::stripes::section_wirl_arrow', \&App::Asciio::Arrows::change_type, 0) ;
}

#----------------------------------------------------------------------------------------------
sub angled_arrow_elements_change_type
{
my ($asciio, $element_type) = @_ ;
elements_change_type($asciio, $element_type, 'App::Asciio::stripes::angled_arrow', \&App::Asciio::Arrows::change_type, 0) ;
}

#----------------------------------------------------------------------------------------------
sub ellipse_elements_change_type
{
my ($asciio, $element_type) = @_ ;
elements_change_type($asciio, $element_type, 'App::Asciio::stripes::ellipse', \&App::Asciio::Boxes::change_type, 1) ;
}

#----------------------------------------------------------------------------------------------
sub rhombus_elements_change_type
{
my ($asciio, $element_type) = @_ ;
elements_change_type($asciio, $element_type, 'App::Asciio::stripes::rhombus', \&App::Asciio::Boxes::change_type, 1) ;
}

#----------------------------------------------------------------------------------------------
sub triangle_up_elements_change_type
{
my ($asciio, $element_type) = @_ ;
elements_change_type($asciio, $element_type, 'App::Asciio::stripes::triangle_up', \&App::Asciio::Boxes::change_type, 1) ;
}

#----------------------------------------------------------------------------------------------
sub triangle_down_elements_change_type
{
my ($asciio, $element_type) = @_ ;
elements_change_type($asciio, $element_type, 'App::Asciio::stripes::triangle_down', \&App::Asciio::Boxes::change_type, 1) ;
}

#----------------------------------------------------------------------------------------------

1 ;

