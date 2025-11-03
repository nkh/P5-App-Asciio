# Bindings

Goals when adding bindings:

- keep code separate from other bindings code if the new bindings are not very general, ie: code them in their own module

- align the structures

- avoid long or generic or numbered name

- if possible the bindings should be the same as the vim-bindings
	- some GUI standards may require different bindings, IE: C00-A to select everything

- create an equivalent binding set in the vim bindings file

- documents the bindings
	- name, keep them logical, start with an uppercase
	- key
	- what they do, preferably with some screenshot

- don't use control, shift and alt if possible (logical)

- split groups if they become too large

- sort by name or key if possible


