
use strict ;
use warnings ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Create multiple box elements from a text description' => ['C00-m', \&insert_multiple_boxes_from_text_description, 1],
	'Create multiple text elements from a text description' => ['C0S-M', \&insert_multiple_boxes_from_text_description, 0],
	'Flip transparent element background' => ['C00-t', \&transparent_elements],
	'Flip grid display' => ['000-g', \&flip_grid_display],
	'Flip color scheme' => ['CA0-c', \&flip_color_scheme],
	'Undo' => ['C00-z', \&undo],
	'Display undo stack statistics' => ['C0S-Z', \&display_undo_stack_statistics],
	'Redo' => ['C00-y', \&redo],
	'Display keyboard mapping' => ['000-k', \&display_keyboard_mapping],
	'Display commands' => ['C00-k', \&display_commands],
	'Display action files' => ['C0S-K', \&display_action_files],
	'Zoom in' => ['000-KP_Add', \&zoom, 1],
	'Zoom out' => ['000-minus', \&zoom, -1],
	'Zoom in' => ['000-plus', \&zoom, 1],
	'Zoom out' => ['000-KP_Subtract', \&zoom, -1],
	'Help' => ['000-F1', \&display_help],
	'External command output in a box' => ['000-x', \&external_command_output, 1],
	'External command output in a box no frame' => ['C00-x', \&external_command_output, 0],
	) ;

#----------------------------------------------------------------------------------------------

sub display_help
{
my ($self) = @_ ;


$self->display_message_modal(<<EOM) ;

Very short help:

k show the keyboard mapping
CTL+SHIFT+k 
	
b, Add a box
B, Add a box, edit the text directly
CTL+m, Add multiple boxes in one shot

t, Add a text element
CTL+SHIFT+M, Add multiple texts in one shot

quick link:
	select a box
	CTL+SHIFT+ left mouse on the other element
	
a, add a wirl arrow (AsciiO arrow)
SHIFT+A, add an angled arrow
d, change the direction of the arrows (selection)
f, flip the arrows (selection)


CTL+click, copy elements
SHIFT+click: add elements to the selection

CTL+g, group elements
CTL+u, ungroup object

Mouse right button shows a context menu.
Double click shows the element editing dialog

EOM
}

#----------------------------------------------------------------------------------------------

sub zoom
{
my ($self, $direction) = @_ ;

my ($family, $size) = $self->get_font() ;

$self->set_font($family, $size + $direction) ;
}

#----------------------------------------------------------------------------------------------

