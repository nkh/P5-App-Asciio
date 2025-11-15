package App::Asciio::Actions::ElementAttributes ;

use strict ; use warnings ;

use App::Asciio::Actions::Git ;
use Clone ;

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

sub copy_element_attributes
{
my ($asciio) = @_ ;

my @selected_elements = $asciio->get_selected_elements(1);

@{$asciio->{COPIED_ATTRIBUTES}}{'NAME', 'TYPE'} = $selected_elements[0]->get_attributes() if @selected_elements == 1 ;
}

#----------------------------------------------------------------------------------------------

sub paste_element_attributes
{
my ($asciio, @elements) = @_ ;

return unless defined $asciio->{COPIED_ATTRIBUTES} ;

$asciio->create_undo_snapshot() ;

my @selected_elements = (@elements) ? @elements : $asciio->get_selected_elements(1) ;

for(@selected_elements)
	{
	my ($type, $name) = @{$asciio->{COPIED_ATTRIBUTES}}{'TYPE', 'NAME'} ;
	
	if($name =~ /arrow/)
		{
		App::Asciio::Arrows::change_type($asciio, {ELEMENT => $_, USER_TYPE => $type}, 0) ;
		}
	else
		{
		App::Asciio::Boxes::change_type($asciio, {ELEMENT => $_, USER_TYPE => $type}, 0) ;
		}
	
	delete $_->{CACHE} ;
	}

$asciio->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub change_element_type
{
my ($asciio, $element_type, $element_class, $change_type_function, $use_ref, @elements) = @_ ;

$asciio->create_undo_snapshot() ;

my @selected_elements = (@elements) ? @elements : $asciio->get_selected_elements(1) ;

for my $element (grep { $use_ref ? ref $_ eq $element_class : $_->isa($element_class) } @selected_elements)
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
change_element_type($asciio, $element_type, 'App::Asciio::stripes::editable_box2', \&App::Asciio::Boxes::change_type, 0) ;
}

#----------------------------------------------------------------------------------------------

sub wirl_arrow_elements_change_type
{
my ($asciio, $element_type) = @_ ;
change_element_type($asciio, $element_type, 'App::Asciio::stripes::section_wirl_arrow', \&App::Asciio::Arrows::change_type, 0) ;
}

#----------------------------------------------------------------------------------------------

sub angled_arrow_elements_change_type
{
my ($asciio, $element_type) = @_ ;
change_element_type($asciio, $element_type, 'App::Asciio::stripes::angled_arrow', \&App::Asciio::Arrows::change_type, 0) ;
}

#----------------------------------------------------------------------------------------------

sub ellipse_elements_change_type
{
my ($asciio, $element_type) = @_ ;
change_element_type($asciio, $element_type, 'App::Asciio::stripes::ellipse', \&App::Asciio::Boxes::change_type, 1) ;
}

#----------------------------------------------------------------------------------------------

sub rhombus_elements_change_type
{
my ($asciio, $element_type) = @_ ;
change_element_type($asciio, $element_type, 'App::Asciio::stripes::rhombus', \&App::Asciio::Boxes::change_type, 1) ;
}

#----------------------------------------------------------------------------------------------

sub triangle_up_elements_change_type
{
my ($asciio, $element_type) = @_ ;
change_element_type($asciio, $element_type, 'App::Asciio::stripes::triangle_up', \&App::Asciio::Boxes::change_type, 1) ;
}

#----------------------------------------------------------------------------------------------

sub triangle_down_elements_change_type
{
my ($asciio, $element_type) = @_ ;
change_element_type($asciio, $element_type, 'App::Asciio::stripes::triangle_down', \&App::Asciio::Boxes::change_type, 1) ;
}

#----------------------------------------------------------------------------------------------
1 ;

