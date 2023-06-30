# Binding override

You can re-bind an existing shortcut to another command, Asciio will generate a warning in the console.

```
Overriding shortcut 'C00-y'
        new is 'Redo 2' defined in file '.../actions/override_bindings.pl'
        old was 'Redo' defined in file 'actions/default_bindings.pl'
```

![warning](warning.svg) Don't use the same shortcut multiple times in the *same* file, the order of registration in the *same* file not guaranteed.

