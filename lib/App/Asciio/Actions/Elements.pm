package App::Asciio::Actions::Elements ;

#----------------------------------------------------------------------------------------------

sub add_element
{
my ($self, $name_and_edit) = @_ ;

$self->create_undo_snapshot() ;

$self->deselect_all_elements() ;

my ($name, $edit) = @{$name_and_edit} ;

my $element = $self->add_new_element_named($name, $self->{MOUSE_X}, $self->{MOUSE_Y}) ;

$element->edit($self) if $edit;

$self->select_elements(1, $element);

$self->update_display() ;
} ;

#----------------------------------------------------------------------------------------------

1 ;

