
#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Add box' => ['000-b', \&add_element, ['stencils/asciio/box', 0]],
	'Add shrink box' => ['00S-B', \&add_element, ['stencils/asciio/shrink_box', 1]],
	'Add text' => ['000-t', \&add_element, ['stencils/asciio/text', 0]],
	'Add if' => ['000-i', \&add_element, ['stencils/asciio/boxes/if', 1]],
	'Add process' => ['000-p', \&add_element, ['stencils/asciio/boxes/process', 1]],
	'Add arrow' => ['000-a', \&add_element, ['stencils/asciio/wirl_arrow', 0]],
	'Add angled arrow' => ['00S-A', \&add_element, ['stencils/asciio/angled_arrow', 0]],
	) ;
	
#----------------------------------------------------------------------------------------------

sub add_element
{
my ($self, $name_and_edit) = @_ ;

$self->create_undo_snapshot() ;

$self->deselect_all_elements() ;

my ($name, $edit) = @{$name_and_edit} ;

my $element = $self->add_new_element_named($name, $self->{MOUSE_X}, $self->{MOUSE_Y}) ;

$element->edit($self) if $edit;

$self->update_display() ;
} ;
