DRAW_CONNECTION_POINTS => 1,
ACTION_VERBOSE => 0,
LAST_ACTION => '',
DIALOGS =>
    {
    BOX_EDIT => 'vim',
    },

TAB_AS_SPACES => '    ',
USE_BINDINGS_COMPLETION => 1,

# use ANSI colors
COLOR_SCHEMES =>
	{
	'night' =>
		{
		background => 'on_black',
		grid => 'ansi236',
		grid_2 => 'dark white',
		ruler_line => 'ansi88',
		hint_line => 'blue',
		selected_element_background => 'on_ansi31',
		element_background => 'white',
		element_foreground => 'on_black' ,
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
	'system' =>
		{
		background => 'on_black',
		grid => 'ansi236',
		grid_2 => 'dark white',
		ruler_line => 'ansi88',
		hint_line => 'blue',
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
		}, 
	},

