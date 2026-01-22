
package App::Asciio::GTK::Asciio::Pen ;

use strict ; use warnings ;
use utf8;

use App::Asciio::Actions::Elements ;
use App::Asciio::ZBuffer ;
use App::Asciio::String qw(unicode_length get_keyboard_layout) ;
use App::Asciio::stripes::dot ;
use App::Asciio::Actions::Mouse ;
use App::Asciio::Geometry qw(interpolate) ;

use List::Util qw(max min) ;
use List::MoreUtils qw(any first_value);

#----------------------------------------------------------------------------------------------

sub pen_state
{
my ($asciio) = @_ ;

unless (defined $asciio->{PEN_STATE} && %{$asciio->{PEN_STATE}})
	{
	$asciio->{PEN_STATE} =
		{
		char_index                => 0,
		chars                     => ['?'],
		chars_sets                => [],
		dot_elements_to_insert    => [],
		enable                    => 0,
		existing_points           => [],
		# 'draw' 'eraser'
		sub_mode                  => 'draw',
		mouse_emulation_direction => 'static',
		mouse_states              => 
						{
						right  => { next => 'down',   type => 'right_triangle' },
						down   => { next => 'static', type => 'down_triangle' },
						static => { next => 'right',  type => 'rectangle' },
						},
		overlay_element           => undef,
		prev_char_length          => 1,
		prompt_panel_location     => 'left',
		} ;
	}

return $asciio->{PEN_STATE} ; 
}

#----------------------------------------------------------------------------------------------

