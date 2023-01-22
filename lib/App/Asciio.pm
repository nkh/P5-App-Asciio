
package App::Asciio ;

$|++ ;

use strict;
use warnings;

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

#-----------------------------------------------------------------------------

our $VERSION = '1.6' ;

#-----------------------------------------------------------------------------

=head1 NAME 

App::Asciio - Plain ASCII diagram

	                  |     |             |       |
	          |       |     |      |      |       |
	          |       |     |      |      |       |
	          v       |     v      |      v       |
	                  v            v              v
		 _____                           _____      
		/\  _  \                        /\  __ \    
		\ \ \_\ \    ___     ___   _   _\ \ \ \ \   
	----->	 \ \  __ \  /  __\  / ___\/\ \/\ \ \ \ \ \  ----->
		  \ \ \ \ \/\__,  \/\ \___' \ \ \ \ \ \_\ \ 
		   \ \_\ \_\/\____/\ \____/\ \_\ \_\ \_____\
		    \/_/\/_/\/___/  \/___/  \/_/\/_/\/_____/
	
	          |             |             |     |
	          |     |       |     |       |     |      |
	          v     |       |     |       v     |      |
		        |       v     |             |      |
		        v             |             |      v
		       		      v             v
	(\_/)
	(O.o) ASCII world domination is near!
	(> <) 

=head1 SYNOPSIS

	$> perl asciio.pl

=head1 DESCRIPTION

This application allows you to draw ASCII diagrams in a simple graphical interface.

The ASCII graphs can be saved as ASCII or in a format that allows you to modify them later.


=head1 DOCUMENTATION

=head2 Asciio user interface

	
            .-----------------------------------------------------------------.
            |                             Asciio                              |
            |-----------------------------------------------------------------|
            | ............................................................... |
            | ..............-------------..------------..--------------...... |
            | .............| stencils  > || asciio   > || box          |..... |
            | .............| Rulers    > || computer > || text         |..... |
            | .............| File      > || people   > || wirl_arrow   |..... |
     grid---------->.......'-------------'| divers   > || axis         |..... |
            | ......................^.....'------------'| boxes      > |..... |
            | ......................|...................| rulers     > |..... |
            | ......................|...................'--------------'..... |
            | ......................|........................................ |
            | ......................|........................................ |
            | ......................|........................................ |
            | ......................|........................................ |
            '-----------------------|-----------------------------------------'
                                    |
                                    |
                              context menu
				   

Press 'F1' for help; 'F2', 'F3', 'F4' for mappings.

=head2 Context menu

The context menu allows to access to B<Asciio> commands.

=head2 Keyboard shortcuts

All the keyboad commands definitions can be found under I<asciio/setup/actions/>. Among the commands
implemented are:

=over 2

=item * select all

=item * delete

=item * undo

=item * group/ungroup

=item * open / save

=item * local clipboard operations

=item * send to front/back

=item * insert arrow, boxes, text

=item * ...

=back

=head2 Elements

=head3 wirl arrow

An arrow that tries to do what you want. Rotating the end clockwise or counter-clockwise changes its direction

               ^
               |
               |    --------.
               |            |
               '-------     |
                            |
 O-------------X     /      |
                    /       |
                   /        |
                  /         v
                 /
                /
               v
	       

=head3 multi section wirl arrow

A set of whirl arrows connected to each other

 .----------.                       .
 |          |                \     / \
    .-------'           ^     \   /   \
    |                    \     \ /     \
    |   .----------->     \     '       .
    |   '----.             \           /
    |        |              \         /
    '--------'               '-------'
    


=head3 angled arrow and axis

   -------.         .-------
           \       /
            \     /
             \   /
 
             /   \
            /     \
           /       \
    ------'         '-------
    
          ^
     ^    |    ^
      \   |   /
       \  |  /
        \ | /
 <-------- -------->
        / |\
       /  | \
      /   |  \
     v    |   v
          v
	

