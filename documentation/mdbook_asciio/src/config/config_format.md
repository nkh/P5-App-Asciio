
# CONFIGURATION FORMAT

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

Contains:

- files defining stencils present in the popup menus
- stencil files that you can drag and drop from


### ACTION_FILES

Contains:

- your keyboard bindings
- functionality you want to add to asciio (that you bind keys to), plugins

### HOOK_FILES

Contains:

- hooks called after elements have been modified and rendering the drawing starts, mainly used to call CANONIZE_CONNECTIONS.

### ASCIIO_OBJECT_SETUP

Contains:

- setup variables that influence asciio's behavior and appearance

**asciio** will first read the settings in 'setup/asciio_object/basic.pl' then read
the settings in the files contained in this section.

Some of the default settings are listed below, refer to 'setup/asciio_object/basic.pl' for a complete list

```perl

COLOR_SCHEMES => # asciio has two color schemes, and a binding to flip between them
	{
	'night' =>
		{
		background => [0.04, 0.04, 0.04],
		grid => [0.12, 0.12, 0.12],
		grid_2 => [0.22, 0.22, 0.22],
		...
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
		...
        } 
	},

COPY_OFFSET_X                    => 1,  # x offset for paste
COPY_OFFSET_Y                    => 1,  # y offset for paste
CREATE_BACKUP                    => 1,  # create a '.bak' backup file when set
DISPLAY_GRID                     => 1,  # display the asciio grid
DISPLAY_GRID2                    => 1,  # display every tenth grid line in grid_2 color
DISPLAY_RULERS                   => 1,  # display the asciio ruler lines
DISPLAY_SETUP_INFORMATION_ACTION => 1,  # display which actions are registered
DRAG_SELECTS_ARROWS              => 0,  # selection rectangle also selects arrows when set
...

RULER_LINES => # default ruler lines
	[
	...
	],

...

```

### IMPORT_EXPORT

Links to files which define import and export functionality, you could use this to save files to another format.

