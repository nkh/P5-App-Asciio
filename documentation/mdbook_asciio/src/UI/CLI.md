# CLI


**asciio** can be used and controlled from the command line.


## asciio_to_text

Converts an existing '.asciio' file/project to ASCII and display it in the terminal

## text_to_asciio

Converts files, or text, to asciio elements.


### Converting Files

```bash
text_to_asciio filename.asciio file [file ...]
```

The command will create a box elements containing the content each file and save it in 'filename.asciio'.

### Converting text

A text stream is read from STDIN, split into chunks, and converted into asciio elements.

The resulting **asciio** file is output to STDOUT.

```bash
some_command | text_to_asciio > file.asciio

```

In this mode, text_to_asciio accepts the following options:

| option         |                                       | default               |
| -              | -                                     | -                     |
| -b             | create a box element                  | create a text element |
| text_separator | perl regular expression used to split | "\n"                  |


## scripting interface

You can create these types of scripts for asciio:

- a script that modifies a running **asciio**
    - you can send script to it via a POST to **asciio** web server
    - you can, from the UI, choose a script to be run

- a script in which you can create an asciio, without UI, and insert elements in it
    - the result can be saved in an '.asciio' file
    - the result can be printed as ASCII in your terminal

See the [Scripting](../for_developers/scripting.md) section for detailed information.

