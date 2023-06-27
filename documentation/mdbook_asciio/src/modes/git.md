# git

```

                     .*-----*------------------------------*
                    /                                       \
                   /                                         \
           *------*---------*-----BETA---.                    \
                   \                      \                    \
                    \    .-----.           '                    \
 .-------------.     *---| fix |---*-----RELEASE 1.3------>*-----*---------*
 | Release 2.0 |         '-----'    \                     /               /
 |-------------|                     \                   /               /
 | changes     |------------------->  '---*-------*--------------*------*
 | tag: ...    |                           \           /
 | eta: ...    |                            \         /
 '-------------'                             *-------'

```

The git mode allows you to draw git graph quickly. It adds a binding 

```perl
'Mouse quick link git' => [['0A0-button-press-3', '00S-semicolon'],  \&App::Asciio::Actions::Git::quick_link]
```

when you press the semicolon:

- if nothing is under the pointer or selected, it will insert a commit node
- if a node is selected and nothing under the pointer, it will insert a new node and connect with the previously selected node
- if a node is selected and the pointer is over a node, it will link the nodes

Let's create a simple git graph

![git graph](git_graph_feature_branch.gif)


We can export the text and use it in our documentation

```
                 .----------------------------------.
                 |          feature branch          |
                 |                                  |
                 |       *-------------------*      |
                 |      /                     \     |
                 |     /                       \    |
                 '----/-------------------------\---'
                     /                           \
          *---------*---------*---------*---------*---------*
                    ^                             ^
                    |                             |
                    |                             |
                    |                             |
             we need a new              we want to merge here
             feature branch

```

or we can get some fancy SVGs

![git graph](git_graph_feature_branch.svg)

![git graph](git_graph.svg)






