use utf8;

FONT_FAMILY => 'Monospace',
FONT_SIZE => 12,
FONT_MIN => 3,

ZOOM_STEP => 3,
ZOOM_UPPER_LIMIT => 28,
ZOOM_LOWER_LIMIT => 0,
CANVAS_WIDTH => 200,
CANVAS_HEIGHT => 150,

USE_MARKUP_MODE => '',

EDIT_TEXT_INLINE => 0,
GIT_MODE_CONNECTOR_CHAR_LIST => ['*', 'o', '+', 'x', 'X', '┼', '╋', '╬'],

MAX_UNDO_SNAPSHOTS => 50,

PEN_MODE_CHARS_SETS => [
	{
	},
	{
	a => '●', 'A' => '■' , s => '⦿', d => '◎', f => '○', g => '△', h => '⺆', j => '⼌', k => '⼐', l => '⼕',
	},
	],

IGNORE_ELEMENT_FREEZE => 0,

TAB_AS_SPACES => '    ',
USE_BINDINGS_COMPLETION => 0,

DISPLAY_GRID => 1,
DISPLAY_GRID2 => 1,
COPY_OFFSET_X => 1,
COPY_OFFSET_Y => 1,
MOUSE_X => 0,
MOUSE_Y => 0,

DRAG_SELECTS_ARROWS => 0,

COLORS => {},

USE_CROSS_MODE => 0,

COLOR_SCHEMES =>
	{
	'night' =>
		{
		background => [0.04, 0.04, 0.04],
		grid => [0.12, 0.12, 0.12],
		grid_2 => [0.22, 0.22, 0.22],
		ruler_line => [0.10, 0.23, 0.31],
		hint_line => [0.20, 0.46, 0.62],
		hint_line2 => [0.3, 0.56, 0.72],
		selected_element_background => [0.10, 0.16, 0.20],
		element_background => [0.04, 0.04, 0.04],
		element_foreground => [0.59, 0.59, 0.59] ,
		selection_rectangle => [0.43, 0.00, 0.43],
		test => [0.00, 1.00, 1.00],
		group_colors =>
			[
			[[0.98, 0.86, 0.74], [0.98, 0.96, 0.93]],
			[[0.71, 0.98, 0.71], [0.94, 0.98, 0.94]],
			[[0.72, 0.86, 0.98], [0.95, 0.96, 0.98]],
			[[0.54, 0.98, 0.98], [0.92, 0.98, 0.98]],
			[[0.77, 0.89, 0.77], [0.93, 0.95, 0.93]],
			],
			
		connection => [0.55, 0.25, 0.08],
		connection_point => [0.51, 0.39, 0.20],
		connector_point => [0.12, 0.56, 1.00],
		new_connection => [1.00, 0.00, 0.00],
		extra_point => [0.27, 0.53, 0.27],
		
		mouse_rectangle => [0.90, 0.50, 0.90, 0.50],
		find_current_highlight => [0, 0, 1, 0.50],
		find_other_highlight => [0.90, 0.50, 0.90, 0.50],
		hint_background => [0.20, 0.20, 0.20],
		drag_and_drop   => [1.00, 0.00, 0.00],
		}, 
	'system' =>
		{
		background => [1.00, 1.00, 1.00],
		grid => [0.89, 0.92, 1.00],
		grid_2 => [0.79, 0.82, 0.90],
		ruler_line => [0.33, 0.61, 0.88],
		hint_line => [0.5, 0.80, 1],
		hint_line2 => [0.4, 0.7, 0.9],
		element_background => [1.00, 1.00, 1.00],
		element_foreground => [0.00, 0.00, 0.00] ,
		selected_element_background => [0.70, 0.95, 1.00],
		selection_rectangle => [1.00, 0.00, 1.00],
		test => [0.00, 1.00, 1.00],
		
		group_colors =>
			[
			[[0.98, 0.86, 0.74], [0.98, 0.96, 0.93]],
			[[0.71, 0.98, 0.71], [0.94, 0.98, 0.94]],
			[[0.72, 0.86, 0.98], [0.95, 0.96, 0.98]],
			[[0.54, 0.98, 0.98], [0.92, 0.98, 0.98]],
			[[0.77, 0.89, 0.77], [0.93, 0.95, 0.93]],
			],
			
		connection => [0.55, 0.25, 0.08],
		connection_point => [0.90, 0.77, 0.52],
		connector_point => [0.12, 0.56, 1.00],
		new_connection => [1.00, 0.00, 0.00],
		extra_point => [0.27, 0.53, 0.27],
		
		mouse_rectangle => [0.90, 0.50, 0.90, 0.50],
		find_current_highlight => [0, 0, 1, 0.50],
		find_other_highlight => [0.90, 0.50, 0.90, 0.50],
		hint_background => [0.20, 0.20, 0.20],
		drag_and_drop   => [1.00, 0.00, 0.00],
		} 
	},

