# Why vim-like bindings

## Combinations

To simplify, let's start with having 26 letters accessible on the keyboard, no uppercase.
- using ctl + alt + key  gives us around 100 combinations
- letter + leter gives use around 650 combinations
- letter + letter + letter gives use around 18 000 combinations

If we had uppercase, ie, 52 letters
- using ctl + alt + key  gives us around 200 combinations
- letter + letter + letter gives use around 140 000 combinations

## Speed

typing ctl + alt + key is not faster than key + key + key, and even less key + key

## Structure and mnemonics 

Of course we don't need tens of thousands of combinations

But do you know what CA0-a does? C0S-A? 0AS-a? CAS-A? C00-A? 0A0-a? 00S-a? ... without looking at the docs?

The whole point vim-like binding is to remember them, it's not a perfect system but it's expandable and easier to remember

Let me give you and example, we have multiple types of boxes, let's say
- normal
-  unicode
-  shrink
-  with hash tag as a border

Let' start with a generic binder «i» for insert and «b» for box

- «ibb» normal, we cound have used «ibn» too but the most used keys are usually double for speed
- «ibu» unicode
- «ibs» shrink
- «ibh» with hash tag as a border

The good thing here is that we can use the same thing for arrows but with «ia» as a prefix.

But let's imagine that you come up with 4 new types of unicode borders (well you have), I don't want to imagine how to do that with the mouse, and with ctl + .... we've run out of shortcuts that are easy to remember. on the other hand ...

- «ibb» normal, we cound have used «ibn» too but the most used keys are usually double for speed
-  «ibuu» unicode
-  «ibu1» unicode
-  «ibu2» unicode
-  «ibu3» unicode
-  «ibs» shrink
-  «ibh» with hash tag as a border

I used 1, 2, and 3 because I was lacking imagination but
- double
- thick
- whatnot 

would have given us keys to remember.

## Quizz

Do you remember (although you've just seen it) ...

- insert a box
- insert a box using unicode type 2
- insert a box that shrinks
- inserta box with the default unicode

