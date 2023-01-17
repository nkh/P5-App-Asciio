FONT_FAMILY => 'Monospace',
FONT_SIZE => '14',
TAB_AS_SPACES => '    ',
DISPLAY_GRID => 1,
COPY_OFFSET_X => 4,
COPY_OFFSET_Y => 4,
MOUSE_X => 0,
MOUSE_Y => 0,
ACTION_VERBOSE => 1,

COLORS =>
	{
	background => [1, 1, 1],
	grid => [.90, 0.92, 1],
	ruler_line => [.30, 0.6, .88],
	element_background => [0.98, 0.98, 1],
	element_foreground => [0, 0, 0] ,
	selected_element_background => [0.70, 0.95, 1],
	selection_rectangle => [1, 0, 1],
	test => [0, 1, 1],
	
	group_colors =>
		[
		[[.98, 0.86, 0.74], [.98, 0.96, 0.93]],
		[[0.71, .98, 0.71], [0.94, .98, 0.94]],
		[[0.72, 0.86, .98], [0.95, 0.96, .98]],
		[[0.54, .98, .98], [0.92, .98, .98]],
		[[0.77, 0.89, 0.77], [0.93, 0.95, 0.93]],
		],
	
	connection => [0.82, 0.41, 0.12],
	connection_point => [0.90, 0.77, 0.52],
	connection_point => [0.90, 0.77, 0.52],
	new_connection =>  [1.0, 0.0, 0.0],
	extra_point => [0.90, 0.77, 0.52],

	mouse_rectangle => [0.90, 0.20, 0.20],
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
MIDDLE_BUTTON_SELECTION_FILTER =>  
	sub
	{
	ref $_[0] ne 'App::Asciio::stripes::section_wirl_arrow'
	&& ref $_[0] ne 'App::Asciio::stripes::angled_arrow'
	},

