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

sub copy_attributes
{
my ($asciio) = @_ ;

my @selected_elements = $asciio->get_selected_elements(1);

@{$asciio->{COPIED_ATTRIBUTES}}{'NAME', 'TYPE'} = $selected_elements[0]->get_attributes() if @selected_elements == 1 ;
}

#----------------------------------------------------------------------------------------------

sub paste_attributes
{
my ($asciio, @elements) = @_ ;

return unless defined $asciio->{COPIED_ATTRIBUTES} ;

change_attributes($asciio, [ @{$asciio->{COPIED_ATTRIBUTES}}{'NAME', 'TYPE'}]) ;
}

#----------------------------------------------------------------------------------------------

sub change_attributes
{
my ($asciio, $args) = @_ ;
my ($class, $type) = @$args;

$asciio->create_undo_snapshot() ;

my @elements = grep { $_->isa('App::Asciio::stripes::' . $class) } $asciio->get_selected_elements(1) ;

for(@elements)
	{
	$_->change_attributes($type) ;
	delete $_->{CACHE} ;
	}

$asciio->update_display() ;
}

#----------------------------------------------------------------------------------------------
1 ;

