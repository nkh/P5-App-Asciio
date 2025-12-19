# Mouse Operations Reference

**Navigation:** [Index](bindings_index.md) > Mouse Operations

Complete reference for all mouse-based interactions in Asciio.

## Basic Mouse Operations

### Clicking

| Operation        | Binding              | Description                                          |
| -----------      | ---------            | -------------                                        |
| Left-click       | `«Left-click»`       | Select element at cursor position                    |
| Double-click     | `«Double-click-1»`   | Edit element at cursor position                      |
| Right-click      | `«Right-click»`      | Open context menu                                    |
| Shift+Left-click | `«Shift+Left-click»` | Toggle element selection (add/remove from selection) |

### Drag Operations

| Operation           | Binding             | Description                   |
| -----------         | ---------           | -------------                 |
| Drag elements       | `«Left-click+drag»` | Move selected elements        |
| Start drag and drop | `«Ctrl+Left-click»` | Begin drag and drop operation |
| Release             | `«Left-release»`    | Complete drag operation       |

## Quick Creation

| Operation             | Binding                   | Description                                |
| -----------           | ---------                 | -------------                              |
| Quick link            | `«Alt+Left-click»`        | Create arrow from selection to click point |
| Quick link orthogonal | `«Alt+Shift+Left-click»`  | Create orthogonal arrow to click point     |
| Quick box             | `«Ctrl+Shift+Left-click»` | Create box at click location               |
| Duplicate element     | `«,»`                     | Duplicate selected elements                |

## Interactive Arrow Editing

| Operation              | Binding                   | Description                                |
| -----------            | ---------                 | -------------                              |
| Arrow to mouse         | `«Ctrl+Alt+motion»`       | Extend/modify arrow following mouse cursor |
| Arrow change direction | `«Ctrl+Alt+Double-click»` | Change arrow direction at click point      |
| Add arrow section      | `«Ctrl+Alt+Left-click»`   | Add section to multi-segment arrow         |
| Insert flex point      | `«Ctrl+Alt+Middle-click»` | Insert flexible point in arrow path        |

## Mouse Motion Tracking

| Operation       | Binding              | Description                            |
| -----------     | ---------            | -------------                          |
| Standard motion | `«motion»`           | Track mouse position for hover effects |
| Extended motion | `«Alt+Shift+motion»` | Track with alternate behavior          |

## Mouse Emulation Mode

Mouse emulation allows full mouse control via keyboard.

### Activation

| Operation              | Binding   | Description                           |
| -----------            | --------- | -------------                         |
| Toggle mouse emulation | `«'»`     | Enable/disable keyboard mouse control |

### Cursor Movement

| Operation         | Binding        | Description                           |
| -----------       | ---------      | -------------                         |
| Move cursor left  | `«Ctrl+Left»`  | Move mouse cursor one character left  |
| Move cursor right | `«Ctrl+Right»` | Move mouse cursor one character right |
| Move cursor up    | `«Ctrl+Up»`    | Move mouse cursor one character up    |
| Move cursor down  | `«Ctrl+Down»`  | Move mouse cursor one character down  |

### Clicking

| Operation            | Binding     | Description                                 |
| -----------          | ---------   | -------------                               |
| Emulated left-click  | `«ö»`       | Simulate left mouse button click            |
| Emulated right-click | `«ä»`       | Simulate right mouse button click           |
| Expand selection     | `«Shift+Ö»` | Expand selection at cursor                  |
| Toggle selection     | `«Ctrl+ö»`  | Add/remove element at cursor from selection |

### Dragging

| Operation   | Binding         | Description                       |
| ----------- | ---------       | -------------                     |
| Drag left   | `«Shift+Left»`  | Drag selection while moving left  |
| Drag right  | `«Shift+Right»` | Drag selection while moving right |
| Drag up     | `«Shift+Up»`    | Drag selection while moving up    |
| Drag down   | `«Shift+Down»`  | Drag selection while moving down  |

## Zoom with Mouse

| Operation   | Binding              | Description         |
| ----------- | ---------            | -------------       |
| Zoom in     | `«Ctrl+scroll-up»`   | Increase zoom level |
| Zoom out    | `«Ctrl+scroll-down»` | Decrease zoom level |

