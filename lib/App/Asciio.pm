
package App::Asciio ;

use strict;
use warnings;

use utf8;
use Encode;

use Data::TreeDumper ;
use Clone;
use List::Util qw(min max first) ;
use List::MoreUtils qw(any minmax first_value) ;

use App::Asciio::Setup ;
use App::Asciio::Dialogs ;
use App::Asciio::Elements ;
use App::Asciio::Menues ;
use App::Asciio::Actions ;
use App::Asciio::Undo ;
use App::Asciio::Io ;
use App::Asciio::Ascii ;
use App::Asciio::Options ;
use App::Asciio::Actions ;

use App::Asciio::Toolfunc ;

#-----------------------------------------------------------------------------

our $VERSION = '1.7' ;

#-----------------------------------------------------------------------------

=encoding utf8

=head1 NAME 

     ___              _ _ ____
    /   |  __________(_|_) __ \
   / /| | / ___/ ___/ / / / / /
  / ___ |(__  ) /__/ / / /_/ /
 /_/  |_/____/\___/_/_/\____/


=head1 SYNOPSIS

$> asciio [file.asciio]               # GUI application using Gtk3

$> tasciio [file.asciio]              # TUI application    

$> asciio_to_text file.asciio         # converts asciio files to ASCII

=head1 DESCRIPTION

Asciio allows you to draw ASCII diagrams in a GUI or TUI. The diagrams can be
saved as ASCII text or in a format that allows you to modify them later.

Diagrams consist of boxes and text elements connected by arrows. Boxes stay
connected when you move them around.


Both GUI and TUI have vim-like bindings, the GUI has a few extra bindings that
are usually found in GUI applications; bindings can be modified.

=head1 DOCUMENTATION

=head2 GUI

      .-------------------------------------------------------------.
      | ........................................................... |
      | ..........-------------..------------..--------------...... |
      | .........| stencils  > || asciio   > || box          |..... |
      | .........| Rulers    > || computer > || text         |..... |
      | .........| File      > || people   > || wirl_arrow   |..... |
 grid----->......'-------------'| divers   > || axis         |..... |
      | ..................^.....'------------'| ...          |..... |
      | ..................|...................'--------------'..... |
      | ..................|........................................ |
      '-------------------|-----------------------------------------'
                          |
           context menu access some commands
           most are accessed through the keyboard

=head2 Exporting to ASCII

You can export to a file in ASCII by using a '.txt' file extension.

You can also export the selection, in ASCII, to the Primary clipboard.

=head2 Elements

=head3 boxes and text 

                .----------.
                |  title   |
 .----------.   |----------|   ************
 |          |   | body 1   |   *          *
 '----------'   | body 2   |   ************
                '----------'
                                      any text
                            (\_/)         |
        text                (O.o)  <------'
                            (> <)

=head3 if-box and process-box

                       
   .--------------.    
  / a == b         \     __________
 (    &&            )    \         \
  \ 'string' ne '' /      ) process )
   '--------------'      /_________/
   

=head3 user boxes and exec-boxes 

For simple elements, put your design in a box, with or without a frame.

The an "exec-box" object that lets you put the output of an external
application in a box, in the example below the table is generated, if you
already have text in a file you can use 'cat your_file' as the command. 

  +------------+------------+------------+------------+
  | input_size ‖ algorithmA | algorithmB | algorithmC |
  +============+============+============+============+
  |     1      ‖ 206.4 sec. | 206.4 sec. | 0.02 sec.  |
  +------------+------------+------------+------------+
  |     4      ‖  900 sec.  | 431.1 sec. | 0.08 sec.  |
  +------------+------------+------------+------------+
  |    250     ‖     -      |  80 min.   | 2.27 sec.  |
  +------------+------------+------------+------------+

=head3 wirl-arrow

Rotating the end clockwise or counter-clockwise changes its direction.

        ^
        |            ^  
        |    -----.   \            
        '------   |    \         
  ------>         |     '-------
                  |   
                  v  
                  
=head3 multi section wirl-arrow

A set of whirl arrows connected to each other.

 .----------.                     .
 |          |                \   / \
    .-------'           ^     \ /   \
    |   .----------->    \     '     .
    |   '----.            \          /
    |        |             \        /
    '--------'              '------'
    

=head3 angled-arrow and axis

   -------.       .-------
           \     /
            \   /

            /   \
           /     \
    ------'       '-------
  
 ^
 |   ^
 |  /
 | /
  -------->

