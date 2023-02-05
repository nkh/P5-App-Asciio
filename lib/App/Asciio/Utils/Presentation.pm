
use strict;
use warnings;

#------------------------------------------------------------------------------------------------------

sub load_diagram
{
my ($x_offset, $y_offset, $file) = @_ ;

return 
	compose
		(
		clear_all(),
		insert_diagram($x_offset, $y_offset, $file),
		) ;
}

sub insert_diagram
{
my ($x_offset, $y_offset, $file) = @_ ;

return
	sub
		{
		my ($self) = @_ ;
		$self->run_actions_by_name(['Insert', $x_offset, $y_offset, $file]) ;
		$self->deselect_all_elements() ;
		} ;
}

sub box
{
my ($x, $y, $title, $text, $select) = @_ ;

return
	sub
		{
		my ($self) = @_ ;
		
		my $element = $self->add_new_element_named('stencils/asciio/box', $x, $y) ;
		$element->set_text($title, $text) ;
		
		$self->select_elements($select, $element) ;
		
		return $element ;
		} ;
}

sub clear_all
{
return 
	sub
		{
		my ($self) = @_ ;
		$self->select_all_elements() ;
		$self->delete_elements($self->get_selected_elements(1)) ;
		} ;
}

sub compose
{
my (@elements) = @_ ;

return
	sub
		{
		my ($self) = @_ ;
		
		for my $element (@elements) 
			{
			$element->($self) ;
			}
		} ;
}

sub new_slide_single_box_at
{
my ($x_,$y, $text) = @_ ;

return 
	compose
		(
		clear_all(),
		box($x_,$y, '', $text, 1),
		) ;
}

#------------------------------------------------------------------------------------------------------

1 ;
