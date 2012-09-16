FONT_FAMILY => 'Monospace',
FONT_SIZE => '8',
TAB_AS_SPACES => '   ',
DISPLAY_GRID => 1,
COPY_OFFSET_X => 2,
COPY_OFFSET_Y => 2,
COLORS =>
	{
	background => [255, 255, 255],
	grid => [229, 235, 255],
	ruler_line => [85, 155, 225],
	selected_element_background => [180, 244, 255],
	element_background => [251, 251, 254],
	element_foreground => [0, 0, 0] ,
	selection_rectangle => [255, 0, 255],
	test => [0, 255, 255],
	
	group_colors =>
		[
		[[250, 221, 190], [250, 245, 239]],
		[[182, 250, 182], [241, 250, 241]],
		[[185, 219, 250], [244, 247, 250]],
		[[137, 250, 250], [235, 250, 250]],
		[[198, 229, 198], [239, 243, 239]],
		],
		
	connection => 'Chocolate',
	connection_point => [230, 198, 133],
	connector_point => 'DodgerBlue',
	new_connection => 'red' ,
	extra_point => [230, 198, 133],
	},

RULER_LINES =>
	[
		{
		TYPE => 'VERTICAL',
		COLOR => [220, 200, 200],
		POSITION => 80,
		NAME => 'RIGHT_80',
		},
		
		{
		TYPE => 'VERTICAL',
		COLOR => [220, 200, 200],
		POSITION => 120,
		NAME => 'RIGHT_120',
		},
		
		{
		TYPE => 'HORIZONTAL',
		COLOR => [220, 200, 200],
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

