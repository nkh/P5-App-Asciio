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

use File::Slurp ;
use File::HomeDir ;

sub add_help_box
{
my ($self) = @_ ;

$self->create_undo_snapshot() ;

my $help_path = File::HomeDir->my_home() . '/.config/Asciio/help_box' ;

if(-e $help_path)
	{
	my $new_element = new App::Asciio::stripes::editable_box2
						({
						TEXT_ONLY => join('', read_file($help_path)),
						TITLE => '',
						EDITABLE => 0,
						RESIZABLE => 0,
						}) ;
	
	@$new_element{'X', 'Y', 'SELECTED'} = ($self->{MOUSE_X}, $self->{MOUSE_Y}, 0) ;
	$self->add_elements($new_element) ;
	
	$self->update_display() ;
	}
} ;

#----------------------------------------------------------------------------------------------

1 ;

