package App::Asciio::Actions::ElementAttributes ;

use strict ; use warnings ;

#----------------------------------------------------------------------------------------------

sub make_selection_unicode
{
my ($asciio, $unicode) = @_ ;

change_attributes($asciio,['editable_box2'      => $unicode ? 'unicode' : 'dash']) ;
change_attributes($asciio,['section_wirl_arrow' => $unicode ? 'unicode' : 'dash']) ;
change_attributes($asciio,['angled_arrow'       => $unicode ? 'angled_arrow_unicode' : 'angled_arrow_dash']) ;
}

#----------------------------------------------------------------------------------------------

sub copy_attributes
{
my ($asciio) = @_ ;

my @selected_elements = $asciio->get_selected_elements(1);

if(@selected_elements == 1)
	{
	@{$asciio->{COPIED_ATTRIBUTES}}{'NAME', 'TYPE'} = $selected_elements[0]->get_attributes() ;
	@{$asciio->{COPIED_CONTROL_ATTRIBUTES}}{'CLASS', 'ATTRIBUTES'} = $selected_elements[0]->get_control_attributes() ;
	}
}

#----------------------------------------------------------------------------------------------

sub paste_attributes
{
my ($asciio, @elements) = @_ ;

return unless defined $asciio->{COPIED_ATTRIBUTES} ;

change_attributes($asciio, [ @{$asciio->{COPIED_ATTRIBUTES}}{'NAME', 'TYPE'}], \@elements) ;
}

#----------------------------------------------------------------------------------------------

sub change_attributes
{
my ($asciio, $class_and_type, $elements) = @_ ;
my ($class, $type) = @$class_and_type ;

$asciio->create_undo_snapshot() ;

my @matching_elements = grep { $_->isa('App::Asciio::stripes::' . $class) }
	((defined $elements && @$elements) ? @$elements : $asciio->get_selected_elements(1)) ;

for(@matching_elements)
	{
	$_->change_attributes($type) ;
	delete $_->{CACHE} ;
	}

$asciio->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub paste_control_attributes
{
my ($asciio, @elements) = @_ ;

return unless defined $asciio->{COPIED_CONTROL_ATTRIBUTES} ;

change_control_attributes($asciio, [ @{$asciio->{COPIED_CONTROL_ATTRIBUTES}}{'CLASS', 'ATTRIBUTES'}], \@elements) ;
}

#----------------------------------------------------------------------------------------------

sub change_control_attributes
{
my ($asciio, $class_and_attributes, $elements) = @_ ;
my ($class, $attributes) = @$class_and_attributes ;

$asciio->create_undo_snapshot() ;

my @matching_elements = grep { $_->isa($class) }
	((defined($elements) && @$elements) ? @$elements : $asciio->get_selected_elements(1)) ;

for(@matching_elements)
	{
	$_->change_control_attributes($attributes) ;
	delete $_->{CACHE} ;
	}

$asciio->update_display() ;
}

#----------------------------------------------------------------------------------------------
1 ;

