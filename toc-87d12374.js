// Populate the sidebar
//
// This is a script, and not included directly in the page, to control the total size of the book.
// The TOC contains an entry for each page, so if each page includes a copy of the TOC,
// the total size of the page becomes O(n**2).
class MDBookSidebarScrollbox extends HTMLElement {
    constructor() {
        super();
    }
    connectedCallback() {
        this.innerHTML = '<ol class="chapter"><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="index.html"><strong aria-hidden="true">1.</strong> Introduction</a></span><ol class="section"><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="accessing_documentation.html"><strong aria-hidden="true">1.1.</strong> Documentation</a></span></li></ol><li class="chapter-item expanded "><li class="part-title">User Guide</li></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="guide/running_asciio.html"><strong aria-hidden="true">2.</strong> Running Asciio</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="guide/installation.html"><strong aria-hidden="true">3.</strong> Installation</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="Interface.html"><strong aria-hidden="true">4.</strong> Asciio&#39;s interface</a></span><ol class="section"><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="UIs.html"><strong aria-hidden="true">4.1.</strong> UIs</a></span><ol class="section"><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="UI/GUI.html"><strong aria-hidden="true">4.1.1.</strong> GUI</a></span><ol class="section"><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="tabs.html"><strong aria-hidden="true">4.1.1.1.</strong> Tabs</a></span></li></ol><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="UI/TUI.html"><strong aria-hidden="true">4.1.2.</strong> TUI</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="UI/CLI.html"><strong aria-hidden="true">4.1.3.</strong> CLI</a></span></li></ol></li></ol><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="unicode_support.html"><strong aria-hidden="true">5.</strong> Unicode support</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="stencils.html"><strong aria-hidden="true">6.</strong> Stencils</a></span><ol class="section"><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="stencils/asciio_boxes.html"><strong aria-hidden="true">6.1.</strong> Asciio boxes and text</a></span><ol class="section"><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="stencils/asciio_if_and_process.html"><strong aria-hidden="true">6.1.1.</strong> Asciio if and process</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="stencils/asciio_exec_box.html"><strong aria-hidden="true">6.1.2.</strong> Asciio exec-box</a></span></li></ol><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="stencils/asciio_arrows.html"><strong aria-hidden="true">6.2.</strong> Asciio arrows</a></span><ol class="section"><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="stencils/arrow_dynamic_configuration.html"><strong aria-hidden="true">6.2.1.</strong> Wirl arrow dynamic configuration</a></span></li></ol><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="stencils/pseudo_connectors.html"><strong aria-hidden="true">6.3.</strong> Pseudo connectors</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="stencils/box_connectors.html"><strong aria-hidden="true">6.4.</strong> Connectors</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="stencils/asciio_shapes.html"><strong aria-hidden="true">6.5.</strong> Asciio shapes</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="stencils/asciio_image_box.html"><strong aria-hidden="true">6.6.</strong> Image box</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="stencils/verbatim.html"><strong aria-hidden="true">6.7.</strong> verbatim objects</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="stencils/user.html"><strong aria-hidden="true">6.8.</strong> user stencils</a></span></li></ol><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="editing_elements.html"><strong aria-hidden="true">7.</strong> Editing elements text and attributes</a></span><ol class="section"><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="editing_elements/markup_mode.html"><strong aria-hidden="true">7.1.</strong> Markup mode</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="spellcheck.html"><strong aria-hidden="true">7.2.</strong> Spellchecking</a></span></li></ol><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="working_efficiently.html"><strong aria-hidden="true">8.</strong> Working efficiently</a></span><ol class="section"><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="editing/keyboard.html"><strong aria-hidden="true">8.1.</strong> Keyboard</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="editing/mouse.html"><strong aria-hidden="true">8.2.</strong> Mouse</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="editing/cloning.html"><strong aria-hidden="true">8.3.</strong> Cloning</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="editing/drag_drop.html"><strong aria-hidden="true">8.4.</strong> Stencils and &quot;Drag and Drop&quot;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="editing/changing_element_attributes.html"><strong aria-hidden="true">8.5.</strong> Changing element attributes</a></span></li></ol><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="exporting.html"><strong aria-hidden="true">9.</strong> Export/Save</a></span><ol class="section"><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="export/asciio.html"><strong aria-hidden="true">9.1.</strong> Asciio format</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="export/embedded_png.html"><strong aria-hidden="true">9.2.</strong> Asciio embedded in PNG</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="export/png.html"><strong aria-hidden="true">9.3.</strong> PNG</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="export/text.html"><strong aria-hidden="true">9.4.</strong> text</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="export/svg.html"><strong aria-hidden="true">9.5.</strong> SVG</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="export/json.html"><strong aria-hidden="true">9.6.</strong> JSON</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="export/clipboard.html"><strong aria-hidden="true">9.7.</strong> Clipboard</a></span></li></ol><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="modes.html"><strong aria-hidden="true">10.</strong> Modes</a></span><ol class="section"><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="modes/selection.html"><strong aria-hidden="true">10.1.</strong> Selection</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="modes/pen.html"><strong aria-hidden="true">10.2.</strong> Pen</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="modes/pen_eraser.html"><strong aria-hidden="true">10.3.</strong> Eraser</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="modes/mergin_dots.html"><strong aria-hidden="true">10.4.</strong> Merging and splitting to dots</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="modes/user_character_set.html"><strong aria-hidden="true">10.5.</strong> User character sets</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="modes/pen_examples.html"><strong aria-hidden="true">10.6.</strong> ASCII Art and Stencil examples</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="modes/find.html"><strong aria-hidden="true">10.7.</strong> Find</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="modes/git.html"><strong aria-hidden="true">10.8.</strong> Git</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="modes/cross.html"><strong aria-hidden="true">10.9.</strong> Cross</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="modes/slide_and_slideshow.html"><strong aria-hidden="true">10.10.</strong> Slide and Slideshow</a></span></li></ol><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="examples.html"><strong aria-hidden="true">11.</strong> Examples</a></span><ol class="section"><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="examples/example1.html"><strong aria-hidden="true">11.1.</strong> Class hierarchy</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="examples/example2.html"><strong aria-hidden="true">11.2.</strong> German railway</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="examples/unicode_example.html"><strong aria-hidden="true">11.3.</strong> Unicode Example</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="videos/videos.html"><strong aria-hidden="true">11.4.</strong> Videos</a></span></li></ol><li class="chapter-item expanded "><li class="part-title">Configuration</li></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="configuration.html"><strong aria-hidden="true">12.</strong> Configuration</a></span><ol class="section"><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="config/config_format.html"><strong aria-hidden="true">12.1.</strong> Configuration Format</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="config/binding_format.html"><strong aria-hidden="true">12.2.</strong> Bindings Format</a></span><ol class="section"><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="config/user_bindings/binding_override.html"><strong aria-hidden="true">12.2.1.</strong> Binding override</a></span></li></ol></li></ol><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="bindings_index.html"><strong aria-hidden="true">13.</strong> Bindings</a></span><ol class="section"><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="bindings/vim-like.html"><strong aria-hidden="true">13.1.</strong> Why vim-like bindings</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/bindings_index.html"><strong aria-hidden="true">13.2.</strong> Bindings Reference</a></span><ol class="section"><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/PROXY_help.html"><strong aria-hidden="true">13.2.1.</strong> help</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/PROXY_leader.html"><strong aria-hidden="true">13.2.2.</strong> leader</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/ROOT_Working_efficiently.html"><strong aria-hidden="true">13.2.3.</strong> Working efficiently</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/ROOT_clipboard.html"><strong aria-hidden="true">13.2.4.</strong> clipboard</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/ROOT_edit.html"><strong aria-hidden="true">13.2.5.</strong> edit</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/ROOT_element_selection.html"><strong aria-hidden="true">13.2.6.</strong> element_selection</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/ROOT_find.html"><strong aria-hidden="true">13.2.7.</strong> find</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/ROOT_mouse.html"><strong aria-hidden="true">13.2.8.</strong> mouse</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/ROOT_mouse_emulation.html"><strong aria-hidden="true">13.2.9.</strong> mouse emulation</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/ROOT_mouse_motion.html"><strong aria-hidden="true">13.2.10.</strong> mouse motion</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/ROOT_movements.html"><strong aria-hidden="true">13.2.11.</strong> movements</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/ROOT_zoom.html"><strong aria-hidden="true">13.2.12.</strong> zoom</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_Insert___.html"><strong aria-hidden="true">13.2.13.</strong> Insert -&gt;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_align___.html"><strong aria-hidden="true">13.2.14.</strong> align -&gt;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_angled_arrow_type_change.html"><strong aria-hidden="true">13.2.15.</strong> angled_arrow_type_change</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_animation___.html"><strong aria-hidden="true">13.2.16.</strong> animation -&gt;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_animation_complete___.html"><strong aria-hidden="true">13.2.17.</strong> animation_complete -&gt;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_arrow___.html"><strong aria-hidden="true">13.2.18.</strong> arrow -&gt;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_attributes.html"><strong aria-hidden="true">13.2.19.</strong> attributes</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_both_connectors.html"><strong aria-hidden="true">13.2.20.</strong> both_connectors</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_box_type_change.html"><strong aria-hidden="true">13.2.21.</strong> box_type_change</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_change_type.html"><strong aria-hidden="true">13.2.22.</strong> change_type</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_clone___.html"><strong aria-hidden="true">13.2.23.</strong> clone -&gt;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_color.html"><strong aria-hidden="true">13.2.24.</strong> color</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_commands___.html"><strong aria-hidden="true">13.2.25.</strong> commands -&gt;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_connectors.html"><strong aria-hidden="true">13.2.26.</strong> connectors</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_cross.html"><strong aria-hidden="true">13.2.27.</strong> cross</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_debug___.html"><strong aria-hidden="true">13.2.28.</strong> debug -&gt;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_diagonal.html"><strong aria-hidden="true">13.2.29.</strong> diagonal</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_display_options___.html"><strong aria-hidden="true">13.2.30.</strong> display options -&gt;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_element___.html"><strong aria-hidden="true">13.2.31.</strong> element -&gt;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_element_add_connectors.html"><strong aria-hidden="true">13.2.32.</strong> element_add_connectors</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_ellipse_type_change.html"><strong aria-hidden="true">13.2.33.</strong> ellipse_type_change</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_end_connectors.html"><strong aria-hidden="true">13.2.34.</strong> end_connectors</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_eraser___.html"><strong aria-hidden="true">13.2.35.</strong> eraser -&gt;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_find___.html"><strong aria-hidden="true">13.2.36.</strong> find -&gt;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_fixed_both_connectors.html"><strong aria-hidden="true">13.2.37.</strong> fixed_both_connectors</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_fixed_end_connectors.html"><strong aria-hidden="true">13.2.38.</strong> fixed_end_connectors</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_fixed_start_connectors.html"><strong aria-hidden="true">13.2.39.</strong> fixed_start_connectors</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_freeze.html"><strong aria-hidden="true">13.2.40.</strong> freeze</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_git___.html"><strong aria-hidden="true">13.2.41.</strong> git -&gt;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_graph_selection___.html"><strong aria-hidden="true">13.2.42.</strong> graph selection -&gt;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_grouping___.html"><strong aria-hidden="true">13.2.43.</strong> grouping -&gt;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_image_box___.html"><strong aria-hidden="true">13.2.44.</strong> image box -&gt;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_image_control.html"><strong aria-hidden="true">13.2.45.</strong> image_control</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_insert_box.html"><strong aria-hidden="true">13.2.46.</strong> insert_box</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_insert_connected.html"><strong aria-hidden="true">13.2.47.</strong> insert_connected</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_insert_element.html"><strong aria-hidden="true">13.2.48.</strong> insert_element</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_insert_line.html"><strong aria-hidden="true">13.2.49.</strong> insert_line</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_insert_multiple.html"><strong aria-hidden="true">13.2.50.</strong> insert_multiple</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_insert_ruler.html"><strong aria-hidden="true">13.2.51.</strong> insert_ruler</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_insert_stencil.html"><strong aria-hidden="true">13.2.52.</strong> insert_stencil</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_insert_unicode.html"><strong aria-hidden="true">13.2.53.</strong> insert_unicode</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_modification.html"><strong aria-hidden="true">13.2.54.</strong> modification</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_move_arrow_ends___.html"><strong aria-hidden="true">13.2.55.</strong> move arrow ends -&gt;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_paste___.html"><strong aria-hidden="true">13.2.56.</strong> paste -&gt;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_pen___.html"><strong aria-hidden="true">13.2.57.</strong> pen -&gt;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_pen_eraser.html"><strong aria-hidden="true">13.2.58.</strong> pen_eraser</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_polygon.html"><strong aria-hidden="true">13.2.59.</strong> polygon</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_rhombus_type_change.html"><strong aria-hidden="true">13.2.60.</strong> rhombus_type_change</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_selection___.html"><strong aria-hidden="true">13.2.61.</strong> selection -&gt;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_slides___.html"><strong aria-hidden="true">13.2.62.</strong> slides -&gt;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_slideshow_run.html"><strong aria-hidden="true">13.2.63.</strong> slideshow_run</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_slideshow_run_once.html"><strong aria-hidden="true">13.2.64.</strong> slideshow_run_once</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_spellcheck.html"><strong aria-hidden="true">13.2.65.</strong> spellcheck</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_start_connectors.html"><strong aria-hidden="true">13.2.66.</strong> start_connectors</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_stripes___.html"><strong aria-hidden="true">13.2.67.</strong> stripes -&gt;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_tabs___.html"><strong aria-hidden="true">13.2.68.</strong> tabs -&gt;</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_triangle_down_type_change.html"><strong aria-hidden="true">13.2.69.</strong> triangle_down_type_change</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_triangle_up_type_change.html"><strong aria-hidden="true">13.2.70.</strong> triangle_up_type_change</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_wirl_arrow_type_change.html"><strong aria-hidden="true">13.2.71.</strong> wirl_arrow_type_change</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="generated_bindings_doc/GROUP_yank___.html"><strong aria-hidden="true">13.2.72.</strong> yank -&gt;</a></span></li></ol></li></ol><li class="chapter-item expanded "><li class="part-title">Developer Guide</li></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="for_developers/index.html"><strong aria-hidden="true">14.</strong> For Developers</a></span><ol class="section"><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="for_developers/scripting.html"><strong aria-hidden="true">14.1.</strong> Scripting</a></span><ol class="section"><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="for_developers/scripting_execute.html"><strong aria-hidden="true">14.1.1.</strong> Execute</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="for_developers/scripting_api.html"><strong aria-hidden="true">14.1.2.</strong> Simplified API</a></span></li></ol><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="for_developers/modify_Asciio.html"><strong aria-hidden="true">14.2.</strong> Modifying Asciio</a></span><ol class="section"><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="for_developers/bindings.html"><strong aria-hidden="true">14.2.1.</strong> Bindings</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="config/user_bindings/capturing_groups_overlay.html"><strong aria-hidden="true">14.2.2.</strong> Capturing groups with overlay</a></span></li></ol><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="for_developers/debugging.html"><strong aria-hidden="true">14.3.</strong> Debugging</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="for_developers/cross_algorithm.html"><strong aria-hidden="true">14.4.</strong> Cross algorithm</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="for_developers/unicode_support.html"><strong aria-hidden="true">14.5.</strong> Unicode support</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="for_developers/overlay.html"><strong aria-hidden="true">14.6.</strong> Overlay</a></span></li></ol><li class="chapter-item expanded "><li class="spacer"></li></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="functionality_log.html">Functionality Log</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="misc/contributors.html">Contributors and License</a></span></li><li class="chapter-item expanded "><span class="chapter-link-wrapper"><a href="misc/see_also.html">See Also</a></span></li><li class="chapter-item expanded "><li class="spacer"></li></li></ol>';
        // Set the current, active page, and reveal it if it's hidden
        let current_page = document.location.href.toString().split('#')[0].split('?')[0];
        if (current_page.endsWith('/')) {
            current_page += 'index.html';
        }
        const links = Array.prototype.slice.call(this.querySelectorAll('a'));
        const l = links.length;
        for (let i = 0; i < l; ++i) {
            const link = links[i];
            const href = link.getAttribute('href');
            if (href && !href.startsWith('#') && !/^(?:[a-z+]+:)?\/\//.test(href)) {
                link.href = path_to_root + href;
            }
            // The 'index' page is supposed to alias the first chapter in the book.
            if (link.href === current_page
                || i === 0
                && path_to_root === ''
                && current_page.endsWith('/index.html')) {
                link.classList.add('active');
                let parent = link.parentElement;
                while (parent) {
                    if (parent.tagName === 'LI' && parent.classList.contains('chapter-item')) {
                        parent.classList.add('expanded');
                    }
                    parent = parent.parentElement;
                }
            }
        }
        // Track and set sidebar scroll position
        this.addEventListener('click', e => {
            if (e.target.tagName === 'A') {
                const clientRect = e.target.getBoundingClientRect();
                const sidebarRect = this.getBoundingClientRect();
                sessionStorage.setItem('sidebar-scroll-offset', clientRect.top - sidebarRect.top);
            }
        }, { passive: true });
        const sidebarScrollOffset = sessionStorage.getItem('sidebar-scroll-offset');
        sessionStorage.removeItem('sidebar-scroll-offset');
        if (sidebarScrollOffset !== null) {
            // preserve sidebar scroll position when navigating via links within sidebar
            const activeSection = this.querySelector('.active');
            if (activeSection) {
                const clientRect = activeSection.getBoundingClientRect();
                const sidebarRect = this.getBoundingClientRect();
                const currentOffset = clientRect.top - sidebarRect.top;
                this.scrollTop += currentOffset - parseFloat(sidebarScrollOffset);
            }
        } else {
            // scroll sidebar to current active section when navigating via
            // 'next/previous chapter' buttons
            const activeSection = document.querySelector('#mdbook-sidebar .active');
            if (activeSection) {
                activeSection.scrollIntoView({ block: 'center' });
            }
        }
        // Toggle buttons
        const sidebarAnchorToggles = document.querySelectorAll('.chapter-fold-toggle');
        function toggleSection(ev) {
            ev.currentTarget.parentElement.parentElement.classList.toggle('expanded');
        }
        Array.from(sidebarAnchorToggles).forEach(el => {
            el.addEventListener('click', toggleSection);
        });
    }
}
window.customElements.define('mdbook-sidebar-scrollbox', MDBookSidebarScrollbox);


