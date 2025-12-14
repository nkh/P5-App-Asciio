# requirements
- Linux
- `vim` version >= 8.2
- `asciio`, `asciio_to_text` utils folder in `$PATH`
- `~/.config/Asciio` folder present (see installation instructions)
- running `X session`
  Currently, there are some problems with hotkeys when running `tasciio` in Vim terminal or Tmux pane, so only GUI editor is supported for now.

# usage
```vim
source <P5-App-Asciio root>/examples/vim_integration/asciio_utils.vim
```
  
After sourcing the utils file, the following functions become available:  

 - `AsciioNewTemp()` creates a new diagram in a temporary folder and opens the editor.  
    After the editing is done, the current Asciio object is expected to be saved using `:w` editor command before quitting (`:q`).  
    The object will then be turned into text and read into the current buffer.
 - `AsciioEdit()` is used to edit the existing Asciio object using its full path.  
    Select the path string of the object using `CTRL-V`, then type `:call AsciioEdit()`.
 - `AsciioNew()` creates a new Asciio object with the user-provided name and saves it  
    to the local storage for Asciio objects under current directory (`.asc_objs/`).
 - `AsciioListEdit()` opens a popup window with all existing Asciio objects in `./.asc_objs` of the current working directory.  
    One may modify the object by selecting one of the menu items, and it will be inserted into the current buffer after the editor has closed.
 - `AsciioListRead()` opens a popup window with all existing Asciio objects in `./.asc_objs` of the current working directory.  
    By selecting one of the menu entries, one can read the object's text representation into the current buffer without editing.

There are no default key mappings provided at the moment.
