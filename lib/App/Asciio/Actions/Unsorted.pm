
package App::Asciio::Actions::Unsorted ;

use strict ;
use warnings ;
use utf8 ;
use Encode ;

use File::Temp qw/ tempfile / ;
use File::Slurper qw/ write_text / ;
use Data::TreeDumper ;
use List::Util qw(min max) ;
use List::MoreUtils qw(minmax) ;

use constant HAS_SPELLCHECKER => defined eval { require Text::SpellChecker };

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
"alt+lef_mouse" "."        Quick link

"ibb",                      insert a box
"ibs",                      insert a shrink box
"imb",                      Add multiple boxes
"it",                       Add a text element
"imt"                       Add multiple texts

"ia"                        Add a wirl arrow
"ad"                        Change arrow direction
"as"                        Append multi_wirl section

"ctl-z" "u"                 Undo
"ctl-y" "ctl-r"             Redo

"tab" "n"                   Select next element
"ctl-a" "V"                 Select all elements

"ctl-c/ctl-v" "y/p"         Copy/Paste elements
"ctl-e" "Y"                 Export as ascii

"gg"                        Group selected elements
"gu"                        Group object

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

my ($family, $size)                      = $self->get_font() ;
my ($font_min, $font_max)                = ($self->{FONT_MIN}  // 1, $self->{FONT_MAX} // 28) ;
my ($zoom_step, $remainder)              = ($self->{ZOOM_STEP} // 1, 0) ;
my ($character_width, $character_height) = $self->get_character_size() ;

return if $direction < 0 && $size <= $font_min ;
return if $direction > 0 && $size >= $font_max ;

$size     += ($direction * $zoom_step) ;
$remainder = $size % $zoom_step ;
$size     += $zoom_step - $remainder if $remainder ;
$size      = $font_min if $size < $font_min ;

$self->set_font($family, $size);

# resize canvas
if($self->{UI} eq 'GUI')
	{
	my ($new_character_width, $new_character_height) = $self->get_character_size() ;
	my ($canvas_width, $canvas_height)               = ($self->{CANVAS_WIDTH} * $new_character_width, $self->{CANVAS_HEIGHT} * $new_character_height) ;
	
	$self->{widget}->set_size_request($canvas_width, $canvas_height);
	
	my ($h_value, $v_value) = ($self->{hadjustment}->get_value(), $self->{vadjustment}->get_value()) ;
	
	my $new_h_value = $self->{MOUSE_X} * ($new_character_width  - $character_width)  + $h_value ;
	my $new_v_value = $self->{MOUSE_Y} * ($new_character_height - $character_height) + $v_value ;
	
	$new_h_value = max(0, min($canvas_width, $new_h_value)) ;
	$new_v_value = max(0, min($canvas_height, $new_v_value)) ;
	
	$self->{hadjustment}->set_value($new_h_value) ;
	$self->{vadjustment}->set_value($new_v_value) ;
	}

$self->invalidate_rendering_cache() ;
$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub zoom_extents
{
my ($self, @elements) = @_ ;

@elements = $self->{ELEMENTS}->@* unless @elements ;

my ($min_x, $max_x) = minmax( map { $_->{X} + $_->{EXTENTS}[0],  $_->{X} + $_->{EXTENTS}[2] } @elements );
my ($min_y, $max_y) = minmax( map { $_->{Y} + $_->{EXTENTS}[1],  $_->{Y} + $_->{EXTENTS}[3]} @elements );
my $characters_x   = $max_x - $min_x ;
my $characters_y   = $max_y - $min_y ;

my ($family, $start_size) = $self->get_font() ;
my $visible_width         = $self->{hadjustment}->get_page_size() ;
my $visible_height        = $self->{vadjustment}->get_page_size() ;

my $font_size ;
for ($font_size = $self->{FONT_MAX} // 28 ; $font_size > $self->{FONT_MIN} // 1 ; $font_size -= $self->{ZOOM_STEP} // 1) 
	{
	$self->set_font($family, $font_size);
	
	my ($character_width, $character_height) = $self->get_character_size() ;
	my ($needed_width, $needed_height)       = ($characters_x * $character_width,  $characters_y * $character_height) ;
	
	last if $visible_width >= $needed_width && $visible_height >= $needed_height ;
	}

scroll_to($self, $min_x, $min_y) ;

$self->invalidate_rendering_cache() if $font_size != $start_size ;
$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub scroll_to_element
{
my ($self, $element) = @_ ;

return unless $element ;

return ;
scroll_to($self, $element->{X}, $element->{Y}) ;
}

#----------------------------------------------------------------------------------------------

sub scroll_to
{
my ($self, $x, $y) = @_ ;

my ($character_width, $character_height) = $self->get_character_size() ;

$self->{hadjustment}->set_value($x * $character_width) ;
$self->{vadjustment}->set_value($y * $character_height) ;

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

#----------------------------------------------------------------------------------------------

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
write_text($mapping_file, "@key_actions\n\n" . join("\n", sort(@action_keys))) ;

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
delete $self->{CACHE}{BACKGROUND_AND_GRID} ;
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
$self->invalidate_rendering_cache() ;
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

sub toggle_edit_inline
{
my ($self) = @_ ;
$self->{EDIT_TEXT_INLINE} ^= 1 ;
}

#----------------------------------------------------------------------------------------------

sub spellcheck_elements
{
my ($self, $elements) = @_ ;

if(HAS_SPELLCHECKER)
	{
	$elements //= $self->{ELEMENTS} ;

	my $element_index = 0 ;
	for my $element ($elements->@*)
		{
		my $error = 0 ;
		my $input = $element->{TEXT} ;
		
		my $checker = Text::SpellChecker->new(text => $input) ;
		$checker->set_options(aspell => { 'lang' => 'en' });
		
		while (my $word = $checker->next_word) 
			{
			printf STDERR "Asciio: invalid word %-30s in element[%d] at %d,%d\n", "'$word'", $element_index, @{$element}{qw/X Y/} ;
			
			$error++ ;
			$self->{ACTIONS_STORAGE}{spell}{matches}{$element}++ ;
			}
		
		delete $self->{ACTIONS_STORAGE}{spell}{matches}{$element} unless $error ;
		
		$element_index++ ;
		}
	}

$self->update_display() ;
}

sub clear_spellcheck { my ($self) = @_ ; delete $self->{ACTIONS_STORAGE}{spell} ; $self->update_display() ; }

#----------------------------------------------------------------------------------------------

1 ;

