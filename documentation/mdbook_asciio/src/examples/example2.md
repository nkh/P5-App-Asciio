# German railroad

*Graph-Easy* is an application that generates graphs in ASCII, a bit like GraphViz.

[![Graph-Easy](https://github-readme-stats.vercel.app/api/pin/?username=ironcamel&repo=Graph-Easy)](https://github.com/ironcamel/Graph-Easy)


```
               ..................................
               :                                v
+------+     +--------+     .............     +---------+     +---------+
| Bonn | --> | Berlin | --> :           : --> | Potsdam | ==> | Cottbus |
+------+     +--------+     :           :     +---------+     +---------+
               ^            :           :                       ^
               |            : Frankfurt :                       |
               |            :           :                       |
             +--------+     :           :     +---------+       |
             |   x    | --> :           : <-- |    y    | ------+
             +--------+     :...........:     +---------+
                              |
                              |
                              v
                            +-----------+
                            |  Dresden  |
                            +-----------+
```

I re-drew the example above in Asciio.

```

                 .------------------------------.
                 |                              |
                 |                              v
.------.    .--------.    .-----------.    .---------.  .---------.
| Bonn |-.->| Berlin |-.->| Frankfurt |-.->| Potsdam |->| Cottbus |
'------' |  '--------' |  '-----------' |  '---------'  '---------'
         |             |                |                    ^
       .---.           |                |  .---------.       |
       | x |-----------'                '->| Dresden |       |
       '---'           |                   '---------'       |
       .---.           |                                     |
       | y |-----------'-------------------------------------'
       '---'

```

There are few interesting things to notice:

- Graph-Easy smartly changes the size of the boxes to accommodate more connections
- Asciio doesn't have a routing functionality for graph, it would be a nice addition
- Asciio has 4 connectors per box (but you can get around it)


