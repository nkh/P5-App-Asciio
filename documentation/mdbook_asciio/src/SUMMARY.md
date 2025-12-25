# Summary

[Introduction](README.md)

# User Guide

- [Running Asciio](guide/running_asciio.md)

- [Installation](guide/installation.md)

- [Asciio's interface](Interface.md)
    - [Tabs](tabs.md)

- [Unicode support](unicode_support.md)

- [Accessing documentation](accessing_documentation.md)

- [UIs](UIs.md)
	- [GUI](UI/GUI.md)
	- [TUI](UI/TUI.md)
	- [CLI](UI/CLI.md)

- [Stencils](stencils.md)
	- [Asciio boxes and text](stencils/asciio_boxes.md)
		- [Asciio if and process](stencils/asciio_if_and_process.md)
		- [Asciio exec-box](stencils/asciio_exec_box.md)
	- [Asciio arrows](stencils/asciio_arrows.md)
		- [Wirl arrow dynamic configuration](stencils/arrow_dynamic_configuration.md)
	- [Pseudo connectors](stencils/pseudo_connectors.md)
	- [Box connectors](stencils/box_connectors.md)
	- [Asciio shapes](stencils/asciio_shapes.md)
	- [Image box](stencils/asciio_image_box.md)
	- [verbatim objects](stencils/verbatim.md)
	- [user stencils](stencils/user.md)
	
- [Editing elements text and attributes](editing_elements.md)
	- [Markup mode](editing_elements/markup_mode.md)

- [Working efficiently](working_efficiently.md)
	- [Keyboard](editing/keyboard.md)
	- [Mouse](editing/mouse.md)
	- [Cloning](editing/cloning.md)
	- [Stencils and "Drag and Drop"](editing/drag_drop.md)
    - [Changing element attributes](editing/changing_element_attributes.md)

- [Export/Save](exporting.md)
	- [Asciio format](export/asciio.md)
	- [Asciio embedded in PNG](export/embedded_png.md)
	- [PNG](export/png.md)
	- [text](export/text.md)
	- [SVG](export/svg.md)
	- [JSON](export/json.md)
	- [Clipboard](export/clipboard.md)

- [Modes](modes.md)
	- [Selection](modes/selection.md)
	- [Pen](modes/pen.md)
	- [Find](modes/find.md)
	- [Git](modes/git.md)
	- [Cross](modes/cross.md)
	- [Slide](modes/slides.md)
    - [Animation](modes/animations.md)

- [Examples](examples.md)
	- [Class hierarchy](examples/example1.md)
	- [German railway](examples/example2.md)
	- [Unicode Example](examples/unicode_example.md)
	- [Videos](videos/videos.md)

# Bindings

- [Bindings Reference](bindings_index.md)
	- [Why vim-like bindings](bindings/vim-like.md)
    - [Root level bindings](root_level_bindings.md)
		- [GUI bindings](bindings/gui.md)
        - [Tab Management](bindings_group_tabs.md)
    - [Insert operations](insert_operation.md)
		- [box variants](bindings_group_insert_box.md)            
        - [multiple elements](bindings_group_insert_multiple.md)  
        - [unicode elements](bindings_group_insert_unicode.md)    
        - [connected elements](bindings_group_insert_connected.md)
        - [lines](bindings_group_insert_line.md)                  
        - [stencils](bindings_group_insert_stencil.md)       
        - [special elements](bindings_group_insert_element.md)    
        - [rulers](bindings_group_insert_ruler.md)                
    - [Element manipulation](element_operation.md)
		- [Resizing elements](bindings/resizing.md)
        - [Grouping elements](element_grouping_operation.md)
    - [Arrow manipulation](arrow_operation.md)
        - [Arrow - Connectors](bindings_group_arrow_connectors.md)
            - [Start Connector](bindings_group_arrow_connectors_start.md) 
            - [End Connector](bindings_group_arrow_connectors_end.md)
            - [Both Connectors](bindings_group_arrow_connectors_both.md)
            - [Fixed vs dynamic connectors](fixed_vs_dynamic_connectors.md)
    - [Yank](yank_operations.md)
    - [Mouse](mouse_operations.md)
    - [Image box](image_box_operations.md)
    - [Display option](visual_settings_operation.md)
        - [Color options](color_operations.md)
    - [Debug](debug_operations.md)
    - [Modes](modes_operation.md)
        - [Clone](clone_mode_operation.md)
        - [Eraser](eraser_mode.md)
        - [Pen](pen_mode.md)
        - [Arrow](arrow_mode.md)
        - [Find](find_mode.md)
        - [Git](git_mode.md)
        - [Selection](selection_mode_operation.md)
            - [Selection polygon mode](selection_polygon_mode.md)
        - [Slide](slide_mode.md)
        - [Animation](animation_mode.md)
            - [Animation script](animation_script_mode.md)

# Configuration

- [Configuration](configuration.md)
	- [Configuration Format](config/config_format.md)
    - [Bindings Format](config/binding_format.md)
		- [Binding override](config/user_bindings/binding_override.md)

# Developer Guide

- [For Developers](for_developers/README.md)
	- [Scripting](for_developers/scripting.md)
	    - [Execute](for_developers/scripting_execute.md)
	    - [Simplified API](for_developers/scripting_api.md)
	- [Modifying Asciio](for_developers/modify_Asciio.md)
		- [Bindings](for_developers/bindings.md)
		- [Capturing groups with overlay](config/user_bindings/capturing_groups_overlay.md)
	- [Debugging](for_developers/debugging.md)
	- [Cross algorithm](for_developers/cross_algorithm.md)
	- [Unicode support](for_developers/unicode_support.md)
	- [Overlay](for_developers/overlay.md)

-----------

[Contributors and License](misc/contributors.md)

[See Also](misc/see_also.md)

