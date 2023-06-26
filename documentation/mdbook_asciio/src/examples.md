# Examples

# Unix structure

```
              .---.  .---. .---.  .---.    .---.  .---.
     OS API   '---'  '---' '---'  '---'    '---'  '---'
                |      |     |      |        |      |
                v      v     |      v        |      v
              .------------. | .-----------. |  .-----.
              | Filesystem | | | Scheduler | |  | MMU |
              '------------' | '-----------' |  '-----'
                     |       |      |        |
                     v       |      |        v
                  .----.     |      |    .---------.
                  | IO |<----'      |    | Network |
                  '----'            |    '---------'
                     |              |         |
                     v              v         v
              .---------------------------------------.
              |                  HAL                  |
              '---------------------------------------'


```

## describing a class hierarchy

```

                                 .-Base::Class::Derived_B
                                /
     Something::Else           /
             \                .----Base::Class::Derived_C 
              \              /
               '----Base::Class
                     '       \
                    /         '----Latest::Greatest
      Some::Thing--'                                           

```

## Documenting hardware instrumentation

```
      _____ 
     | ___ |
     ||___|| load
     | ooo |--.------------------.------------------------.
     '_____'  |                  |                        |
              v                  v                        v
      .----------.  .--------------------------.  .----------------.
      | module C |  |         module A         |  |    module B    |
      '----------'  |--------------------------|  | (instrumented) |
           |        |        .-----.           |  '----------------'
           '---------------->| A.o |           |          |
                    |        '-----'           |          |
                    |   .------------------.   |          |
                    |   | A.instrumented.o |<-------------'
                    |   '------------------'   |
                    '--------------------------'
```

## Decorating Forth code

```
       index? dup dup dup dup dup average @ + average ! ." data = " .
    .--------------.
    |  Data Stack  |
    |--------------|
    | next element |-----> average @ + average !
    | dup          |-----> ." data = " .
    | dup          |-----> minv @ < if--.
    | dup          |                    '------> minv ! ." (new minv) " or DROP after ELSE
    | dup          |-----> maxv @ > if---.
    | dup          |                     '---->  maxv ! ." (new maxv) " or DROP after ELSE
    '--------------'
       minv @ < if
       minv ! ." (new minv) "
       else    drop                                                                        \ data > minv so it's ignored
           maxv @ > if
           maxv ! ." (new maxv) "
           else drop                                                                       \ data < maxv so it's ignored
           then
       then
       counter @ 1 - counter !                                                             \ Decrement counter
```
