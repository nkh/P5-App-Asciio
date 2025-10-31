
package App::Asciio::Actions::Unsorted ;

use strict ;
use warnings ;
use utf8 ;
use Encode ;

use File::Temp qw/ tempfile / ;
use File::Slurp ;
use Data::TreeDumper ;
use List::Util qw(min max) ;

#----------------------------------------------------------------------------------------------

sub manpage_in_browser
{
my ($self) = @_ ;

my (undef, $manpage) = tempfile() ;

system("perldoc App::Asciio >$manpage") ;

if(defined $ENV{BROWSER} && $ENV{BROWSER} ne '')
	{
	qx"$ENV{BROWSER} --new-window 'file://$manpage' &" ;
	}
else
	{
	$self->display_message_modal("Environmen variable 'BROWSER' not set.") ;
	}
}

#----------------------------------------------------------------------------------------------

sub display_help
{
my ($self) = @_ ;


$self->display_message_modal(<<EOM) ;

"alt+lef_mouse" "."         Quick link

"ib",                       insert a box
"iB",                       insert a shrink box
"i^b"                       Add multiple boxes

"it",                       Add a text element
"i^t"                       Add multiple texts

"ia"                        Add a wirl arrow
"ad"                        Change arrow direction
"af"                        Flip the arrows
"as"                        Append multi_wirl section

"ctl-z" "u"                 Undo
"ctl-y" "ctl-r"             Redo

"tab" "n"                   Select next element
"ctl-a" "V"                 Select all elements

"ctl-c/ctl-v" "y/p"         Copy/Paste elements
"ctl-e" "Y"                 Export as ascii
"ctl-V" "P"                 Import to box
"alt-p" "A-P"               Import to text

"gg"                        Group selected elements
"gu"                        Group object

"double-click/enter"        Edit object

"right-clik"                Show context menu.

"+"                         Zoom in
"-"                         Zoom out

":e"                        Open
":w"                        Save
":q"                        Quit

":m"                        Displays manpage

EOM
}

#----------------------------------------------------------------------------------------------