=head3 box and text 

                 .----------.
                 |  title   |
  .----------.   |----------|   ************
  |          |   | body 1   |   *          *
  '----------'   | body 2   |   ************
                 '----------'
                                             anything in a box
                                 (\_/)               |
         edit_me                 (O.o)  <------------'
                                 (> <)
				 

You can also use the 'External commands in box' to direct an external command output to a box.

=head3 "if" box and "process" box

                        ____________
   .--------------.     \           \
  / a == b         \     \           \   __________
 (    &&            )     ) process   )  \         \
  \ 'string' ne '' /     /           /    ) process )
   '--------------'     /___________/    /_________/
   

=head3 user stencils

Take a look at I<setup/stencils/computer> for a stencil example. Stencils listed in I<setup/setup.ini> will
be loaded when B<Asciio> starts.

=head3 user element type

For simple elements, put your design in a box. That should cover 90% of anyone's needs. You can look in 
I<lib/stripes> for element implementation examples.

=head2 Exporting to ASCII

You can export to a file in ASCII format but using the B<.txt> extension.

Exporting to the clipboard is done with B<ctl + e>.

=head1 EXAMPLES

	
           User code ^            ^ OS code
                      \          /
                       \        /
                        \      /
           User code <----Mode----->OS code
                        /      \
                       /        \
                      /          \
          User code  v            v OS code
	  
	
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
	     


                 
                 .---------.  .---------.
                 | State 1 |  | State 2 |
                 '---------'  '---------'
                    ^   \         ^  \
                   /     \       /    \
                  /       \     /      \
                 /         \   /        \
                /           \ /          \
               /             v            v
            ******        ******        ******
            * T1 *        * T2 *        * T3 *
            ******        ******        ******
               ^             ^             /
                \             \           /
                 \             \         /
                  \             \       / stimuli
                   \             \     /
                    \             \   v
                     \         .---------.
                      '--------| State 3 |
                               '---------'
			       

                                        .--Base::Class::Derived_A
                                       /
                                      .----Base::Class::Derived_B    
      Something--------.             /         \
                        \           /           '---Base::Class::Derived::More
      Something::else    \         /             \
            \             \       /               '-Base::Class::Derived::Deeper
             \             \     /
              \             \   .-----------Base::Class::Derived_C 
               \             \ /
                '-------Base::Class
                       /   \ \ \
                      '     \ \ \
                      |      \ \ '---The::Latest
                     /|       \ \      \
 With::Some::fantasy' '        \ \      '----The::Latest::Greatest
                     /|         \ \
         More::Stuff' '          \ '-I::Am::Running::Out::Of::Ideas
                     /|           \
         More::Stuff' '            \
                     /              '---Last::One
         More::Stuff'


   ____[]
  | ___ |
  ||   ||  device
  ||___||  loads
  | ooo |------------------------------------------------------------.
  | ooo |    |                          |                            |
  | ooo |    |                          |                            |
  '_____'    |                          |                            |
             |                          |                            |
             v                          v                            v
   .-------------------.  .---------------------------.    .-------------------.
   | Loadable module C |  |     Loadable module A     |    | Loadable module B |
   '-------------------'  |---------------------------|    |   (instrumented)  |
             |            |         .-----.           |    '-------------------'
             '--------------------->| A.o |           |              |
                 calls    |         '-----'           |              |
                          |    .------------------.   |              |
                          |    | A.instrumented.o |<-----------------'
                          |    '------------------'   |    calls
                          '---------------------------'


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
		
		PREVIOUS_X => 0, PREVIOUS_Y => 0,
		MOUSE_X => 0, MOUSE_Y => 0,
		DRAGGING => '',
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

return($self) ;
}

#-----------------------------------------------------------------------------

