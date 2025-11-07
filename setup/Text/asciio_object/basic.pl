
COLOR_SCHEMES => # asciio has two color schemes, and a binding to flip between them
	{
	# use ANSI colors names in TUI
	
	'night' =>
		{
		background                  => 'on_black',
		connection                  => 'red',
		connection_point            => 'ansi31',
		connector_point             => 'green',
		element_background          => 'on_black',
		element_foreground          => 'white' ,
		extra_point                 => 'ansi31',
		grid                        => 'dark white',
		grid_2                      => 'dark white',
		group_colors =>
			[
			'on_ansi94',
			'on_ansi65',
			'on_ansi25',
			'on_ansi97',
			],
		hint_line                   => 'dark blue',
		hint_line2                  => 'blue',
		mouse_rectangle             => 'red',
		new_connection              => 'red',
		ruler_line                  => 'ansi88',
		selected_element_background => 'on_ansi31',
		selection_rectangle         => 'ansi31',
		}, 
	'system' =>
		{
		background                  => 'on_red',
		connection                  => 'red',
		connection_point            => 'ansi31',
		connector_point             => 'green',
		element_background          => 'on_black',
		element_foreground          => 'white' ,
		extra_point                 => 'ansi31',
		grid                        => 'dark white',
		grid_2                      => 'dark white',
		group_colors =>
			[
			'on_ansi94',
			'on_ansi65',
			'on_ansi25',
			'on_ansi97',
			],
		hint_line                   => 'dark blue',
		hint_line2                  => 'blue',
		mouse_rectangle             => 'red',
		new_connection              => 'red',
		ruler_line                  => 'ansi88',
		selected_element_background => 'on_ansi31',
		selection_rectangle         => 'ansi31',
		}, 
	},

DRAW_CONNECTION_POINTS  => 1,     # set to draw the element connection points
DRAW_HINT_LINES         => 0,     # displays thicker lines around the selected elements

DIALOGS =>                        # external commands that handle dialogs
	{
        # BOX_EDIT => '',
	},

DRAG_SELECTS_ARROWS     => 0,     # selection rectangle also selects arrows when set
TAB_AS_SPACES           => '   ', # replacement for \t
USE_BINDINGS_COMPLETION => 0,     # show binding completion popup

