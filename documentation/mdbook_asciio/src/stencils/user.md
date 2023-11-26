# User stencils

You can create stencils that you are going to reuse, details of how to do it in the best way can be found in the *Configuration* section.

Here are three examples:

[![asciio-ditaa](https://github-readme-stats.vercel.app/api/pin/?username=oguma&repo=asciio-ditaa)](https://github.com/oguma/asciio-ditaa)

[![asciio_contrib](https://github-readme-stats.vercel.app/api/pin/?username=fbagagli&repo=asciio_contrib)](https://github.com/fbagagli/asciio_contrib)


## integrating Asciio and ditaa (third party example)

```

There was a page (Corn Empire) where a user detailed how to make an integration.

That page is not online anymore, I modified a copy for this documentation.

If you are the original author please contact me so I can give you credit.

```

## Introduction

You found this page because you are looking for more information on installing asciio and ditaa, and then modifying asciio to better interact with ditaa. Well you came to the right place. This guide will take you step-by-step through installing both tools, and modifying asciio to output diagrams to ditaa.

## Modifying asciio

Make yourself familiar with ditaa and asciio, you may see the benefit of outputting asciio text files that are compatible with ditaa without modification. Or better yet, generate your diagrams for you when you save :) . This section will explain how to do all of that and more!

## Adding in a Ditaa Stencil

You will need to create a new stencils file to create boxes and arrows that are compatible with ditaa (you could optionally modify the standard files if you will only use asciio for ditaa purposes). I got the idea for the modifications from here: http://strawp.net/archive/geeking-out-with-diagrams-in-ascii/

## A Standard Box

Go to the App/Asciio/setup/stencils (in the /usr/share/perl5/ or /usr/share/perl/5.10.0/) directory, and find the asciio file. Using for favourite editor, copy and paste the standard box code into a new file called ditaa. Then make the following changes to the standard box code in this new file:

To change the corners, modify line 14/33 and change . to + and modify line 17/36 and change \' to +.

Then modify lines 5 and 7 in the same way. Replace the . with + and the \' with +.

Or you could optionally just copy and paste the completed code below (the $VAR1 = [ is only needed once, and just starts off the file, the ]; at the end of the block, ends the file. All bless calls should be between these lines) :

```perl
$VAR1 = [
 
          bless( {
                   'HEIGHT' => 3,
                   'TEXT' => '+---+
|   |
+---+',
                   'NAME' => 'ditaabox',
                   'WIDTH' => 5,
		   'TEXT_ONLY' => '',
		   'TITLE' => '',
		   'BOX_TYPE' => 
				[
				[TRUE, 'top', '+', '-', '+', TRUE, ],
				[FALSE, 'title separator', '|', '-', '|', TRUE, ],
				[TRUE, 'body separator', '| ', '|', ' |', TRUE, ], 
				[TRUE, 'bottom', '+', '-', '+', TRUE, ],
				] ,
		   'EDITABLE' => 1,
		   RESIZABLE => 1,
		   X_OFFSET => 0, Y_OFFSET => 0,
                 }, 'App::Asciio::stripes::editable_box2' ),
 
                ];
```

## Add Rounded Box

But why stop there? How about we add in a nice ditaa rounded box. Add this code to the ditaa stencil file just below our modified box code:

```perl
          bless( {
                   'HEIGHT' => 3,
                   'TEXT' => '/---\\
|   |
\\---/',
                   'NAME' => 'roundedbox',
                   'WIDTH' => 5,
                   'TEXT_ONLY' => '',
                   'TITLE' => '',
                   'BOX_TYPE' =>
                                [
                                [TRUE, 'top', '/', '-', '\\', TRUE, ],
                                [FALSE, 'title separator', '|', '-', '|', TRUE, ],
                                [TRUE, 'body separator', '| ', '|', ' |', TRUE, ],
                                [TRUE, 'bottom', '\\', '-', '/', TRUE, ],
                                ] ,
                   'EDITABLE' => 1,
                   RESIZABLE => 1,
                   X_OFFSET => 0, Y_OFFSET => 0,
                 }, 'App::Asciio::stripes::editable_box2' ),
```

## Add ditaa Arrows

The asciio arrows don't jive well with ditaa. You can add this in the ditaa stencil file, it is based on the whirl arrow:

```perl
bless({
        'NAME' => 'ditaa_arrow',
        'HEIGHT' => 6,
        'WIDTH' => 17,
        'POINTS' => [[16,5]],
        'SELECTED' => 0,
        'EDITABLE' => 1,
        'ALLOW_DIAGONAL_LINES' => 0,
        'POINTS_OFFSETS' => [[0,0]],
        'DIRECTION' => 'down-right' ,
        'ARROW_TYPE' =>
                [
                ['origin', '', '*', '', '', '', TRUE],
                ['up', '|', '|', '', '', '^', TRUE],
                ['down', '|', '|', '', '', 'v', TRUE],
                ['left', '-', '-', '', '', '<', TRUE],
                ['upleft', '|', '|', '\\', '-', '<', TRUE],
                ['leftup', '-', '-', '\\', '|', '^', TRUE],
                ['downleft', '|', '|', '/', '-', '<', TRUE],
                ['leftdown', '-', '-', '/', '|', 'v', TRUE],
                ['right', '-', '-','', '', '>', TRUE],
                ['upright', '|', '|', '/', '-', '>', TRUE],
                ['rightup', '-', '-', '/', '|', '^', TRUE],
                ['downright', '|', '|', '\\', '-', '>', TRUE],
                ['rightdown', '-', '-', '\\', '|', 'v', TRUE],
                ['45', '/', '/', '', '', '^', TRUE, ],
                ['135', '\\', '\\', '', '', 'v', TRUE, ],
                ['225', '/', '/', '', '', 'v', TRUE, ],
                ['315', '\\', '\\', '', '', '^', TRUE, ],
                ],
 
        'ARROWS' =>
                [
                bless(
                        {
                        'HEIGHT' => 6,
                        'STRIPES' =>
                                [
                                {'TEXT' => '|
|
|
|
|
\'',
 
                                'HEIGHT' => 6,
                                'Y_OFFSET' => 0,
                                'WIDTH' => 1,
                                'X_OFFSET' => 0}
                                ,
                                {
                                'TEXT' => '--------------->',
                                'HEIGHT' => 1,
                                'Y_OFFSET' => 5,
                                'WIDTH' => 16,
                                'X_OFFSET' => 1
                                }
                                ],
                        'WIDTH' => 17,
                        'END_X' => 16,
                        'ARROW_TYPE' =>
                                [
                                #name: $start, $body, $connection, $body_2, $end
 
                                ['origin', '', '*', '', '', '', TRUE],
                                ['up', '|', '|', '', '', '^', TRUE],
                                ['down', '|', '|', '', '', 'v', TRUE],
                                ['left', '-', '-', '', '', '<', TRUE],
                                ['upleft', '|', '|', '\\', '-', '<', TRUE],
                                ['leftup', '-', '-', '\\', '|', '^', TRUE],
                                ['downleft', '|', '|', '/', '-', '<', TRUE],
                                ['leftdown', '-', '-', '/', '|', 'v', TRUE],
                                ['right', '-', '-','', '', '>', TRUE],
                                ['upright', '|', '|', '/', '-', '>', TRUE],
                                ['rightup', '-', '-', '/', '|', '^', TRUE],
                                ['downright', '|', '|', '\\', '-', '>', TRUE],
                                ['rightdown', '-', '-', '\\', '|', 'v', TRUE],
                                ['45', '/', '/', '', '', '^', TRUE, ],
                                ['135', '\\', '\\', '', '', 'v', TRUE, ],
                                ['225', '/', '/', '', '', 'v', TRUE, ],
                                ['315', '\\', '\\', '', '', '^', TRUE, ],
                                ],
                        'END_Y' => 5,
                        'DIRECTION' => 'down-right'
                        }, 'App::Asciio::stripes::wirl_arrow' ),
 
                ],
        }, 'App::Asciio::stripes::section_wirl_arrow' ) ,
```

## Add Colours and Special Shape Codes

All of the above will give you the core functionality of ditaa into asciio. But what about some basic colour tags, and shape codes. I've created a special stencil file for those. You can copy this below, and place it in a file called ditaatags next to the asciio stencil file.

```perl
my @ascii =
        (
        'shapes/document' => <<'EOA',
{d}
EOA
        'shapes/storage' => <<'EOA',
{s}
EOA
	'shapes/input_output' => <<'EOA',
{io}
EOA
        'shapes/tr' => <<'EOA',
{tr}
EOA
        'shapes/o' => <<'EOA',
{o}
EOA
        'shapes/mo' => <<'EOA',
{mo}
EOA
        'shapes/c' => <<'EOA',
{c}
EOA
        'colours/Red' => <<'EOA',
cRED
EOA
        'colours/Blue' => <<'EOA',
cBLU
EOA
        'colours/Pink' => <<'EOA',
cPNK
EOA
        'colours/Black' => <<'EOA',
cBLK
EOA
        'colours/Green' => <<'EOA',
cGRE
EOA
        'colours/Yellow' => <<'EOA',
cYEL
EOA
 
        ) ;
 
my @boxes ;
 
use App::Asciio::stripes::editable_box2 ;
 
for(my $ascii_index = 0 ; $ascii_index < $#ascii ; $ascii_index+= 2)
        {
        my $box = new App::Asciio::stripes::editable_box2
                                ({
                                TEXT_ONLY => $ascii[$ascii_index + 1],
                                EDITABLE => 1,
                                RESIZABLE => 1,
                                }) ;
 
        $box->set_box_type([map{$_->[0] = 0; $_} @{$box->get_box_type()}]) ;
        $box->shrink() ;
        $box->{'NAME'} = $ascii[$ascii_index] ;
        push @boxes, $box ;
        }
 
[@boxes] ;
```

Once these have been added, you need to modify the setup.ini file to point to the new stencils. To do that, run the following commands:

cd ..
sudo vim setup.ini
Where it says 'stencils/divers', add on the next line, 'stencils/ditaa', and then 'stencils/ditaatags',. Your new file should look like this:

```perl
{
STENCILS =>
        [
        'stencils/asciio',
        'stencils/computer',
        'stencils/people',
        'stencils/divers',
        'stencils/ditaa',
        'stencils/ditaatags',
        ],

ACTION_FILES =>
        [
        'actions/align.pl',
        'actions/clipboard.pl',
        'actions/debug.pl',
        'actions/new_elements.pl',
        'actions/elements_manipulation.pl',
        'actions/file.pl',
        'actions/mouse.pl',
        'actions/colors.pl',
        'actions/unsorted.pl',
        'actions/presentation.pl',

        'actions/context_menu_multi_wirl.pl',
        'actions/context_menu_box.pl',
        'actions/context_menu_rulers.pl',
        ],

HOOK_FILES =>
        [
        'hooks/canonize_connections.pl',
        ],

ASCIIO_OBJECT_SETUP =>
        [
        'asciio_object/basic.pl',
        ],

IMPORT_EXPORT =>
        [
        'import_export/ascii.pl',
        'import_export/perl.pl',
        'import_export/png.pl',
        ],

CUSTOM_MOUSE_CURSORS =>
        {
        'pen'    => 'mouse_cursors/pen.png',
        'eraser' => 'mouse_cursors/eraser.png',
        },
}
```

## Modifying Saving

It is nice to generate a text file of the data in case you need to make further tweaks before running it through ditaa. It is also required if you want to generate .pngs on the fly of your diagrams.

Go to App/Asciio/setup/actions and load up the file.pl file.

On line 65, replace the original saving code with the following:

```perl
		#$new_title = $self->save_with_type($elements_to_save, $type, $file_name) ;
		## Regardless of previous stuff, save one asciio file and one asciio.<ext>.txt ascii file
		## Courtesy of Strawp of http://strawp.net/archive/geeking-out-with-diagrams-in-ascii/
		$new_title = $self->save_with_type($elements_to_save, "asciio", $file_name) ;
		$new_title = $self->save_with_type($elements_to_save, "txt", $file_name.".txt") ;
 
		## Run ditaa to convert text version into nice copy
		## Use this if you have Proc::Background available.  Otherwise, use the system call below.
		#use Proc::Background;
		#my $proc1 = Proc::Background->new("c:\\bin\\ditaa.bat \"".$file_name.".txt\" \"".$file_name.".png\"");
		#my $proc1 = Proc::Background->new("java -jar /home/thomas/programs/ditaa/ditaa0_9.jar \"".$file_name.".txt\" \"".$file_name.".png\"");
		## This call converts while saving.  Slows down save time.  Replace the path below with your path to ditaa.jar
                ## You can add any special parameters here that you commonly use as well.
                ## Use this command if you unzipped the .jar file
		system("java -jar /home/thomas/programs/asciio-ditaa/ditaa0_9.jar \"".$file_name.".txt\" \"".$file_name.".png\"");
		## Use this command if you installed the .deb.
		#system("ditaa \"".$file_name.".txt\" \"".$file_name.".png\"");
```

## Using the New Setup

Now that you have made all of your tweaks, you are ready to start using your asciio/ditaa combo! Start by making a simple diagram. Here is one below:

Notice when you save this file for the first time:


Several files are created at first. As well as our rendered image.

Now, lets spice it up with some colour and some shapes. Use the right click menu to add the document tag to each of the items labelled document. To do this you will need to:

Right click and select stencils → ditaatags → shapes → document
Drag the {d} over the first document. I suggest you group any shapes, and shape modifiers by using CTRL+G once you set them up. If you do this, all of your pieces will move around if you have to tweak your image. Grouping involves selecting each item (hold shift while clicking each item), then press CTRL+G on your keyboard. This will cause this group of items to change background colour, and if you move one item, they will all move together. (You can ungroup by pressing CTRL+U)
Add another {d} to the other document.
If your item is falling behind the item you want, you can press CTRL+F to bring it to the foreground. Or CTRL+B to push the item on top into the background.
Now lets add some colour. Right click, and add some colour tags to the documents. As you save, you will notice the .png updates automatically.




Here is your final work of art:


## Troubleshooting

asciio Won't Load File
I've noticed that if you modify the stock asciio shapes (either through the gui itself, or in the stencils file) often times if you launch asciio, and then try to load a file with altered shapes, it will fail to load. It generates this output in the terminal:

thomas@thomas-desktop:~/programs/asciio-ditaa$ asciio
Using setup directory:'/usr/share/perl5/App/Asciio/setup/'
running action 'Open'.
load_file: can't load file '/home/thomas/programs/asciio-ditaa/saves/test':  Unrecognized character \x8E in column 23827 at (eval 105) line 372.
You can still get asciio to open, you just need to launch it with the file you want to load. So either launch it by typing something like:

thomas@thomas-desktop:~/programs/asciio-ditaa$ asciio /home/thomas/programs/asciio-ditaa/saves/test
Using setup directory:'/usr/share/perl5/App/Asciio/setup/'
running action 'Open'.
Or launch from your file manager. In my case, Nautilus:


## asciio Forgets Where I Saved

When loading asciio for the first time, and saving, I find that asciio forgets where I saved the document. It always returns to the original launching location.

To avoid this, I'd recommend that after your first save, you reopen asciio by using one of the two procedures mentioned above. This will allow it to remember where you are working, and the Save function will work correctly.


