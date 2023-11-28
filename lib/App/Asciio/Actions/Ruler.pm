
package App::Asciio::Actions::Ruler ;

use strict ; use warnings ;

use Clone ;

#----------------------------------------------------------------------------------------------

sub add_ruler
{
my ($self, $data_argument) = @_ ;

$self->create_undo_snapshot() ;

my $data = defined $data_argument ? Clone::clone($data_argument) : {TYPE => 'VERTICAL', POSITION => $self->{MOUSE_X}}  ;

if(! defined $data->{POSITION})
	{
	if($data->{TYPE} eq 'VERTICAL')
		{
		$data->{POSITION} = $self->{MOUSE_X} ;
		}
	else
		{
		$data->{POSITION} = $self->{MOUSE_Y} ;
		}
	}

$self->add_ruler_lines({NAME => 'from context menu', %{$data},}) ;

$self->update_display();
}

#----------------------------------------------------------------------------------------------

sub remove_ruler
{
my ($self, $to_remove) = @_ ;

$self->create_undo_snapshot() ;

$self->remove_ruler_lines
	(
	$to_remove // 
		(
		{ TYPE => 'VERTICAL',   POSITION => $self->{MOUSE_X} },
		{ TYPE => 'HORIZONTAL', POSITION => $self->{MOUSE_Y} },
		)
	) ;

$self->update_display();
}

#----------------------------------------------------------------------------------------------

sub context_menu
{
my ($self, $popup_x, $popup_y) = @_ ;

my $vertical =   {TYPE => 'VERTICAL',   POSITION => $popup_x} ;
my $horizontal = {TYPE => 'HORIZONTAL', POSITION => $popup_y} ;

my @context_menu_entries ;

push @context_menu_entries, 
	$self->exists_ruler_line($vertical) 
		? ["/Asciio/Ruler/remove vertical ruler",   \&remove_ruler, $vertical]
		: ["/Asciio/Ruler/add vertical ruler",      \&add_ruler, $vertical   ] ;

push @context_menu_entries, 
	$self->exists_ruler_line($horizontal) 
		? ["/Asciio/Ruler/remove horizontal ruler", \&remove_ruler, $horizontal]
		: ["/Asciio/Ruler/add horizontal ruler",    \&add_ruler, $horizontal   ] ;

return @context_menu_entries ;
}

#----------------------------------------------------------------------------------------------

1 ;

