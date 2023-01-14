
package App::Asciio::GTK::Asciio ;

use base qw(App::Asciio) ;

$|++ ;

use strict;
use warnings;

use Glib ':constants';
use Gtk3 -init;
# use Gtk3::Gdk::Keysyms ;

use App::Asciio::GTK::Asciio::stripes::editable_arrow2;
use App::Asciio::GTK::Asciio::stripes::wirl_arrow ;
use App::Asciio::GTK::Asciio::stripes::section_wirl_arrow ;
use App::Asciio::GTK::Asciio::stripes::editable_box2;

use App::Asciio::GTK::Asciio::Dialogs ;
use App::Asciio::GTK::Asciio::Menues ;

#-----------------------------------------------------------------------------

our $VERSION = '0.01' ;

#-----------------------------------------------------------------------------

=head1 NAME 

=cut

sub new
{
my ($class, $window, $width, $height) = @_ ;

my $self = App::Asciio::new($class) ;
bless $self, $class ;

$window->signal_connect(key_press_event => \&key_press_event, $self);
$window->signal_connect(motion_notify_event => \&motion_notify_event, $self);
$window->signal_connect(button_press_event => \&button_press_event, $self);
$window->signal_connect(button_release_event => \&button_release_event, $self);

my $drawing_area = Gtk3::DrawingArea->new;
$self->{widget} = $drawing_area ;

$drawing_area->signal_connect(draw => \&expose_event, $self);

$drawing_area->set_events
		([qw/
		exposure-mask
		leave-notify-mask
		button-press-mask
		button-release-mask
		pointer-motion-mask
		key-press-mask
		key-release-mask
		/]);

$self->event_options_changed() ;

return($self) ;
}

#-----------------------------------------------------------------------------

sub destroy
{
my ($self) = @_;

$self->{widget}->get_toplevel()->destroy() ;
}

#-----------------------------------------------------------------------------

sub set_title
{
my ($self, $title) = @_;

$self->SUPER::set_title($title) ;

if(defined $title)
	{
	$self->{widget}->get_toplevel()->set_title($title . ' - asciio') ;
	}
}

#-----------------------------------------------------------------------------

sub set_font
{
my ($self, $font_family, $font_size) = @_;

$self->SUPER::set_font($font_family, $font_size) ;

$self->{widget}->modify_font
	(
	Pango::FontDescription::from_string 
		(
		$self->{FONT_FAMILY} . ' ' . $self->{FONT_SIZE}
		)
		
	);
}

#-----------------------------------------------------------------------------

sub update_display 
{
my ($self) = @_;

$self->SUPER::update_display() ;

my $widget = $self->{widget} ;
$widget->queue_draw_area(0, 0, $widget->get_allocated_width, $widget->get_allocated_height);
}

#-----------------------------------------------------------------------------