=head2 Examples

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


                                  
                             .----Base::Class::Derived_B
                            /
 Something::Else           /
         \                .-------Base::Class::Derived_C 
          \              /
           '-------Base::Class
                    '       \
                   /         '----Latest::Greatest
     Some::Thing--'                                           

  _____ 
 | ___ |
 ||   ||  
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

=head3 Unicode example

   ╭───────────────────────────────────────────────────────╮
   │ 中文韩文和unicode符号支持以及全新的菱形元素           │
   │ Chinese Korean and unicode symbols and rhombus object │
   ╰───────────────────────────────────────────────────────╯
                        ,',
                      ,'   ',
                    ,'       ',
          ╭────────:           :───────────╮
          │         ',       ,'            │
          │           ',   ,'              │
          │             ','                │
          │              │                 v
          v              v              ⎛     ⎞
        ┌───┐          ╭───╮            ⎜     ⎟
        │   │          │   │            ⎜     ⎟
        └───┘          ╰───╯            ⎝     ⎠

        ┌──────────────┐          ┌──────────────┐
        │ 主机1(host1) │          │ 主机2(host2) │
        └──────────────┘          └──────────────┘
          ^   ^                           ^   ^
          │   │                           │   │
          │   ╰───────────────────────╮   │   │
          │                           │   │   │
          │       ╭───────────────────│───╯   │
          │       │                   │       │
    PCIEx4│ PCIEx4│            PCIEx4 │ PCIEx4│
        ┌─────────────┐           ┌─────────────┐
        │ HBA card1   │           │ HBA card2   │
        └─────────────┘           └─────────────┘

=head2 Bindings

 «Enter»            Edit selected element

 «d»                Delete selected element(s)

 «u»                Undo

 «C»-r              Redo

 «.»                Quick link

 «,»                Quick copy

 «r»                Add vertical ruler

 «A-r»              Add horizontal ruler

 «R»                Remove rulers

 Moving elements:

=over 4

 «h»                Move selected elements left

 «j»                Move selected elements down

 «k»                Move selected elements up

 «l»                Move selected elements right


 «Left»             Move selected elements left

 «Down»             Move selected elements down

 «Up»               Move selected elements up

 «Right»            Move selected elements right

=back

 Selecting elements:

=over 4

 «n»                Select next element

 «N»                Select previous element

 «Tab»              Select next element move mouse

 «V»                Select all elements

 «v»                Select connected elements

 «Escape»           Deselect all elements

=back

 Resizing elements:

=over 4

 «1»                Make element narrower

 «2»                Make element taller

 «3»                Make element shorter

 «4»                Make element wider

 «s»                Shrink box

=back

 Clipboard:

=over 4

 «y»                Copy to clipboard

 «p»                Insert from clipboard

 «Y»                Export to clipboard & primary as ascii

 «P»                Import from primary to box

 «A-P»              Import from primary to text

=back

 «:» command group:

=over 4

 «q»                Quit

 «Q»                Quit no save

 «w»                Save

 «W»                SaveAs

 «e»                Open

 «r»                Insert

 «m»                Display manpage

 «h»                Help

 «c»                Display commands

 «f»                Display action files

 «k»                Display keyboard mapping

=back

 «i» Insert group:

=over 4

 «A»                Add angled arrow

 «a»                Add arrow

 «A-a»              Add unicode arrow

 «B»                Add shrink box

 «b»                Add box

 «A-b»              Add unicode box

 «c»                Add connector

 «E»                Add exec-box no border

 «e»                Add exec-box

 «f»                Insert from file

 «g»                Add group object type 1

 «h»                Add help box

 «i»                Add if-box

 «R»                Add horizontal ruler

 «x»                External command output in a box

 «X»                External command output in a box no frame

 «p»                Add process

 «r»                Add vertical ruler

 «t»                Add text

=back

 «a» arrow group:

=over 4

 «S»                Insert multi-wirl section

 «f»                Flip arrow start and end

 «d»                Change arrow direction

 «s»                Append multi-wirl sectioni

 «A-s»              Remove last section from multi-wirl

=back


 «A» align group:

=over 4

 «b»                Align bottom

 «c»                Align center

 «l»                Align left

 «m»                Align middle

 «r»                Align right

 «t»                Align top

=back

 «g» grouping group:

=over 4

 «g»                Group selected elements

 «u»                Ungroup selected elements

 «F»                Temporary move selected element to the front

 «f»                Move selected elements to the front

 «b»                Move selected elements to the back

