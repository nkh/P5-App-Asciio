package App::Asciio::Actions::Elements ;

use strict ;
use warnings ;
use Encode ;
use utf8 ;

use File::Slurp ;
use File::HomeDir ;

use App::Asciio::Actions::Box ;
use App::Asciio::Actions::Multiwirl ;
use App::Asciio::Toolfunc ;


#----------------------------------------------------------------------------------------------

sub add_element
{
my ($self, $name_and_edit) = @_ ;

$self->create_undo_snapshot() ;

$self->deselect_all_elements() ;

my ($name, $edit) = @{$name_and_edit} ;

my $element = $self->add_new_element_named($name, $self->{MOUSE_X}, $self->{MOUSE_Y}) ;

if($edit)
	{
	$element->edit($self);
	$self->{EDIT_SEMAPHORE} = 3 if((defined $self->{GTK_POPUP_BOX_TYPE}) && ($self->{GTK_POPUP_BOX_TYPE} != 0)) ;
	}

$self->select_elements(1, $element);

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub make_unicode
{
my ($self) = @_ ;

$self->create_undo_snapshot() ;

for my $element (@{$self->{ELEMENTS}}) 
	{
	if($element->isa('App::Asciio::stripes::editable_box2'))
		{
		App::Asciio::Actions::Box::change_box_type($self, { ELEMENT => $element, TYPE => 'unicode' }, 0) ;
		}
	
	if($element->isa('App::Asciio::stripes::section_wirl_arrow'))
		{
		unless(defined $element->{NAME} && $element->{NAME} =~ /line/)
			{
			App::Asciio::Actions::Multiwirl::change_arrow_type($self, { ELEMENT => $element, TYPE => 'unicode' }, 0) ;
			}
		}

	if($element->isa('App::Asciio::stripes::angled_arrow'))
		{
		App::Asciio::Actions::Multiwirl::change_arrow_type($self, { ELEMENT => $element, TYPE => 'angled_arrow_unicode' }, 0) ;
		}
	}

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub make_ascii
{
my ($self) = @_ ;

$self->create_undo_snapshot() ;

for my $element (@{$self->{ELEMENTS}}) 
	{
	if($element->isa('App::Asciio::stripes::editable_box2'))
		{
		App::Asciio::Actions::Box::change_box_type($self, { ELEMENT => $element, TYPE => 'dash' }, 0) ;
		}
	
	if($element->isa('App::Asciio::stripes::section_wirl_arrow'))
		{
		unless(defined $element->{NAME} && $element->{NAME} =~ /line/)
			{
			App::Asciio::Actions::Multiwirl::change_arrow_type($self, { ELEMENT => $element, TYPE => 'dash' }, 0) ;
			}
		}

	if($element->isa('App::Asciio::stripes::angled_arrow'))
		{
		App::Asciio::Actions::Multiwirl::change_arrow_type($self, { ELEMENT => $element, TYPE => 'angled_arrow_dash' }, 0) ;
		}
	}

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub add_help_box
{
my ($self) = @_ ;

$self->create_undo_snapshot() ;

my $help_path = File::HomeDir->my_home() . '/.config/Asciio/help_box' ;

if(-e $help_path)
	{
	my $help_text = read_file($help_path, {bin_mode => ':utf8'});
	
	Encode::_utf8_on($help_text);
	$help_text =~ s/\t/$self->{TAB_AS_SPACES}/g;
	$help_text =~ s/\r//g;
	
	my $new_element = new App::Asciio::stripes::editable_box2
						({
						TEXT_ONLY => $help_text,
						TITLE => '',
						EDITABLE => 0,
						RESIZABLE => 0,
						}) ;
	
	@$new_element{'X', 'Y', 'SELECTED'} = ($self->{MOUSE_X}, $self->{MOUSE_Y}, 0) ;
	$self->add_elements($new_element) ;
	
	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------
sub delete_cross_elements_cache
{
my ($self) = @_;
$self->delete_cross_elements_cache();
}

#----------------------------------------------------------------------------------------------

sub create_line
{
my ($self, $line_type) = @_;
$self->create_undo_snapshot();

$self->create_line($line_type);

$self->update_display();
}

#----------------------------------------------------------------------------------------------

1 ;

