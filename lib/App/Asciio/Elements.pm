
package App::Asciio ;

$|++ ;

use strict;
use warnings;
use utf8;
use Carp ;

use Data::TreeDumper ;
use File::Slurper qw(read_text) ;
use Clone;
use List::Util qw(min max) ;
use List::MoreUtils qw(any minmax first_value) ;
use Readonly ;

use App::Asciio::Connections ;

use App::Asciio::GTK::Asciio::stripes::editable_exec_box ;
use App::Asciio::GTK::Asciio::stripes::editable_box2 ;
use App::Asciio::GTK::Asciio::stripes::rhombus ;
use App::Asciio::GTK::Asciio::stripes::ellipse ;
use App::Asciio::GTK::Asciio::stripes::editable_arrow2 ;
use App::Asciio::GTK::Asciio::stripes::wirl_arrow ;
use App::Asciio::GTK::Asciio::stripes::angled_arrow ;
use App::Asciio::GTK::Asciio::stripes::section_wirl_arrow ;

use App::Asciio::GTK::Asciio::Dialogs ;
use App::Asciio::GTK::Asciio::DnD ;
use App::Asciio::GTK::Asciio::Menues ;

#-----------------------------------------------------------------------------

sub set_modified_state { my ($self, $state) = @_ ; $self->{MODIFIED} = $state ; }

#-----------------------------------------------------------------------------

sub get_modified_state { my ($self) = @_ ; $self->{MODIFIED} ; }

#-----------------------------------------------------------------------------

sub get_group_color
{
# cycle through color to give visual clue to user
my ($self) = @_ ;

my $colors = $self->{COLORS}{group_colors}[$self->{NEXT_GROUP_COLOR}] ;

$self->{NEXT_GROUP_COLOR}++ ;
$self->{NEXT_GROUP_COLOR} = 0 if $self->{NEXT_GROUP_COLOR} >= scalar(@{$self->{COLORS}{group_colors}}) ;

return ($colors) ;
}

#-----------------------------------------------------------------------------

sub add_ruler_lines
{
my ($self, @lines) = @_ ;
push @{$self->{RULER_LINES}}, @lines ;

$self->{MODIFIED }++ ;
}

sub remove_ruler_lines
{
my ($self, @ruler_lines_to_remove) = @_ ;

my %removed ;

for my $ruler_line_to_remove (@ruler_lines_to_remove)
	{
	for my $ruler_line (@{$self->{RULER_LINES}})
		{
		if
			(
			   $ruler_line->{TYPE}     eq $ruler_line_to_remove->{TYPE}
			&& $ruler_line->{POSITION} == $ruler_line_to_remove->{POSITION}
			)
			{
			$removed{$ruler_line} ++ ;
			}
		}
	}

$self->{RULER_LINES} = [ grep { ! exists $removed{$_} } @{$self->{RULER_LINES}} ] ;
}

sub exists_ruler_line
{
my ($self, @ruler_lines_to_check) = @_ ;

my $exists = 0 ;

for my $ruler_line_to_check (@ruler_lines_to_check)
	{
	for my $ruler_line (@{$self->{RULER_LINES}})
		{
		if
			(
			$ruler_line->{TYPE} eq $ruler_line_to_check->{TYPE}
			&& $ruler_line->{POSITION} == $ruler_line_to_check->{POSITION}
			)
			{
			$exists++ ;
			last ;
			}
		}
	}

return $exists ;
}

#-----------------------------------------------------------------------------

sub add_new_element_named
{
my ($self, $element_name, $x, $y) = @_ ;

my $element_index = $self->{ELEMENT_TYPES_BY_NAME}{$element_name} ;

if(defined $element_index)
	{
	return add_new_element_of_type($self, $self->{ELEMENT_TYPES}[$element_index], $x, $y) ;
	}
else
	{
	croak "add_new_element_named: can't create element named '$element_name'!\n" ;
	}
}

