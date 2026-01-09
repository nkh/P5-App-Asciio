use utf8 ;

# default user configuration for asciio GUI
# this configuration can be overridden by your configuration files

COLOR_SCHEMES => # asciio has two color schemes, and a binding to flip between them
	{
	'night' =>
		{
		group_colors =>
			[
			[[0.98, 0.86, 0.74], [0.98, 0.96, 0.93]],
			[[0.71, 0.98, 0.71], [0.94, 0.98, 0.94]],
			[[0.72, 0.86, 0.98], [0.95, 0.96, 0.98]],
			[[0.54, 0.98, 0.98], [0.92, 0.98, 0.98]],
			[[0.77, 0.89, 0.77], [0.93, 0.95, 0.93]],
			],
		
		background                    => [0.04, 0.04, 0.04      ],
		connection                    => [0.55, 0.25, 0.08      ],
		connection_point              => [0.51, 0.39, 0.20      ],
		connector_point               => [0.12, 0.56, 1.00      ],
		drag_and_drop                 => [1.00, 0.00, 0.00      ],
		element_background            => [0.04, 0.04, 0.04      ],
		element_foreground            => [0.59, 0.59, 0.59      ],
		extra_point                   => [0.27, 0.53, 0.27      ],
		find_current                  => [0.30, 0.30, 0.90, 0.40],
		find_match                    => [0.30, 0.70, 0.30, 0.40],
		find_match_bg                 => [0.20, 0.20, 0.40      ],
		grid                          => [0.12, 0.12, 0.12      ],
		grid_2                        => [0.22, 0.22, 0.22      ],
		hint_background               => [0.40, 0.40, 0.40      ],
		hint_line                     => [0.20, 0.46, 0.62      ],
		hint_line2                    => [0.30, 0.56, 0.72      ],
		mouse_rectangle               => [0.90, 0.50, 0.90, 0.50],
		new_connection                => [1.00, 0.00, 0.00      ],
		prompt_background             => [0.15, 0.15, 0.15, 1.00],
		prompt_foreground             => [0.85, 0.85, 0.85, 1.00],
		ruler_line                    => [0.10, 0.23, 0.31      ],
		selected_element_background   => [0.10, 0.16, 0.20      ],
		selection_rectangle           => [0.43, 0.00, 0.43      ],
		spelling_error                => [1.00, 0.00, 0.00, 0.60],
		temporary_to_front_background => [0.80, 0.30, 0.80, 0.40],
		test                          => [0.00, 1.00, 1.00      ],
		}, 
	'system' =>
		{
		group_colors =>
			[
			[[0.98, 0.86, 0.74], [0.98, 0.96, 0.93]],
			[[0.71, 0.98, 0.71], [0.94, 0.98, 0.94]],
			[[0.72, 0.86, 0.98], [0.95, 0.96, 0.98]],
			[[0.54, 0.98, 0.98], [0.92, 0.98, 0.98]],
			[[0.77, 0.89, 0.77], [0.93, 0.95, 0.93]],
			],
		
		background                    => [1.00, 1.00, 1.00      ],
		connection                    => [0.55, 0.25, 0.08      ],
		connection_point              => [0.90, 0.77, 0.52      ],
		connector_point               => [0.12, 0.56, 1.00      ],
		drag_and_drop                 => [1.00, 0.00, 0.00      ],
		element_background            => [1.00, 1.00, 1.00      ],
		element_foreground            => [0.00, 0.00, 0.00      ],
		extra_point                   => [0.27, 0.53, 0.27      ],
		find_current                  => [0.30, 0.30, 0.90, 0.40],
		find_match                    => [0.30, 0.70, 0.30, 0.40],
		find_match_bg                 => [0.60, 0.60, 0.70      ],
		grid                          => [0.89, 0.92, 1.00      ],
		grid_2                        => [0.79, 0.82, 0.90      ],
		hint_background               => [0.60, 0.60, 0.60      ],
		hint_line                     => [0.50, 0.80, 1.00      ],
		hint_line2                    => [0.40, 0.70, 0.90      ],
		mouse_rectangle               => [0.90, 0.50, 0.90, 0.50],
		new_connection                => [1.00, 0.00, 0.00      ],
		prompt_background             => [0.90, 0.90, 0.90, 1.00],
		prompt_foreground             => [0.00, 0.00, 0.00, 1.00],
		ruler_line                    => [0.33, 0.61, 0.88      ],
		selected_element_background   => [0.70, 0.95, 1.00      ],
		selection_rectangle           => [1.00, 0.00, 1.00      ],
		spelling_error                => [1.00, 0.00, 0.00, 0.60],
		temporary_to_front_background => [0.80, 0.30, 0.80, 0.40],
		test                          => [0.00, 1.00, 1.00      ],
		} 
	},