sub event_options_changed
{
my ($self) = @_;

$self->{CURRENT_ACTIONS} = $self->{ACTIONS}  ;

$self->set_font($self->{FONT_FAMILY}, $self->{FONT_SIZE});
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

#-----------------------------------------------------------------------------

sub update_display 
{
my ($self) = @_;

$self->call_hook('CANONIZE_CONNECTIONS', $self->{CONNECTIONS}, $self->get_character_size()) ;
}

#-----------------------------------------------------------------------------

sub get_grid_usage
{
my ($self) = @_;

my %cost_map ;

# todo: keep previous cost map and update only changed elements

for my $element (@{$self->{ELEMENTS}})
	{
	for my $strip (@{$element->get_stripes()})
		{
		my $x_offset = $element->{X} + $strip->{X_OFFSET} ;
		my $y_offset = $element->{Y} + $strip->{Y_OFFSET} ;
		
		my $string_offset = 0 ;
		
		for my $string ( split /\n/, $strip->{TEXT})
			{
			for (0 .. length($string) - 1 )
				{
				my $x_offset_line = $x_offset + $_ ;
				my $y_offset_line = ($y_offset + $string_offset)  ;
				
				$cost_map{"$x_offset_line.$y_offset_line"} = 0 ;
				}
				
			$string_offset++ ;
			}
		}
	}

return \%cost_map ;
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

my $modifiers = $event->{MODIFIERS} ;

if($self->exists_action("${modifiers}-button_release"))
	{
	$self->run_actions(["${modifiers}-button_release", $event]) ;
	return 1 ;
	}

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

$self->{DRAGGING} = '' ;
delete $self->{RESIZE_CONNECTOR_NAME} ;

$self->create_undo_snapshot() ;
$self->{MODIFIED_INDEX} = $self->{MODIFIED} ;

my $modifiers = $event->{MODIFIERS} ;
my $button = $event->{BUTTON} ;

if($self->exists_action("${modifiers}-button_press-$button"))
	{
	$self->run_actions(["${modifiers}-button_press-$button", $event]) ;
	return 1 ;
	}

my($x, $y) = @{$event->{COORDINATES}} ;

if($event->{TYPE} eq '2button-press')
	{
	my @element_over = grep { $self->is_over_element($_, $x, $y) } reverse @{$self->{ELEMENTS}} ;
	
	if(@element_over)
		{
		my $selected_element = $element_over[0] ;
		$self->edit_element($selected_element) ;
		$self->update_display();
		}
		
	return 1 ;
	}

if($event->{BUTTON} == 1) 
	{
	my $modifiers = $event->{MODIFIERS} ;
	
	my ($first_element) = first_value {$self->is_over_element($_, $x, $y)} reverse @{$self->{ELEMENTS}} ;
	
	if ($modifiers eq 'C00')
		{
		if(defined $first_element)
			{
			$self->select_elements_flip($first_element) ;
			}
		}
	
	if ($modifiers eq '0A0')
		{
		if(defined $first_element)
			{
			$self->run_actions_by_name('Copy to clipboard', ['Insert from clipboard', 0, 0])  ;
			}
		}
	
	if ($modifiers eq '000')
		{
		if(defined $first_element)
			{
			unless($self->is_element_selected($first_element))
				{
				# make the element under cursor the only selected element
				$self->select_elements(0, @{$self->{ELEMENTS}}) ;
				$self->select_elements(1, $first_element) ;
				}
			}
		else
			{
			# deselect all
			$self->deselect_all_elements()  if ($modifiers eq '000')  ;
			}
		}
	
	$self->{SELECTION_RECTANGLE} = {START_X => $x , START_Y => $y} ;
	
	$self->update_display();
	}
	
if($event->{BUTTON} == 2) 
	{
	$self->{SELECTION_RECTANGLE} = {START_X => $x , START_Y => $y} ;
	
	$self->update_display();
	}
  
if($event->{BUTTON} == 3) 
	{
	$self->display_popup_menu($event) ; # display_popup_menu is handled by derived Asciio
	}

return 1;
}

#-----------------------------------------------------------------------------

sub motion_notify_event 
{
my ($self, $event) = @_ ;

my $button = $event->{BUTTON} ;
my($x, $y) = @{$event->{COORDINATES}} ;
my $modifiers = $event->{MODIFIERS} ; 

if($self->exists_action("${modifiers}motion_notify"))
	{
	$self->run_actions(["${modifiers}-motion_notify", $event]) ;
	return 1 ;
	}

if ($event->{STATE} eq "dragging-button1") 
	{
	if($self->{DRAGGING} eq '')
		{
		my @selected_elements = $self->get_selected_elements(1) ;
		my ($first_element) = first_value {$self->is_over_element($_, $self->{PREVIOUS_X}, $self->{PREVIOUS_Y})} reverse @selected_elements ;
		
		if(@selected_elements <= 1)
			{
			if(defined $first_element)
				{
				$self->{DRAGGING} = $first_element->get_selection_action
									(
									$self->{PREVIOUS_X} - $first_element->{X},
									$self->{PREVIOUS_Y} - $first_element->{Y},
									);
									
				}
			else
				{
				$self->{DRAGGING} = 'select' ;
				}
			}
		else
			{
			if(defined $first_element)
				{
				$self->{DRAGGING} = 'move' ;
				}
			else
				{
				$self->{DRAGGING} = 'select' ;
				}
			}
		
		}
	
	if    ($self->{DRAGGING} eq 'move')   { $self->move_elements_event($x, $y) ; }
	elsif ($self->{DRAGGING} eq 'resize') { $self->resize_element_event($x, $y) ; }
	elsif ($self->{DRAGGING} eq 'select') { $self->select_element_event($x, $y) ; }
	
	if($self->{PREVIOUS_X} != $x || $self->{PREVIOUS_Y} != $y)
		{
		($self->{MOUSE_X}, $self->{MOUSE_Y}) = ($x, $y) ;
		$self->{PREVIOUS_X} = $x ;
		$self->{PREVIOUS_Y} = $y ;
		# $self->update_display() ;
		}
	}
else
	{
	if($self->{PREVIOUS_X} != $x || $self->{PREVIOUS_Y} != $y)
		{
		($self->{MOUSE_X}, $self->{MOUSE_Y}) = ($x, $y) ;
		$self->{PREVIOUS_X} = $x ;
		$self->{PREVIOUS_Y} = $y ;
		$self->update_display() ;
		}
	}

# if ($event->{STATE} eq "dragging-button2") 
# 	{
# 	$self->select_element_event($x, $y, $self->{MIDDLE_BUTTON_SELECTION_FILTER} || sub{1}) ;
# 	}
	
return 1;
}

#-----------------------------------------------------------------------------

sub select_element_event
{
my ($self, $x, $y, $filter) = @_ ;

my ($x_offset, $y_offset) = ($x - $self->{PREVIOUS_X},  $y - $self->{PREVIOUS_Y}) ;
	
if($x_offset != 0 || $y_offset != 0)
	{
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
	
	($self->{PREVIOUS_X}, $self->{PREVIOUS_Y}) = ($x, $y) ;
	($self->{MOUSE_X}, $self->{MOUSE_Y}) = ($x, $y) ;
	}
}

#-----------------------------------------------------------------------------

sub move_elements_event
{
my ($self, $x, $y) = @_;

my ($x_offset, $y_offset) = ($x - $self->{PREVIOUS_X},  $y - $self->{PREVIOUS_Y}) ;

if($x_offset != 0 || $y_offset != 0)
	{
	my @selected_elements = $self->get_selected_elements(1) ;
	
	$self->move_elements($x_offset, $y_offset, @selected_elements) ;
	$self->update_display();
	
	($self->{PREVIOUS_X}, $self->{PREVIOUS_Y}) = ($x, $y) ;
	($self->{MOUSE_X}, $self->{MOUSE_Y}) = ($x, $y) ;
	}
}

#-----------------------------------------------------------------------------

sub resize_element_event
{
my ($self, $x, $y) = @_ ;

my ($x_offset, $y_offset) = ($x - $self->{PREVIOUS_X},  $y - $self->{PREVIOUS_Y}) ;

if($x_offset != 0 || $y_offset != 0)
	{
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

	($self->{PREVIOUS_X}, $self->{PREVIOUS_Y}) = ($x, $y) ;
	($self->{MOUSE_X}, $self->{MOUSE_Y}) = ($x, $y) ;
	}
}
	
#-----------------------------------------------------------------------------

sub key_press_event
{
my ($self, $event)= @_;

my $modifiers = $event->{MODIFIERS} ;
my $key = $event->{KEY_NAME} ;

$self->{EVENT} = $event ;
$self->run_actions("$modifiers-$key") ;

return 0 ;
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

Undoubtedly many as I wrote this as a fun little project where I used no design nor 'methodic' whatsoever.

=head1 AUTHOR

	Khemir Nadim ibn Hamouda
	CPAN ID: NKH
	mailto:nadim@khemir.net

=head1 LICENSE AND COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

Special thanks go to the Muppet, the gtk-perl group, and Gabor Szabo for their help.

Adam Kennedy coined the name.

=head1 SUPPORTED OSes

=head2 Gentoo

I run gentoo, packages to install gtk-perl exist. Install Asciio with cpan.

=head2 FreeBSD

FreeBSD users can now install asciio either by package:

$ pkg_add -r asciio

or from source (out of the ports system) by:

$ cd /usr/ports/graphics/asciio
$ make install clean

Thanks to Emanuel Haupt.

=head2 Ubuntu and Debian

Ports for the older gtk2 version exist, gtk3 not yet.

=head2 Windows

B<Asciio> is part of the B<camelbox> distribution and can be found here: L<http://code.google.com/p/camelbox/>. Install, run AsciiO from the 'bin' directory.

      .-------------------------------.
     /                               /|
    /     camelbox for win32        / |
   /                               /  |
  /                               /   |
 .-------------------------------.    |
 |  ______\\_,                   |    |
 | (_. _ o_ _/                   |    |
 |  '-' \_. /                    |    |
 |      /  /                     |    |
 |     /  /    .--.  .--.        |    |
 |    (  (    / '' \/ '' \   "   |    |
 |     \  \_.'            \   )  |    |
 |     ||               _  './   |    |
 |      |\   \     ___.'\  /     |    |
 |        '-./   .'    \ |/      |    |
 |           \| /       )|\      |    |
 |            |/       // \\     |    .
 |            |\    __//   \\__  |   /
 |           //\\  /__/  mrf\__| |  /
 |       .--_/  \_--.            | /
 |      /__/      \__\           |/      
 '-------------------------------'

B<camelbox> is a great distribution for windows. I hope it will merge with X-berry series of Perl distributions.

=head1 Mac OsX

This works too (and I have screenshots to prove it :). I don't own a mac and the mac user hasn't send me how to do it yet.

=head1 other unices

YMMV, install gtk-perl and AsciiO from cpan.

=head1 SEE ALSO

	http://www.jave.de
	http://search.cpan.org/~osfameron/Text-JavE-0.0.2/JavE.pm
	http://ditaa.sourceforge.net/
	http://www.codeproject.com/KB/macros/codeplotter.aspx
	http://search.cpan.org/~jpierce/Text-FIGlet-1.06/FIGlet.pm
	http://www.fossildraw.com/?gclid=CLanxZXxoJECFRYYEAodnBS8Dg (doesn't always respond)
	
	http://www.ascii-art.de (used some entries as base for the network stencil)
	http://c2.com/cgi/wiki?UmlAsciiArt
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

"ASCII world domination!"  ;

