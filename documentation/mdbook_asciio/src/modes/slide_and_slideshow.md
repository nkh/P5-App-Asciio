
# Slides and Slideshows

## Introduction

A slide is a normal document marked with the slide attribute; the slide attribute is saved with the document.

A slideshow exists when at least one document is marked as slide.

Slides are ordered by tab position; reorder tabs to change slideshow order.

## Turning a Document into a Slide

To turn a document into a slide:

- enable the slide attribute for the document
- the tab color changes to indicate slide status

## Slideshow Modes

### Manual Slideshow

The manual mode is intended for previewing does not create snapshots.

- the slides will be show one after another in a continuous loop
- you can pause and take over navigation
- navigate between slides
- change the delay between slides

### Automatic Slideshow

Automatic slideshow runs once through all slides in tab order and generates snapshots which can be used for video creation.

#### Timing

- default slide duration is 1000 ms (defined in the bindings)
- each slide can override its duration
- timing cannot be changed while running

#### 00_on_load

When running automatic slideshow:

- the script named 00_on_load is executed if present
- it runs before the snapshot is taken
- it can control timing
- it can trigger other scripts
- it can take additional snapshots

Scripts starting with '00' are reserved.

All other scripts must be started manually unless invoked from 00_on_load.

#### Snapshots

Snapshots are taken after 00_on_load completes.

Snapshots are saved to a configurable directory, the default directory is snapshots.

File naming format:

`snapshots/NNN_time_<time>_screenshot.png`

Where:

- NNN is a zero padded index
- time is the slide time

The slideshow can be interrupted by the user.

#### Slide State and Restoration

During a slideshow:

- slides are immutable
- script modifications do not persist

When leaving slideshow mode:

- each slide is restored from undo stack memory

Scripts executed outside slideshow mode modify the document normally.
The user can choose to save or not save those changes.

## Slide Directories

Each slide can define a slide directory.

When a slide directory is set:

- the directory is created if it does not exist
- a stub 00_on_load script is created

Multiple slides may share the same slide directory.

### Directory Resolution Order

When executing a script, directories are searched in this order:

- slide directory
- top directory
- scripts paths
- current directory

$directory //= $self->{ANIMATION}{SLIDE_DIRECTORY} // $self->{ANIMATION}{TOP_DIRECTORY} // $self->{SCRIPTS_PATHS} // '.' ;

The top directory can be defined on the command line, if not set, the current directory is used.

## Slides Bindings

```perl
'slides ->' => GROUP
	(
	SHORTCUTS    => '0A0-s',
	
	'tag as slide'           => '000-s', # make the document a slide, the tab color is changed
	'tag all as slide'       => 'C00-s',
	'untag as slide'         => '00S-S',
	
	'previous slide'         => '000-p', # these shortcuts navigate the tabs that are also slides
	'previous slide2'        => '00S-N', # they jump over the non slides
	'next slide'             => '000-n', # this let's us mix them
	'first slide'            => '000-g', # insert normal tabs that we can modify to be slides later
	'first slide2'           => '000-0', # remove slides from slideshows, ...
	
	'set slide time'         => '000-t', # each slide can have it's own time
	'set default slide time' => '00S-T',
	'run slideshow ->'       => '000-r', USE_GROUP('slideshow_run')      # manual slideshow
	'run slideshow once ->'  => '00S-R', USE_GROUP('slideshow_run_once') # automatic slideshow, a snapshot taken for each slide
	
	'set slide directory'    => '000-d', # if we want specific scripts for this slide, we can give it a special directory
	
	'animation ->'           => '000-a', USE_GROUP('animation') # bindings for animation/scripts
	),
```

## Slideshow Bindings

### Manual

```perl
'slideshow_run'    => GROUP
	(
	'pause'          => '000-p' # stop cycling through slides
	'previous slide' => '00S-N' # navigation bindings
	'next slide'     => '000-n'
	'slower'         => '000-s'
	'faster'         => '000-f'
	),
```

### Automatic

```perl
'slideshow_run_once' => GROUP
	(
	                # run with a 1000 ms slide time, except if it is set, and take a screenshot
	ENTER_GROUP  => [\&App::Asciio::Actions::Presentation::start_automatic_slideshow_once, [1000, 1]],
	
	# "$self->{ANIMATION}{SLIDE_DIRECTORY}/00_on_load" will be run if it exists
	),
```

## Running Scripts

