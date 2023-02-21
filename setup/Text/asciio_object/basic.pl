
DRAW_CONNECTION_POINTS => 1,
ACTION_VERBOSE => 0,
LAST_ACTION => '',
DIALOGS => 
	{
	#BOX_EDIT => '',
	},

# use ANSI colors
COLOR_SCHEMES =>
	{
	'night' =>
		{
		background => 'reset',
		grid => 'reset',
		grid_2 => 'reser',
		ruler_line => 'reset',
		selected_element_background => 'reset',
		element_background => 'reset',
		element_foreground => 'reset' ,
		group_colors =>
			[
			'on_red',
			'on_cyan',
			'on_red',
			'on_cyan',
			],
		connection => 'reset',
		connection_point => 'reset',
		connector_point => 'reset',
		new_connection => 'reset',
		extra_point => 'reset',
		mouse_rectangle => 'reset',
		selection_rectangle => 'reset',
		}, 
	'system' =>
		{
		background => 'reset',
		grid => 'dark white',
		grid_2 => 'dark white',
		ruler_line => 'ansi88',
		selected_element_background => 'on_ansi31',
		element_background => 'reset',
		element_foreground => 'reset' ,
		group_colors =>
			[
			'on_ansi94',
			'on_ansi65',
			'on_ansi25',
			'on_ansi97',
			],
		connection => 'red',
		connection_point => 'ansi31',
		connector_point => 'green',
		extra_point => 'ansi31',
		new_connection => 'red',
		mouse_rectangle => 'red',
		selection_rectangle => 'ansi31',
		}, 
	},
