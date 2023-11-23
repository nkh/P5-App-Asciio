# Executing your script

## From the command line

The script is a normal perl script.

```
perl my_asciio_script.pl
```

## From within Asciio

***Binding:*** «:!»

Pick the file you want to execute.

Or pass it on the command line 

```
asciio -s full_path_to_script
```

## Via Asciio's Web server

You can POST scripts via HTTP. 

Start Asciio with **--web_server**, a server will run at port **4444**; you can change the port with **--port other_port**. 

### script commands

POST http://localhost:4444/script script="add '1', new_box, 0, 0 ;"

You can have multiple commands in your script.

### script file

POST http://localhost:4444/script_file script="path_to_script"

### connecting to Asciio Web server

- directly from your application
- via a command line application like xh (https://github.com/ducaale/xh) or httpie.
- piping to *stdin_to_asciio_web* script which is installed with asciio (uses xh).

Example:

```bash

# bash script that adds an element to an asciio instance, offsets it, and deletes it

# create a script to add one element, the script can contain many scripting commands
# httpie has a large startup time, use xh instead

script= ; for i in $(seq 1) ; do script="$script add '1', new_box(TEXT_ONLY =>'$i'),  $((($i - 1) * 6)),  $((($i - 1) * 4)) ;" ; done

# execute the script
xh -f POST http://localhost:4444/script script="$script"

# offset the element
for i in $(seq 25) ; do sleep .05 ; xh  -f POST http://localhost:4444/script script="offset '1', 1, 1 ;" ; done

# delete the element
xh  -f POST http://localhost:4444/script script="delete_by_name '1' ;"

```

