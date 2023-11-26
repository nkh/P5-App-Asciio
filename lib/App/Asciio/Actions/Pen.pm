
package App::Asciio::Actions::Pen ;

use App::Asciio::Actions::Elements ;
use App::Asciio::ZBuffer ;
use App::Asciio::String qw(unicode_length) ;
use App::Asciio::stripes::pixel ;

use Gtk3 '-init' ;

use utf8;
# binmode(STDOUT, ":encoding(utf8)");
# binmode(STDIN, ":encoding(utf8)");
# binmode(STDERR, ":encoding(utf8)");

use strict ; use warnings ;

use List::Util qw(max) ;
use List::MoreUtils qw(any);

my $pen_cursor ;
my $eraser_cursor ;

my @pixel_elements_to_insert ;

my $overlay_element ;

my @pen_chars = ('?') ;
my @last_points;

my $char_index = 0 ;
my $char_num ;
my $is_eraser = 0 ;

# :TODO: The following speed of the current overlay is very slow and needs to be analyze.
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
$overlay_element;
}


#----------------------------------------------------------------------------------------------
sub pen_custom_mouse_cursor
{
my ($asciio) = @_ ;

unless(defined $pen_cursor)
	{
	my $display = $asciio->{widget}->get_display() ;

	my ($pen_pixbuf, $eraser_pixbuf) ;

	eval
		{
		$pen_pixbuf = Gtk3::Gdk::Pixbuf->new_from_file($asciio->{CUSTOM_MOUSE_CURSORS}->{'pen'});
		$eraser_pixbuf = Gtk3::Gdk::Pixbuf->new_from_file($asciio->{CUSTOM_MOUSE_CURSORS}->{'eraser'});
		};
	if ($@)
		{
		print STDERR "caught an error:$@\n" ;
		return ;
		}

	$pen_cursor = Gtk3::Gdk::Cursor->new_from_pixbuf($display, $pen_pixbuf, 0, 0);
	$eraser_cursor = Gtk3::Gdk::Cursor->new_from_pixbuf($display, $eraser_pixbuf, 0, 0);
	}
if($is_eraser)
	{
	# :TODO: The eraser mouse cursor is too large and inconvenient to operate. It needs to be replaced.Need a shape similar to that of a pen nib
	$asciio->{widget}->get_parent_window()->set_cursor($eraser_cursor) ;
	}
else
	{
	$asciio->{widget}->get_parent_window()->set_cursor($pen_cursor) ;
	}
}

#----------------------------------------------------------------------------------------------
sub mouse_change_char
{
my ($asciio) = @_;
pen_enter($asciio, undef, 1) ;
}

#----------------------------------------------------------------------------------------------
sub pen_eraser_switch
{
my ($asciio) = @_ ;

$is_eraser ^= 1 ;

pen_custom_mouse_cursor($asciio) ;
pen_set_overlay($asciio) ;
$asciio->set_overlays_sub(\&pen_get_overlay) ;
$asciio->update_display ;
}

#----------------------------------------------------------------------------------------------
sub pen_enter
{
my ($asciio, $chars, $no_selected_elements) = @_;

# custom mouse cursor
pen_custom_mouse_cursor($asciio) ;

my @get_chars ;

if(defined $chars)
	{
	@pen_chars = @{$chars} ;
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
		my $all_elements_zbuffer = App::Asciio::ZBuffer->new(0, @{$asciio->{ELEMENTS}});
		my $current_char = $all_elements_zbuffer->{coordinates}{$current_point} // ' ' ;
		push @get_chars, $current_char unless $current_char =~ /^\s*$/ ;
		}
	@pen_chars = @get_chars if @get_chars ;
	}

pen_create_clone_elements($asciio, @pen_chars) ;

pen_set_overlay($asciio) ;

$asciio->set_overlays_sub(\&pen_get_overlay) ;

if(defined $chars)
	{
	pen_add_or_delete_element($asciio) ;
	}
else
	{
	$asciio->update_display ;
	}
}

#----------------------------------------------------------------------------------------------

sub pen_escape
{
my ($asciio) = @_;

$asciio->set_overlays_sub(undef);
$asciio->change_cursor('left_ptr');
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
		|| abs($x - $points[$#points][0]) >= unicode_length(
			$pen_chars[($char_index+$point_offset) % $char_num - 1]))
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
	pen_set_overlay($asciio);
	$asciio->set_overlays_sub(\&pen_get_overlay);
	$asciio->update_display ;
	}
}

#----------------------------------------------------------------------------------------------
sub pen_add_or_delete_element
{
my ($asciio) = @_ ;
if($is_eraser)
	{
	pen_delete_element($asciio) ;
	}
else
	{
	pen_add_element($asciio) ;
	}
}

#----------------------------------------------------------------------------------------------
sub pen_add_element
{
my ($asciio) = @_ ;

my $add_pixel =Clone::clone($pixel_elements_to_insert[$char_index]) ;

@$add_pixel{'X', 'Y', 'SELECTED'} = ($asciio->{MOUSE_X}, $asciio->{MOUSE_Y}, 0) ;
$asciio->add_elements($add_pixel);
$char_index = ($char_index + 1) % $char_num ;
@last_points = ([$asciio->{MOUSE_X}, $asciio->{MOUSE_Y}]);
$asciio->update_display() ;
}

#----------------------------------------------------------------------------------------------
sub pen_delete_element
{
my ($asciio) = @_ ;

my @elements = grep { $asciio->is_over_element($_, $asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) } reverse @{$asciio->{ELEMENTS}} ;

# :TODO: It would be better to temporarily set a color for the element to be deleted,In this way, the eraser does not need to use a space overlay.

if(@elements)
	{
	$asciio->create_undo_snapshot() ;
	$asciio->delete_elements(@elements) ;
	
	$asciio->update_display();
	}
}

#----------------------------------------------------------------------------------------------

1 ;
