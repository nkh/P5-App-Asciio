# Clipboard

| command | bindings|
|-|-|
|Copy to clipboard                       | 'C00-c' or 'C00-Insert'|
|Insert from clipboard                   | 'C00-v' or '00S-Insert'|
|-|-|
|Copy to clipboard                       | '000-y'+'000-y'|
|Export to clipboard & primary as ascii  | '000-y'+'00S-Y'|
|Export to clipboard & primary as markup | '000-y'+'000-m'|
|-|-|
|Insert from clipboard                   | '000-p'+'000-p'|
|Import from primary to box              | '000-p'+'00S-P'|
|Import from primary to text             | '000-p'+'0A0-p'|
|Import from clipboard to box            | '000-p'+'000-b'|
|Import from clipboard to text           | '000-p'+'000-t'|

Some clipboard commands are using the **xsel** command.

## Win11 Msys2

For users of `Win11 Msys2` system. To make using the clipboard function smoother,
it is best to install the `Win32::Clipboard` module. If this module is not
installed, then using `PowerShell` to perform clipboard operations is very
inefficient. Users of other systems do not have this requirement!

```bash
cpanm Win32::Clipboard --force
```

