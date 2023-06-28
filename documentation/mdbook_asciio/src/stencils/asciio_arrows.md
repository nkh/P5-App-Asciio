# Asciio arrows

         «A»                Add angled arrow

         «a»                Add arrow

         «A-a»              Add unicode arrow

## wirl-arrow

Rotating the end clockwise or counter-clockwise changes its direction.

          ^            ^          
          |    -----.   \         
          |         |    \           
          '----     |     '------- 
    ------>         |             
                    v             

## multi section wirl-arrow

A set of whirl arrows connected to each other.

     .----------.                     .
     |          |                \   / \
        .-------'           ^     \ /   \
        |   .----------->    \     '     .
        |   '----.            \          /
        |        |             \        /
        '--------'              '------'

## angled-arrow and axis

    -------.       .-------
            \     /
             \   /            ^         
                              |   ^     
             /   \            |  /      
            /     \           | /       
     ------'       '-------    -------->

# Asciio lines

**line** is actually a special kind of **wirl-arrow** that removes the head and 
tail and turns off the automatic link function. The function of the line 
is mainly used to draw the table, and it is often used together with the 
cross mode.

> cross mode are described separately in a separate chapter

- line in normal insert mode


     «i» Insert group:

         «w»                Add ascii line

         «S-W»              Add unicode line

         «C-w»              Add unicode bold line

         «A-w»              Add unicode double line


- line in cross mode

     «x» cross group:

         «w»                Add cross ascii line

         «S-W»              Add cross unicode line

         «C-w»              Add cross unicode bold line

         «A-w»              Add cross unicode double line

## ascii line

```
                    ----------------------.
                                          |
                                          |
                                          |
                                          |
                                          |
```

## unicode line

```
                      ─────────────────────────╮
                                               │
                                               │
                                               │
                                               │
                                               │

```

## unicode bold line

```
                        ━━━━━━━━━━━━━━━━━━━━━━━┓
                                               ┃
                                               ┃
                                               ┃
                                               ┃

```

## unicode double line

```
                  ═══════════════════════════╗
                                             ║
                                             ║
                                             ║
                                             ║
                                             ║

```

## lines in cross mode

> Here's an example of using lines in a cross mode.

```
                     ╔═════╦═════╦══════╦═════╦════╦═════╗
                     ║     ║     ║      ║     ║    ║     ║
                     ╠═════╬═════╬══════╬═════╬════╬═════╣
                     ║     ║  A  ║      ║  B  ║    ║     ║
                     ╠═════╬═════╬══════╬═════╬════╬═════╣
                     ║     ║  C  ║      ║     ║    ║     ║
                     ╠═════╬═════╬══════╬═════╬════╬═════╣
                     ║     ║     ║      ║     ║  D ║     ║
                     ╠═════╬═════╬══════╬═════╬════╬═════╣
                     ╚═════╩═════╩══════╩═════╩════╩═════╝

```


