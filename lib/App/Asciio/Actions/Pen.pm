
package App::Asciio::Actions::Pen ;

use App::Asciio::Actions::Elements ;
use App::Asciio::ZBuffer ;
use App::Asciio::String qw(unicode_length) ;
use App::Asciio::stripes::pixel ;
use App::Asciio::Actions::Mouse ;

use utf8;

use strict ; use warnings ;

use List::Util qw(max min) ;
use List::MoreUtils qw(any first_value);

my @pixel_elements_to_insert ;

my $overlay_element ;

my @pen_chars = ('?') ;
my @last_points;

my $char_index = 0 ;
my $char_num ;
my $is_eraser = 0 ;
my $last_char_lenth = 1;

my %direction_map = (
    'right'  => 'down',
    'down'   => 'static',
    'static' => 'right',
) ;

my %simulate_mouse_type_map = (
	'right' => 'right_triangle',
	'down'  => 'down_triangle',
	'static'=> 'rectangle',
) ;

my $mouse_emulation_move_direction = 'static' ;

my @keyboard_layout = (
    ['`', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 'BS'],
    ['Tab', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\\'],
    ['CL', 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", 'Enter'],
    ['Shift', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 'Shift'],
) ;


# :TODO: US keyboards and German keyboards may be different, this should not be hardcoded, flexibility needs to be added
my %key_widths = map { $_ => 30 } ('`', '0'..'9', '-', '=', 'a'..'z', ';', '\'', ',', '.', '/', '[', ']') ;
@key_widths{'BS', 'Tab', '\\', 'CL', 'Enter', 'Shift'} = (60, 45, 45, 51, 69, 75) ;

my %pen_uc = map { $_ => uc($_) } ('a'..'z') ;
@pen_uc{'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '-', '=', '`', '[', ']', '\\', ';', "'", ',', '.', '/'} = (
		')', '!', '@', '#', '$', '%', '^', '&', '*', '(', '_', '+', '~', '{', '}', '|',  ':', '"', '<', '>', '?'
		) ;

my $pen_mode_enable = 0 ;
my $pen_show_mapping_location = 'left' ;

#----------------------------------------------------------------------------------------------
sub pen_switch_show_mapping_help_location
{
my ($asciio) = @_ ;

$pen_show_mapping_location = ($pen_show_mapping_location eq 'left') ? 'right' : 'left' ;
}

#----------------------------------------------------------------------------------------------
sub pen_show_mapping_help
{
my ($asciio, $gc) = @_ ;

if($pen_mode_enable && (scalar keys %{$asciio->{PEN_MODE_CHARS_SETS}->[0]}))
	{
	my $pen_randering_cache = $asciio->{CACHE}{PEN_CHARS_MAPPING_RENDERING_CACHE}{$asciio->{PEN_MODE_CHARS_SETS}->[0]} ;

	my ($font_character_width, $font_character_height) = (9, 21) ;
	my ($width, $height) = (60 * $font_character_width, 30 * $font_character_height) ;
	
	my ($window_width, $window_height) = $asciio->{root_window}->get_size() ;
	my ($scroll_bar_x, $scroll_bar_y)  = ($asciio->{sc_window}->get_hadjustment()->get_value(), $asciio->{sc_window}->get_vadjustment()->get_value()) ;

	my ($overlay_location_x, $overlay_location_y) = ($scroll_bar_x, $scroll_bar_y) ;

	if($pen_show_mapping_location eq 'right')
		{
		$overlay_location_x = max($scroll_bar_x, $scroll_bar_x + $window_width - $width) ;
		}
	
	unless(defined $pen_randering_cache)
		{
		my $surface = Cairo::ImageSurface->create('argb32', $width, $height) ;
		my $gco = Cairo::Context->create($surface) ;
		
		my $current_mapping_group = $asciio->{PEN_MODE_CHARS_SETS}->[0];

		my $layout = Pango::Cairo::create_layout($gco) ;
		my $font_description = Pango::FontDescription->from_string("$asciio->{FONT_FAMILY} 9") ;
		$layout->set_font_description($font_description) ;

		my $key_height = 60 ;

		for my $row (0..$#keyboard_layout) 
			{
			my $x = 30 ;
			for my $col (0..$#{$keyboard_layout[$row]})
				{
				my $key = $keyboard_layout[$row][$col];

				my $y = ($row+1) * $key_height;

				# Draw the rectangle for the key
				$gco->set_source_rgba(0.678, 0.847, 0.902, 1);  # Set color to light blue
				$gco->rectangle($x, $y, $key_widths{$key}, $key_height);
				$gco->fill;

				# Draw the border of the key
				$gco->set_source_rgba(0.565, 0.933, 0.565, 1);  # Set color to light green
				$gco->rectangle($x, $y, $key_widths{$key}, $key_height);
				$gco->stroke;

				# Draw the original key
				$gco->set_source_rgba(0, 0, 0, 1);  # Set color to black
				$gco->move_to($x + $key_widths{$key} / 3, $y + $key_height / 8);
				$layout->set_text($key);
				Pango::Cairo::show_layout($gco, $layout) ;

				# Draw the mapped key
				if(exists $current_mapping_group->{$key})
					{
					$gco->set_source_rgba(1, 0, 0, 1);  # Set color to red
					$gco->move_to($x + $key_widths{$key} / 3, $y + $key_height / 2.5);
					$layout->set_text($current_mapping_group->{$key});
					Pango::Cairo::show_layout($gco, $layout) ;
					}

				# Draw the uppercase mapped key
				if(exists $pen_uc{$key} && exists $current_mapping_group->{$pen_uc{$key}})
					{
					$gco->set_source_rgba(0.502, 0, 0.502, 1);  # Set color to purple
					$gco->move_to($x + $key_widths{$key} / 3, $y + 3 * $key_height / 4);
					$layout->set_text($current_mapping_group->{$pen_uc{$key}});
					Pango::Cairo::show_layout($gco, $layout) ;
					}
				$x += $key_widths{$key} ;
				}
			}
		$asciio->{CACHE}{PEN_CHARS_MAPPING_RENDERING_CACHE}{$asciio->{PEN_MODE_CHARS_SETS}->[0]} = $pen_randering_cache = $surface ;
		}
	$gc->set_source_surface($pen_randering_cache, $overlay_location_x, $overlay_location_y) ;
	$gc->paint;
	
	$gc->stroke() ;
	}
}

#----------------------------------------------------------------------------------------------
sub pen_switch_next_character_sets
{
my ($asciio) = @_ ;

push @{$asciio->{PEN_MODE_CHARS_SETS}}, shift @{$asciio->{PEN_MODE_CHARS_SETS}} ;
}

#----------------------------------------------------------------------------------------------
sub pen_switch_previous_character_sets
{
my ($asciio) = @_ ;

unshift @{$asciio->{PEN_MODE_CHARS_SETS}}, pop @{$asciio->{PEN_MODE_CHARS_SETS}} ;
}

#----------------------------------------------------------------------------------------------
sub pen_set_overlay
{
my ($asciio) = @_;

if($is_eraser)
	{
	$overlay_element = Clone::clone(App::Asciio::stripes::pixel->new({TEXT => ' ', NAME => 'pixel'})) ;
	}
else
	{
	$overlay_element = Clone::clone($pixel_elements_to_insert[$char_index]) ;
	}

$asciio->set_element_position($overlay_element, $asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) ;

}

#----------------------------------------------------------------------------------------------

sub pen_create_clone_elements
{
my ($asciio, @chars) = @_ ;

@pixel_elements_to_insert = ();
$char_index = 0 ;

for my $char (@chars)
	{
	push @pixel_elements_to_insert, Clone::clone(App::Asciio::stripes::pixel->new({TEXT => $char, NAME => 'pixel'})) ;
	}
$char_num = $#pixel_elements_to_insert + 1;
}

#----------------------------------------------------------------------------------------------
sub pen_get_overlay
{
my ($asciio, $UI_type, $gc, $widget_width, $widget_height, $character_width, $character_height) = @_;
$asciio->set_element_position($overlay_element, $asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) ;

$overlay_element ;
}

#----------------------------------------------------------------------------------------------
sub pen_custom_mouse_cursor
{
my ($asciio) = @_ ;

$asciio->change_custom_cursor(($is_eraser) ? 'eraser' : 'pen') ;
}

#----------------------------------------------------------------------------------------------
sub pen_set_overlays_sub
{
my ($asciio) = @_ ;

if($is_eraser || ($asciio->{SIMULATE_MOUSE_TYPE} eq 'rectangle'))
	{
	pen_set_overlay($asciio) ;
	$asciio->set_overlays_sub(\&pen_get_overlay) ;
	}
else
	{
	$asciio->set_overlays_sub(undef) ;
	}
}

#----------------------------------------------------------------------------------------------
sub mouse_change_char
{
my ($asciio) = @_;
pen_enter($asciio, undef, 1, $mouse_emulation_move_direction) ;
}

#----------------------------------------------------------------------------------------------
sub pen_eraser_switch
{
my ($asciio) = @_ ;

$is_eraser ^= 1 ;

pen_custom_mouse_cursor($asciio) ;
pen_set_overlays_sub($asciio) ;
$asciio->update_display ;
}

#----------------------------------------------------------------------------------------------
sub eraser_enter
{
my ($asciio) = @_ ;

$is_eraser = 1 ;

pen_enter($asciio, undef, 1) ;
}

#----------------------------------------------------------------------------------------------
sub pen_enter_then_move_mouse
{
my ($asciio, $chars) = @_ ;

$asciio->create_undo_snapshot() ;
pen_enter($asciio, $chars, undef, $mouse_emulation_move_direction, 1) ;
}

#----------------------------------------------------------------------------------------------
sub toggle_mouse_emulation_move_direction ()
{
my ($asciio) = @_ ;

$mouse_emulation_move_direction = $direction_map{$mouse_emulation_move_direction} ;
$asciio->{SIMULATE_MOUSE_TYPE} = $simulate_mouse_type_map{$mouse_emulation_move_direction} ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_enter
{
my ($asciio) = @_ ;

$asciio->{MOUSE_TOGGLE} = 1 ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
$asciio->{SIMULATE_MOUSE_TYPE} = $simulate_mouse_type_map{$mouse_emulation_move_direction} ;
pen_enter($asciio) ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_escape
{
my ($asciio) = @_ ;

$asciio->{MOUSE_TOGGLE} = 0 ;
pen_escape($asciio) ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_move_space
{
my ($asciio) = @_ ;

return if $mouse_emulation_move_direction eq 'static' ;

App::Asciio::Actions::Mouse::mouse_move(
	$asciio, 
	$mouse_emulation_move_direction eq 'right' 
		? [$last_char_lenth, 0] 
		: [0, $last_char_lenth]) ;
}


#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_move_left_tab
{
my ($asciio) = @_ ;

return if $mouse_emulation_move_direction eq 'static' ;

App::Asciio::Actions::Mouse::mouse_move(
	$asciio, 
	$mouse_emulation_move_direction eq 'right' 
		? [-4, 0] 
		: [0, -4]) ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_move_right_tab
{
my ($asciio) = @_ ;

return if $mouse_emulation_move_direction eq 'static' ;

App::Asciio::Actions::Mouse::mouse_move(
	$asciio, 
	$mouse_emulation_move_direction eq 'right' 
		? [4, 0] 
		: [0, 4]) ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_move_left
{
my ($asciio) = @_ ;
App::Asciio::Actions::Mouse::mouse_move($asciio, [-$last_char_lenth, 0]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_move_right
{
my ($asciio) = @_ ;

App::Asciio::Actions::Mouse::mouse_move($asciio, [$last_char_lenth, 0]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_move_up
{
my ($asciio) = @_ ;
App::Asciio::Actions::Mouse::mouse_move($asciio, [0, -1]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_move_down
{
my ($asciio) = @_ ;
App::Asciio::Actions::Mouse::mouse_move($asciio, [0, 1]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_move_up_quick
{
my ($asciio) = @_ ;
App::Asciio::Actions::Mouse::mouse_move($asciio, [0, -4]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_move_down_quick
{
my ($asciio) = @_ ;
App::Asciio::Actions::Mouse::mouse_move($asciio, [0, 4]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_move_right_quick
{
my ($asciio) = @_ ;
App::Asciio::Actions::Mouse::mouse_move($asciio, [4, 0]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_move_left_quick
{
my ($asciio) = @_ ;
App::Asciio::Actions::Mouse::mouse_move($asciio, [-4, 0]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#----------------------------------------------------------------------------------------------
sub pen_enter
{
my ($asciio, $chars, $no_selected_elements, $mouse_move_direction, $is_key_char) = @_;

$pen_mode_enable = 1;

# custom mouse cursor
pen_custom_mouse_cursor($asciio) ;

my @get_chars ;

if(defined $chars)
	{
	if($is_key_char && exists $asciio->{PEN_MODE_CHARS_SETS}->[0]->{$chars->[0]})
		{
		@pen_chars = $asciio->{PEN_MODE_CHARS_SETS}->[0]->{$chars->[0]} ;
		}
	else
		{
		@pen_chars = @{$chars} ;
		}
	}
else
	{
	if($asciio->get_selected_elements(1) && (!defined $no_selected_elements))
		{
		my $select_elements_zbuffer = App::Asciio::ZBuffer->new(0, $asciio->get_selected_elements(1)) ;
		for my $key (sort {
			my ($ay, $ax) = split /;/, $a;
			my ($by, $bx) = split /;/, $b;
			$ay <=> $by || $ax <=> $bx
			} keys %{$select_elements_zbuffer->{coordinates}})
			{
			my $value = $select_elements_zbuffer->{coordinates}{$key};
			next if $value =~ /^\s*$/;
			push @get_chars, $value;
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
	@pen_chars = @get_chars if @get_chars ;
	}

pen_create_clone_elements($asciio, @pen_chars) ;

pen_set_overlays_sub($asciio) ;

if(defined $chars)
	{
	pen_add_or_delete_element($asciio, $mouse_move_direction) ;
	}
else
	{
	$asciio->update_display ;
	}
}

#----------------------------------------------------------------------------------------------

sub pen_escape
{
my ($asciio, $is_eraser_escape) = @_;

$is_eraser = 0 if $is_eraser_escape ;

$asciio->set_overlays_sub(undef);
$asciio->change_cursor('left_ptr');



$pen_mode_enable = 0 ;

$asciio->update_display ;
}

#----------------------------------------------------------------------------------------------
sub interpolate 
{
my ($x0, $y0, $x1, $y1) = @_;
my @points = @last_points;
my $point_offset = 0;

my ($dx, $dy) = ($x1 - $x0, $y1 - $y0) ;
my $steps = max(abs($dx), abs($dy));

for(my $i = 0; $i <= $steps; $i++)
	{
	my $t = $steps == 0 ? 0 : ($i / $steps);
	my ($x, $y) = (int($x0 + $dx * $t), int($y0 + $dy * $t)) ;
	
	next if any { $_->[0] == $x && $_->[1] == $y } @points ;
	
	if (!@points
		|| $y != $points[$#points][1]
		|| abs($x - $points[$#points][0]) >= (($is_eraser) ? 1 : unicode_length(
		$pen_chars[($char_index+$point_offset) % $char_num - 1])))
		{
		push @points, [$x, $y];
		$point_offset++;
		}
	}
return @points ;
}

#----------------------------------------------------------------------------------------------
sub pen_mouse_motion
{
my ($asciio, $event) = @_;

my ($x, $y) = @{$event->{COORDINATES}}[0,1] ;

($asciio->{PREVIOUS_X}, $asciio->{PREVIOUS_Y}) = ($asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) ;
($asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) = ($x, $y) ;

if($event->{STATE} eq 'dragging-button1' && ($asciio->{PREVIOUS_X} != $x || $asciio->{PREVIOUS_Y} != $y))
	{
	$asciio->set_overlays_sub(undef);
	my @points = interpolate($asciio->{PREVIOUS_X}, $asciio->{PREVIOUS_Y}, $x, $y) ;
	
	for my $point (@points)
		{
		next if any { $_->[0] == $point->[0] && $_->[1] == $point->[1] } @last_points ;
		($asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) = @$point ;
		pen_add_or_delete_element($asciio) ;
		}
	@last_points = @points ;
	}

if($event->{STATE} ne 'dragging-button1')
	{
	@last_points = ([$asciio->{MOUSE_X}, $asciio->{MOUSE_Y}]);
	pen_set_overlays_sub($asciio) ;
	$asciio->update_display ;
	}
}

#----------------------------------------------------------------------------------------------
sub pen_add_or_delete_element
{
my ($asciio, $mouse_move_direction) = @_ ;
if($is_eraser)
	{
	pen_delete_element($asciio) ;
	}
else
	{
	pen_add_element($asciio, $mouse_move_direction) ;
	}
}

#----------------------------------------------------------------------------------------------
sub mouse_emulation_press_enter_key
{
my ($asciio) = @_ ;

return if $mouse_emulation_move_direction eq 'static' ;

if(defined $asciio->{MOUSE_EMULATION_FIRST_COORDINATE})
{
if($mouse_emulation_move_direction eq 'right')
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

my $add_pixel = Clone::clone($pixel_elements_to_insert[$char_index]) ;
$last_char_lenth = unicode_length($pen_chars[$char_index]) ;

@$add_pixel{'X', 'Y', 'SELECTED'} = ($asciio->{MOUSE_X}, $asciio->{MOUSE_Y}, 0) ;

# If there are one or more pixel elements below the current coordinate, delete it.
# :TODO: It’s more time consuming here
pen_delete_element($asciio, 1) ;

$asciio->add_elements($add_pixel);
$char_index = ($char_index + 1) % $char_num ;
@last_points = ([$asciio->{MOUSE_X}, $asciio->{MOUSE_Y}]);

@{$asciio->{MOUSE_EMULATION_FIRST_COORDINATE}} = ($asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) unless(defined $asciio->{MOUSE_EMULATION_FIRST_COORDINATE}) ;

mouse_move_forward($asciio) if($mouse_move_direction) ;

$asciio->update_display() ;
}

#----------------------------------------------------------------------------------------------
sub pen_delete_element
{
my ($asciio, $pixel_delete_only) = @_ ;

my @elements ;

if($pixel_delete_only)
	{
	@elements = grep { ( ref($_) eq 'App::Asciio::stripes::pixel' )  
					   && ( $asciio->is_over_element($_, $asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) ) } reverse @{$asciio->{seen_elements}} ;
	}
else
	{
	@elements = grep { $asciio->is_over_element($_, $asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) } reverse @{$asciio->{seen_elements}} ;
	}

if(@elements)
	{
	$asciio->delete_elements(@elements) ;

	@last_points = ([$asciio->{MOUSE_X}, $asciio->{MOUSE_Y}]) ;
	$asciio->update_display();
	}
}

#----------------------------------------------------------------------------------------------
sub mouse_move_forward
{
my ($asciio) = @_ ;

return if $mouse_emulation_move_direction eq 'static' ;

if($mouse_emulation_move_direction eq 'down')
	{
	$asciio->{MOUSE_Y}++ ;
	}
else
	{
	$asciio->{MOUSE_X} += $last_char_lenth ;
	}
}

#----------------------------------------------------------------------------------------------
sub mouse_move_backward
{
my ($asciio) = @_ ;

return if $mouse_emulation_move_direction eq 'static' ;

if($mouse_emulation_move_direction eq 'down')
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
my ($asciio, $pixel_delete_only) = @_ ;

mouse_move_backward($asciio) ;
pen_delete_element($asciio, $pixel_delete_only) ;
}

#----------------------------------------------------------------------------------------------

1 ;
