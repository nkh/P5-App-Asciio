
package App::Asciio::Actions::Ruler ;

#----------------------------------------------------------------------------------------------

use Clone ;

#----------------------------------------------------------------------------------------------

sub add_ruler
{
my ($self, $data_argument) = @_ ;

add_named_ruler($self, "from context menu", $data_argument) ;
}

#----------------------------------------------------------------------------------------------

sub add_named_ruler
{
my ($self, $name, $data_argument) = @_ ;

$self->create_undo_snapshot() ;

my $data ;

if(! defined $data_argument)
	{
	$data = {TYPE => 'VERTICAL', POSITION => $self->{MOUSE_X}} 
	}
else
	{
	$data = Clone::clone$data_argument ;
	}

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

$self->add_ruler_lines({NAME => $name, %{$data},}) ;

$self->update_display();
}


#----------------------------------------------------------------------------------------------
sub add_cross_x_ruler
{
my ($self, $data_argument) = @_ ;

my @cross_x_rulers = grep {$_->{NAME} eq "CROSS_X"} @{$self->{RULER_LINES}} ;
if(scalar(@cross_x_rulers) > 1)
	{
	remove_ruler_with_name($self, "CROSS_X");
	}

add_named_ruler($self, "CROSS_X", $data_argument) ;
}

#----------------------------------------------------------------------------------------------
sub add_cross_y_ruler
{
my ($self, $data_argument) = @_ ;

my @cross_y_rulers = grep {$_->{NAME} eq "CROSS_Y"} @{$self->{RULER_LINES}} ;
if(scalar(@cross_y_rulers) > 1)
	{
	remove_ruler_with_name($self, "CROSS_Y");
	}

add_named_ruler($self, "CROSS_Y", $data_argument) ;
}

#----------------------------------------------------------------------------------------------

sub remove_ruler
{
my ($self, $data) = @_ ;

$data = {TYPE => 'VERTICAL', POSITION => $self->{MOUSE_X}} unless defined $data ;

$self->create_undo_snapshot() ;
$self->remove_ruler_lines($data) ;
$self->update_display();
}

#----------------------------------------------------------------------------------------------

sub remove_ruler_with_name
{
my ($self, $name) = @_ ;

$self->remove_ruler_lines_with_name($name) ;
}

#----------------------------------------------------------------------------------------------

sub rulers_context_menu
{
my ($self, $popup_x, $popup_y) = @_ ;
my @context_menu_entries ;

my ($x, $y) = ($popup_x, $popup_y) ;

my $vertical = {TYPE => 'VERTICAL', POSITION => $x} ;
my $horizontal = {TYPE => 'HORIZONTAL', POSITION => $y} ;

if($self->exists_ruler_line($vertical))
	{
	push @context_menu_entries, ["/Ruler/remove vertical ruler", \&remove_ruler,  $vertical] ;
	}
else
	{
	push @context_menu_entries, ["/Ruler/add normal vertical ruler", \&add_ruler,  $vertical] ;
	push @context_menu_entries, ["/Ruler/add cross mode x vertical ruler", \&add_cross_x_ruler,  $vertical] ;
	}
	
if($self->exists_ruler_line($horizontal))
	{
	push @context_menu_entries, ["/Ruler/remove horizontal ruler", \&remove_ruler,  $horizontal] ;
	}
else
	{
	push @context_menu_entries, ["/Ruler/add normal horizontal ruler", \&add_ruler,  $horizontal] ;
	push @context_menu_entries, ["/Ruler/add cross mode y horizontal ruler", \&add_cross_y_ruler, $horizontal] ;
	}

return(@context_menu_entries) ;
}

#----------------------------------------------------------------------------------------------


1 ;
