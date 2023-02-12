
use List::Util qw(min max) ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Export to clipboard & primary as ascii' => [['C00-e', '00S-Y'], \&export_to_clipboard_as_ascii] ,
	'Import from clipboard to box'           => [['C0S-E', '000-p'], \&import_from_clipboard_to_box] ,
	'Import from primary to box'             => ['0A0-e', \&import_from_primary_to_box  ] ,
	) ;

#----------------------------------------------------------------------------------------------

sub export_to_clipboard_as_ascii
{
my ($self) = @_ ;

my $ascii = $self->transform_elements_to_ascii_buffer($self->get_selected_elements(1)) ;

Gtk3::Clipboard::get($Gdk::SELECTION_CLIPBOARD)->set_text($ascii);

# also put in selection  --  DH
Gtk3::Clipboard::get($Gdk::SELECTION_PRIMARY)->set_text($ascii);
}

#----------------------------------------------------------------------------------------------

sub import_from_clipboard_to_box
{
my ($self) = @_ ;


my $ascii = Gtk3::Clipboard::get($Gdk::SELECTION_CLIPBOARD)->wait_for_text();

my $element = $self->add_new_element_named('Stencils/Asciio/box', $self->{MOUSE_X}, $self->{MOUSE_Y}) ;

$element->set_text('', $ascii) ;

$self->select_elements(1, $element) ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub import_from_primary_to_box
{
my ($self) = @_ ;

my $ascii = Gtk3::Clipboard::get($Gdk::SELECTION_PRIMARY)->wait_for_text();

my $element = $self->add_new_element_named('Stencils/Asciio/box', $self->{MOUSE_X}, $self->{MOUSE_Y}) ;

$element->set_text('', $ascii) ;

$self->select_elements(1, $element) ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------


