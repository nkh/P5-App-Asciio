FONT_FAMILY => 'Monospace',
FONT_SIZE => 12,
FONT_MIN => 3,

ZOOM_STEP => 3,
CANVAS_WIDTH => 3000,
CANVAS_HEIGHT => 4000,

CROSS_MODE => 0,
MARKUP_MODE => 1,

DOUBLE_WIDTH_QR => qr/
			[\x{3400}-\x{4db5}] |
			[\x{4e00}-\x{9fa5}] |
			[\x{ac00}-\x{d7ff}] |
			[\x{3008}-\x{3011}] |
			[\x{2014}\x{2026}\x{3001}\x{3002}\x{3014}\x{3015}\x{FF01}\x{FF08}\x{FF09}\x{FF0C}\x{FF0E}\x{FF1A}\x{FF1B}\x{FF1F}\x{FF0F}\x{FF3C}]
			/x,
TAB_AS_SPACES => '    ',

DISPLAY_GRID => 1,
DISPLAY_GRID2 => 1,
COPY_OFFSET_X => 4,
COPY_OFFSET_Y => 4,
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
		cross_mode_ruler_line => [0.10, 0.23, 0.31],
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
		extra_point => [0.70, 0.57, 0.32],
		
		mouse_rectangle => [0.90, 0.20, 0.20],
		}, 
	'system' =>
		{
		background => [1.00, 1.00, 1.00],
		grid => [0.89, 0.92, 1.00],
		grid_2 => [0.79, 0.82, 0.90],
		ruler_line => [0.33, 0.61, 0.88],
		cross_mode_ruler_line => [0.00, 0.00, 0.00],
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
		extra_point => [0.70, 0.57, 0.32],
		
		mouse_rectangle => [0.90, 0.20, 0.20],
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

