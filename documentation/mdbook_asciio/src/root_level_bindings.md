# Root Level Bindings

**Navigation:** [Index](bindings_index.md) > Root Level Bindings

These bindings work directly without requiring a prefix key.

## Editing Operations

| Operation                | Binding                  | Description                        |
| -----------              | ---------                | -------------                      |
| Undo                     | `«Ctrl+z»` or `«u»`      | Undo last operation                |
| Redo                     | `«Ctrl+y»` or `«Ctrl+r»` | Redo previously undone operation   |
| Delete selected elements | `«Delete»` or `«d»`      | Remove currently selected elements |

## View Control

| Operation   | Binding                                     | Description                |
| ----------- | ---------                                   | -------------              |
| Zoom in     | `«+»` or `«Ctrl+j»` or `«Ctrl+scroll-up»`   | Increase canvas zoom level |
| Zoom out    | `«-»` or `«Ctrl+h»` or `«Ctrl+scroll-down»` | Decrease canvas zoom level |

## Selection Operations

### Basic Selection

| Operation                        | Binding                   | Description                                        |
| -----------                      | ---------                 | -------------                                      |
| Select all elements              | `«Ctrl+a»` or `«Shift+V»` | Select every element in the canvas                 |
| Deselect all elements            | `«Escape»`                | Clear current selection                            |
| Select connected elements        | `«v»`                     | Select all elements connected to current selection |
| Select elements by word          | `«Ctrl+f»`                | Select all elements containing specific text       |
| Select elements by word no group | `«Ctrl+Shift+f»`          | Select by text without grouping                    |

### Sequential Selection

| Operation                 | Binding       | Description                               |
| -----------               | ---------     | -------------                             |
| Select next element       | `«Tab»`       | Cycle forward through all elements        |
| Select previous element   | `«Shift+Tab»` | Cycle backward through all elements       |
| Select next non-arrow     | `«n»`         | Cycle forward through non-arrow elements  |
| Select previous non-arrow | `«Shift+N»`   | Cycle backward through non-arrow elements |
| Select next arrow         | `«m»`         | Cycle forward through arrow elements      |
| Select previous arrow     | `«Shift+M»`   | Cycle backward through arrow elements     |

### Advanced Selection

| Operation                        | Binding   |
| -----------                      | --------- |
| Enter interactive selection mode | `«s»`     |

## Element Manipulation

### Editing Elements

| Operation                    | Binding                                   | Description                          |
| -----------                  | ---------                                 | -------------                        |
| Edit selected element        | `«Double-click-1»` or `«Return»`          | Open editor for selected element     |
| Edit selected element inline | `«Ctrl+Double-click-1»` or `«Alt+Return»` | Edit element text directly on canvas |

### Moving Elements

| Operation                  | Binding            | Description                        |
| -----------                | ---------          | -------------                      |
| Move selected left         | `«Left»` or `«h»`  | Move selection one character left  |
| Move selected right        | `«Right»` or `«l»` | Move selection one character right |
| Move selected up           | `«Up»` or `«k»`    | Move selection one character up    |
| Move selected down         | `«Down»` or `«j»`  | Move selection one character down  |
| Move selected left (fast)  | `«Alt+Left»`       | Move selection 10 characters left  |
| Move selected right (fast) | `«Alt+Right»`      | Move selection 10 characters right |
| Move selected up (fast)    | `«Alt+Up»`         | Move selection 10 characters up    |
| Move selected down (fast)  | `«Alt+Down»`       | Move selection 10 characters down  |

### Resizing Elements

| Operation             | Binding   | Description                      |
| -----------           | --------- | -------------                    |
| Make element narrower | `«1»`     | Decrease width by one character  |
| Make element taller   | `«2»`     | Increase height by one character |
| Make element shorter  | `«3»`     | Decrease height by one character |
| Make element wider    | `«4»`     | Increase width by one character  |

## Mouse Operations

See [Mouse Operations Reference](mouse_operations.md) for complete details.

### Basic Mouse

| Operation            | Binding              | Description                           |
| -----------          | ---------            | -------------                         |
| Mouse left-click     | `«Left-click»`       | Select element or set insertion point |
| Mouse right-click    | `«Right-click»`      | Open context menu                     |
| Mouse left-release   | `«Left-release»`     | Complete drag operation               |
| Mouse selection flip | `«Shift+Left-click»` | Toggle element in selection           |

### Quick Operations

| Operation             | Binding                     | Description                      |
| -----------           | ---------                   | -------------                    |
| Quick link            | `«Alt+Left-click»` or `«.»` | Create arrow to clicked location |
| Quick link orthogonal | `«Alt+Shift+Left-click»`    | Create orthogonal arrow          |
| Quick box             | `«Ctrl+Shift+Left-click»`   | Create box at location           |
| Duplicate elements    | `«,»`                       | Duplicate selected elements      |

### Drag and Drop

| Operation | Binding | Description |
|-----------|---------|-------------|
| Start drag and drop | `«Ctrl+Left-click»` | Begin dragging elements |

### Interactive Arrow Editing

| Operation                    | Binding                   | Description                           |
| -----------                  | ---------                 | -------------                         |
| Arrow to mouse               | `«Ctrl+Alt+motion»`       | Extend arrow to follow mouse          |
| Arrow change direction       | `«Ctrl+Alt+d»`            | Toggle arrow direction interactively  |
| Arrow mouse change direction | `«Ctrl+Alt+Double-click»` | Change arrow direction at click point |
| Wirl arrow add section       | `«Ctrl+Alt+Left-click»`   | Add section to multi-segment arrow    |
| Wirl arrow insert flex point | `«Ctrl+Alt+Middle-click»` | Insert flexible point in arrow        |

### Mouse Motion

| Operation               | Binding              | Description                   |
| -----------             | ---------            | -------------                 |
| Mouse motion            | `«motion»`           | Track mouse position          |
| Mouse motion (extended) | `«Alt+Shift+motion»` | Track with alternate behavior |

## Mouse Emulation

| Operation              | Binding   | Description                           |
| -----------            | --------- | -------------                         |
| Toggle mouse emulation | `«'»`     | Enable/disable keyboard mouse control |

### When Mouse Emulation Active

| Operation                  | Binding         | Description                |
| -----------                | ---------       | -------------              |
| Emulation left-click       | `«ö»`           | Simulate left mouse click  |
| Emulation expand selection | `«Shift+Ö»`     | Expand selection at cursor |
| Emulation selection flip   | `«Ctrl+ö»`      | Toggle selection at cursor |
| Emulation right-click      | `«ä»`           | Simulate right mouse click |
| Emulation move left        | `«Ctrl+Left»`   | Move mouse cursor left     |
| Emulation move right       | `«Ctrl+Right»`  | Move mouse cursor right    |
| Emulation move up          | `«Ctrl+Up»`     | Move mouse cursor up       |
| Emulation move down        | `«Ctrl+Down»`   | Move mouse cursor down     |
| Emulation drag left        | `«Shift+Left»`  | Drag while moving left     |
| Emulation drag right       | `«Shift+Right»` | Drag while moving right    |
| Emulation drag up          | `«Shift+Up»`    | Drag while moving up       |
| Emulation drag down        | `«Shift+Down»`  | Drag while moving down     |

## Clipboard Operations

| Operation            | Binding                        | Description                        |
| -----------          | ---------                      | -------------                      |
| Copy to clipboard    | `«Ctrl+c»` or `«Ctrl+Insert»`  | Copy selection to system clipboard |
| Paste from clipboard | `«Ctrl+v»` or `«Shift+Insert»` | Insert from system clipboard       |

