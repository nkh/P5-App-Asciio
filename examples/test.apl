add 'box1', new_box(TEXT_ONLY =>'A'),  0,  2 ;
add 'box2', new_box(TEXT_ONLY =>'B'), 20, 10 ;
add 'box3', new_box(TEXT_ONLY =>'C'), 40,  5 ;

connect_elements 'box1', 'box2', 'down' ;

select_by_name 'box2' ;
move 'box1', 50,  20 ;
optimize_connections

# select_all_script_elements ;
# flash_selected 0 ;

# vim: set filetype=perl :
