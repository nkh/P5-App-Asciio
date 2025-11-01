# Configuration


Your user configuration is '$HOME/.config/Asciio/Asciio.ini'

Your configuration file has this format:

```perl
{
STENCILS =>
	[
	#'stencils/asciio',
	],
	
ACTION_FILES =>
	[
	#'actions/xxx.pl',
	],
	
HOOK_FILES =>
	[
	],

ASCIIO_OBJECT_SETUP =>
	[
	#$ASCIIO_UI eq 'TUI' ? 'asciio_object/tui.pl' : 'asciio_object/gui.pl' ,
	],
	
IMPORT_EXPORT =>
	[
	#'import_export/ascii.pl',
	],
}
```

## Sections

### STENCILS

contains:

- files defining stencils present in the popup menuwes
- stencil files that you can drag drop from


### ACTION_FILES

contains:

- your keyboard bindings
- functionality you want add to asciio (that you bind keys to), plugins

### HOOK_FILES

contains:

hooks called after elements have been modifie and rendering the drawing starts, mainly used to call CANONIZE_CONNECTIONS.

### ASCIIO_OBJECT_SETUP

file containing setting that influence asciio behavior and look


```perl

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

TAB_AS_SPACES => '    ',
USE_BINDINGS_COMPLETION => 0,

DISPLAY_RULERS => 1,
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
		...
		}, 
	'system' =>
		{
		background => [1.00, 1.00, 1.00],
		grid => [0.89, 0.92, 1.00],
		...
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

```
### IMPORT_EXPORT

Links to files which define import and export functionality, you could use this to save files to a naother format.