#-----------------------------------------------------------------------------

sub add_new_element_of_type
{
my ($self, $element, $x, $y) = @_ ;

my $new_element = Clone::clone($element) ;

@$new_element{'X', 'Y', 'SELECTED'} = ($x, $y, 0) ;
$self->add_elements($new_element) ;

return($new_element) ;
}

#-----------------------------------------------------------------------------

sub set_element_position
{
my ($self, $element, $x, $y) = @_ ;

@$element{'X', 'Y'} = ($x, $y) ;
}

#-----------------------------------------------------------------------------

sub set_elements_position
{
my ($self, $elements, $x, $y) = @_ ;

@$_{'X', 'Y'} = ($x, $y) for @$elements ;
}

#-----------------------------------------------------------------------------

sub add_element_at
{
my ($self, $element, $x, $y) = @_ ;

$self->add_element_at_no_connection($element, $x, $y) ;
$self->connect_elements($element) ;

$element
}

sub add_element_at_no_connection
{
my ($self, $element, $x, $y) = @_ ;

$self->set_element_position($element, $x, $y) ;
$self->add_elements_no_connection($element) ;

$element
}

#-----------------------------------------------------------------------------

sub add_elements
{
my ($self, @elements) = @_ ;

$self->add_elements_no_connection(@elements) ;
$self->connect_elements(@elements) ;
}

sub add_elements_no_connection
{
my ($self, @elements) = @_ ;
push @{$self->{ELEMENTS}}, @elements ;

$self->{MODIFIED }++ ;
}

#-----------------------------------------------------------------------------

sub unshift_elements
{
my ($self, @elements) = @_ ;
unshift @{$self->{ELEMENTS}}, @elements ;
$self->{MODIFIED }++ ;
}

#-----------------------------------------------------------------------------

sub move_elements
{
my ($self, $x_offset, $y_offset, @elements) = @_ ;

$self->blink_element(grep { $_->is_frozen } @elements) ;

@elements = grep { !$_->is_frozen() } @elements ;

my %selected_elements = map { $_ => 1} @elements ;

for my $element (@elements)
	{
	@$element{'X', 'Y'} = ($element->{X} + $x_offset, $element->{Y} + $y_offset) ;
	
	# handle arrow element
	my (@current_element_connections, %used_connectors) ;
	
	if($self->is_connected($element))
		{
		# disconnect current connections if it is not connected to another elements we are moving
		# connectees move their connected along
		
		@current_element_connections = $self->get_connections_containing($element)  ,
		
		my (@connections_to_delete, @connections_to_keep) ;
		for my $current_element_connection (@current_element_connections)
			{
			if(exists $selected_elements{$current_element_connection->{CONNECTEE}})
				{
				$used_connectors{$current_element_connection->{CONNECTOR}{NAME}}++ ;
				push @connections_to_keep, $current_element_connection ;
				}
			else
				{
				push @connections_to_delete, $current_element_connection ;
				}
			}
			
		$self->delete_connections(@connections_to_delete) ;
		@current_element_connections = @connections_to_keep ;
		}
		
	# connect to new elements if the connection doesn't already exist
	# and connection not already done with one of the elements being moved
	my @new_connections = 
		grep 
			{ # connector already used to connect to a moved element
			! exists $used_connectors{$_->{CONNECTOR}{NAME}}
			} 
			grep 
				{ # connection to that element already exists, don't reconnect to moved element
				! exists $selected_elements{$_->{CONNECTEE}}
				} 
				$self->get_possible_connections($element) ;
	
	$self->add_connections(@new_connections) ;
	
	# handle box  element
	for my $connection ($self->get_connections_with_connectee($element))
		{
		# move connected with connectees
		if (exists $selected_elements{$connection->{CONNECTED}})
			{
			# arrow is part of the selection being moved
			}
		else
			{
			my ($x_offset, $y_offset, $width, $height, $new_connector) = 
				$connection->{CONNECTED}->move_connector
					(
					$connection->{CONNECTOR}{NAME},
					$x_offset, $y_offset
					) ;
					
			$connection->{CONNECTED}{X} += $x_offset ;
			$connection->{CONNECTED}{Y} += $y_offset;
			
			# the connection point has also changed
			$connection->{CONNECTOR} = $new_connector ;
			$connection->{FIXED}++ ;
			
			#find the other connectors belonging to this connected
			for my $other_connection (grep{ ! $_->{FIXED}} @{$self->{CONNECTIONS}})
				{
				# move them relatively to their previous position
				if($connection->{CONNECTED} == $other_connection->{CONNECTED})
					{
					my ($named_connection) = $other_connection->{CONNECTED}->get_named_connection($other_connection->{CONNECTOR}{NAME}) ;
					
					$other_connection->{CONNECTOR} = $named_connection ;
					$other_connection->{FIXED}++ ;
					}
				}
			}
		}
	
	for my $connection (@{$self->{CONNECTIONS}})
		{
		delete $connection->{FIXED} ;
		}
	
	$self->{MODIFIED }++ ;
	delete $element->{CACHE}{SELECTION_COORDINATES} ;
	}
}

