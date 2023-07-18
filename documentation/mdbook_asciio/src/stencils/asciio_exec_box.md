# Asciio exec-boxes

An "exec-box" is and object that lets you run an external command and put its output in a box. There are different types of exec-boxes explained below.

## Multi command

Binding: «ie» Add exec box              

The simplest exec-box accepts multiple commands, one per line. It will redirect stderr for each command.

Editing the box will let you edit the command.

![ie](ie.gif)

## Verbatim 

Binding: «iv» Add exec box verbatim     

This exec-box doesn't redirect stderr, you can use it for commands that span multiple line or commands that take a multi line input

Editing the box will let you edit the command.

![iv](iv.gif)

## Once

Binding: «io» Add exec box verbatim once

This exec-box will run your commands once, editing the box will let you edit the command's output.

![io](io.gif)

## Add line numbers

Binding: «i + c-l» Add line numbered box     

This is an example of a custom stencil which will add line numbers to your input.

![il](il.gif)

## Examples

### Using previously generated output

If you already have text in a file you can use 'cat your_file' as the command.

### Tables

tbd: Command: ...

      +------------+------------+------------+------------+
      | input_size ‖ algorithmA | algorithmB | algorithmC |
      +============+============+============+============+
      |     1      ‖ 206.4 sec. | 206.4 sec. | 0.02 sec.  |
      +------------+------------+------------+------------+
      |    250     ‖     -      |  80 min.   | 2.27 sec.  |
      +------------+------------+------------+------------+

### FIGlet

FIGlet is a program for making large letters out of ordinary text.

- The tool's home page:
http://www.figlet.org/

- The man page for this tool:
http://www.figlet.org/figlet-man.html

The Linux system can be installed with source code.If you are in windows, The video below shows how to use
https://www.youtube.com/watch?v=mC_OvZyeoUo

#### The most basic usage

![FIGlet_asciio](FIGlet_asciio.gif)

#### More advanced usage

The fonts supported by figlet can be replaced. Use the following methods to view the figlet fonts installed in the current system. 
Just specify after the -f parameter.

```bash
pc@DESKTOP-0MVRMOU ~
$ ls /usr/share/figlet/
646-ca.flc   646-hu.flc   646-se2.flc  big.flf       lean.flf      smslant.flf
646-ca2.flc  646-irv.flc  646-yu.flc   block.flf     mini.flf      standard.flf
646-cn.flc   646-it.flc   8859-2.flc   bubble.flf    mnemonic.flf  term.flf
646-cu.flc   646-jp.flc   8859-3.flc   digital.flf   moscow.flc    upper.flc
646-de.flc   646-kr.flc   8859-4.flc   frango.flc    script.flf    ushebrew.flc
646-dk.flc   646-no.flc   8859-5.flc   hz.flc        shadow.flf    uskata.flc
646-es.flc   646-no2.flc  8859-7.flc   ilhebrew.flc  slant.flf     utf8.flc
646-es2.flc  646-pt.flc   8859-8.flc   ivrit.flf     small.flf
646-fr.flc   646-pt2.flc  8859-9.flc   jis0201.flc   smscript.flf
646-gb.flc   646-se.flc   banner.flf   koi8r.flc     smshadow.flf

pc@DESKTOP-0MVRMOU ~
$

```

For example, we want to specify this font: `slant`

![FLGlet_asciio_slant_font](FLGlet_asciio_slant_font.gif)

This is the exported effect:

```
            .-----------------------------------.
            |     _                _  _         |
            |    / \    ___   ___ (_)(_)  ___   |
            |   / _ \  / __| / __|| || | / _ \  |
            |  / ___ \ \__ \| (__ | || || (_) | |
            | /_/   \_\|___/ \___||_||_| \___/  |
            |                                   |
            '-----------------------------------'

            .------------------------------------.
            |     ___                 _  _       |
            |    /   |   _____ _____ (_)(_)____  |
            |   / /| |  / ___// ___// // // __ \ |
            |  / ___ | (__  )/ /__ / // // /_/ / |
            | /_/  |_|/____/ \___//_//_/ \____/  |
            |                                    |
            '------------------------------------'

```

There are more advanced usages of this tool, if you want to use it in depth, please check its man page.


### Diagon

https://github.com/ArthurSonzogni/Diagon

Diagon is an interactive interpreter. It transforms markdown-style expression into an ascii-art representation.
It is very suitable for use in combination with Asciio to improve efficiency. Makes it easier to generate certain 
charts and manage them nicely with Asciio.This tool can be used under both linux and windows.

In order to use this tool better, you can first generate a **help box** about this tool in Asciio:

![diagon_help.gif](diagon_help.gif)

It can also generate a help box about a **sub-function**

![diagon_help_sub](diagon_help_sub.gif)


I give a few simple examples:

- Mathematic Expression

![diagon_math](diagon_math.gif)

- generate a file tree

It is better to use ***exec verbatim box***, Because some commands involve multiple lines.


![diagon_ascii_tree](diagon_ascii_tree.gif)

![diagon_unicode_tree](diagon_unicode_tree.gif)

There are more advanced usages, please check the man page of the tool, here is not exhaustive.

### plantuml

https://plantuml.com/zh/ascii-art

This tool combined with Asciio's command box can easily and automatically generate sequence diagrams.
For details, please see the instructions in the link above.

tbd: Command: ...