COPY_OFFSET_X                    => 1,  # x offset for paste
COPY_OFFSET_Y                    => 1,  # y offset for paste
CREATE_BACKUP                    => 1,  # create a '.bak' backup file when set
DISPLAY_GRID                     => 1,  # display the asciio grid
DISPLAY_GRID2                    => 1,  # display every tenth grid line in grid_2 color
DISPLAY_MATCHING_STRIPE          => 0,  # best effort to display which stripe matches a search
DISPLAY_RULERS                   => 1,  # display the ascioo ruler lines
DISPLAY_SETUP_INFORMATION_ACTION => 1,  # display which actions are registered
DRAG_SELECTS_ARROWS              => 0,  # selection rectangle also selects arrows when set
DRAW_HINT_LINES                  => 0,  # displays thicker lines around the selected elements
FONT_BINDINGS_SIZE               => 11, # font size for the popup which shows bindings
FONT_BINDINGS_SIZE               => 11, # font size for the popup which shows bindings
FONT_MIN                         => 3,  # minimum font size,
FONT_SIZE                        => 11, # font size for characters
FONT_SIZE                        => 12, # size of the element characters
GIT_MODE_CONNECTOR_CHAR_LIST     => ['*', 'o'], # Linker style in git mode
GTK_MEMORY_OVER_SPEED            => 0,  # draw the entire canvas or just the viewport
						# 0: Draw the entire canvas (more memory)
						# 1: Only draw the viewport (less memory, more cache updatds)
OPAQUE_ELEMENTS                  => 1,  # clear the background behind the strips when set, for debugging

RULER_LINES => # default ruler lines
	[
		{
		TYPE     => 'VERTICAL',
		COLOR    => [0.86, 0.78, 0.78],
		POSITION => 80,
		NAME     => 'RIGHT_80',
		},
		
		{
		TYPE     => 'VERTICAL',
		COLOR    => [0.86, 0.78, 0.78],
		POSITION => 120,
		NAME     => 'RIGHT_120',
		},
		
		{
		TYPE     => 'HORIZONTAL',
		COLOR    => [0.86, 0.78, 0.78],
		POSITION => 50,
		NAME     => 'BOTTOM_50',
		},
	],

TAB_AS_SPACES            => '   ', # replacement for \t
USE_BINDINGS_COMPLETION  => 1,     # show binding completion popup
ZOOM_STEP                => 3,     # increment for font size

PEN_KEYBOARD_LAYOUT_NAME => 'US_QWERTY', # US_QWERTY or SWE_QWERTY
PEN_CHARS_SETS           => # For the mapping of keys to inserted characters in pen mode
			[
				{
				'~' => '─' , '!' => '▀' , '@' => '▁' , '#' => '▂'  , '$' => '▃' , '%' => '▄' ,
				'^' => '▅' , '&' => '▆' , '*' => '▇' , '(' => '█'  , ')' => '▉' , '_' => '▊' ,
				'+' => '▋' , '`' => '▋' , '1' => '▌' , '2' => '▍'  , '3' => '▎' , '4' => '▏' ,
				'5' => '▐' , '6' => '░' , '7' => '▒' , '8' => '▓'  , '9' => '▔' , '0' => 'À' ,
				'-' => '│' , '=' => '┌' , 'Q' => '┐' , 'W' => '└'  , 'E' => '┘' , 'R' => '├' ,
				'T' => '┤' , 'Y' => '┬' , 'U' => '┴' , 'I' => 'Ì'  , 'O' => 'Ð' , 'P' => '┼' ,
				'{' => 'Ã' , '}' => 'Ä' , '|' => 'Â' , 'q' => 'Á'  , 'w' => 'Å' , 'e' => 'Æ' ,
				'r' => 'Ç' , 't' => 'Ò' , 'y' => 'Ó' , 'u' => 'Ô'  , 'i' => 'Õ' , 'o' => 'à' ,
				'p' => 'á' , '[' => 'â' , ']' => 'ã' , '\\' => 'ì' , 'A' => 'ø' , 'S' => 'ù' ,
				'D' => 'ú' , 'F' => 'û' , 'G' => '¢' , 'H' => '£'  , 'J' => '¥' , 'K' => '€' ,
				'L' => '₩' , ':' => '±' , '"' => '×' , 'a' => '÷'  , 's' => 'Þ' , 'd' => '√' ,
				'f' => '§' , 'g' => '¶' , 'h' => '©' , 'j' => '®'  , 'k' => '™' , 'l' => '‡' ,
				';' => '†' , "'" => '‾' , 'Z' => '¯' , 'X' => '˚'  , 'C' => '˙' , 'V' => '˝' ,
				'B' => 'ˇ' , 'N' => 'µ' , 'M' => '∂' , '<' => '≈'  , '>' => '≠' , '?' => '≤' ,
				'z' => '≥' , 'x' => '≡' , 'c' => '─' , 'v' => '│'  , 'b' => '┌' , 'n' => '┐' ,
				'm' => '└' , ',' => '┘' , '.' => '├' , '/' => '┤' ,
				},
				{
				'1' => '┬', '2' => '┴', '3' => '┼',
				},
			],

