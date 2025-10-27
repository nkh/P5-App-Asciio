FONT_FAMILY => 'Monospace',
FONT_SIZE => 14,
FONT_BINDINGS_SIZE => 14,
FONT_MIN => 3,

ZOOM_STEP => 1,

TAB_AS_SPACES => '    ',
USE_BINDINGS_COMPLETION => 1,

DISPLAY_GRID => 1,
DISPLAY_GRID2 => 1,
COPY_OFFSET_X => 0,
COPY_OFFSET_Y => 0,
MOUSE_X => 0,
MOUSE_Y => 0,
ACTION_VERBOSE => undef,

COLORS => {},

COLOR_SCHEMES =>
	{
	'night' =>
		{
		background => [0.04, 0.04, 0.04],
		grid => [0.12, 0.12, 0.12],
		grid_2 => [0.22, 0.22, 0.22],
		ruler_line => [0.10, 0.23, 0.31],
		hint_line => [0.20, 0.46, 0.62],
		hint_line2 => [0.74, 0.77, 0.85],
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
		
		mouse_rectangle => [0.90, 0.20, 0.20],
		hint_background => [0.80, 0.80, 0.80],
		drag_and_drop   => [1.00, 0.00, 0.00],
		
		cross_element_backgroud => [0.15, 0.25, 0.15],
		cross_filler_background => [0.13, 0.37, 0.13],
		normal_filler_background => [0.12, 0.07, 0.12],
		}, 
	'system' =>
		{
		background => [1.00, 1.00, 1.00],
		grid => [0.89, 0.92, 1.00],
		grid_2 => [0.79, 0.82, 0.90],
		ruler_line => [0.33, 0.61, 0.88],
		hint_line => [0.74, 0.77, 0.85],
		hint_line2 => [0.64, 0.67, 0.75],
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
		
		mouse_rectangle => [0.90, 0.20, 0.20],
		hint_background => [0.80, 0.80, 0.80],
		drag_and_drop   => [1.00, 0.00, 0.00],
		
		cross_element_backgroud => [1, 1, 1],
		cross_filler_background => [1, 0.9, 0.9],
		normal_filler_background => [0, 1, 0],
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
MIDDLE_BUTTON_SELECTION_FILTER =>  
	sub
	{
	ref $_[0] ne 'App::Asciio::stripes::section_wirl_arrow'
	&& ref $_[0] ne 'App::Asciio::stripes::angled_arrow'
	},