Scripts are run in-process, they can access the full Asciio API, the current document, selected elements, and element ids.

Scripts can be started manually, name completion helps you chose the script.

### Numbered Scripts

Scripts matching the pattern NN_name can be used for sequential animation.

- scripts are ordered by numeric prefix
- scripts with prefix 00 are reserved
- the lowest numeric prefix runs first
- the user can execute next or previous based on prefix

### 00_on_load Script

00_on_load runs automatically in automatic slideshow mode.

## Using Element IDs

Elements can be assigned ids, ids are intended for use in scripting and animation.

Ids:

- are saved with the document
- are not required to be unique
- may match multiple elements, scripts querying an id receive all matching elements.

It is possible to temporarily display the elements ids for inspection.

```perl
'element ->' =>  GROUP
	(
	SHORTCUTS   => '000-e',
	
	'set id'    => '000-i',
	'remove id' => '00S-I',
	)
```

Example of "unicode character pointer", that can be moved around by a script.

It's also a good example of MACRO to create and assign an id to an element.

```perl
'Insert ->' => GROUP
	(
	SHORTCUTS   => '000-i',
	
	'Add pointer'        => [
				'000-p', 
				MACRO
					(
					[\&App::Asciio::Actions::Elements::add_element, ['🡴', 0 ]                       ],
					[\&App::Asciio::Actions::Elements::flip_autoconnect                             ],
					[\&App::Asciio::Actions::Elements::set_id, 'pointer'                            ],
					[\&App::Asciio::Actions::Colors::change_elements_colors, [0, [0.80, 0.10, 1.00]]],
					),
				],
	)

'display options ->' => GROUP
	(
	SHORTCUTS   => '000-z',
	'Flip display element id' => '000-i',
	),
```

## Animation Bindings

```perl
'animation ->' => GROUP
	(
	'show animation bindings'     => '00S-question' # the group hides all its bindings, this shows them
	
	'previous numbered animation' => '000-p', # if scripts start with qr/\d\d/ (except 00_xxxx) we can run them     
	'previous numbered animation' => '00S-N', # manually one after the other, forward and backwards     
	'next numbered animation'     => '000-n',      
	'first numbered animation'    => '000-g',      
	're-run animation'            => '000-r', 
	
	'take snapshot'               => '000-s', # builtin snapshot, maybe we need a binding at higher level     
	
	'find and run animation'      => '000-Tab', USE_GROUP('animation_complete')
	),

'animation_complete ->' => GROUP
	(
	'complete complete'     => '000-Tab'       # show a list of scripts matching the current prefix
	'complete complete all' => 'C00-Tab'       # show all the scripts
	'complete backspace'    => '000-BackSpace' # erase a character
	'complete erase'        => 'C00-l'         # erase the prefix
	'complete execute'      => '000-Return'    # run the current script
	
	"complete $_"           => "000-$_" ('a'..'z', '0'..'9', '_', '-')), # the script characters that are allowed
	),
```

## Generating a Video

Automatic slideshow generates image files.

To create a video:

- run automatic slideshow
- collect generated snapshots
- use an external tool to assemble the video

Video creation is performed outside Asciio but it's easy to add bindings.

[APNG](https://github.com/nkh/P5-Image-APNG) has a command line application, and a module, to generate Animated PNGs.

## Advanced Scripting

Advanced scripting allows fine grained control over animation and snapshot timing.

### Sequential Animation

Create scripts with numeric prefixes:

- 01_intro
- 02_highlight
- 03_finish

Execute them manually in order or trigger them from 00_on_load.

### Custom Timing in scripts (including 00_on_load)

Inside 00_on_load you may:

- control animation timing
- run other scripts
- take snapshots at specific points
- override the slide delay

**IMPORTANT:** Use ***asciio_sleep*** to control timing (*sleep* would block screen updates)

### Example Perl Snippet

```perl
set_slide_delay 0 ;

add 'box1', new_box(TEXT_ONLY =>'A'),  0,  2 ;
select_all_script_elements 1 ;
asciio_sleep 500 ;

add 'box2', new_box(TEXT_ONLY =>'B'), 20, 10 ;
select_all_script_elements 1 ;
asciio_sleep 500 ;

add 'box3', new_box(TEXT_ONLY =>'C'), 40,  5 ;
select_all_script_elements 1 ;
asciio_sleep 500 ;

flash_selected_elements ;
take_screenshot ;
```

