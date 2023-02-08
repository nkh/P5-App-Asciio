
package App::Asciio::Actions::Colors ;

#----------------------------------------------------------------------------------------------

sub change_elements_colors
{
my ($self, $is_background) = @_ ;

my ($color) = $self->get_color_from_user([0, 0, 0]) ;

$self->create_undo_snapshot() ;

for my $element($self->get_selected_elements(1))
	{
	$is_background
		? $element->set_background_color($color) 
		: $element->set_foreground_color($color) ;
	}
	
$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub change_background_color
{
my ($self) = @_ ;

my ($color) = $self->get_color_from_user([0, 0, 0]) ;

$self->create_undo_snapshot() ;

delete $self->{CACHE}{GRID} ;
$self->{COLORS}{background} = $color ;
	
$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub change_grid_color
{
my ($self) = @_ ;

my ($color) = $self->get_color_from_user([0, 0, 0]) ;

$self->create_undo_snapshot() ;

delete $self->{CACHE}{GRID} ;
$self->{COLORS}{grid} = $color ;
	
$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub flip_color_scheme
{
my ($self) = @_ ;
$self->invalidate_rendering_cache() ;

$self->{COLOR_SCHEME} = 'system' unless exists $self->{COLOR_SCHEME} ;

if($self->{COLOR_SCHEME} eq 'system')
	{
	$self->{COLOR_SCHEME} = 'night' ;
	$self->{COLORS} = $self->{COLOR_SCHEMES}{night} ;
	}
else
	{
	$self->{COLOR_SCHEME} = 'system' ;
	$self->{COLORS} = $self->{COLOR_SCHEMES}{system} ;
	}

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

1 ;

