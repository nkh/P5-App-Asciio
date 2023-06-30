# Group bindings

Bindings can be grouped so you can use multiple key presses (vim-like) to reach an action.


```perl

'group name' =>
	{
	SHORTCUTS => 'C00-x',
	
	'sub group name' => 
		{
		SHORTCUTS => 'C00-x',
		
		'binding in sub group' => ['C00-x', sub { print "you're in x/x/x\n" ; } ],  
		} ,
	
	'binding 1' => ['000-1', sub { print "you're in x/1\n" ; } ],  
	'binding 2' => ['000-2', sub { print "you're in x/2\n" ; } ],  
	},

```
