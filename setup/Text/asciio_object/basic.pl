
DRAW_CONNECTION_POINTS => 1,
DRAW_HINT_LINES => 0,
ACTION_VERBOSE => 0,
LAST_ACTION => '',
DIALOGS => 
	{
	#BOX_EDIT => '',
	},

DOUBLE_WIDTH_QR => qr/
			[\x{3400}-\x{4db5}] |
			[\x{4e00}-\x{9fa5}] |
			[\x{ac00}-\x{d7ff}] |
			[\x{3008}-\x{3011}] |
			[\x{2014}\x{2026}\x{3001}\x{3002}\x{3014}\x{3015}\x{FF01}\x{FF08}\x{FF09}\x{FF0C}\x{FF0E}\x{FF1A}\x{FF1B}\x{FF1F}\x{FF0F}\x{FF3C}]
			/x,
TAB_AS_SPACES => '    ',

# use ANSI colors
COLOR_SCHEMES =>
	{
	'night' =>
		{
		background => 'on_black',
		grid => 'dark white',
		grid_2 => 'dark white',
		ruler_line => 'ansi88',
		hint_line => [0.74, 0.77, 0.85],
		selected_element_background => 'on_ansi31',
		element_background => 'on_black',
		element_foreground => 'white' ,
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
		cross_element_backgroud => 'on_ansi94',
		cross_filler_background => 'on_ansi65',
		normal_filler_background => 'on_ansi25',
		}, 
	'system' =>
		{
		background => 'on_black',
		grid => 'dark white',
		grid_2 => 'dark white',
		ruler_line => 'ansi88',
		hint_line => [0.74, 0.77, 0.85],
		selected_element_background => 'on_ansi31',
		element_background => 'on_black',
		element_foreground => 'white' ,
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
		cross_element_backgroud => 'on_ansi94',
		cross_filler_background => 'on_ansi65',
		normal_filler_background => 'on_ansi25',
		}, 
	},