#-----------------------------------------------------------------------------

sub resize_element
{
my ($self, $reference_x, $reference_y, $new_x, $new_y, $selected_element, $connector_name) = @_;

my ($x_offset, $y_offset, undef, undef, $resized_connector_name) = 
	$selected_element->resize($reference_x, $reference_y, $new_x, $new_y, undef, $connector_name) ;

$selected_element->{X} += $x_offset ;
$selected_element->{Y} += $y_offset;

# arrows
$self->delete_connections_containing($selected_element) if $self->is_connected($selected_element) ;
$self->connect_elements($selected_element) ; # connect to new elements if any

# non arrows
for my $connection ($self->get_connections_with_connectee($selected_element))
	{
	my ($named_connection) = $selected_element->get_named_connection($connection->{CONNECTION}{NAME}) ;
		# {X =>  ..., Y => ..., NAME => same_as_apssed as argumnent} ;
	
	if(defined $named_connection)
		{
		# move arrow connector to match the element connection
		my ($x_offset, $y_offset, $width, $height, $new_connector) = 
			$connection->{CONNECTED}->move_connector
				(
				$connection->{CONNECTOR}{NAME},
				$named_connection->{X} - $connection->{CONNECTION}{X},
				$named_connection->{Y}- $connection->{CONNECTION}{Y}
				) ;
		
		$connection->{CONNECTED}{X} += $x_offset ;
		$connection->{CONNECTED}{Y} += $y_offset ;
		
		# the connection point has also changed
		$connection->{CONNECTOR} = $new_connector ;
		$connection->{CONNECTION} = $named_connection ;
		
		$connection->{FIXED}++ ;
		
		# find the other connectors belonging to this arrow
		for my $other_connection (grep{ ! $_->{FIXED}} @{$self->{CONNECTIONS}})
			{
			# move them relatively to their previous position
			if($connection->{CONNECTED} == $other_connection->{CONNECTED})
				{
				my ($named_connection) = $other_connection->{CONNECTED}->get_named_connection($other_connection->{CONNECTOR}{NAME}) ;
				
				$other_connection->{CONNECTOR} = $named_connection ;
				$other_connection->{FIXED}++ ;
				}
			}
			
		for my $connection (@{$self->{CONNECTIONS}})
			{
			delete $connection->{FIXED} ;
			}
		}
	else
		{
		$self->delete_connections($connection) ;
		}
	}

return($x_offset, $y_offset, $resized_connector_name) ;
}

#-----------------------------------------------------------------------------

