# Group bindings

Bindings can be grouped so you can use multiple key presses (vim-like) to reach an action.


```perl

'group name' =>
    {
    SHORTCUTS => 'C00-x',

    'binding group' => ['C00-x', ACTION_GROUP('next_level') ] ,
    'binding 1'     => ['000-1', sub { print "you're in x/1\n" ; } ],  
    },

'group_next_level' => # need to be prefixed with 'group_'
    {
    SHORTCUTS => 'C00-y', # can be accessed directly

    'binding in sub group' => ['C00-x', sub { print "you're in x/x/x\n" ; } ],  
    } ,

```