// ---------------------------------------------------------------------------
// Support for dynamically adding headers to the sidebar.

(function() {
    // This is used to detect which direction the page has scrolled since the
    // last scroll event.
    let lastKnownScrollPosition = 0;
    // This is the threshold in px from the top of the screen where it will
    // consider a header the "current" header when scrolling down.
    const defaultDownThreshold = 150;
    // Same as defaultDownThreshold, except when scrolling up.
    const defaultUpThreshold = 300;
    // The threshold is a virtual horizontal line on the screen where it
    // considers the "current" header to be above the line. The threshold is
    // modified dynamically to handle headers that are near the bottom of the
    // screen, and to slightly offset the behavior when scrolling up vs down.
    let threshold = defaultDownThreshold;
    // This is used to disable updates while scrolling. This is needed when
    // clicking the header in the sidebar, which triggers a scroll event. It
    // is somewhat finicky to detect when the scroll has finished, so this
    // uses a relatively dumb system of disabling scroll updates for a short
    // time after the click.
    let disableScroll = false;
    // Array of header elements on the page.
    let headers;
    // Array of li elements that are initially collapsed headers in the sidebar.
    // I'm not sure why eslint seems to have a false positive here.
    // eslint-disable-next-line prefer-const
    let headerToggles = [];
    // This is a debugging tool for the threshold which you can enable in the console.
    let thresholdDebug = false;

    // Updates the threshold based on the scroll position.
    function updateThreshold() {
        const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
        const windowHeight = window.innerHeight;
        const documentHeight = document.documentElement.scrollHeight;

        // The number of pixels below the viewport, at most documentHeight.
        // This is used to push the threshold down to the bottom of the page
        // as the user scrolls towards the bottom.
        const pixelsBelow = Math.max(0, documentHeight - (scrollTop + windowHeight));
        // The number of pixels above the viewport, at least defaultDownThreshold.
        // Similar to pixelsBelow, this is used to push the threshold back towards
        // the top when reaching the top of the page.
        const pixelsAbove = Math.max(0, defaultDownThreshold - scrollTop);
        // How much the threshold should be offset once it gets close to the
        // bottom of the page.
        const bottomAdd = Math.max(0, windowHeight - pixelsBelow - defaultDownThreshold);
        let adjustedBottomAdd = bottomAdd;

        // Adjusts bottomAdd for a small document. The calculation above
        // assumes the document is at least twice the windowheight in size. If
        // it is less than that, then bottomAdd needs to be shrunk
        // proportional to the difference in size.
        if (documentHeight < windowHeight * 2) {
            const maxPixelsBelow = documentHeight - windowHeight;
            const t = 1 - pixelsBelow / Math.max(1, maxPixelsBelow);
            const clamp = Math.max(0, Math.min(1, t));
            adjustedBottomAdd *= clamp;
        }

        let scrollingDown = true;
        if (scrollTop < lastKnownScrollPosition) {
            scrollingDown = false;
        }

        if (scrollingDown) {
            // When scrolling down, move the threshold up towards the default
            // downwards threshold position. If near the bottom of the page,
            // adjustedBottomAdd will offset the threshold towards the bottom
            // of the page.
            const amountScrolledDown = scrollTop - lastKnownScrollPosition;
            const adjustedDefault = defaultDownThreshold + adjustedBottomAdd;
            threshold = Math.max(adjustedDefault, threshold - amountScrolledDown);
        } else {
            // When scrolling up, move the threshold down towards the default
            // upwards threshold position. If near the bottom of the page,
            // quickly transition the threshold back up where it normally
            // belongs.
            const amountScrolledUp = lastKnownScrollPosition - scrollTop;
            const adjustedDefault = defaultUpThreshold - pixelsAbove
                + Math.max(0, adjustedBottomAdd - defaultDownThreshold);
            threshold = Math.min(adjustedDefault, threshold + amountScrolledUp);
        }

        if (documentHeight <= windowHeight) {
            threshold = 0;
        }

        if (thresholdDebug) {
            const id = 'mdbook-threshold-debug-data';
            let data = document.getElementById(id);
            if (data === null) {
                data = document.createElement('div');
                data.id = id;
                data.style.cssText = `
                    position: fixed;
                    top: 50px;
                    right: 10px;
                    background-color: 0xeeeeee;
                    z-index: 9999;
                    pointer-events: none;
                `;
                document.body.appendChild(data);
            }
            data.innerHTML = `
                <table>
                  <tr><td>documentHeight</td><td>${documentHeight.toFixed(1)}</td></tr>
                  <tr><td>windowHeight</td><td>${windowHeight.toFixed(1)}</td></tr>
                  <tr><td>scrollTop</td><td>${scrollTop.toFixed(1)}</td></tr>
                  <tr><td>pixelsAbove</td><td>${pixelsAbove.toFixed(1)}</td></tr>
                  <tr><td>pixelsBelow</td><td>${pixelsBelow.toFixed(1)}</td></tr>
                  <tr><td>bottomAdd</td><td>${bottomAdd.toFixed(1)}</td></tr>
                  <tr><td>adjustedBottomAdd</td><td>${adjustedBottomAdd.toFixed(1)}</td></tr>
                  <tr><td>scrollingDown</td><td>${scrollingDown}</td></tr>
                  <tr><td>threshold</td><td>${threshold.toFixed(1)}</td></tr>
                </table>
            `;
            drawDebugLine();
        }

        lastKnownScrollPosition = scrollTop;
    }

    function drawDebugLine() {
        if (!document.body) {
            return;
        }
        const id = 'mdbook-threshold-debug-line';
        const existingLine = document.getElementById(id);
        if (existingLine) {
            existingLine.remove();
        }
        const line = document.createElement('div');
        line.id = id;
        line.style.cssText = `
            position: fixed;
            top: ${threshold}px;
            left: 0;
            width: 100vw;
            height: 2px;
            background-color: red;
            z-index: 9999;
            pointer-events: none;
        `;
        document.body.appendChild(line);
    }

    function mdbookEnableThresholdDebug() {
        thresholdDebug = true;
        updateThreshold();
        drawDebugLine();
    }

    window.mdbookEnableThresholdDebug = mdbookEnableThresholdDebug;

    // Updates which headers in the sidebar should be expanded. If the current
    // header is inside a collapsed group, then it, and all its parents should
    // be expanded.
    function updateHeaderExpanded(currentA) {
        // Add expanded to all header-item li ancestors.
        let current = currentA.parentElement;
        while (current) {
            if (current.tagName === 'LI' && current.classList.contains('header-item')) {
                current.classList.add('expanded');
            }
            current = current.parentElement;
        }
    }

    // Updates which header is marked as the "current" header in the sidebar.
    // This is done with a virtual Y threshold, where headers at or below
    // that line will be considered the current one.
    function updateCurrentHeader() {
        if (!headers || !headers.length) {
            return;
        }

        // Reset the classes, which will be rebuilt below.
        const els = document.getElementsByClassName('current-header');
        for (const el of els) {
            el.classList.remove('current-header');
        }
        for (const toggle of headerToggles) {
            toggle.classList.remove('expanded');
        }

        // Find the last header that is above the threshold.
        let lastHeader = null;
        for (const header of headers) {
            const rect = header.getBoundingClientRect();
            if (rect.top <= threshold) {
                lastHeader = header;
            } else {
                break;
            }
        }
        if (lastHeader === null) {
            lastHeader = headers[0];
            const rect = lastHeader.getBoundingClientRect();
            const windowHeight = window.innerHeight;
            if (rect.top >= windowHeight) {
                return;
            }
        }

        // Get the anchor in the summary.
        const href = '#' + lastHeader.id;
        const a = [...document.querySelectorAll('.header-in-summary')]
            .find(element => element.getAttribute('href') === href);
        if (!a) {
            return;
        }

        a.classList.add('current-header');

        updateHeaderExpanded(a);
    }

    // Updates which header is "current" based on the threshold line.
    function reloadCurrentHeader() {
        if (disableScroll) {
            return;
        }
        updateThreshold();
        updateCurrentHeader();
    }


    // When clicking on a header in the sidebar, this adjusts the threshold so
    // that it is located next to the header. This is so that header becomes
    // "current".
    function headerThresholdClick(event) {
        // See disableScroll description why this is done.
        disableScroll = true;
        setTimeout(() => {
            disableScroll = false;
        }, 100);
        // requestAnimationFrame is used to delay the update of the "current"
        // header until after the scroll is done, and the header is in the new
        // position.
        requestAnimationFrame(() => {
            requestAnimationFrame(() => {
                // Closest is needed because if it has child elements like <code>.
                const a = event.target.closest('a');
                const href = a.getAttribute('href');
                const targetId = href.substring(1);
                const targetElement = document.getElementById(targetId);
                if (targetElement) {
                    threshold = targetElement.getBoundingClientRect().bottom;
                    updateCurrentHeader();
                }
            });
        });
    }

    // Takes the nodes from the given head and copies them over to the
    // destination, along with some filtering.
    function filterHeader(source, dest) {
        const clone = source.cloneNode(true);
        clone.querySelectorAll('mark').forEach(mark => {
            mark.replaceWith(...mark.childNodes);
        });
        dest.append(...clone.childNodes);
    }

    // Scans page for headers and adds them to the sidebar.
    document.addEventListener('DOMContentLoaded', function() {
        const activeSection = document.querySelector('#mdbook-sidebar .active');
        if (activeSection === null) {
            return;
        }

        const main = document.getElementsByTagName('main')[0];
        headers = Array.from(main.querySelectorAll('h2, h3, h4, h5, h6'))
            .filter(h => h.id !== '' && h.children.length && h.children[0].tagName === 'A');

        if (headers.length === 0) {
            return;
        }

        // Build a tree of headers in the sidebar.

        const stack = [];

        const firstLevel = parseInt(headers[0].tagName.charAt(1));
        for (let i = 1; i < firstLevel; i++) {
            const ol = document.createElement('ol');
            ol.classList.add('section');
            if (stack.length > 0) {
                stack[stack.length - 1].ol.appendChild(ol);
            }
            stack.push({level: i + 1, ol: ol});
        }

        // The level where it will start folding deeply nested headers.
        const foldLevel = 3;

        for (let i = 0; i < headers.length; i++) {
            const header = headers[i];
            const level = parseInt(header.tagName.charAt(1));

            const currentLevel = stack[stack.length - 1].level;
            if (level > currentLevel) {
                // Begin nesting to this level.
                for (let nextLevel = currentLevel + 1; nextLevel <= level; nextLevel++) {
                    const ol = document.createElement('ol');
                    ol.classList.add('section');
                    const last = stack[stack.length - 1];
                    const lastChild = last.ol.lastChild;
                    // Handle the case where jumping more than one nesting
                    // level, which doesn't have a list item to place this new
                    // list inside of.
                    if (lastChild) {
                        lastChild.appendChild(ol);
                    } else {
                        last.ol.appendChild(ol);
                    }
                    stack.push({level: nextLevel, ol: ol});
                }
            } else if (level < currentLevel) {
                while (stack.length > 1 && stack[stack.length - 1].level > level) {
                    stack.pop();
                }
            }

            const li = document.createElement('li');
            li.classList.add('header-item');
            li.classList.add('expanded');
            if (level < foldLevel) {
                li.classList.add('expanded');
            }
            const span = document.createElement('span');
            span.classList.add('chapter-link-wrapper');
            const a = document.createElement('a');
            span.appendChild(a);
            a.href = '#' + header.id;
            a.classList.add('header-in-summary');
            filterHeader(header.children[0], a);
            a.addEventListener('click', headerThresholdClick);
            const nextHeader = headers[i + 1];
            if (nextHeader !== undefined) {
                const nextLevel = parseInt(nextHeader.tagName.charAt(1));
                if (nextLevel > level && level >= foldLevel) {
                    const toggle = document.createElement('a');
                    toggle.classList.add('chapter-fold-toggle');
                    toggle.classList.add('header-toggle');
                    toggle.addEventListener('click', () => {
                        li.classList.toggle('expanded');
                    });
                    const toggleDiv = document.createElement('div');
                    toggleDiv.textContent = '❱';
                    toggle.appendChild(toggleDiv);
                    span.appendChild(toggle);
                    headerToggles.push(li);
                }
            }
            li.appendChild(span);

            const currentParent = stack[stack.length - 1];
            currentParent.ol.appendChild(li);
        }

        const onThisPage = document.createElement('div');
        onThisPage.classList.add('on-this-page');
        onThisPage.append(stack[0].ol);
        const activeItemSpan = activeSection.parentElement;
        activeItemSpan.after(onThisPage);
    });

    document.addEventListener('DOMContentLoaded', reloadCurrentHeader);
    document.addEventListener('scroll', reloadCurrentHeader, { passive: true });
})();