sub move_elements_to_front
{
my ($self, @elements) = @_ ;

my %elements_to_move = map {$_ => 1} @elements ;
my @new_element_list ;

for(@{$self->{ELEMENTS}})
	{
	push @new_element_list, $_ unless (exists $elements_to_move{$_}) ;
	}

$self->{ELEMENTS} = [@new_element_list, @elements] ;
} ;

#----------------------------------------------------------------------------------------------

sub move_elements_to_back
{	
my ($self, @elements) = @_ ;

my %elements_to_move = map {$_ => 1} @elements ;
my @new_element_list ;

for(@{$self->{ELEMENTS}})
	{
	push @new_element_list, $_ unless (exists $elements_to_move{$_}) ;
	}

$self->{ELEMENTS} = [@elements, @new_element_list] ;
} ;

#-----------------------------------------------------------------------------

sub delete_selected_elements
{
my($self, @elements) = @_ ;

my %elements_to_delete = map {$_, 1} grep { defined $_ } $self->get_selected_elements(1) ;

for my $element (@{$self->{ELEMENTS}})
	{
	if(exists $elements_to_delete{$element})
		{
		$self->delete_connections_containing($element) ;
		$element = undef ;
		}
	}

@{$self->{ELEMENTS}} = grep { defined $_} @{$self->{ELEMENTS}} ;

$self->{MODIFIED }++ ;
}

#-----------------------------------------------------------------------------

sub blink_element
{
my ($self, @elements) = @_ ;

$self->{BLINK_ELEMENTS}{$_}++ for @elements ;
}


sub delete_elements
{
my($self, @elements) = @_ ;

$self->blink_element(grep { defined $_ && ($_->is_background_element && $_->is_frozen) } @elements) ;

my %elements_to_delete = map {$_, 1} grep { defined $_ && !($_->is_background_element && $_->is_frozen) } @elements ;

for my $element (@{$self->{ELEMENTS}})
	{
	if(exists $elements_to_delete{$element})
		{
		$self->delete_connections_containing($element) ;
		$element = undef ;
		}
	}

@{$self->{ELEMENTS}} = grep { defined $_} @{$self->{ELEMENTS}} ;

$self->{MODIFIED }++ ;
}

#-----------------------------------------------------------------------------

sub edit_element
{
my ($self, $selected_element) = @_ ;

$selected_element->edit($self) ;

# handle connections
if($self->is_connected($selected_element))
	{
	# disconnect current connections
	$self->delete_connections_containing($selected_element) ;
	}

$self->connect_elements($selected_element) ; # connect to new elements if any

for my $connection ($self->get_connections_containing($selected_element))
	{
	# all connection where the selected element is the connectee
	
	my ($named_connection) = $selected_element->get_named_connection($connection->{CONNECTION}{NAME}) ;
	
	if(defined $named_connection)
		{
		my ($x_offset, $y_offset, $width, $height, $new_connector) = 
			$connection->{CONNECTED}->move_connector
				(
				$connection->{CONNECTOR}{NAME},
				$named_connection->{X} - $connection->{CONNECTION}{X},
				$named_connection->{Y}- $connection->{CONNECTION}{Y}
				) ;
				
		$connection->{CONNECTED}{X} += $x_offset ;
		$connection->{CONNECTED}{Y} += $y_offset;
		
		# the connection point has also changed
		$connection->{CONNECTOR} = $new_connector ;
		$connection->{CONNECTION} = $named_connection ;
		
		$connection->{FIXED}++ ;
		
		#find the other connectors belonging to this connected
		for my $other_connection (grep{ ! $_->{FIXED}} @{$self->{CONNECTIONS}})
			{
			# move them relatively to their previous position
			if($connection->{CONNECTED} == $other_connection->{CONNECTED})
				{
				my ($named_connection) = $other_connection->{CONNECTED}->get_named_connection($other_connection->{CONNECTOR}{NAME}) ;
				
				$other_connection->{CONNECTOR} = $named_connection ;
				$other_connection->{FIXED}++ ;
				}
			}
		
		delete $_->{FIXED} for @{$self->{CONNECTIONS}} ;
		}
	else
		{
		$self->delete_connections($connection) ;
		}
	}

$self->{MODIFIED }++ ;
}