RULER_LINES =>
	[
		{
		TYPE => 'VERTICAL',
		COLOR => [0.86, 0.78, 0.78],
		POSITION => 80,
		NAME => 'RIGHT_80',
		},
		
		{
		TYPE => 'VERTICAL',
		COLOR => [0.86, 0.78, 0.78],
		POSITION => 120,
		NAME => 'RIGHT_120',
		},
		
		{
		TYPE => 'HORIZONTAL',
		COLOR => [0.86, 0.78, 0.78],
		POSITION => 50,
		NAME => 'BOTTOM_50',
		},
	],

WORK_DIRECTORY => '.asciio_work_dir',
CREATE_BACKUP => 1,
DISPLAY_SETUP_INFORMATION => 0,
DISPLAY_SETUP_ACTION_INFORMATION => 1,
MIDDLE_BUTTON_SELECTION_FILTER =>  
	sub
	{
	ref $_[0] ne 'App::Asciio::stripes::section_wirl_arrow'
	&& ref $_[0] ne 'App::Asciio::stripes::angled_arrow'
	},

HIDE_GROUP_BINDING_HELP => {
	'<< pen leader >>' => {
		'pen insert asterisk'     => 1,
		'pen insert parenleft'    => 1,
		'pen insert exclam'       => 1,
		'pen insert at'           => 1,
		'pen insert numbersign'   => 1,
		'pen insert dollar'       => 1,
		'pen insert percent'      => 1,
		'pen insert asciicircum'  => 1,
		'pen insert ampersand'    => 1,
		'pen insert parenright'   => 1,
		'pen insert underscore'   => 1,
		'pen insert plus'         => 1,
		'pen insert braceleft'    => 1,
		'pen insert braceright'   => 1,
		'pen insert colon'        => 1,
		'pen insert quotedbl'     => 1,
		'pen insert asciitilde'   => 1,
		'pen insert bar'          => 1,
		'pen insert question'     => 1,
		'pen insert less'         => 1,
		'pen insert greater'      => 1,
		'pen insert minus'        => 1,
		'pen insert equal'        => 1,
		'pen insert bracketleft'  => 1,
		'pen insert bracketright' => 1,
		'pen insert semicolon'    => 1,
		'pen insert apostrophe'   => 1,
		'pen insert grave'        => 1,
		'pen insert backslash'    => 1,
		'pen insert slash'        => 1,
		'pen insert comma'        => 1,
		'pen insert period'       => 1,
		'pen insert A' => 1,
		'pen insert B' => 1,
		'pen insert C' => 1,
		'pen insert D' => 1,
		'pen insert E' => 1,
		'pen insert F' => 1,
		'pen insert G' => 1,
		'pen insert H' => 1,
		'pen insert I' => 1,
		'pen insert J' => 1,
		'pen insert K' => 1,
		'pen insert L' => 1,
		'pen insert M' => 1,
		'pen insert N' => 1,
		'pen insert O' => 1,
		'pen insert P' => 1,
		'pen insert Q' => 1,
		'pen insert R' => 1,
		'pen insert S' => 1,
		'pen insert T' => 1,
		'pen insert U' => 1,
		'pen insert V' => 1,
		'pen insert W' => 1,
		'pen insert X' => 1,
		'pen insert Y' => 1,
		'pen insert Z' => 1,
		'pen insert a' => 1,
		'pen insert b' => 1,
		'pen insert c' => 1,
		'pen insert d' => 1,
		'pen insert e' => 1,
		'pen insert f' => 1,
		'pen insert g' => 1,
		'pen insert h' => 1,
		'pen insert i' => 1,
		'pen insert j' => 1,
		'pen insert k' => 1,
		'pen insert l' => 1,
		'pen insert m' => 1,
		'pen insert n' => 1,
		'pen insert o' => 1,
		'pen insert p' => 1,
		'pen insert q' => 1,
		'pen insert r' => 1,
		'pen insert s' => 1,
		'pen insert t' => 1,
		'pen insert u' => 1,
		'pen insert v' => 1,
		'pen insert w' => 1,
		'pen insert x' => 1,
		'pen insert y' => 1,
		'pen insert z' => 1,
		'pen insert 0' => 1,
		'pen insert 1' => 1,
		'pen insert 2' => 1,
		'pen insert 3' => 1,
		'pen insert 4' => 1,
		'pen insert 5' => 1,
		'pen insert 6' => 1,
		'pen insert 7' => 1,
		'pen insert 8' => 1,
		'pen insert 9' => 1,
		},
	},
