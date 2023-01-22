
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
	$self->{COLORS} =
		{
		background => [0.04, 0.04, 0.04],
		grid => [0.12, 0.12, 0.12],
		ruler_line => [0.10, 0.23, 0.31],
		selected_element_background => [0.10, 0.16, 0.20],
		element_background => [0.10, 0.10, 0.10],
		element_foreground => [0.59, 0.59, 0.59] ,
		selection_rectangle => [0.43, 0.00, 0.43],
		test => [0.00, 1.00, 1.00],
		group_colors =>
			[
			[[0.98, 0.86, 0.74], [0.98, 0.96, 0.93]],
			[[0.71, 0.98, 0.71], [0.94, 0.98, 0.94]],
			[[0.72, 0.86, 0.98], [0.95, 0.96, 0.98]],
			[[0.54, 0.98, 0.98], [0.92, 0.98, 0.98]],
			[[0.77, 0.89, 0.77], [0.93, 0.95, 0.93]],
			],
			
		connection => [0.55, 0.25, 0.08],
		connection_point => [0.51, 0.39, 0.20],
		connector_point => [0.12, 0.56, 1.00],
		new_connection => [1.00, 0.00, 0.00],
		extra_point => [0.59, 0.43, 50], 
		
		mouse_rectangle => [0.90, 0.20, 0.20],
		} ;
	}
else
	{
	$self->{COLOR_SCHEME} = 'system' ;
	$self->{COLORS} =
		{
		background => [1.00, 1.00, 1.00],
		grid => [0.89, 0.92, 1.00],
		ruler_line => [0.33, 0.61, 0.88],
		element_background => [0.98, 0.98, 1],
		element_foreground => [0.00, 0.00, 0.00] ,
		selected_element_background => [0.70, 0.95, 1.00],
		selection_rectangle => [1.00, 0.00, 1.00],
		test => [0.00, 1.00, 1.00],
		
		group_colors =>
			[
			[[0.98, 0.86, 0.74], [0.98, 0.96, 0.93]],
			[[0.71, 0.98, 0.71], [0.94, 0.98, 0.94]],
			[[0.72, 0.86, 0.98], [0.95, 0.96, 0.98]],
			[[0.54, 0.98, 0.98], [0.92, 0.98, 0.98]],
			[[0.77, 0.89, 0.77], [0.93, 0.95, 0.93]],
			],
			
		connection => [0.55, 0.25, 0.08],
		connection_point => [0.90, 0.77, 0.52],
		connector_point => [0.12, 0.56, 1.00],
		new_connection => [1.00, 0.00, 0.00],
		extra_point => [0.90, 0.77, 0.52],
		
		mouse_rectangle => [0.90, 0.20, 0.20],
		} ;
	}

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

1 ;

