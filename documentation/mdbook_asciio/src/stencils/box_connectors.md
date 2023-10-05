# Box connectors

It is possible to add custom connectors when creating a box stencil, see *setup/Asciio* for the default stencils.

```perl
create_box
	(
	NAME               => 'rabbit paw',
	TEXT_ONLY          => <<'TEXT'
(\_/)
(O.o)
/>
TEXT
,
	RESIZABLE          => 0,
	WITH_FRAME         => 0,
	DEFAULT_CONNECTORS => 0,
	CONNECTORS         => [[2, -1, -1, 2, -1, -1, 'paw']]
	),
```

## CONNECTORS

```perl
[ # An array of connector
	[
	2,      # X coordinate
	-1,     # percentage of width, -1 to disabe
	-1,     # offset added to position if perventage is used
	2,      # Y coordinate
	-1,     # same as above for Y
	-1,     # same as above for Y
	'paw'   # connector name
	],
	[
	# next connector
	...
	],
]
```

The box element class also has these functions:

- add_connector, dynamically add connector
- remove_connector, by name

## Example

![box_connector](box_connector.png)