=back

 «A-g» stripes-group group:

=over 4

 «1»                Create one stripe group

 «g»                Create stripes group

 «u»                Ungroup stripes group

=back

 «z» display group:

=over 4

 «C»                Change grid color

 «c»                Change Asciio background color

 «g»                Flip grid display

 «s»                Flip color scheme

 «t»                Flip transparent element background

=back

 «D» debug group:

=over 4

 «E»                Dump selected elements

 «e»                Dump all elements

 «S»                Display undo stack statistics

 «o»                Test

 «s»                Dump self

 «t»                Display numbered objects

=back

 «S» slides group:

=over 4

 «N»                Previous slide

 «g»                First slide

 «l»                Load slides

 «n»                Next slide

=back

Mouse emulation:

=over 4

 «'»                Toggle» mouse

 «Ö»                Mouse shift-left-click

 «ö»                Mouse left-click

 «ä»                Mouse right-click

 «H»                Mouse drag left 3

 «J»                Mouse drag down 3

 «K»                Mouse drag up 3

 «L»                Mouse drag right 3

 «Down»             Mouse drag down

 «Left»             Mouse drag left

 «Right»            Mouse drag right

 «Up»               Mouse drag up


 «A-Down»           Mouse drag down

 «A-Left»           Mouse drag left

 «A-Right»          Mouse drag right

 «A-Up»             Mouse drag up


 «ö»                Mouse alt-left-click

 «ö»                Mouse ctl-left-click

=back

=head2 GUI extra bindings

 «C00-a»            Select all elements

 «C00-c»            Copy to clipboard

 «C00-v»            Insert from clipboard

 «C00-e»            Export to clipboard & primary as ascii

 «C0S-V»            Import from primary to box

 «C00-z»            Undo

 «C00-y»            Redo

 «+»                Zoom in

 «-»                Zoom out

 «double-click»     Edit selected element

 «C00-button-1»     Add to delection

 «0A0-button-1»     Quick link

 «0AS-button-1»     Duplicate elements

 «CA0-button-1»     Insert flex point

=head1 Asciio and Vim 

You can call Asciio from vim and insert your diagram.

    map  <leader><leader>a :call TAsciio()<cr>

    function! TAsciio()
        let line = getline('.')

        let tempn = tempname()
        let tempnt = tempn . '.txt'
        let temp = shellescape(tempn)
        let tempt = shellescape(tempnt)

        exec "normal i Asciio_file:" . tempn . "\<Esc>"

        if ! has("gui_running")
        exec "silent !mkdir -p $(dirname " . temp . ")" 
        exec "silent !cp ~/.config/Asciio/templates/empty.asciio ". temp . "; tasciio " . temp . "; asciio_to_text " . temp . " >" . tempt 
        exec "read " . tempnt
        endif

        redraw!
    endfunction

=cut

sub new
{
my ($class) = @_ ;

my $self = 
	bless 
		{
		ELEMENT_TYPES => [],
		ELEMENTS => [],
		CONNECTIONS => [],
		CLIPBOARD => {},
		FONT_FAMILY => 'Monospace',
		FONT_SIZE => '10',
		TAB_AS_SPACES => '   ',
		OPAQUE_ELEMENTS => 1,
		DISPLAY_GRID => 1,
		DISPLAY_GRID2 => 1,
		
		DOUBLE_WIDTH_QR => qr/(?!)/,
		BROWSER => "$ENV{BROWSER} --new-window",
		
		PREVIOUS_X => 0, PREVIOUS_Y => 0,
		MOUSE_X => 0, MOUSE_Y => 0,
		DRAGGING => undef,
		SELECTION_RECTANGLE =>{START_X => 0, START_Y => 0},
		
		ACTIONS => {},
		
		COPY_OFFSET_X => 3,
		COPY_OFFSET_Y => 3,
		COLORS => {},
		
		NEXT_GROUP_COLOR => 0, 
		
		WORK_DIRECTORY => '.asciio_work_dir',
		CREATE_BACKUP => 1,
		MODIFIED => 0,
		
		DO_STACK_POINTER => 0,
		DO_STACK => [] ,
		}, $class ;

set_double_width_qr($self) ;

return($self) ;
}

#-----------------------------------------------------------------------------

sub event_options_changed
{
my ($self) = @_;

$self->{CURRENT_ACTIONS} = $self->{ACTIONS} ;

$self->set_font($self->{FONT_FAMILY}, $self->{FONT_SIZE}) ;

$self->{TAB_AS_SPACES} = '   ' unless defined $self->{TAB_AS_SPACES} ;
set_double_width_qr($self) ;
}