sub expose_event
{

my ( $widget, $gc, $self ) = @_;

# draw background
$gc->set_source_rgb(@{$self->get_color('background')});
$gc->rectangle(0, 0, $widget->get_allocated_width, $widget->get_allocated_height);
$gc->fill;
$gc->stroke;

$gc->select_font_face($self->{FONT_FAMILY}, 'normal', 'normal');
$gc->set_font_size($self->{FONT_SIZE});

my ($character_width, $character_height) = $self->get_character_size() ;

my $character_lift = $character_height / 3 ;

my ($widget_width, $widget_height) = ($widget->get_allocated_width(), $widget->get_allocated_height()) ;

if($self->{DISPLAY_GRID})
	{
	$gc->set_line_width(1);
	$gc->set_source_rgb(@{$self->get_color('grid')});

	for my $horizontal (0 .. ($widget_height/$character_height) + 1)
		{
		$gc->move_to(0,  $horizontal * $character_height);
		$gc->line_to($widget_width, $horizontal * $character_height);
		}

	for my $vertical(0 .. ($widget_width/$character_width) + 1)
		{
		$gc->move_to($vertical * $character_width, 0) ;
		$gc->line_to($vertical * $character_width, $widget_height);
		}
	
	$gc->stroke;
	}

# draw elements
for my $element (@{$self->{ELEMENTS}})
	{
	# do not draw elements that are outside the viewport
	# do not draw unchanged elements, use a rendering cache

	my ($background_color, $foreground_color) =  $element->get_colors() ;
	
	if($self->is_element_selected($element))
		{
		if(exists $element->{GROUP} and defined $element->{GROUP}[-1])
			{
			$background_color = $element->{GROUP}[-1]{GROUP_COLOR}[0]
			}
		else
			{
			$background_color = $self->get_color('selected_element_background');
			}
		}
	else
		{
		unless (defined $background_color)
			{
			if(exists $element->{GROUP} and defined $element->{GROUP}[-1])
				{
				$background_color = $element->{GROUP}[-1]{GROUP_COLOR}[1]
				}
			else
				{
				$background_color = $self->get_color('element_background') ;
				}
			}
		}
			
	$foreground_color //= $self->get_color('element_foreground') ;
	
	for my $mask_and_element_strip ($element->get_mask_and_element_stripes())
		{
		my $line_index=0 ;
		for my $line (split /\n/, $mask_and_element_strip->{TEXT})
			{
			$gc->set_line_width(1);
			$gc->set_source_rgba(@{$background_color}, $self->{OPAQUE_ELEMENTS});
			$gc->rectangle
				(
				($element->{X} + $mask_and_element_strip->{X_OFFSET}) * $character_width,
				($element->{Y} + $mask_and_element_strip->{Y_OFFSET}  + $line_index) * $character_height,
				($mask_and_element_strip->{WIDTH}) * $character_width,
				$character_height,
				);
			$gc->fill();
			
			$gc->set_source_rgb(@{$foreground_color});
			
			my $char_index = 0 ;
			for my $char (split //, $line)
				{
				$gc->move_to
					(
					($element->{X} + ($mask_and_element_strip->{X_OFFSET}) + $char_index++) * $character_width,
					($element->{Y} + $mask_and_element_strip->{Y_OFFSET} + 1 + $line_index) * $character_height - $character_lift
					);
				
				$gc->show_text($char);
				}
				
			$line_index++;
			$gc->stroke;
			}
		}
	}

# draw ruler lines
for my $line (@{$self->{RULER_LINES}})
	{
	$gc->set_source_rgb(@{$line->{COLOR} });
	
	if($line->{TYPE} eq 'VERTICAL')
		{
		$gc->move_to($line->{POSITION} * $character_width, 0) ;
		$gc->line_to($line->{POSITION} * $character_width, $widget_height) ;
		}
	else
		{
		$gc->move_to(0, $line->{POSITION} * $character_height) ;
		$gc->line_to($widget_width, $line->{POSITION} * $character_height);
		}

	$gc->stroke() ;
	}

# draw connections
my (%connected_connections, %connected_connectors) ;

for my $connection (@{$self->{CONNECTIONS}})
	{
	my $draw_connection ;
	my $connector  ;
	
	if($self->is_over_element($connection->{CONNECTED}, $self->{MOUSE_X}, $self->{MOUSE_Y}, 1))
		{
		$draw_connection++ ;
		
		$connector = $connection->{CONNECTED}->get_named_connection($connection->{CONNECTOR}{NAME}) ;
		$connected_connectors{$connection->{CONNECTED}}{$connector->{X}}{$connector->{Y}}++ ;
		}
		
	if($self->is_over_element($connection->{CONNECTEE}, $self->{MOUSE_X}, $self->{MOUSE_Y}, 1))
		{
		$draw_connection++ ;
		
		my $connectee_connection = $connection->{CONNECTEE}->get_named_connection($connection->{CONNECTION}{NAME}) ;
		
		if($connectee_connection)
			{
			$connected_connectors{$connection->{CONNECTEE}}{$connectee_connection->{X}}{$connectee_connection->{Y}}++ ;
			}
		}
		
	if($draw_connection)
		{
		$gc->set_source_rgb(@{$self->get_color('connection')});
		
		$connector ||= $connection->{CONNECTED}->get_named_connection($connection->{CONNECTOR}{NAME}) ;
		
		$gc->rectangle
			(
			($connector->{X} + $connection->{CONNECTED}{X}) * $character_width,
			($connector->{Y}  + $connection->{CONNECTED}{Y}) * $character_height,
			$character_width, $character_height
			);
		
		$gc->stroke() ;
		}
	}
	
# draw connectors and connection points
for my $element (grep {$self->is_over_element($_, $self->{MOUSE_X}, $self->{MOUSE_Y}, 1)} @{$self->{ELEMENTS}})
	{
	$gc->set_source_rgb(@{$self->get_color('connector_point')});
		
	for my $connector ($element->get_connector_points())
		{
		next if exists $connected_connectors{$element}{$connector->{X}}{$connector->{Y}} ;
		
		$gc->rectangle
			(
			($element->{X} + $connector->{X}) * $character_width,
			($connector->{Y} + $element->{Y}) * $character_height,
			$character_width, $character_height
			);
		
		$gc->stroke() ;
		}
		
	$gc->set_source_rgb(@{$self->get_color('connection_point')});
	for my $connection_point ($element->get_connection_points())
		{
		next if exists $connected_connections{$element}{$connection_point->{X}}{$connection_point->{Y}} ;
		
		$gc->rectangle
			(
			(($connection_point->{X} + $element->{X}) * $character_width) + ($character_width / 3),
			(($connection_point->{Y} + $element->{Y}) * $character_height) + ($character_height / 3),
			$character_width / 3 , $character_height / 3
			);
		
		$gc->stroke() ;
		}
	
	for my $extra_point ($element->get_extra_points())
		{
		if(exists $extra_point->{COLOR})
			{
			$gc->set_source_rgb(@{$self->get_color($extra_point->{COLOR})});
			}
		else
			{
			$gc->set_source_rgb(@{$self->get_color('extra_point')});
			}
			
		$gc->rectangle
			(
			(($extra_point ->{X}  + $element->{X}) * $character_width),
			(($extra_point ->{Y}  + $element->{Y}) * $character_height),
			$character_width, $character_height 
			);
		
		$gc->stroke() ;
		}
	}

# draw new connections
for my $new_connection (@{$self->{NEW_CONNECTIONS}})
	{
	$gc->set_source_rgb(@{$self->get_color('new_connection')});
	
	my $end_connection = $new_connection->{CONNECTED}->get_named_connection($new_connection->{CONNECTOR}{NAME}) ;
	
	$gc->rectangle
		(
		($end_connection->{X} + $new_connection->{CONNECTED}{X}) * $character_width ,
		($end_connection->{Y} + $new_connection->{CONNECTED}{Y}) * $character_height ,
		$character_width, $character_height
		);
	}

delete $self->{NEW_CONNECTIONS} ;
	
# draw selection rectangle
if(defined $self->{SELECTION_RECTANGLE}{END_X})
	{
	my $start_x = $self->{SELECTION_RECTANGLE}{START_X} * $character_width ;
	my $start_y = $self->{SELECTION_RECTANGLE}{START_Y} * $character_height ;
	my $width = ($self->{SELECTION_RECTANGLE}{END_X} - $self->{SELECTION_RECTANGLE}{START_X}) * $character_width ;
	my $height = ($self->{SELECTION_RECTANGLE}{END_Y} - $self->{SELECTION_RECTANGLE}{START_Y}) * $character_height; 
	
	if($width < 0)
		{
		$width *= -1 ;
		$start_x -= $width ;
		}
		
	if($height < 0)
		{
		$height *= -1 ;
		$start_y -= $height ;
		}
		
	$gc->set_source_rgb(@{$self->get_color('selection_rectangle')}) ;
	$gc->rectangle($start_x, $start_y, $width, $height) ;
	$gc->stroke() ;
	
	delete $self->{SELECTION_RECTANGLE}{END_X} ;
	}

return TRUE;
}

#-----------------------------------------------------------------------------

sub get_key_modifiers
{
my ($event) = @_ ;

my $key_modifiers = $event->state() ;

my $modifiers = $key_modifiers =~ /control-mask/ ? 'C' :0 ;
$modifiers .= $key_modifiers =~ /mod1-mask/ ? 'A' :0 ;
$modifiers .= $key_modifiers =~ /shift-mask/ ? 'S' :0 ;

return($modifiers) ;
}

#-----------------------------------------------------------------------------

sub button_release_event 
{
my ($widget, $event, $self) = @_ ;

$self->SUPER::button_release_event($self->create_asciio_event($event)) ;
}

#-----------------------------------------------------------------------------

sub create_asciio_event
{
my ($self, $event) = @_ ;

my $event_type= $event->type() ;

my $asciio_event =
	{
	TYPE =>  $event_type,
	STATE => $event->state() ,
	MODIFIERS => get_key_modifiers($event),
	BUTTON => -1,
	KEY_NAME => -1,
	COORDINATES => [-1, -1],
	} ;

$asciio_event->{BUTTON} = $event->button() if ref $event eq 'Gtk3::Gdk::EventButton' ;
if
	(
	$event_type eq "motion-notify" 
	|| ref $event eq "Gtk3::Gdk::EventButton" 
	)
	{
	$asciio_event->{COORDINATES} = [$self->closest_character($event->get_coords())]  ;
	}

$asciio_event->{KEY_NAME} = Gtk3::Gdk::keyval_name($event->keyval) if $event_type eq 'key-press' ;

# use Data::TreeDumper ; print DumpTree $asciio_event ;

return $asciio_event ;
}

#-----------------------------------------------------------------------------

sub button_press_event 
{
#~ print "button_press_event\n" ;
my ($widget, $event, $self) = @_ ;

my $asciio_event = $self->create_asciio_event($event) ;

$self->SUPER::button_press_event($asciio_event, $event) ;
}

#-----------------------------------------------------------------------------

sub motion_notify_event 
{
my ($widget, $event, $self) = @_ ;

my $asciio_event = $self->create_asciio_event($event) ;

$self->SUPER::motion_notify_event($asciio_event) ;
}

#-----------------------------------------------------------------------------

sub key_press_event
{
my ($widget, $event, $self)= @_;

my $asciio_event = $self->create_asciio_event($event) ;

$self->SUPER::key_press_event($asciio_event) ;
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
	$self->set_font($self->{FONT_FAMILY}, $self->{FONT_SIZE});
	return $self->{widget}->create_pango_layout('M')->get_pixel_size() ;
	}
}

#-----------------------------------------------------------------------------


=head1 DEPENDENCIES

gnome libraries, gtk, gtk-perl, perl

=head1 AUTHOR

	Khemir Nadim ibn Hamouda
	CPAN ID: NKH
	mailto:nadim@khemir.net

=head1 LICENSE AND COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=cut

#------------------------------------------------------------------------------------------------------

"GTK world domination!"  ;

