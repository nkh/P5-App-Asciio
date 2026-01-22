
# User defined character sets

The character sets allow you to type in any character not only those on the keyboard.

Characters sets are defined in *gui.pl`*.

Character set bindings:

| action                                    | binding     |
|-------------------------------------------|-------------|
| Switch user-defined character set forward | `<<C00-n>>` |
| Switch user-defined character set back    | `<<C00-p>>` |
| Toggle prompt keyboard position           | `<<C00-c>>` |


After switching to a user defined character set, a layout panel will show the mapping,

![pen_char_prompt_panel](pen_char_prompt_panel.gif)

Example of user defined set:

```
'~' => '─' , '!' => '▀' , '@' => '▁' , '#' => '▂'  , '$' => '▃' , '%' => '▄' ,
'^' => '▅' , '&' => '▆' , '*' => '▇' , '(' => '█'  , ')' => '▉' , '_' => '▊' ,
'+' => '▋' , '`' => '▋' , '1' => '▌' , '2' => '▍'  , '3' => '▎' , '4' => '▏' ,
'5' => '▐' , '6' => '░' , '7' => '▒' , '8' => '▓'  , '9' => '▔' , '0' => 'À' ,
'-' => '│' , '=' => '┌' , 'Q' => '┐' , 'W' => '└'  , 'E' => '┘' , 'R' => '├' ,
'T' => '┤' , 'Y' => '┬' , 'U' => '┴' , 'I' => 'Ì'  , 'O' => 'Ð' , 'P' => '┼' ,
'{' => 'Ã' , '}' => 'Ä' , '|' => 'Â' , 'q' => 'Á'  , 'w' => 'Å' , 'e' => 'Æ' ,
'r' => 'Ç' , 't' => 'Ò' , 'y' => 'Ó' , 'u' => 'Ô'  , 'i' => 'Õ' , 'o' => 'à' ,
'p' => 'á' , '[' => 'â' , ']' => 'ã' , '\\' => 'ì' , 'A' => 'ø' , 'S' => 'ù' ,
'D' => 'ú' , 'F' => 'û' , 'G' => '¢' , 'H' => '£'  , 'J' => '¥' , 'K' => '€' ,
'L' => '₩' , ':' => '±' , '"' => '×' , 'a' => '÷'  , 's' => 'Þ' , 'd' => '√' ,
'f' => '§' , 'g' => '¶' , 'h' => '©' , 'j' => '®'  , 'k' => '™' , 'l' => '‡' ,
';' => '†' , "'" => '‾' , 'Z' => '¯' , 'X' => '˚'  , 'C' => '˙' , 'V' => '˝' ,
'B' => 'ˇ' , 'N' => 'µ' , 'M' => '∂' , '<' => '≈'  , '>' => '≠' , '?' => '≤' ,
'z' => '≥' , 'x' => '≡' , 'c' => '─' , 'v' => '│'  , 'b' => '┌' , 'n' => '┐' ,
'm' => '└' , ',' => '┘' , '.' => '├' , '/' => '┤' ,
```

The layout of the prompt keyboard can also be customized. Currently, two
keyboard layouts are supported.

```perl
PEN_KEYBOARD_LAYOUT_NAME => 'US_QWERTY', # US_QWERTY or SWE_QWERTY
```