#-----------------------------------------------------------------------------

sub exit
{
my ($self, $code) = @_ ;

exit ($code // 0) ;
}

#-----------------------------------------------------------------------------

sub set_title
{
my ($self, $title) = @_;

defined $title and $self->{TITLE} = $title ;
}

sub get_title
{
my ($self) = @_;
Encode::_utf8_on($self->{TITLE});
$self->{TITLE} ;
}

#-----------------------------------------------------------------------------

sub set_font
{
my ($self, $font_family, $font_size) = @_;

$self->{FONT_FAMILY} = $font_family || 'Monospace';
$self->{FONT_SIZE} = $font_size || 10 ;
}

sub get_font
{
my ($self) = @_;

return($self->{FONT_FAMILY},  $self->{FONT_SIZE}) ;
}

sub get_font_as_string
{
my ($self) = @_;

return("$self->{FONT_FAMILY} $self->{FONT_SIZE}") ;
}

#-----------------------------------------------------------------------------

sub update_display 
{
my ($self) = @_;

$self->call_hook('CANONIZE_CONNECTIONS', $self->{CONNECTIONS}, $self->get_character_size()) ;
}

#-----------------------------------------------------------------------------

sub call_hook
{
my ($self, $hook_name,  @arguments) = @_;

$self->{HOOKS}{$hook_name}->(@arguments)  if (exists $self->{HOOKS}{$hook_name}) ;
}

#-----------------------------------------------------------------------------

sub button_release_event 
{
my ($self, $event) = @_ ;

my $button = $event->{BUTTON} ;
my $modifiers = $event->{MODIFIERS} ;

if($self->exists_action("${modifiers}$event->{TYPE}-$button"))
	{
	$self->run_actions(["${modifiers}$event->{TYPE}-$button", $event]) ;
	}

undef $self->{DRAGGING} ;

if(defined $self->{MODIFIED_INDEX} && defined $self->{MODIFIED} && $self->{MODIFIED_INDEX} == $self->{MODIFIED})
	{
	$self->pop_undo_buffer(1) ; # no changes
	}

$self->update_display();
}

#-----------------------------------------------------------------------------

sub button_press_event 
{
my ($self, $event) = @_ ;

undef $self->{DRAGGING} ;
delete $self->{RESIZE_CONNECTOR_NAME} ;

$self->create_undo_snapshot() ;
$self->{MODIFIED_INDEX} = $self->{MODIFIED} ;

my $button = $event->{BUTTON} ;
my $modifiers = $event->{MODIFIERS} ;

$self->run_actions(["${modifiers}$event->{TYPE}-$button", $event]) ;
}

#-----------------------------------------------------------------------------

sub motion_notify_event 
{
my ($self, $event) = @_ ;

my $button = $event->{BUTTON} ;
my($x, $y) = @{$event->{COORDINATES}} ;
my $modifiers = $event->{MODIFIERS} ; 

if($self->{PREVIOUS_X} != $x || $self->{PREVIOUS_Y} != $y)
	{
	$self->run_actions(["${modifiers}motion_notify", $event]) ;
	
	($self->{PREVIOUS_X}, $self->{PREVIOUS_Y}) = ($x, $y) ;
	}

($self->{MOUSE_X}, $self->{MOUSE_Y}) = ($x, $y) ;
}

#-----------------------------------------------------------------------------

sub select_element_event
{
my ($self, $x, $y, $filter) = @_ ;

my ($x_offset, $y_offset) = ($x - $self->{PREVIOUS_X},  $y - $self->{PREVIOUS_Y}) ;

$self->{SELECTION_RECTANGLE}{END_X} = $x ;
$self->{SELECTION_RECTANGLE}{END_Y} = $y ;

$filter = sub {1} unless defined $filter ;

$self->select_elements
	(
	1,
	grep
		{ $filter->($_) }
	grep # elements within selection rectangle
		{
		$self->element_completely_within_rectangle
			(
			$_,
			$self->{SELECTION_RECTANGLE},
			)
		} @{$self->{ELEMENTS}}
	)  ;

$self->update_display();
}

#-----------------------------------------------------------------------------

sub move_elements_event
{
my ($self, $x, $y) = @_;

my ($x_offset, $y_offset) = ($x - $self->{PREVIOUS_X},  $y - $self->{PREVIOUS_Y}) ;

my @selected_elements = $self->get_selected_elements(1) ;

$self->move_elements($x_offset, $y_offset, @selected_elements) ;
$self->update_display();
}

#-----------------------------------------------------------------------------

sub resize_element_event
{
my ($self, $x, $y) = @_ ;

my ($x_offset, $y_offset) = ($x - $self->{PREVIOUS_X},  $y - $self->{PREVIOUS_Y}) ;

my ($selected_element) = $self->get_selected_elements(1) ;

$self->{RESIZE_CONNECTOR_NAME} =
	$self->resize_element
			(
			$self->{PREVIOUS_X} - $selected_element->{X}, $self->{PREVIOUS_Y} - $selected_element->{Y} ,
			$x - $selected_element->{X}, $y - $selected_element->{Y} ,
			$selected_element,
			$self->{RESIZE_CONNECTOR_NAME},
			) ;
			
$self->update_display();
}

#-----------------------------------------------------------------------------

my %ignored_keys = map { $_ => 1 } qw(000-Control_L 000-Control_R 000-Shift_L 000-Shift_R 000-Alt_L 000-ISO_Level3_Shift) ;

sub key_press_event
{
my ($self, $event)= @_;

my $modifiers = $event->{MODIFIERS} ;
my $key = $event->{KEY_NAME} ;

$self->{CACHE}{ORIGINAL_EVENT} = $event ;

$self->run_actions("${modifiers}$key") unless exists $ignored_keys{"${modifiers}$key"} ;
}

#-----------------------------------------------------------------------------

sub update_quadrants
{
my ($self, $element) = @_ ;

my ($x1, $x2, $y1, $y2) = $element->get_extents() ;
}

#-----------------------------------------------------------------------------

sub get_character_size
{
my ($self) = @_ ;
	
if(exists $self->{USER_CHARACTER_WIDTH})
	{
	return ($self->{USER_CHARACTER_WIDTH}, $self->{USER_CHARACTER_HEIGHT}) ;
	}
else
	{
	return (8, 16) ;
	}
}

#-----------------------------------------------------------------------------

sub set_character_size
{
my ($self, $width, $height) = @_ ;

($self->{USER_CHARACTER_WIDTH}, $self->{USER_CHARACTER_HEIGHT}) = ($width, $height) ;
}

#-----------------------------------------------------------------------------

sub get_color 
{
my ($self, $name) = @_;

return($self->{COLORS}{$name} // [1, 0, 0]) ;
}

#-----------------------------------------------------------------------------

sub invalidate_rendering_cache
{
my ($self) = @_ ;

for my $element (@{$self->{ELEMENTS}}) 
	{
	delete $element->{CACHE} ;
	}

delete $self->{CACHE} ;
}

#-----------------------------------------------------------------------------

=head1 DEPENDENCIES

gnome libraries, gtk, gtk-perl for the gtk version

=head1 BUGS AND LIMITATIONS

Please report errors at  https://github.com/nkh/P5-App-Asciio/issues.

=head1 AUTHORS

	Khemir Nadim ibn Hamouda
	https://github.com/nkh
	CPAN ID: NKH

	Qin Qing
	northisland2017@gmail.com
	unicode support, scroll bar, and rhombus object
 
=head1 LICENSE AND COPYRIGHT

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=head2 Docker Image

There are docker images made by third parties, use a search engine for the latest.

example image: https://gist.github.com/BruceWind/32920cf74ba5b7172b31b06fec38aabb

=head1 SEE ALSO

	http://www.jave.de
	http://search.cpan.org/~osfameron/Text-JavE-0.0.2/JavE.pm
	http://ditaa.sourceforge.net/
	http://www.codeproject.com/KB/macros/codeplotter.aspx
	http://search.cpan.org/~jpierce/Text-FIGlet-1.06/FIGlet.pm
	http://www.ascii-art.de (used some entries as base for the network stencil)
	http://www.textfiles.com/art/
	http://www2.b3ta.com/_bunny/texbunny.gif


     *\o_               _o/*
      /  *             *  \
     <\       *\o/*       />
                )
         o/*   / >    *\o
         <\            />
 __o     */\          /\*     o__
 * />                        <\ *
  /\*    __o_       _o__     */\
        * /  *     *  \ *
         <\           />
              *\o/*
 ejm97        __)__

=cut

#------------------------------------------------------------------------------------------------------

"
(\_/)
(O.o)
/> ASCII world domination!
"