sub zoom
{
my ($self, $direction) = @_ ;

my ($family, $size) = $self->get_font() ;

my ($zoom_lower_limit, $zoom_upper_limit) = ($self->{ZOOM_LOWER_LIMIT} // 0, $self->{ZOOM_UPPER_LIMIT} // 28) ;

if($direction > 0) 
	{
	return if($size >= $zoom_upper_limit) ;
	}
elsif($direction < 0)
	{
	return if($size <= $zoom_lower_limit) ;
	}

my ($character_width, $character_height) = $self->get_character_size() ;

$self->set_font($family, $size + $direction) ;

my $zoom_step = $self->{ZOOM_STEP} // 1 ;
my $font_min = $self->{FONT_MIN} // 1  ;

$size += ($direction * $zoom_step) ;

my $remainder = $size % $zoom_step ;
$size += $zoom_step - $remainder if $remainder ;

$size = $font_min if $size < $font_min ;

# making the character size change
$self->set_font($family, $size);

# resize canvas
if($self->{UI} eq 'GUI')
	{
	my $h_value = $self->{sc_window}->get_hadjustment()->get_value() ;
	my $v_value = $self->{sc_window}->get_vadjustment()->get_value() ;

	$self->invalidate_rendering_cache() ;

	my ($new_character_width, $new_character_height) = $self->get_character_size() ;
	my ($canvas_width, $canvas_height) = ($self->{CANVAS_WIDTH} * $new_character_width, $self->{CANVAS_HEIGHT} * $new_character_height) ;

	$self->{widget}->set_size_request($canvas_width, $canvas_height);

	# The state equation of the scroll bar before and after zooming, 
	# using the coordinates of the mouse as the zoom point
	# MOUSE_X * character_width - h_value = MOUSE_X * new_character_width - new_h_value
	# MOUSE_Y * character_height - v_value = MOUSE_Y * new_character_height - new_v_value
	my $new_h_value = $self->{MOUSE_X} * ($new_character_width-$character_width) + $h_value ;
	my $new_v_value = $self->{MOUSE_Y} * ($new_character_height-$character_height) + $v_value ;

	$new_h_value = max(0, min($canvas_width, $new_h_value)) ;
	$new_v_value = max(0, min($canvas_height, $new_v_value)) ;

	$self->{sc_window}->get_hadjustment()->set_value($new_h_value) ;
	$self->{sc_window}->get_vadjustment()->set_value($new_v_value) ;

	}

$self->invalidate_rendering_cache() ;
$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub display_keyboard_mapping_in_browser
{
my ($self) = @_ ;

my $mapping_file = get_keyboard_mapping_file($self) ;

if(defined $ENV{BROWSER} && $ENV{BROWSER} ne '')
	{
	qx"$ENV{BROWSER} --new-window 'file://$mapping_file' &" ;
	}
else
	{
	$self->display_message_modal("Environmen variable 'BROWSER' not set.") ;
	}
}

sub get_keyboard_mapping_file
{
my ($self, $file_name) = @_ ;

my (@key_actions, @action_keys, @groups) ;

for (sort keys %{$self->{ACTIONS}})
	{
	if(exists $self->{ACTIONS}{$_}{IS_GROUP})
		{
		push @groups, [$_, $self->{ACTIONS}{$_}] ;
		}
	else
		{
		push @key_actions, sprintf "%-40s: %s\n", $_, $self->{ACTIONS}{$_}{NAME} ;
		push @action_keys, sprintf "%-40s: %s\n", $self->{ACTIONS}{$_}{NAME}, $_ ;
		}
	}

for my $group (sort { $a->[0] cmp $b->[0] } @groups)
	{
	for (grep { 'HASH' eq ref $group->[1]{$_} } sort keys %{$group->[1]})
		{
		push @key_actions, sprintf "%-40s: %s\n", "$group->[0] + $_", $group->[1]{$_}{NAME} ;
		push @action_keys, sprintf "%-40s: %s\n", $group->[1]{$_}{NAME}, "$group->[0] + $_" ;
		}
	}

my $mapping_file = $file_name // (tempfile())[1] ;
write_file($mapping_file, @key_actions, "\n\n", sort @action_keys) ;

return $mapping_file ;
}

#----------------------------------------------------------------------------------------------

sub display_commands
{
my ($self) = @_ ;

#~ print STDERR Data::TreeDumper::DumpTree $self->{ACTIONS_BY_NAME}, 'ACTIONS_BY_NAME:';

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
my ($actions) = @_ ;

my $commands ;

for my $action (keys %{$actions})
	{
	if('ARRAY' eq ref $actions->{$action})
		{
		my $shortcut =  ref $actions->{$action}[0] eq '' 
			? $actions->{$action}[0] 
			: '[' . join('/', @{$actions->{$action}[0]}) . ']';
		
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
		
		#~ print STDERR Data::TreeDumper::DumpTree $key_mapping->{$action} ;
		#~ print STDERR Data::TreeDumper::DumpTree $sub_actions ;
		
		my $shortcuts = $key_mapping->{$action}{SHORTCUTS} ;
		$shortcuts = join(' ', @{$key_mapping->{$action}{SHORTCUTS}}) 
			if('ARRAY' eq ref $key_mapping->{$action}{SHORTCUTS}) ;
		
		$actions_per_file->{$key_mapping->{$action}{ORIGIN}}{"group: $action [$shortcuts]"} 
			= $sub_actions->{$key_mapping->{$action}{ORIGIN}} ;
		}
	else
		{
		#~ print STDERR Data::TreeDumper::DumpTree $key_mapping->{$action}, $action ;
		#~ die "unknown type while running 'dump_keyboard_mapping'\n" ;
		}
	}
}

#----------------------------------------------------------------------------------------------

sub undo { my ($self) = @_ ; $self->undo(1) ; }

#----------------------------------------------------------------------------------------------

sub redo { my ($self) = @_ ; $self->redo(1) ; }

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

sub flip_connector_display
{
my ($self) = @_ ;
$self->{DISPLAY_ALL_CONNECTORS} ^=1 ;
$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub flip_grid_display
{
my ($self) = @_ ;
$self->{DISPLAY_GRID} ^=1 ;
delete $self->{CACHE}{GRID} ;
$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub flip_rulers_display
{
my ($self) = @_ ;
$self->{DISPLAY_RULERS} ^=1 ;
$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub flip_hint_lines
{
my ($self) = @_ ;
$self->{DRAW_HINT_LINES} ^=1 ;
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

sub change_font
{
my ($self) = @_ ;

my ($family, $size) = $self->get_font() ;
if($family eq 'Monospace')
	{
	$self->set_font('sarasa mono sc', 12) ;
	$self->{FONT_MIN} = 3 ;
	$self->{ZOOM_STEP} = 3 ;
	}
else
	{
	$self->set_font('Monospace', 12) ;
	$self->{FONT_MIN} = 3 ;
	$self->{ZOOM_STEP} = 1 ;
	}

$self->invalidate_rendering_cache() ;
$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

1 ;

