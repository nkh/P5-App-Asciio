# Simplified Scripting API

## stop_updating_display  

Stops updating the display until *start_updating_display* is called; this can be used to reduce flickering.

```
stop_updating_display
```

## start_updating_display  

Start updating the display; display will automatically be updated from when this is called. An update is also made.

```
start_updating_display
```

## create_undo_snapshot

Creates an undo snapshot.

```
create_undo_snapshot ;
```

## add

Adds a named element:
- element_name
- element, see *new_box* *new_text*, ... below
- x coordinate
- y coordinate

```
add 'text1', new_text(TEXT_ONLY =>'text'),  22,  20 ;
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

## new_box

Creates a new box element. Use it with **add**.

```
new_box() ; # default box text
new_box(TEXT_ONLY =>'text') ;
```

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

## move

Moves a namex element to a new coordinate:
- element name
- x position
- y position

```
move 'text1', 22,  20 ;
```

## offset

Offsets a named element:
- element name
- x offset
- y offset

```
offset 'text1', 22,  20 ;
```

## select_all_elements

Selects all the elements in Asciio.

```
select_all_elements ;
```

## deselect_all_elements

Deselects all the elements in Asciio.

```
deselect_all_elements ;
```

## select_all_script_elements

Selects all the elements added by the script.

```
select_all_script_elements ;
```

## deselect_all_script_elements

Deselects all the elements added by the script.

```
deselect_all_script_elements ;
```

## connect_elements

Connects named elements with a *wirl-arrow*.

```
connect_elements 'box2', 'text1' ;
```

## optimize

Optimizes the connections.

```
optimize
```

## delete_all_ruler_lines

Deletes all ruler lines.

```
delete_all_ruler_lines ;
```

## add_ruler_line

Adds a ruler line.

- axis: 'vertical' or 'horizontal'
- position

```
add_ruler_line 'vertical, 10 ;
```

## save_to

Saves the diagram to a file in Asciio's native format.

```
save_to 'diagram.asciio' ;
```

## to_ascii

Returns the diagram as ASCII.

```
to_ascii ;
```

## ascii_out

Prints the diagram, as ASCII, to stdout.

```
ascii_out ;
```

