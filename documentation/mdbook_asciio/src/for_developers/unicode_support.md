# Unicode character classification
- characters of length 1
- characters of length 2
- characters of length 0

>The length mentioned here refers to the printed 
length of the characters, that is, the length seen by the eyes

## Characters of length 1

Most unicode characters are characters with a length of 1, such 
as the commonly used tab character, ascii characters.
```
a b c d , . ┼ ┬ │
```
## Characters of length 2
Characters with a typographical width of 2 refer primarily to East 
Asian pictographs and related special punctuation, as well as full-width 
characters.

```
你好啊！《》
안녕하세요
こんにちは
```

They need to occupy two grids in the UI interface. Then aligning them 
requires special fonts that ***align 2:1 with width 1 characters***.Here is 
a commonly used font.

https://github.com/be5invis/Sarasa-Gothic/

These characters have a special property called ***East Asian Width***.
They are included in the unicode standard, so they can be used as a 
programming basis.

Links to the unicode standard:
https://www.unicode.org/reports/tr11/tr11-40.html

In perl's unicode documentation, corresponding properties are also 
provided to use.

This represents a wide character, occupying two spaces:

```perl
\p{EA=W}
```

This represents a full-width character, which also occupies two spaces:

```perl
\p{EA=F}
```
The above information can be found here:

https://perldoc.perl.org/perlunicook

https://perldoc.perl.org/perlunicode


## Characters of length 0

In some languages, there are special characters whose string length is 1, 
but they do not occupy physical space on the interface, they will be attached 
to the previous characters.they are called nonspacing characters.Occurs in 
Thai and Arabic, as well as Hebrew

```
◌ั ◌ึ ◌ุ
```

Please look at the above characters, they cannot appear alone, they must be 
used in combination with the previous entity characters, and then they will 
appear above or below the previous characters.

These characters are called Nonspacing characters in the unicode standard, 
and then they have the following properties that can be used for programming

```perl
\p{gc:Mn}
```

To support Thai, or Arabic, or Hebrew, like East Asian languages, we also need 
a special font that can be aligned.In general, the system's default monospaced 
font can align them






