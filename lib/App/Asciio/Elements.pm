
package App::Asciio ;

$|++ ;

use strict;
use warnings;
use utf8;
use Carp ;

use Data::Dumper ;
use Data::TreeDumper ;
use File::Slurp ;
use Clone;
use List::Util qw(min max) ;
use List::MoreUtils qw(any minmax first_value) ;
use Readonly ;

use App::Asciio::Connections ;

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
			$ruler_line->{TYPE} eq $ruler_line_to_remove->{TYPE}
			&& $ruler_line->{POSITION} == $ruler_line_to_remove->{POSITION}
			)
			{
			$removed{$ruler_line} ++ ;
			}
		}
	}

$self->{RULER_LINES} = [grep {! exists $removed{$_}} @{$self->{RULER_LINES}} ] ;
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

sub add_element_at
{
my ($self, $element, $x, $y) = @_ ;

$self->add_element_at_no_connection($element, $x, $y) ;
$self->connect_elements($element) ;
}

sub add_element_at_no_connection
{
my ($self, $element, $x, $y) = @_ ;

$self->set_element_position($element, $x, $y) ;
$self->add_elements_no_connection($element) ;
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
{
my %makeup_elements_cache;

sub create_makeup_element
{
my ($self, $char, $X, $Y) = @_;

unless(exists($makeup_elements_cache{$char}))
{
	my $init_element = create_box(NAME => 'make_up_character', TEXT_ONLY => $char, AUTO_SHRINK => 1, MAKE_UP_FLAG => 1, RESIZABLE => 0, EDITABLE => 0);
	$init_element->enable_autoconnect(0);
	$makeup_elements_cache{$char} = Clone::clone($init_element);
}


my $new_element = Clone::clone($makeup_elements_cache{$char});
@$new_element{'X', 'Y', 'SELECTED'} = ($X, $Y, 0);
$self->add_elements($new_element);
}
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
	for my $connection ($self->get_connected($element))
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
					my ($new_connector) = # in characters relative to element origin
							$other_connection->{CONNECTED}->get_named_connection($other_connection->{CONNECTOR}{NAME}) ;
					
					$other_connection->{CONNECTOR} = $new_connector ;
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

# handle connections
if($self->is_connected($selected_element))
	{
	# disconnect current connections
	$self->delete_connections_containing($selected_element) ;
	}

$self->connect_elements($selected_element) ; # connect to new elements if any

for my $connection ($self->get_connected($selected_element))
	{
	# all connection where the selected element is the connectee
	
	my ($new_connection) = # in characters relative to element origin
	$selected_element->get_named_connection($connection->{CONNECTION}{NAME}) ;
	
	if(defined $new_connection)
		{
		my ($x_offset, $y_offset, $width, $height, $new_connector) = 
			$connection->{CONNECTED}->move_connector
				(
				$connection->{CONNECTOR}{NAME},
				$new_connection->{X} - $connection->{CONNECTION}{X},
				$new_connection->{Y}- $connection->{CONNECTION}{Y}
				) ;
				
		$connection->{CONNECTED}{X} += $x_offset ;
		$connection->{CONNECTED}{Y} += $y_offset ;
		
		# the connection point has also changed
		$connection->{CONNECTOR} = $new_connector ;
		$connection->{CONNECTION} = $new_connection ;
		
		$connection->{FIXED}++ ;
		
		#find the other connectors belonging to this connected
		for my $other_connection (grep{ ! $_->{FIXED}} @{$self->{CONNECTIONS}})
			{
			# move them relatively to their previous position
			if($connection->{CONNECTED} == $other_connection->{CONNECTED})
				{
				my ($new_connector) = # in characters relative to element origin
						$other_connection->{CONNECTED}->get_named_connection($other_connection->{CONNECTOR}{NAME}) ;
				
				$other_connection->{CONNECTOR} = $new_connector ;
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

sub delete_elements
{
my($self, @elements) = @_ ;

my %elements_to_delete = map {$_, 1}  @elements ;

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

sub delete_makeup_elements
{
my ($self) = @_;

$self->delete_elements(grep{defined($_->{MAKE_UP_FLAG}) && ($_->{MAKE_UP_FLAG} == 1) } @{$self->{ELEMENTS}});
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

for my $connection ($self->get_connected($selected_element))
	{
	# all connection where the selected element is the connectee
	
	my ($new_connection) = # in characters relative to element origin
			$selected_element->get_named_connection($connection->{CONNECTION}{NAME}) ;
	
	if(defined $new_connection)
		{
		my ($x_offset, $y_offset, $width, $height, $new_connector) = 
			$connection->{CONNECTED}->move_connector
				(
				$connection->{CONNECTOR}{NAME},
				$new_connection->{X} - $connection->{CONNECTION}{X},
				$new_connection->{Y}- $connection->{CONNECTION}{Y}
				) ;
				
		$connection->{CONNECTED}{X} += $x_offset ;
		$connection->{CONNECTED}{Y} += $y_offset;
		
		# the connection point has also changed
		$connection->{CONNECTOR} = $new_connector ;
		$connection->{CONNECTION} = $new_connection ;
		
		$connection->{FIXED}++ ;
		
		#find the other connectors belonging to this connected
		for my $other_connection (grep{ ! $_->{FIXED}} @{$self->{CONNECTIONS}})
			{
			# move them relatively to their previous position
			if($connection->{CONNECTED} == $other_connection->{CONNECTED})
				{
				my ($new_connector) = # in characters relative to element origin
						$other_connection->{CONNECTED}->get_named_connection($other_connection->{CONNECTOR}{NAME}) ;
				
				$other_connection->{CONNECTOR} = $new_connector ;
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

$self->{MODIFIED }++ ;
}

#-----------------------------------------------------------------------------

sub get_selected_elements
{
my ($self, $state) = @_ ;

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

sub any_select_elements
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

sub select_makeup_elements
{
my ($self) = @_;

for my $element (@{$self->{ELEMENTS}})
{
    $element->{SELECTED} = ++$self->{SELECTION_INDEX} if (defined($element->{MAKE_UP_FLAG}) && ($element->{MAKE_UP_FLAG} == 1));
}
}

#-----------------------------------------------------------------------------

sub switch_makeup_cross_mode
{

my ($self) = @_;

if($self->{MAKE_UP_CROSS_MODE} == 0)
{
    $self->{MAKE_UP_CROSS_MODE} = 1;
	print("enter normal makeup cross mode\n");
}
elsif($self->{MAKE_UP_CROSS_MODE} == 1)
{
    $self->{MAKE_UP_CROSS_MODE} = 2;
	print("enter deep makeup cross mode\n");	
} else 
{
    $self->{MAKE_UP_CROSS_MODE} = 0;
	print("exit makeup cross mode\n");
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
my $is_under = 0 ;

for my $strip (@{$element->get_stripes()})
	{
	my $stripe_x = $element->{X} + $strip->{X_OFFSET} ;
	my $stripe_y = $element->{Y} + $strip->{Y_OFFSET} ;
	
	if
		(
		$stripe_x - $field <= $x   && $x < $stripe_x + $strip->{WIDTH} + $field
		&& $stripe_y - $field <= $y && $y < $stripe_y + $strip->{HEIGHT} + $field
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
my $width = $rectangle->{END_X} - $rectangle->{START_X} ;
my $height = $rectangle->{END_Y} - $rectangle->{START_Y}; 

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

my $is_under = 1 ;

for my $strip (@{$element->get_stripes()})
	{
	my $stripe_x = $element->{X} + $strip->{X_OFFSET} ;
	my $stripe_y = $element->{Y} + $strip->{Y_OFFSET} ;
	
	if
	(
	    $start_x <= $stripe_x
	&& ($stripe_x + $strip->{WIDTH})  <= $start_x +$width
	&& $start_y <= $stripe_y 
	&& ($stripe_y + $strip->{HEIGHT}) <= $start_y + $height
	) 
		{
		}
	else
		{
		$is_under = 0 ;
		last
		}
	}

return($is_under) ;
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
# asciio: + X . '
# unicode: ┼ ┤ ├ ┬ ┴ ╭ ╮ ╯ ╰ ╳ 
# todo: 1. performance problem
#       2. ⍀ ⌿ these two symbols are not necessary
#       3. unicode deep mode 
#       4. char color

{

my %normal_char_cache;
my %diagonal_char_cache;
my %deep_char_cache;
my $undef_char = 'Ȝ';


my @normal_char_func = (
	['+', \&makeup_scene_cross],
	['.', \&makeup_scene_dot],
	['\'',\&makeup_scene_apostrophe],
	['┼', \&makeup_scene_unicode_cross],
	['┤', \&makeup_scene_unicode_cross_lose_right],
	['├', \&makeup_scene_unicode_cross_lose_left],
	['┬', \&makeup_scene_unicode_cross_lose_up],
	['┴', \&makeup_scene_unicode_cross_lose_down],
	['╭', \&makeup_scene_unicode_right_down],
	['╮', \&makeup_scene_unicode_left_down],
	['╯', \&makeup_scene_unicode_left_up],
	['╰', \&makeup_scene_unicode_right_up],
) ;

my @diagonal_char_func = (
	['X', \&makeup_scene_x],
	['╳', \&makeup_scene_unicode_x],
) ;

my @need_deal_char = ('-', '|', '.', '\'', '\\', '/', '─', '│', '╭', '╮', '╯', '╰') ;

my @deep_char_func = (
	['+', \&makeup_scene_cross_deep],
) ;


sub add_makeup_elements
{
my ($self, $deep_flag) = @_;

$self->delete_makeup_elements();

#~ this func is slow
my @ascii_array = $self->transform_elements_to_ascii_two_dimensional_array();

my @keep_elements;

my ($row, $col, $scene_func, $origin_char) ;
my ($up, $down, $left, $right, $char_45, $char_135, $char_225, $char_315, $normal_key, $diagonal_key);
for $row (1 .. $#ascii_array)
{
	for $col (1 .. $#{$ascii_array[$row]})
	{
		$origin_char = $ascii_array[$row][$col];
		next unless($origin_char && any { $_ eq $origin_char } @need_deal_char);

		($up, $down, $left, $right) = ($ascii_array[$row-1][$col], $ascii_array[$row+1][$col], $ascii_array[$row][$col-1], $ascii_array[$row][$col+1]);

		$normal_key = ($up || $undef_char) . ($down || $undef_char) . ($left || $undef_char) . ($right || $undef_char);

		unless(exists($normal_char_cache{$normal_key}))
		{
			$scene_func = first { $_->[1]($up, $down, $left, $right) } @normal_char_func;
			$normal_char_cache{$normal_key} = ($scene_func) ? [1, $scene_func->[0]] : [0, '0'];
		}

		if($normal_char_cache{$normal_key}[0]) {
			$self->create_makeup_element($normal_char_cache{$normal_key}[1], $col, $row) if ($normal_char_cache{$normal_key}[1] ne $origin_char);
			$ascii_array[$row][$col] = $normal_char_cache{$normal_key}[1];
			next;
		}

		($char_45, $char_135, $char_225, $char_315) = ($ascii_array[$row-1][$col+1], $ascii_array[$row+1][$col+1], $ascii_array[$row+1][$col-1], $ascii_array[$row-1][$col-1]);
		
		$diagonal_key = ($char_45 || $undef_char) . ($char_135 || $undef_char) . ($char_225 || $undef_char) . ($char_315 || $undef_char);

		unless(exists($diagonal_char_cache{$diagonal_key}))
		{
			$scene_func = first { $_->[1]($char_45, $char_135, $char_225, $char_315) } @diagonal_char_func;
			$diagonal_char_cache{$diagonal_key} = ($scene_func) ? [1, $scene_func->[0]] : [0, '0'];
		}

		if($diagonal_char_cache{$diagonal_key}[0])
		{
			$self->create_makeup_element($diagonal_char_cache{$diagonal_key}[1], $col, $row) if ($diagonal_char_cache{$diagonal_key}[1] ne $origin_char);
			$ascii_array[$row][$col] = $diagonal_char_cache{$diagonal_key}[1];
		}
	}
}

if(($deep_flag && $deep_flag == 1) || ($self->{MAKE_UP_CROSS_MODE} == 2))
{

my $deep_key;
my $continue_flag = 1;

until($continue_flag == 0)
{
	$continue_flag = 0;

	for $row (1 .. $#ascii_array)
	{
		for $col (1 .. $#{$ascii_array[$row]})
		{
		$origin_char = $ascii_array[$row][$col];
		next unless($origin_char && any { $_ eq $origin_char } @need_deal_char);

		($up, $down, $left, $right) = ($ascii_array[$row-1][$col], $ascii_array[$row+1][$col], $ascii_array[$row][$col-1], $ascii_array[$row][$col+1]);

		$deep_key = ($up || $undef_char) . ($down || $undef_char) . ($left || $undef_char) . ($right || $undef_char);

		unless(exists($deep_char_cache{$deep_key}))
		{
			$scene_func = first { $_->[1]($up, $down, $left, $right) } @deep_char_func;
			$deep_char_cache{$deep_key} = ($scene_func) ? [1, $scene_func->[0]] : [0, '0'];
		}

		if($deep_char_cache{$deep_key}[0]) 
		{
			$continue_flag = 1;
			$self->create_makeup_element($deep_char_cache{$deep_key}[1], $col, $row) if ($deep_char_cache{$deep_key}[1] ne $origin_char);
			$ascii_array[$row][$col] = $deep_char_cache{$deep_key}[1];
		}
		}
	}
}
}
}
}

#-----------------------------------------------------------------------------
# +
sub makeup_scene_cross
{
my ($up, $down, $left, $right) = @_;

return 0 unless($up && $down && $left && $right) ;

return (($up eq '|' || $up eq '^' || $up eq '.' || $up eq '\'') &&
		($down eq '|' || $down eq 'v' || $down eq '.' || $down eq '\'') &&
		($left eq '-' || $left eq '<' || $left eq '.' || $left eq '\'') &&
		($right eq '-' || $right eq '>' || $right eq '.' || $right eq '\'')) ;

}

#-----------------------------------------------------------------------------
# +
sub makeup_scene_cross_deep
{
my ($up, $down, $left, $right) = @_;

return 0 unless($up && $down && $left && $right) ;

return 1 if(($up && $up eq '-') && 
			($down eq '|' || $down eq 'v' || $down eq '.' || $down eq '\'' || $down eq '+') &&
			($left eq '-' || $left eq '<' || $left eq '.' || $left eq '\'' || $left eq '+') &&
			($right eq '-' || $right eq '>' || $right eq '.' || $right eq '\'' || $right eq '+'));

return 1 if(($down && $down eq '-') && 
			($up eq '|' || $up eq '^' || $up eq '.' || $up eq '\'' || $up eq '+') &&
			($left eq '-' || $left eq '<' || $left eq '.' || $left eq '\'' || $left eq '+') &&
			($right eq '-' || $right eq '>' || $right eq '.' || $right eq '\'' || $right eq '+'));

return 1 if(($left && $left eq '|') && 
			($up eq '|' || $up eq '^' || $up eq '.' || $up eq '\'' || $up eq '+') &&
			($down eq '|' || $down eq 'v' || $down eq '.' || $down eq '\'' || $down eq '+') &&
			($right eq '-' || $right eq '>' || $right eq '.' || $right eq '\'' || $right eq '+'));

return 1 if(($right && $right eq '|') && 
			($up eq '|' || $up eq '^' || $up eq '.' || $up eq '\'' || $up eq '+') &&
			($down eq '|' || $down eq 'v' || $down eq '.' || $down eq '\'' || $down eq '+') &&
			($left eq '-' || $left eq '<' || $left eq '.' || $left eq '\'' || $left eq '+'));

return (($up eq '|' || $up eq '^' || $up eq '.' || $up eq '\'' || $up eq '+') &&
		($down eq '|' || $down eq 'v' || $down eq '.' || $down eq '\'' || $down eq '+') &&
		($left eq '-' || $left eq '<' || $left eq '.' || $left eq '\'' || $left eq '+') &&
		($right eq '-' || $right eq '>' || $right eq '.' || $right eq '\'' || $right eq '+')) ;

}

#-----------------------------------------------------------------------------
# .
#                              |   |
#         ---.  .---  ---.---  |   |
#            |  |        |  ---.   .---
#            |  |        |     |   |
sub makeup_scene_dot
{
my ($up, $down, $left, $right) = @_;

return 0 if(($up && $up eq '|') && ($down && $down eq '|') && 
			($left && $left eq '-') && ($right && $right eq '-'));

return ((($left && $left eq '-') && ($down && $down eq '|')) || 
	   (($right && $right eq '-') && ($down && $down eq '|'))) ;
}

#-----------------------------------------------------------------------------
# '
#       |          |       |
#       |          |       |
#       '---    ---'    ---'---
sub makeup_scene_apostrophe
{
my ($up, $down, $left, $right) = @_;

return 1 if((($up && $up eq '|') && ($right && $right eq '-')) && 
			!($down && $down eq '|')) ;

return (($up && $up eq '|') && ($left && $left eq '-') && 
		!(($down && $down eq '|') || ($right && $right eq '|'))) ;

}

#-----------------------------------------------------------------------------
# ┼
sub makeup_scene_unicode_cross
{
my ($up, $down, $left, $right) = @_;

return 0 unless($up && $down && $left && $right) ;

return (($up eq '│' || $up eq '^' || $up eq '╭' || $up eq '╮') &&
		($down eq '│' || $down eq 'v' || $down eq '╰' || $down eq '╯') &&
		($left eq '─' || $left eq '<' || $left eq '╭' || $left eq '╰') &&
		($right eq '─' || $right eq '>' || $right eq '╮' || $right eq '╯')) ;
}

#-----------------------------------------------------------------------------
# ┤
sub makeup_scene_unicode_cross_lose_right
{
my ($up, $down, $left, $right) = @_;

return 0 unless($up && $down && $left) ;

return 0 if($right && ($right eq '─' || $right eq '>' || $right eq '╮' || $right eq '╯')) ;

return (($up eq '│' || $up eq '^' || $up eq '╭' || $up eq '╮') &&
		($down eq '│' || $down eq 'v' || $down eq '╰' || $down eq '╯') &&
		($left eq '─' || $left eq '<' || $left eq '╭' || $left eq '╰')) ;
}

#-----------------------------------------------------------------------------
# ├
sub makeup_scene_unicode_cross_lose_left
{
my ($up, $down, $left, $right) = @_;

return 0 unless($up && $down && $right) ;

return 0 if($left && ($left eq '─' || $left eq '<' || $left eq '╭' || $left eq '╰')) ;

return (($up eq '│' || $up eq '^' || $up eq '╭' || $up eq '╮') &&
		($down eq '│' || $down eq 'v' || $down eq '╰' || $down eq '╯') &&
		($right eq '─' || $right eq '>' || $right eq '╮' || $right eq '╯')) ;
}

#-----------------------------------------------------------------------------
# ┬
sub makeup_scene_unicode_cross_lose_up
{
my ($up, $down, $left, $right) = @_;

return 0 unless($down && $left && $right) ;

return 0 if($up && ($up eq '│' || $up eq '^' || $up eq '╭' || $up eq '╮')) ;

return (($down eq '│' || $down eq 'v' || $down eq '╰' || $down eq '╯') &&
		($left eq '─' || $left eq '<' || $left eq '╭' || $left eq '╰') &&
		($right eq '─' || $right eq '>' || $right eq '╮' || $right eq '╯')) ;
}

#-----------------------------------------------------------------------------
# ┴
sub makeup_scene_unicode_cross_lose_down
{
my ($up, $down, $left, $right) = @_;

return 0 unless($up && $left && $right) ;

return 0 if($down && ($down eq '│' || $down eq 'v' || $down eq '╰' || $down eq '╯')) ;

return (($up eq '│' || $up eq '^' || $up eq '╭' || $up eq '╮') &&
		($left eq '─' || $left eq '<' || $left eq '╭' || $left eq '╰') &&
		($right eq '─' || $right eq '>' || $right eq '╮' || $right eq '╯')) ;
}

#-----------------------------------------------------------------------------
# ╭
sub makeup_scene_unicode_right_down
{
my ($up, $down, $left, $right) = @_;

return 0 unless($down && $right) ;

return 0 if(($up && ($up eq '│' || $up eq '^' || $up eq '╭' || $up eq '╮')) || 
			($left && ($left eq '─' || $left eq '<' || $left eq '╭' || $left eq '╰'))) ;

return (($down eq '│' || $down eq 'v' || $down eq '╰' || $down eq '╯') &&
		($right eq '─' || $right eq '>' || $right eq '╮' || $right eq '╯')) ;
}

#-----------------------------------------------------------------------------
# ╮
sub makeup_scene_unicode_left_down
{
my ($up, $down, $left, $right) = @_;

return 0 unless($down && $left) ;

return 0 if (($up && ($up eq '│' || $up eq '^' || $up eq '╭' || $up eq '╮')) ||
			 ($right && ($right eq '─' || $right eq '>' || $right eq '╮' || $right eq '╯')));

return (($down eq '│' || $down eq 'v' || $down eq '╰' || $down eq '╯') &&
		($left eq '─' || $left eq '<' || $left eq '╭' || $left eq '╰')) ;
}

#-----------------------------------------------------------------------------
# ╯
sub makeup_scene_unicode_left_up
{
my ($up, $down, $left, $right) = @_;

return 0 unless($up && $left) ;

return 0 if(($down && ($down eq '│' || $down eq 'v' || $down eq '╰' || $down eq '╯')) || 
			($right && ($right eq '─' || $right eq '>' || $right eq '╮' || $right eq '╯'))) ;

return (($up eq '│' || $up eq '^' || $up eq '╭' || $up eq '╮') &&
		($left eq '─' || $left eq '<' || $left eq '╭' || $left eq '╰')) ;
}

#-----------------------------------------------------------------------------
# ╰
sub makeup_scene_unicode_right_up
{
my ($up, $down, $left, $right) = @_;

return 0 unless($up && $right) ;

return 0 if(($left && ($left eq '─' || $left eq '<' || $left eq '╭' || $left eq '╰')) || 
			($down && ($down eq '│' || $down eq 'v' || $down eq '╰' || $down eq '╯')));

return (($up eq '│' || $up eq '^' || $up eq '╭' || $up eq '╮') &&
		($right eq '─' || $right eq '>' || $right eq '╮' || $right eq '╯')) ;
}

#-----------------------------------------------------------------------------
# X
sub makeup_scene_x
{
my ($char_45, $char_135, $char_225, $char_315) = @_;

return 0 unless($char_45 && $char_135 && $char_225 && $char_315);

return (($char_45 eq '/' || $char_45 eq '^') && 
		($char_135 eq '\\' || $char_135 eq 'v') && 
		($char_225 eq '/' || $char_225 eq 'v') && 
		($char_315 eq '\\' || $char_315 eq '^')) ;

}

#-----------------------------------------------------------------------------
# ╳
sub makeup_scene_unicode_x
{
my ($char_45, $char_135, $char_225, $char_315) = @_;

return 0 unless($char_45 && $char_135 && $char_225 && $char_315);

return (($char_45 eq '╱' || $char_45 eq '^') && 
		($char_135 eq '╲' || $char_135 eq 'v') && 
		($char_225 eq '╱' || $char_225 eq 'v') && 
		($char_315 eq '╲' || $char_315 eq '^')) ;
}



#-----------------------------------------------------------------------------


1 ;

