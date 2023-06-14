
package App::Asciio::Actions::Unsorted ;

use strict ;
use warnings ;
use utf8 ;
use Encode ;

use File::Temp qw/ tempfile / ;
use File::Slurp ;
use Data::TreeDumper ;

#----------------------------------------------------------------------------------------------

sub manpage_in_browser
{
my ($self) = @_ ;

my (undef, $manpage) = tempfile() ;

system("perldoc App::Asciio >$manpage") ;

qx"$self->{BROWSER} 'file://$manpage' &" ;
}

#----------------------------------------------------------------------------------------------

sub display_help
{
my ($self) = @_ ;


$self->display_message_modal(<<EOM) ;

"alt+lef_mouse" "."         Quick link:

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

"+" "none"                  Zoom in
"-" "none"                  Zoom out

":e"                        Open
":w"                        Save
":q"                        Quit

"none" ":m"                 Displays manpage

EOM
}

#----------------------------------------------------------------------------------------------

sub zoom
{
my ($self, $direction) = @_ ;

my ($family, $size) = $self->get_font() ;

$self->set_font($family, $size + $direction) ;

my $zoom_step = $self->{ZOOM_STEP} // 1 ;
my $font_min = $self->{FONT_MIN} // 1  ;

$size += ($direction * $zoom_step) ;

my $remainder = $size % $zoom_step ;
$size += $zoom_step - $remainder if $remainder ;

$size = $font_min if $size < $font_min ;

$self->set_font($family, $size);

$self->invalidate_rendering_cache() ;
$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub display_keyboard_mapping_in_browser
{
my ($self) = @_ ;

my $mapping_file = get_keyboard_mapping_file($self) ;

qx"$self->{BROWSER} 'file://$mapping_file' &" ;
}

sub get_keyboard_mapping_file
{
my ($self) = @_ ;

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

my $mapping_file = (tempfile())[1] ;
write_file($mapping_file, @key_actions, "\n\n", sort @action_keys) ;

return $mapping_file ;
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

sub insert_multiple_boxes_from_text_description
{
my ($self, $boxed) = @_ ;

my $text = $self->display_edit_dialog('multiple objects from input', "\ntext\ntext\ntext\ntext", $self) ;

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
delete $self->{CACHE}{GRID} ;
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

my $command = $self->display_edit_dialog('Enter command', '', $self) ;

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
	
	$output = decode("utf-8", $output);
	$output =~ s/\r//g;
	$output =~ s/\t/$self->{TAB_AS_SPACES}/g;
	
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

#----------------------------------------------------------------------------------------------

sub change_font
{
my ($self) = @_ ;

my ($family, $size) = $self->get_font() ;
if($family eq 'Monospace')
	{
	$self->set_font('sarasa mono sc', 12) ;
	$self->{FONT_MIN} = 9 ;
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