sub flip_color_scheme
{
my ($self) = @_ ;

$self->{COLOR_SCHEME} = 'system' unless exists $self->{COLOR_SCHEME} ;

if($self->{COLOR_SCHEME} eq 'system')
	{
	$self->flush_color_cache() ;
	$self->{COLOR_SCHEME} = 'linux' ;
	$self->{COLORS} =
		{
		background => [10, 10, 10],
		grid => [30, 30, 30],
		ruler_line => [25, 60, 80],
		selected_element_background => [25, 40, 50],
		element_background => [25, 25, 25],
		element_foreground => [150, 150, 150] ,
		selection_rectangle => [110, 0, 110],
		test => [0, 255, 255],
		group_colors =>
			[
			[[0x41, 0x32, 0x23], [0x2B, 0x21, 0x17]],
			[[0x21, 0x3C, 0x23], [0x15, 0x27, 0x17]],
			[[0x23, 0x32, 0x3C], [0x18, 0x22, 0x29]],
			[[0x10, 0x44, 0x44], [0x0A, 0x2C, 0x2C]],
			[[0x50, 0x28, 0x20], [0x2E, 0x17, 0x13]],
			],
			
		connection => [140, 65, 20],
		connection_point => [130, 100, 50],
		connector_point => [20, 100, 155],
		new_connection => [180, 0, 0],
		extra_point => [150, 110, 50], 
		} ;
		
	$self->update_display() ;
	}
else
	{
	$self->flush_color_cache() ;
	$self->{COLOR_SCHEME} = 'system' ;
	$self->{COLORS} =
		{
		background => [255, 255, 255],
		grid => [229, 235, 255],
		ruler_line => [85, 155, 225],
		selected_element_background => [180, 244, 255],
		element_background => [251, 251, 254],
		element_foreground => [0, 0, 0] ,
		selection_rectangle => [255, 0, 255],
		test => [0, 255, 255],
		
		group_colors =>
			[
			[[250, 221, 190], [250, 245, 239]],
			[[182, 250, 182], [241, 250, 241]],
			[[185, 219, 250], [244, 247, 250]],
			[[137, 250, 250], [235, 250, 250]],
			[[198, 229, 198], [239, 243, 239]],
			],
			
		connection => 'Chocolate',
		connection_point => [230, 198, 133],
		connector_point => 'DodgerBlue',
		new_connection => 'red' ,
		extra_point => [230, 198, 133],
		} ;

	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

sub display_keyboard_mapping
{
my ($self) = @_ ;

#~ print Data::TreeDumper::DumpTree $self->{ACTIONS_BY_NAME}, 'ACTIONS_BY_NAME:';

my $keyboard_mapping = get_keyboard_mapping($self->{ACTIONS_BY_NAME}) ;

#~ print Data::TreeDumper::DumpTree $keyboard_mapping , 'Keyboard mapping:';

$self->show_dump_window
		(
		$keyboard_mapping ,
		'Keyboard mapping:',
		DISPLAY_ADDRESS => 0,
		)
}

sub get_keyboard_mapping
{
my ($actions, $list) = @_ ;

$list ||= [] ;
my $keyboard_mapping ;

for my $action (keys %{$actions})
	{
	if('ARRAY' eq ref $actions->{$action})
		{
		my $shortcut =  ref $actions->{$action}[0] eq '' 
						? $actions->{$action}[0] 
						:  '[' . join('/', @{$actions->{$action}[0]}) . ']';
		
		$keyboard_mapping->{$shortcut . ' => ' . $action} = {FILE=> $actions->{$action}[6]} ;
		}
	elsif('HASH' eq ref $actions->{$action})
		{
		my $sub_keyboard_mapping = get_keyboard_mapping($actions->{$action}) ;
		
		for my $shortcut (keys %{$sub_keyboard_mapping})
			{
			my $start_shortcut = '[' . join('/', $actions->{$action}{SHORTCUTS}) . '] + ';
			$keyboard_mapping->{$start_shortcut . $shortcut} = $sub_keyboard_mapping->{$shortcut} ;
			}
		}
	else
		{
		#~ die "unknown type while running 'dump_keyboard_mapping'\n" ;
		}
	}

return($keyboard_mapping) ;
}

#----------------------------------------------------------------------------------------------

sub display_commands
{
my ($self) = @_ ;

#~ print Data::TreeDumper::DumpTree $self->{ACTIONS_BY_NAME}, 'ACTIONS_BY_NAME:';

my $commands = get_commands($self->{ACTIONS_BY_NAME}) ;

$self->show_dump_window
		(
		$commands,
		'commands:',
		DISPLAY_ADDRESS => 0,
		)
}

sub get_commands
{
my ($actions, $list) = @_ ;

$list ||= [] ;
my $commands ;

for my $action (keys %{$actions})
	{
	if('ARRAY' eq ref $actions->{$action})
		{
		my $shortcut =  ref $actions->{$action}[0] eq '' 
						? $actions->{$action}[0] 
						:  '[' . join('/', @{$actions->{$action}[0]}) . ']';
		
		$commands->{$action . " [$shortcut]"} = {FILE=> $actions->{$action}[6]} ;
		}
	elsif('HASH' eq ref $actions->{$action})
		{
		my $sub_commands = get_commands($actions->{$action}) ;
		
		for my $shortcut (keys %{$sub_commands})
			{
			my ($name, $shortcut_text) = $shortcut =~ /([^\[]*)(.*)/ ;
			my $start_shortcut = '[' . join('/', $actions->{$action}{SHORTCUTS}) . '] + ';
			$commands->{$name . $start_shortcut . $shortcut_text} = $sub_commands->{$shortcut} ;
			}
		}
	else
		{
		#~ die "unknown type while running 'dump_keyboard_mapping'\n" ;
		}
	}

return($commands) ;
}

#----------------------------------------------------------------------------------------------

sub display_action_files
{
my ($self) = @_ ;

my $actions_per_file = {} ;

generate_keyboard_mapping_text_dump($self->{ACTIONS_BY_NAME}, $actions_per_file) ;

#~ print Data::TreeDumper::DumpTree 
		#~ $actions_per_file,
		#~ 'Action files:',
		#~ DISPLAY_ADDRESS => 0,
		#~ GLYPHS => ['  ', '  ', '  ', '  '],
		#~ NO_NO_ELEMENTS => 1,
		#~ FILTER => \&filter_keyboard_mapping ;
		
$self->show_dump_window
		(
		$actions_per_file,
		'Action files:',
		DISPLAY_ADDRESS => 0,
		GLYPHS => ['  ', '  ', '  ', '  '],
		NO_NO_ELEMENTS => 1,
		FILTER => \&filter_keyboard_mapping
		) ;
}

sub filter_keyboard_mapping
{
my $s = shift ;

if('HASH' eq ref $s)
	{
	my (%hash, @keys) ;
	
	for my $entry (sort keys %{$s})
		{
		if('ARRAY' eq ref $s->{$entry})
			{
			my $shortcuts = $s->{$entry}[0] ;
			
			$shortcuts = join(' ',  @{$shortcuts}) if('ARRAY' eq ref $shortcuts) ;
				
			my $key_name = "$entry [$shortcuts]" ;
			
			$hash{$key_name} = [] ;
			
			push @keys, $key_name ;
			}
		else
			{
			$hash{$entry} = $s->{$entry} ;
			push @keys, $entry ;
			}
		}
		
	return('HASH', \%hash, @keys) ;
	}
	
return(Data::TreeDumper::DefaultNodesToDisplay($s)) ;
}

sub generate_keyboard_mapping_text_dump
{
my ($key_mapping, $actions_per_file) = @_ ;

die "Need argument!" unless defined $actions_per_file ;

for my $action (keys %{$key_mapping})
	{
	if('ARRAY' eq ref $key_mapping->{$action})
		{
		$actions_per_file->{$key_mapping->{$action}[6]}{$action} = $key_mapping->{$action} ;
		}
	elsif('HASH' eq ref $key_mapping->{$action})
		{
		my $sub_actions = {} ;
			
		{
		local $key_mapping->{$action}{GROUP_NAME} = undef ;
		local $key_mapping->{$action}{ORIGIN} = undef ;
		local $key_mapping->{$action}{SHORTCUTS} = undef ;
		
		generate_keyboard_mapping_text_dump($key_mapping->{$action}, $sub_actions) ;
		}
		
		#~ print Data::TreeDumper::DumpTree $key_mapping->{$action} ;
		#~ print Data::TreeDumper::DumpTree $sub_actions ;
		
		my $shortcuts = $key_mapping->{$action}{SHORTCUTS} ;
		$shortcuts = join(' ', @{$key_mapping->{$action}{SHORTCUTS}}) 
			if('ARRAY' eq ref $key_mapping->{$action}{SHORTCUTS}) ;
				
		$actions_per_file->{$key_mapping->{$action}{ORIGIN}}{"group: $action [$shortcuts]"} 
			= $sub_actions->{$key_mapping->{$action}{ORIGIN}} ;
		}
	else
		{
		#~ print Data::TreeDumper::DumpTree $key_mapping->{$action}, $action ;
		#~ die "unknown type while running 'dump_keyboard_mapping'\n" ;
		}
	}
}

#----------------------------------------------------------------------------------------------

sub undo
{
my ($self) = @_ ;

$self->undo(1) ;
}

#----------------------------------------------------------------------------------------------

sub redo
{
my ($self) = @_ ;

$self->redo(1) ;
}


#----------------------------------------------------------------------------------------------

sub display_undo_stack_statistics
{
my ($self) = @_ ;

my $statistics  = { DO_STACK_POINTER => $self->{DO_STACK_POINTER} } ;

my $total_size = 0 ;

for my $stack_element (@{$self->{DO_STACK}})
	{
	push @{$statistics->{ELEMENT_SIZE}}, length($stack_element) ;
	$total_size += length($stack_element) ;
	}

$statistics->{TOTAL_SIZE} = $total_size ;

$self->show_dump_window($statistics, 'Undo stack statistics:') ;
}

#----------------------------------------------------------------------------------------------

sub insert_multiple_boxes_from_text_description
{
my ($self, $boxed) = @_ ;

my $text = $self->display_edit_dialog('multiple texts from input', "\ntext\ntext\ntext\ntext" ) ;

if(defined $text && $text ne '')
	{
	$self->create_undo_snapshot() ;
	
	my ($current_x, $current_y) = ($self->{MOUSE_X}, $self->{MOUSE_Y}) ;
	my ($separator) = split("\n", $text) ;
	
	$text =~ s/$separator\n// ;

	my @new_elements ;
	
	for my $element_text (split("$separator\n", $text))
		{
		chomp $element_text ;
		
		my $new_element = new App::Asciio::stripes::editable_box2
							({
							TITLE => '',
							TEXT_ONLY => $element_text,
							EDITABLE => 1,
							RESIZABLE => 1,
							}) ;
							
		if(! $boxed)
			{
			my $box_type = $new_element->get_box_type() ;
			
			for  my $box_element (@{$box_type})
				{
				$box_element->[0] = 0 ;
				}
				
			$new_element->set_box_type($box_type) ;
			$new_element->shrink() ;
			}
			
		@$new_element{'X', 'Y'} = ($current_x, $current_y) ;
		$current_x += $self->{COPY_OFFSET_X} ; 
		$current_y += $self->{COPY_OFFSET_Y} ;
		
		push @new_elements , $new_element ;
		}
	
	$self->deselect_all_elements() ;
	$self->add_elements(@new_elements) ;
	$self->select_elements(1, @new_elements) ;
	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

sub flip_grid_display
{
my ($self) = @_ ;
$self->{DISPLAY_GRID} ^=1 ;
$self->update_display() ;
}
	
#----------------------------------------------------------------------------------------------

sub transparent_elements
{
my ($self) = @_ ;
$self->{OPAQUE_ELEMENTS} ^=1 ;
$self->update_display() ;
}
	
#----------------------------------------------------------------------------------------------

sub external_command_output
{
my ($self, $in_box) = @_ ;

$self->create_undo_snapshot() ;

my $command = $self->display_edit_dialog('Enter command', '') ;

if(defined $command && $command ne '')
	{
	(my $command_stderr_redirected = $command) =~ s/$/ 2>&1/gsm ;
	my $output = `$command_stderr_redirected` ;
	
	if($?)
		{
		$output = '' unless defined $output ;
		$output = "Can't execute '$command':\noutput:\n$output\nerror:\n$! [$?]" ;
		$in_box++ ;
		}

	my @box ;
	
	unless($in_box)
		{
		push @box,
			BOX_TYPE =>
				[
				[0, 'top', '.', '-', '.', 1, ],
				[0, 'title separator', '|', '-', '|', 1, ],
				[0, 'body separator', '| ', '|', ' |', 1, ], 
				[0, 'bottom', '\'', '-', '\'', 1, ],
				]  ;
		}
		
	use App::Asciio::stripes::editable_box2 ;
	my $new_element = new App::Asciio::stripes::editable_box2
					({
					TEXT_ONLY => $output,
					TITLE => '',
					EDITABLE => 1,
					RESIZABLE => 1,
					@box
					}) ;
		
	$self->add_element_at($new_element, $self->{MOUSE_X}, $self->{MOUSE_Y}) ;

	$self->update_display() ;
	}
}

