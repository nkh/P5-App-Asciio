# Simplified Scripting API

APIs are defined in **lib/App/Asciio/Scripting.pm**



## add

Adds a named element:
- element_name
- element, see *new_box* *new_text*, ... below
- x coordinate
- y coordinate

```
add 'text1', new_text(TEXT_ONLY =>'text'),  22,  20 ;
```

## add_connection

Create an arrow and connects two named elements with it, you can pass a routing hint.

```perl
add 'box1', new_box(TEXT_ONLY =>'box1'),  0,  2 ;
add 'box2', new_box(TEXT_ONLY =>'box2'), 20, 10 ;

connect_elements 'box1', 'box2', 'down' ;
```
## add_ruler_line

Adds a ruler line.

- axis: 'vertical' or 'horizontal'
- position

```
add_ruler_line 'vertical, 10 ;
```

## add_type

Adds a named element:
- element_name
- element_type
- x coordinate
- y coordinate

Returns the element.

```
my $process = add_type 'process', 'Asciio/Boxes/process', 5, 15 ;
```

## asciio_sleep 

use to sleep in a script, *sleep* blocks update 

## ascii_out

Prints the diagram, as ASCII, to stdout.

```
ascii_out ;
```

## change_selected_elements_color

Changes selected elements background or foreground color.

```
change_selected_elements_color 1, [1, 0, 0] ; # foreground color to red
```

## connect_elements

Connects named elements with a *wirl-arrow*.

```
connect_elements 'box2', 'text1' ;
```

## create_undo_snapshot

Creates an undo snapshot.

```
create_undo_snapshot ;
```

## delete_all_ruler_lines

Deletes all ruler lines.

```
delete_all_ruler_lines ;
```

## delete_by_name

Deletes an element by name

```
delete_by_name 'text1' ;
```

## delete_selected_elements

Deletes selected elements

```
delete_selected_elements ;
```

## deselect_all_elements

Deselects all the elements in Asciio.

```
deselect_all_elements ;
```

## deselect_all_script_elements

Deselects all the elements added by the script.

```
deselect_all_script_elements ;
```

## generate_keyboard_mapping

Writes the current keyboard bindings to a file

## get_canonizer

Canonizes a connection.

```perl
my $box1  = add 'box1',  new_box(TEXT_ONLY =>'box1'), 0, 2 ;
my $box2  = add 'box2',  new_box(TEXT_ONLY =>'box2'), 20, 10 ;
my $arrow = add 'arrow', new_wirl_arrow (), 0,  0 ;

my $start_connection = move_named_connector($arrow, 'startsection_0', $box1, 'bottom_center');
my $end_connection = move_named_connector($arrow, 'endsection_0', $box2, 'bottom_center') ;

die "missing connection!" unless defined $start_connection && defined $end_connection ;

set_connection($start_connection, $end_connection) ;

get_canonizer()->([$start_connection, $end_connection]) ;
```
## get_option

Get one of the options passes as arguments to *asciio*. Used in *text_toasciio*.

## move

Moves a namex element to a new coordinate:
- element name
- x position
- y position

```
move 'text1', 22,  20 ;
```

## move_named_connector

Arrows and text elements are created separately in scripts, this allows you to connect elements together.
## new_box

Creates a new box element. Use it with **add**.

```
new_box() ; # default box text
new_box(TEXT_ONLY =>'text') ;
```

## new_script_asciio

Internal function used to create an asciio object for running scripts.



## new_text

Creates a new text element. Use it with **add**.

```
new_text(TEXT_ONLY =>'text') ;
```

## new_wirl_arrow

Creates a new wirl-arrow element. Use it with **add**.

Pass wirl arrow section coordinates and directions as arguments.

```
new_wirl_arrow([5, 5, 'downright'], [10, 7, 'downright'], [7, 14, 'downleft']) ;
```

## offset

Offsets a named element:
- element name
- x offset
- y offset

```
offset 'text1', 22,  20 ;
```

## optimize

Optimizes the connections.

```
optimize
```

## optimize_connections

Calls *asciio* routing hook.

## quit

Closes *Asciio*

```perl
asciio_sleep 2000 ; # wait for slideshow which it driven by timer events, to end
quit ;
```
## reset_screenshot_index

Screenshot index are incremented for each screenshot taken, you can set the start index with this function.
## run_external_script_text

Will run the passed script (text not file name)

Running scripts passed as text is how the *asciio* web server works, allowing other processes to use *asciio* for display 


## save_to

Saves the diagram to a file in Asciio's native format.

```
save_to 'diagram.asciio' ;
```

## select_all_elements

Selects all the elements in Asciio.

```
select_all_elements ;
```

## select_all_script_elements

Selects all the elements added by the script.

```
select_all_script_elements ;
```

## select_by_name

Selects an elements by name.

```
select_by_name 'A' ;
```

## select_elements

Select or deselects the passed elements

```perl
select_elements 1, $element, $element ... # 1 to select, 0 to deselect
```
##  set_slide_delay 

override a slide delay from the script

## start_automatic_slideshow

Runs the slideshow once

By default the slide lay is set to 1000 ms and screenshots are taken, you can pass arguments to change the defaults

```perl
start_automatic_slideshow [1000, 1] ; 
```

## start_updating_display  

Start updating the display; display will automatically be updated from when this is called. An update is also made.

```
start_updating_display
```

## stop_updating_display  

Stops updating the display until *start_updating_display* is called; this can be used to reduce flickering.

```
stop_updating_display
```

## take_screenshot

Takes a screenshot of the slide.

file_name is: "screenshots/". sprintf("%03d", $index) . "_time_${slide_time}_screenshot.png" ;

terminal output: "APNG: $file_name" . ($time ? ":$time " : ' ') ;
## take_screenshot_and_sleep

takes a screenshot of the slide and calls asciio_sleep

file_name is: "screenshots/". sprintf("%03d", $index) . "_time_${slide_time}_screenshot.png" ;

terminal output: "APNG: $file_name" . ($time ? ":$time " : ' ') ;
 

## to_ascii

Returns the diagram as ASCII.

```
to_ascii ;
```

## to_asciio

Returns an asciio document, used in *text_to_asciio* 
## update_display

Force a display update, API functions usually do it automatically.
