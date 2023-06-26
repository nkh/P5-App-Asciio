# UIs

«R»                Add horizontal ruler

«r»                Add vertical ruler

![GUI](https://github.com/nkh/P5-App-Asciio/blob/master/screencasts/asciio.png)

```
          .-------------------------------------------------------------.
          | ........................................................... |
          | ..........-------------..------------..--------------...... |
          | .........| stencils  > || asciio   > || box          |..... |
          | .........| Rulers    > || computer > || text         |..... |
          | .........| File      > || people   > || wirl_arrow   |..... |
     grid----->......'-------------'| divers   > || axis         |..... |
          | ..................^.....'------------'| ...          |..... |
          | ..................|...................'--------------'..... |
          | ..................|........................................ |
          '-------------------|-----------------------------------------'
                              |
               context menu access some commands
               most are accessed through the keyboard

```

# TUI

```
         Open                                     [actions/vim_bindings.pl]    |         |  
         |         |         |         |         |         |         |         |         |  
         |         |         |         |         |         |         |         |         |  
         |         | .*-----*------------------------------*         |         |         |  
         |         |/        |         |         |         |\        |         |         |  
         |         /         |         |         |         | \       |         |         |  
         | *------*---------*------ABC---.       |         |  \      |         |         |  
---------|---------\---------|---------|--\------|---------|---\-----|---------|---------|--
         |         |\    .-----.       |   '     |         |    \    |         |         |  
         |         | *---| fix |---*------XYZ------------->*-----*---------*   |         |  
         |         |     '-----'    \  |         |        /|         |    /    |         |  
         |         |         |       \ |         |       / |         |   /     |         |  
         |         |         |        A---*-------*--------------*------*      |         |  
         |         |         |         |   \     |     /   |         |         |         |  
         |         |         |         |    \    |    /    |         |         |         |  
         |         |         |         |     *-------'     |         |         |         |  
         |         |         |         |         |         |         |         |         |  
---------|---------|---------|---------|---------|---------|---------|---------|---------|--
 
```


![TUI](https://github.com/nkh/P5-App-Asciio/blob/master/screencasts/tasciio.png)


# Asciio TUI and Vim

You can call Asciio from vim and insert your diagram.

        map  <leader><leader>a :call TAsciio()<cr>

        function! TAsciio()
            let line = getline('.')

            let tempn = tempname()
            let tempnt = tempn . '.txt'
            let temp = shellescape(tempn)
            let tempt = shellescape(tempnt)

            exec "normal i Asciio_file:" . tempn . "\<Esc>"

            if ! has("gui_running")
            exec "silent !mkdir -p $(dirname " . temp . ")" 
            exec "silent !cp ~/.config/Asciio/templates/empty.asciio ". temp . "; tasciio " . temp . "; asciio_to_text " . temp . " >" . tempt 
            exec "read " . tempnt
            endif

            redraw!
        endfunction

