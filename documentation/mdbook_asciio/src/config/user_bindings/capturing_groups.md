# Capturing groups

If a group has an ESCAPE_KEY, the group is a capturing group. The group's bindings will be used repeatedly till the ESCAPE_KEY is pressed.


```perl

'capture group' =>
	{
	SHORTCUTS => '0A0-c',
	ESCAPE_KEY => '000-Escape',
	
	'capture x'     => [ '000-x', sub { print "captured x\n"; } ],
	'capture y'     => [ '000-y', sub { print "captured y\n"; } ],
	},

```