#-----------------------------------------------------------------------------

sub get_selected_elements
{
my ($self, $state) = @_ ;

$state //= 1 ;

return
	(
	grep 
		{
		if($state)
			{
			exists $_->{SELECTED} && $_->{SELECTED} != 0
			}
		else
			{
			! exists $_->{SELECTED} || $_->{SELECTED} == 0
			}
		} @{$self->{ELEMENTS}}
	) ;
}

#-----------------------------------------------------------------------------

sub any_selected_elements
{
my ($self) = @_ ;

return(any {$_->{SELECTED}} @{$self->{ELEMENTS}}) ;
}

#-----------------------------------------------------------------------------

sub select_elements
{
my ($self, $state, @elements) = @_ ;

my %groups_to_select ;

for my $element (@elements) 
	{
	if($state)
		{
		$element->{SELECTED} = ++$self->{SELECTION_INDEX} ;
		}
	else
		{
		$element->{SELECTED} = 0 ;
		}
	
	if(exists $element->{GROUP} && defined $element->{GROUP}[-1])
		{
		$groups_to_select{$element->{GROUP}[-1]}++ ;
		}
	}

# select groups
for my $element (@{$self->{ELEMENTS}}) 
	{
	if
		(
		exists $element->{GROUP} && defined $element->{GROUP}[-1]
		&& exists $groups_to_select{$element->{GROUP}[-1]}
		)
		{
		if($state)
			{
			$element->{SELECTED} = ++$self->{SELECTION_INDEX} ;
			}
		else
			{
			$element->{SELECTED} = 0 ;
			}
		}
	}

delete $self->{SELECTION_INDEX} unless $self->get_selected_elements(1) ;
}

#-----------------------------------------------------------------------------

sub select_all_elements_by_search_words
{
my ($self) = @_ ;

my $search_words = $self->display_edit_dialog("input search words", '', $self);

for my $element (@{$self->{ELEMENTS}}) 
	{
	$self->select_elements(1, $element) if ($self->transform_elements_to_ascii_buffer($element) =~ m/$search_words/i);
	}
}

#-----------------------------------------------------------------------------

sub select_all_elements_by_search_words_ignore_group
{
my ($self) = @_ ;

my $search_words = $self->display_edit_dialog("input search words", '', $self);

for my $element (@{$self->{ELEMENTS}}) 
	{
	$element->{SELECTED} = ++$self->{SELECTION_INDEX} if ($self->transform_elements_to_ascii_buffer($element) =~ m/$search_words/i);
	}
}

#-----------------------------------------------------------------------------

sub select_all_elements
{
my ($self) = @_ ;

$self->select_elements(1, @{$self->{ELEMENTS}}) ;
}

#-----------------------------------------------------------------------------

sub deselect_all_elements
{
my ($self) = @_ ;

$self->select_elements(0, @{$self->{ELEMENTS}}) ;
}

#-----------------------------------------------------------------------------

sub select_elements_flip
{
my ($self, @elements) = @_ ;

for my $element (@elements) 
	{
	$self->select_elements($element->{SELECTED} ? 0 : 1, $element)  ;
	}

delete $self->{SELECTION_INDEX} unless $self->get_selected_elements(1) ;
}

#-----------------------------------------------------------------------------

sub is_element_selected
{
my ($self, $element) = @_ ;

$element->{SELECTED} ;
}

#-----------------------------------------------------------------------------