sub switch_key_mapping_panel_location
{
my ($asciio) = @_ ;

$asciio->{PEN_STATE}{prompt_panel_location} = $asciio->{PEN_STATE}{prompt_panel_location} eq 'left' ? 'right' : 'left' ;
$asciio->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub draw_mouse_cursor
{
my ($gc, $emulation_mouse_type, $character_width, $character_height, $start_x, $start_y) = @_ ;

if($emulation_mouse_type eq 'right_triangle')
	{
	$gc->move_to($start_x, $start_y) ;
	$gc->line_to($start_x + $character_width, $start_y + $character_height / 2) ;
	$gc->line_to($start_x, $start_y + $character_height) ;
	$gc->close_path() ;
	$gc->fill() ;
	$gc->stroke() ;
	}
elsif($emulation_mouse_type eq 'down_triangle')
	{
	$gc->move_to($start_x + $character_width / 2, $start_y + $character_height) ;
	$gc->line_to($start_x, $start_y) ;
	$gc->line_to($start_x + $character_width, $start_y) ;
	$gc->close_path() ;
	$gc->fill() ;
	$gc->stroke() ;
	}
else
	{
	$gc->rectangle($start_x, $start_y, $character_width, $character_height) ;
	$gc->fill() ;
	$gc->stroke() ;
	}
}

#----------------------------------------------------------------------------------------------

sub show_mapping_help
{
my ($asciio, $gc) = @_ ;

if ($asciio->{PEN_STATE}{enable} && (scalar keys %{$asciio->{PEN_STATE}{chars_sets}->[0]}))
	{
	my ($prompt_background, $prompt_foreground) = ($asciio->get_color("prompt_background"), $asciio->get_color("prompt_foreground")) ;
	my $cache_key                               = $asciio->{PEN_STATE}{chars_sets}->[0] . '-' . $prompt_background . '-' . $prompt_foreground ;
	my $pen_rendering_cache                     = $asciio->{CACHE}{PEN_CHARS_MAPPING_RENDERING_CACHE}{$cache_key} ;
	
	unless (defined $pen_rendering_cache)
		{
		my $measure_surface  = Cairo::ImageSurface->create('argb32', 1, 1) ;
		my $measure_context  = Cairo::Context->create($measure_surface) ;
		my $layout           = Pango::Cairo::create_layout($measure_context) ;
		my $font_family      = "sarasa mono sc, $asciio->{FONT_FAMILY}" ;
		my $font_description = Pango::FontDescription->from_string("$font_family 12") ;
		
		$layout->set_font_description($font_description) ;
		
		my $current_mapping_group = $asciio->{PEN_STATE}{chars_sets}->[0] ;
		my $keyboard_ascii        = get_keyboard_layout($current_mapping_group, $asciio->{PEN_KEYBOARD_LAYOUT_NAME}) ;
		
		$layout->set_text($keyboard_ascii) ;
		
		my ($ink_rect, $logical_rect) = $layout->get_extents() ;
		my $text_w                    = $ink_rect->{width}  / Pango::SCALE ;
		my $text_h                    = $ink_rect->{height} / Pango::SCALE ;
		
		my $surface = Cairo::ImageSurface->create('argb32', $text_w, $text_h) ;
		my $gco     = Cairo::Context->create($surface) ;
		
		# draw background
		$gco->set_source_rgba(@{$prompt_background}) ;
		$gco->rectangle(0, 0, $surface->get_width(), $surface->get_height()) ;
		$gco->fill ;
		
		my $layout2 = Pango::Cairo::create_layout($gco) ;
		$layout2->set_font_description($font_description) ;
		$layout2->set_text($keyboard_ascii) ;
		
		$gco->set_source_rgba(@{$prompt_foreground}) ;
		$gco->move_to(0, 0) ;
		Pango::Cairo::show_layout($gco, $layout2) ;
		
		$asciio->{CACHE}{PEN_CHARS_MAPPING_RENDERING_CACHE}{$cache_key} = $pen_rendering_cache = $surface ;
		}
	
	my ($overlay_location_x, $overlay_location_y) = ($asciio->{hadjustment}->get_value(), $asciio->{vadjustment}->get_value()) ;
	
	if ($asciio->{PEN_STATE}{prompt_panel_location} eq 'right')
		{
		my $window_width    = $asciio->get_allocated_width() ;
		$overlay_location_x = max($overlay_location_x, $overlay_location_x + $window_width - $pen_rendering_cache->get_width()) ;
		}
	
	$gc->set_source_surface($pen_rendering_cache, $overlay_location_x, $overlay_location_y) ;
	$gc->paint ;
	$gc->stroke() ;
	}
}

#----------------------------------------------------------------------------------------------

sub switch_next_character_sets
{
my ($asciio) = @_ ;

push @{$asciio->{PEN_STATE}{chars_sets}}, shift @{$asciio->{PEN_STATE}{chars_sets}} ;
$asciio->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub switch_previous_character_sets
{
my ($asciio) = @_ ;

unshift@{$asciio->{PEN_STATE}{chars_sets}}, pop @{$asciio->{PEN_STATE}{chars_sets}} ;
$asciio->update_display() ;
}

#----------------------------------------------------------------------------------------------
sub set_overlay
{
my ($asciio) = @_ ;

if($asciio->{PEN_STATE}{sub_mode} eq 'eraser')
	{
	$asciio->{PEN_STATE}{overlay_element} = Clone::clone(App::Asciio::stripes::dot->new({TEXT => ' ', NAME => 'dot'})) ;
	}
else
	{
	$asciio->{PEN_STATE}{overlay_element} = Clone::clone($asciio->{PEN_STATE}{dot_elements_to_insert}->[$asciio->{PEN_STATE}{char_index}]) ;
	}

$asciio->set_element_position($asciio->{PEN_STATE}{overlay_element}, $asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) ;
}

#----------------------------------------------------------------------------------------------

sub create_clone_elements
{
my ($asciio, @chars) = @_ ;

@{$asciio->{PEN_STATE}{dot_elements_to_insert}} = () ;
$asciio->{PEN_STATE}{char_index} = 0 ;

for my $char (@chars)
	{
	push @{$asciio->{PEN_STATE}{dot_elements_to_insert}}, Clone::clone(App::Asciio::stripes::dot->new({TEXT => $char, NAME => 'dot'})) ;
	}
}

#----------------------------------------------------------------------------------------------

sub get_overlay
{
my ($asciio, $UI_type, $gc, $widget_width, $widget_height, $character_width, $character_height) = @_ ;
$asciio->set_element_position($asciio->{PEN_STATE}{overlay_element}, $asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) ;

$asciio->{PEN_STATE}{overlay_element} ;
}

#----------------------------------------------------------------------------------------------

sub custom_mouse_cursor
{
my ($asciio) = @_;

my %cursors = ( eraser => 'icon', draw => 'xterm',) ;

my $sub_mode = $asciio->{PEN_STATE}{sub_mode};
my $cursor = $cursors{$sub_mode} // 'left_ptr' ;

$asciio->change_cursor($cursor) ;
}

#----------------------------------------------------------------------------------------------

sub set_overlays_sub
{
my ($asciio) = @_ ;

if(		($asciio->{PEN_STATE}{sub_mode} eq 'eraser' )
	||	($asciio->{SIMULATE_MOUSE_TYPE} eq 'rectangle'))
	{
	set_overlay($asciio) ;
	$asciio->set_overlays_sub(\&get_overlay) ;
	}
else
	{
	$asciio->set_overlays_sub(undef) ;
	}
}

#----------------------------------------------------------------------------------------------

sub handle_secondary_input
{
my ($asciio) = @_ ;

if($asciio->{PEN_STATE}{sub_mode} eq 'draw')
	{
	pen_enter($asciio, undef, 1, $asciio->{PEN_STATE}{mouse_emulation_direction}) ;
	}
}

#----------------------------------------------------------------------------------------------

sub sub_mode_switch
{
my ($asciio, $sub_mode) = @_ ;

$asciio->{MOUSE_TOGGLE} = 1 ;
$asciio->{PEN_STATE}{sub_mode} = $sub_mode ;

custom_mouse_cursor($asciio) ;
set_overlays_sub($asciio) ;

$asciio->update_display ;
}

#----------------------------------------------------------------------------------------------

sub enter_then_move_mouse
{
my ($asciio, $chars) = @_ ;

$asciio->create_undo_snapshot() ;
pen_enter($asciio, $chars, undef, $asciio->{PEN_STATE}{mouse_emulation_direction}, 1) ;
}

#----------------------------------------------------------------------------------------------

sub toggle_mouse_emulation_move_direction ()
{
my ($asciio) = @_ ;

$asciio->{PEN_STATE}{mouse_emulation_direction} = $asciio->{PEN_STATE}{mouse_states}{$asciio->{PEN_STATE}{mouse_emulation_direction}}{next} ;
$asciio->{SIMULATE_MOUSE_TYPE}          = $asciio->{PEN_STATE}{mouse_states}{$asciio->{PEN_STATE}{mouse_emulation_direction}}{type} ;

set_overlays_sub($asciio) ;
$asciio->update_display() ;
}

#---------------------------------------------------------------------------------------------

sub mouse_emulation_enter
{
my ($asciio) = @_ ;

pen_state($asciio) ;

# Mouse drawing function bound to Pen
$asciio->{DRAW_MOUSE_CURSOR} = \&App::Asciio::GTK::Asciio::Pen::draw_mouse_cursor ;

$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
$asciio->{SIMULATE_MOUSE_TYPE}              = $asciio->{PEN_STATE}{mouse_states}{$asciio->{PEN_STATE}{mouse_emulation_direction}}{type} ;
$asciio->change_cursor('left_ptr') ;
pen_enter($asciio) ;

sub_mode_switch($asciio, 'draw') ;
}

#---------------------------------------------------------------------------------------------

sub mouse_emulation_escape
{
my ($asciio) = @_ ;

delete $asciio->{DRAW_MOUSE_CURSOR} ;
$asciio->{MOUSE_TOGGLE} = 0 ;
pen_escape($asciio) ;
}

#---------------------------------------------------------------------------------------------

sub mouse_emulation_move_space
{
my ($asciio) = @_ ;

return if $asciio->{PEN_STATE}{mouse_emulation_direction} eq 'static' ;

App::Asciio::Actions::Mouse::mouse_move
				(
				$asciio, 
				$asciio->{PEN_STATE}{mouse_emulation_direction} eq 'right' 
					? [$asciio->{PEN_STATE}{prev_char_length}, 0] 
					: [0, $asciio->{PEN_STATE}{prev_char_length}]
				) ;
}


#---------------------------------------------------------------------------------------------

sub mouse_emulation_move_left_tab
{
my ($asciio) = @_ ;

return if $asciio->{PEN_STATE}{mouse_emulation_direction} eq 'static' ;

App::Asciio::Actions::Mouse::mouse_move
				(
				$asciio, 
				$asciio->{PEN_STATE}{mouse_emulation_direction} eq 'right' 
					? [-4, 0] 
					: [0, -4]
				) ;
}

#---------------------------------------------------------------------------------------------

sub mouse_emulation_move_right_tab
{
my ($asciio) = @_ ;

return if $asciio->{PEN_STATE}{mouse_emulation_direction} eq 'static' ;

App::Asciio::Actions::Mouse::mouse_move
				(
				$asciio, 
				$asciio->{PEN_STATE}{mouse_emulation_direction} eq 'right' 
					? [4, 0] 
					: [0, 4]
				) ;
}

#---------------------------------------------------------------------------------------------

sub mouse_emulation_move_left
{
my ($asciio) = @_ ;
App::Asciio::Actions::Mouse::mouse_move($asciio, [-$asciio->{PEN_STATE}{prev_char_length}, 0]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#---------------------------------------------------------------------------------------------

sub mouse_emulation_move_right
{
my ($asciio) = @_ ;

App::Asciio::Actions::Mouse::mouse_move($asciio, [$asciio->{PEN_STATE}{prev_char_length}, 0]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#---------------------------------------------------------------------------------------------

sub mouse_emulation_move_up
{
my ($asciio) = @_ ;
App::Asciio::Actions::Mouse::mouse_move($asciio, [0, -1]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#---------------------------------------------------------------------------------------------

sub mouse_emulation_move_down
{
my ($asciio) = @_ ;
App::Asciio::Actions::Mouse::mouse_move($asciio, [0, 1]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#---------------------------------------------------------------------------------------------

sub mouse_emulation_move_up_quick
{
my ($asciio) = @_ ;
App::Asciio::Actions::Mouse::mouse_move($asciio, [0, -4]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#---------------------------------------------------------------------------------------------

sub mouse_emulation_move_down_quick
{
my ($asciio) = @_ ;
App::Asciio::Actions::Mouse::mouse_move($asciio, [0, 4]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#---------------------------------------------------------------------------------------------

sub mouse_emulation_move_right_quick
{
my ($asciio) = @_ ;
App::Asciio::Actions::Mouse::mouse_move($asciio, [4, 0]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#---------------------------------------------------------------------------------------------

sub mouse_emulation_move_left_quick
{
my ($asciio) = @_ ;
App::Asciio::Actions::Mouse::mouse_move($asciio, [-4, 0]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#----------------------------------------------------------------------------------------------

sub pen_enter
{
my ($asciio, $chars, $no_selected_elements, $mouse_move_direction, $is_key_char) = @_ ;

$asciio->{PEN_STATE}{enable} = 1 ;

unless(@{$asciio->{PEN_STATE}{chars_sets}})
{
	@{$asciio->{PEN_STATE}{chars_sets}} = @{ $asciio->{PEN_CHARS_SETS} } ;
	
	if (!@{$asciio->{PEN_STATE}{chars_sets}}
		|| ref($asciio->{PEN_STATE}{chars_sets}->[0]) ne 'HASH'
		|| keys %{ $asciio->{PEN_STATE}{chars_sets}->[0] } )
		{
		unshift @{$asciio->{PEN_STATE}{chars_sets}}, {} ;
		}
	}

my @get_chars ;

if(defined $chars)
	{
	if($is_key_char && exists $asciio->{PEN_STATE}{chars_sets}->[0]->{$chars->[0]})
		{
		@{$asciio->{PEN_STATE}{chars}} = $asciio->{PEN_STATE}{chars_sets}->[0]->{$chars->[0]} ;
		}
	else
		{
		@{$asciio->{PEN_STATE}{chars}} = @{$chars} ;
		}
	}
else
	{
	if($asciio->get_selected_elements(1) && (!defined $no_selected_elements))
		{
		my $select_elements_zbuffer = App::Asciio::ZBuffer->new(0, $asciio->get_selected_elements(1)) ;
		for my $key
			(
			sort
				{
				my ($ay, $ax) = split /;/, $a ;
				my ($by, $bx) = split /;/, $b ;
				
				$ay <=> $by || $ax <=> $bx
				} keys %{$select_elements_zbuffer->{coordinates}}
			)
			{
			my $value = $select_elements_zbuffer->{coordinates}{$key} ;
			
			next if $value =~ /^\s*$/ ;
			push @get_chars, $value ;
			}
		}
	else
		{
		my $current_point = $asciio->{MOUSE_Y} . ';' . $asciio->{MOUSE_X} ;
		my ($first_element) = first_value {$asciio->is_over_element($_, $asciio->{MOUSE_X}, $asciio->{MOUSE_Y})} reverse @{$asciio->{ELEMENTS}} ;
		my $current_char ;
		
		if($first_element)
			{
			$current_char = App::Asciio::ZBuffer->new(0, $first_element)->{coordinates}{$current_point} // ' ' ;
			}
		else
			{
			$current_char = ' ' ;
			}
		
		push @get_chars, $current_char unless $current_char =~ /^\s*$/ ;
		}
	@{$asciio->{PEN_STATE}{chars}} = @get_chars if @get_chars ;
	}

create_clone_elements($asciio, @{$asciio->{PEN_STATE}{chars}}) ;

# set_overlays_sub($asciio) ;

if(defined $chars)
	{
	handle_primary_input($asciio, $mouse_move_direction) ;
	}
else
	{
	$asciio->update_display ;
	}
}

#----------------------------------------------------------------------------------------------

sub pen_escape
{
my ($asciio) = @_ ;

$asciio->set_overlays_sub(undef) ;
$asciio->change_cursor('left_ptr') ;

$asciio->{PEN_STATE}{enable} = 0 ;

$asciio->update_display ;
}

#----------------------------------------------------------------------------------------------

sub pen_mouse_motion
{
my ($asciio, $event) = @_ ;

my ($x, $y) = @{$event->{COORDINATES}}[0,1] ;

($asciio->{PREVIOUS_X}, $asciio->{PREVIOUS_Y}) = ($asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) ;
($asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) = ($x, $y) ;

if($event->{STATE} eq 'dragging-button1' && ($asciio->{PREVIOUS_X} != $x || $asciio->{PREVIOUS_Y} != $y))
	{
	$asciio->set_overlays_sub(undef) ;
	
	my @points = interpolate
			(
			$asciio->{PREVIOUS_X}, $asciio->{PREVIOUS_Y}, $x, $y,
			sub 
				{ 
				my $len = scalar @{ $asciio->{PEN_STATE}{dot_elements_to_insert} } ;
				$asciio->{PEN_STATE}{sub_mode} eq 'draw'
					? unicode_length($asciio->{PEN_STATE}{chars}->[($asciio->{PEN_STATE}{char_index}+shift) % $len - 1])
					: 1
				},
			1,
			$asciio->{PEN_STATE}{existing_points}
			);
	
	for my $point (@points)
		{
		next if any { $_->[0] == $point->[0] && $_->[1] == $point->[1] } @{$asciio->{PEN_STATE}{existing_points}} ;
		($asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) = @$point ;
		handle_primary_input($asciio) ;
		}
	
	@{$asciio->{PEN_STATE}{existing_points}} = @points ;
	}

if($event->{STATE} ne 'dragging-button1')
	{
	@{$asciio->{PEN_STATE}{existing_points}} = ([$asciio->{MOUSE_X}, $asciio->{MOUSE_Y}]) ;
	set_overlays_sub($asciio) ;
	}

$asciio->update_display ;
}

#----------------------------------------------------------------------------------------------

sub handle_primary_input
{
my ($asciio, $mouse_move_direction) = @_ ;

if($asciio->{PEN_STATE}{sub_mode} eq 'eraser')
	{
	pen_delete_element($asciio) ;
	}
elsif($asciio->{PEN_STATE}{sub_mode} eq 'draw')
	{
	pen_add_element($asciio, $mouse_move_direction) ;
	}
}

#----------------------------------------------------------------------------------------------

sub mouse_emulation_press_enter_key
{
my ($asciio) = @_ ;

return if $asciio->{PEN_STATE}{mouse_emulation_direction} eq 'static' ;

if(defined $asciio->{MOUSE_EMULATION_FIRST_COORDINATE})
	{
	if($asciio->{PEN_STATE}{mouse_emulation_direction} eq 'right')
		{
		($asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) = ($asciio->{MOUSE_EMULATION_FIRST_COORDINATE}->[0], $asciio->{MOUSE_EMULATION_FIRST_COORDINATE}->[1] + 1) ;
		}
	else
		{
		($asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) = ($asciio->{MOUSE_EMULATION_FIRST_COORDINATE}->[0] + 1, $asciio->{MOUSE_EMULATION_FIRST_COORDINATE}->[1]) ;
		}
	
	$asciio->update_display() ;
	}

$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#----------------------------------------------------------------------------------------------

sub pen_add_element
{
my ($asciio, $mouse_move_direction) = @_ ;

my $add_dot                    = Clone::clone($asciio->{PEN_STATE}{dot_elements_to_insert}->[$asciio->{PEN_STATE}{char_index}]) ;
$asciio->{PEN_STATE}{prev_char_length} = unicode_length($asciio->{PEN_STATE}{chars}->[$asciio->{PEN_STATE}{char_index}]) ;

@$add_dot{'X', 'Y', 'SELECTED'} = ($asciio->{MOUSE_X}, $asciio->{MOUSE_Y}, 0) ;

# If there are one or more dot elements below the current coordinate, delete it.
pen_delete_element($asciio, 1) ;

$asciio->add_elements($add_dot);

my $len                          = scalar @{ $asciio->{PEN_STATE}{dot_elements_to_insert} } ;
$asciio->{PEN_STATE}{char_index}         = ($asciio->{PEN_STATE}{char_index} + 1) % $len ;
@{$asciio->{PEN_STATE}{existing_points}} = ([$asciio->{MOUSE_X}, $asciio->{MOUSE_Y}]) ;

@{$asciio->{MOUSE_EMULATION_FIRST_COORDINATE}} = ($asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) unless(defined $asciio->{MOUSE_EMULATION_FIRST_COORDINATE}) ;

mouse_move_forward($asciio) if($mouse_move_direction) ;

$asciio->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub pen_delete_element
{
my ($asciio, $dot_delete_only) = @_ ;

my @elements ;

if($dot_delete_only)
	{
	@elements = grep
			{
			   ( ref($_) eq 'App::Asciio::stripes::dot' )  
			&& ( $asciio->is_over_element($_, $asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) ) 
			} reverse @{$asciio->{ELEMENTS}} ;
	}
else
	{
	@elements = grep { $asciio->is_over_element($_, $asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) } reverse @{$asciio->{ELEMENTS}} ;
	}

if(@elements)
	{
	$asciio->delete_elements(@elements) ;
	
	@{$asciio->{PEN_STATE}{existing_points}} = ([$asciio->{MOUSE_X}, $asciio->{MOUSE_Y}]) ;
	$asciio->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

sub mouse_move_forward
{
my ($asciio) = @_ ;

return if $asciio->{PEN_STATE}{mouse_emulation_direction} eq 'static' ;

if($asciio->{PEN_STATE}{mouse_emulation_direction} eq 'down')
	{
	$asciio->{MOUSE_Y}++ ;
	}
else
	{
	$asciio->{MOUSE_X} += $asciio->{PEN_STATE}{prev_char_length} ;
	}
}

#----------------------------------------------------------------------------------------------

sub mouse_move_backward
{
my ($asciio) = @_ ;

return if $asciio->{PEN_STATE}{mouse_emulation_direction} eq 'static' ;

if($asciio->{PEN_STATE}{mouse_emulation_direction} eq 'down')
	{
	$asciio->{MOUSE_Y}-- ;
	}
else
	{
	$asciio->{MOUSE_X}-- ;
	}
}

#----------------------------------------------------------------------------------------------

sub pen_back_delete_element
{
my ($asciio, $dot_delete_only) = @_ ;

mouse_move_backward($asciio) ;
pen_delete_element($asciio, $dot_delete_only) ;
}

#----------------------------------------------------------------------------------------------

1 ;

