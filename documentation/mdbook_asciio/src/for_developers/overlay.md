# Overlay

After Asciio draws the elements, a user defined call back is called.

## User defined callback

The callback receives an instance of Asciio as the first argument, you can use that instance to get elements, ...

The callback return a list of **1**character overlay in array references:

- x coordinate
- y coordinate
- character
- optional background color
- optional foreground color

Example list:

```perl
[ 0, 0, 'T'],
[ 1, 0, 'e'],
[ 2, 0, 's'],
[ 3, 0, 't'],
```

## Setting and resetting the callback

The callback is set by calling $asciio->*set_overlays_sub*. The simplest is to do it via a key binding.

```perl
'set overlays' =>
	[
	'0A0-o',
	sub 
		{
		my ($asciio) = @_ ;
		
		$asciio->set_overlays_sub
			(
			sub { [0, 0, 'O'], [1, 0, 'K'] }
			) ;
		
		$asciio->update_display ;
		}
	],
```

Reset the callback
 
```perl
'reset overlays' => [ '000-o', sub { $_[0]->set_overlays_sub(undef) ; $_[0]->update_display ; } ],
```

## Callback access to canvas

The callback can also have access to the canvas, but don't

Arguments:
- $asciio
- $UI_type, set to GUI/TUI
- $gc
- $widget_width
- $widget_height
- $character_width
- $character_height


Example: draw and overlay and a filled rectangle above the mouse pointer

```perl
sub click_element_overlay
{
my ($asciio, $UI_type, $gc, $widget_width, $widget_height, $character_width, $character_height) = @_ ;

# draw directly
if($UI_type eq 'GUI')
	{
	my $surface = Cairo::ImageSurface->create('argb32', 50, 50) ;
	my $gco = Cairo::Context->create($surface) ;
	
	my $background_color = $asciio->get_color('cross_filler_background') ;
	$gco->set_source_rgb(@$background_color) ;
	
	$gco->rectangle(0, 0, $character_width, $character_height) ;
	$gco->fill() ;
	
	$gc->set_source_surface($surface, ($asciio->{MOUSE_X} - 1 ) * $character_width, ($asciio->{MOUSE_Y} - 1) * $character_height);
	$gc->paint() ; 
	}

# send a list of characters to draw
my @overlays = map { [ $asciio->{MOUSE_X} + $_->[0], $asciio->{MOUSE_Y} + $_->[1], $_->[2] ] } @$click_element_overlay ;

@overlays
}
```

## Callback  hide/show mouse

Hide and show the mouse pointer, useful if you draw objects that are moved around.

```perl

sub callback_enter { my ($asciio) = @_ ; $asciio->hide_cursor ; ... }

sub callback_escape { my ($asciio) = @_ ; $asciio->show_cursor ; ... }

```