sub is_over_element
{
my ($self, $element, $x, $y, $field) = @_ ;

$field //= 0 ;

# keep elements intersecting the area around the $x and $y 
my ($emin_x, $emin_y, $emax_x, $emax_y) = @{ $element->{EXTENTS} } ;

if	
	(
	   ($emin_y + $element->{Y} > $y + $field)
	|| ($emax_y + $element->{Y}  < $y - $field)
	|| ($emin_x + $element->{X}  > $x + $field)
	|| ($emax_x + $element->{X}  < $x - $field)
	)
	{
	return 0 ;
	}

my $is_under = 0 ;

for my $stripe (@{$element->get_stripes()})
	{
	my $stripe_x = $element->{X} + $stripe->{X_OFFSET} ;
	my $stripe_y = $element->{Y} + $stripe->{Y_OFFSET} ;
	
	if
		(
		   $stripe_x - $field <= $x   && $x < $stripe_x + $stripe->{WIDTH} + $field
		&& $stripe_y - $field <= $y && $y < $stripe_y + $stripe->{HEIGHT} + $field
		) 
		{
		$is_under++ ;
		last ;
		}
	}

return($is_under) ;
}

#-----------------------------------------------------------------------------

sub element_completely_within_rectangle
{
my ($self, $element, $rectangle) = @_ ;

my ($start_x, $start_y) = ($rectangle->{START_X}, $rectangle->{START_Y}) ;
my $width               = $rectangle->{END_X} - $rectangle->{START_X} ;
my $height              = $rectangle->{END_Y} - $rectangle->{START_Y};

if($width < 0)
	{
	$width *= -1 ;
	$start_x -= $width ;
	}

if($height < 0)
	{
	$height *= -1 ;
	$start_y -= $height ;
	}

my $is_within = 1 ;

for my $stripe (@{$element->get_stripes()})
	{
	my $stripe_x = $element->{X} + $stripe->{X_OFFSET} ;
	my $stripe_y = $element->{Y} + $stripe->{Y_OFFSET} ;
	
	if
	(
	    $start_x <= $stripe_x
	&& ($stripe_x + $stripe->{WIDTH})  <= $start_x +$width
	&& $start_y <= $stripe_y 
	&& ($stripe_y + $stripe->{HEIGHT}) <= $start_y + $height
	) 
		{
		}
	else
		{
		$is_within = 0 ;
		last
		}
	}

return($is_within) ;
}

#-----------------------------------------------------------------------------

sub get_selected_elements_extents
{
my ($self, @elements) = @_ ;

@elements = $self->get_selected_elements(1) unless @elements ;

my ($xs, $ys, $xe, $ye, $has_extents) = (10_000, 10_000, 0, 0, 0) ;

for (grep { ref($_) !~ /arrow/ } @elements)
	{
	$has_extents++ ;
	
	$xs = min($xs//10_000, $_->{X} + $_->{EXTENTS}[0]) ;
	$ys = min($ys//10_000, $_->{Y} + $_->{EXTENTS}[1]) ;
	$xe = max($xe//0, $_->{X} + $_->{EXTENTS}[2]) ;
	$ye = max($ye//0, $_->{Y} + $_->{EXTENTS}[3]) ;
	}

($xs // 0, $ys // 0, $xe // 0, $ye // 0, $has_extents) ;
}

#-----------------------------------------------------------------------------

sub pixel_to_character_x
{
my ($self, @pixels) = @_ ;

my ($character_width, $character_height) = $self->get_character_size() ;

map {int($_ / $character_width)} @pixels ;
}

#-----------------------------------------------------------------------------

sub pixel_to_character_y
{
my ($self, @pixels) = @_ ;

my ($character_width, $character_height) = $self->get_character_size() ;

map {int($_ / $character_height)} @pixels ;
}

#-----------------------------------------------------------------------------

sub closest_character
{
my ($self, $x, $y) = @_ ;

my ($character_width, $character_height) = $self->get_character_size() ;

my $character_x = int($x / $character_width) ;
my $character_y = int($y / $character_height) ;

return($character_x, $character_y) ;
}

#-----------------------------------------------------------------------------

1 ;

