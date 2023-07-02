# Overlay

This *overlay* branch contains:
- code for the overlay functionality
- a default callback which writes 'test' at the top of the canvas
- a test callback that writes 'ok' at the top of the canvas
- test bindings
	- to set a test callback «Alt-o»
	- to reset to the default callback «o»

After the elements are drawn, a user defined call back is called.

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



