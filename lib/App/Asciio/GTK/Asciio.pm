
package App::Asciio::GTK::Asciio ;

use base qw(App::Asciio) ;

$|++ ;

use strict;
use warnings;

use Glib ':constants';
use Gtk2 -init;
use Gtk2::Gdk::Keysyms ;

use App::Asciio::GTK::Asciio::stripes::editable_arrow2;
use App::Asciio::GTK::Asciio::stripes::wirl_arrow ;
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
my ($class, $width, $height) = @_ ;

my $self = App::Asciio::new($class) ;
bless $self, $class ;

$self->{KEYS}{K} = {%Gtk2::Gdk::Keysyms} ;
$self->{KEYS}{C}= {map{$self ->{KEYS}{K}{$_} => $_} keys %{$self->{KEYS}{K}}} ;

my $drawing_area = Gtk2::DrawingArea->new;

$self->{widget} = $drawing_area ;

$drawing_area->can_focus(TRUE) ;

$drawing_area->signal_connect(configure_event => \&configure_event, $self);
$drawing_area->signal_connect(expose_event => \&expose_event, $self);
$drawing_area->signal_connect(motion_notify_event => \&motion_notify_event, $self);
$drawing_area->signal_connect(button_press_event => \&button_press_event, $self);
$drawing_area->signal_connect(button_release_event => \&button_release_event, $self);
$drawing_area->signal_connect(key_press_event => \&key_press_event, $self);

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
	Gtk2::Pango::FontDescription->from_string 
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
$widget->queue_draw_area(0, 0, $widget->allocation->width,$widget->allocation->height);
}

#-----------------------------------------------------------------------------

sub configure_event 
{
my ($widget, $event, $self) = @_;

$self->{PIXMAP} = Gtk2::Gdk::Pixmap->new 
			(
			$widget->window,
			$widget->allocation->width, $widget->allocation->height,
			-1
			);
			
$self->{WINDOW_SIZE} = [$widget->allocation->width, $widget->allocation->height] ;

$self->{PIXMAP}->draw_rectangle
		(
		$widget->get_style->base_gc ($widget->state),
		TRUE, 0, 0, $widget->allocation->width,
		$widget->allocation->height
		);
		
return TRUE;
}

#-----------------------------------------------------------------------------

sub expose_event
{
my ($widget, $event, $self) = @_;

my $gc = Gtk2::Gdk::GC->new($self->{PIXMAP});

# draw background
$gc->set_foreground($self->get_color('background'));

$self->{PIXMAP}->draw_rectangle
		(
		$gc,	TRUE,
		0, 0,
		$widget->allocation->width, $widget->allocation->height
		);

my ($character_width, $character_height) = $self->get_character_size() ;
my ($widget_width, $widget_height) = $self->{PIXMAP}->get_size();

if($self->{DISPLAY_GRID})
	{
	$gc->set_foreground($self->get_color('grid'));

	for my $horizontal (0 .. ($widget_height/$character_height) + 1)
		{
		$self->{PIXMAP}->draw_line
					(
					$gc,
					0,  $horizontal * $character_height,
					$widget_width, $horizontal * $character_height
					);
		}

	for my $vertical(0 .. ($widget_width/$character_width) + 1)
		{
		$self->{PIXMAP}->draw_line
					(
					$gc,
					$vertical * $character_width, 0,
					$vertical * $character_width, $widget_height
					);
		}
	}
	
# draw elements
for my $element (@{$self->{ELEMENTS}})
	{
	# do not draw elements that are outside the viewport
	# do not draw unnchanged elements, use a rendering cache

	my ($background_color, $foreground_color) =  $element->get_colors() ;
	
	if($self->is_element_selected($element))
		{
		if(exists $element->{GROUP} and defined $element->{GROUP}[-1])
			{
			$background_color = 
				$self->get_color
					(
					$self->{COLORS}{group_colors}[$element->{GROUP}[-1]{GROUP_COLOR}][0]
					) ;
			}
		else
			{
			$background_color = $self->get_color('selected_element_background');
			}
		}
	else
		{
		if(defined $background_color)
			{
			$background_color = $self->get_color($background_color) ;
			}
		else
			{
			if(exists $element->{GROUP} and defined $element->{GROUP}[-1])
				{
				$background_color = 
					$self->get_color
						(
						$self->{COLORS}{group_colors}[$element->{GROUP}[-1]{GROUP_COLOR}][1]
						) ;
				}
			else
				{
				$background_color = $self->get_color('element_background') ;
				}
			}
		}
			
	$foreground_color = 
		defined $foreground_color
			? $self->get_color($foreground_color)
			: $self->get_color('element_foreground') ;
			
	$gc->set_foreground($foreground_color);
	
	for my $mask_and_element_strip ($element->get_mask_and_element_stripes())
		{
		$gc->set_foreground($background_color);
			
		$self->{PIXMAP}->draw_rectangle
					(
					$gc,
					$self->{OPAQUE_ELEMENTS},
					($element->{X} + $mask_and_element_strip->{X_OFFSET}) * $character_width,
					($element->{Y} + $mask_and_element_strip->{Y_OFFSET}) * $character_height,
					$mask_and_element_strip->{WIDTH} * $character_width,
					$mask_and_element_strip->{HEIGHT} * $character_height,
					);
					
		$gc->set_foreground($foreground_color);
		
		my $layout = $widget->create_pango_layout($mask_and_element_strip->{TEXT}) ;
		
		my ($text_width, $text_height) = $layout->get_pixel_size;
		
		$self->{PIXMAP}->draw_layout
					(
					$gc,
					($element->{X} + $mask_and_element_strip->{X_OFFSET}) * $character_width,
					($element->{Y} + $mask_and_element_strip->{Y_OFFSET}) * $character_height,
					$layout
					);
		}
	}

# draw ruler lines
for my $line (@{$self->{RULER_LINES}})
	{
	my $color = Gtk2::Gdk::Color->new( map {$_ * 257} @{$line->{COLOR} }) ;
	$self->{widget}->get_colormap->alloc_color($color,TRUE,TRUE) ;
	
	$gc->set_foreground($color);
	
	if($line->{TYPE} eq 'VERTICAL')
		{
		$self->{PIXMAP}->draw_line
					(
					$gc,
					$line->{POSITION} * $character_width, 0,
					$line->{POSITION} * $character_width, $widget_height
					);
		}
	else
		{
		$self->{PIXMAP}->draw_line
					(
					$gc,
					0, $line->{POSITION} * $character_height,
					$widget_width, $line->{POSITION} * $character_height
					);
		}
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
		$gc->set_foreground($self->get_color('connection'));	
		
		$connector ||= $connection->{CONNECTED}->get_named_connection($connection->{CONNECTOR}{NAME}) ;
		
		$self->{PIXMAP}->draw_rectangle
						(
						$gc,
						FALSE,
						($connector->{X} + $connection->{CONNECTED}{X}) * $character_width,
						($connector->{Y}  + $connection->{CONNECTED}{Y}) * $character_height,
						$character_width, $character_height
						);
		}
	}
	
# draw connectors and connection points
for my $element (grep {$self->is_over_element($_, $self->{MOUSE_X}, $self->{MOUSE_Y}, 1)} @{$self->{ELEMENTS}})
	{
	$gc->set_foreground($self->get_color('connector_point'));
	for my $connector ($element->get_connector_points())
		{
		next if exists $connected_connectors{$element}{$connector->{X}}{$connector->{Y}} ;
		
		$self->{PIXMAP}->draw_rectangle
						(
						$gc,
						FALSE,
						($element->{X} + $connector->{X}) * $character_width,
						($connector->{Y} + $element->{Y}) * $character_height,
						$character_width, $character_height
						);
		}
		
	$gc->set_foreground($self->get_color('connection_point'));
	for my $connection_point ($element->get_connection_points())
		{
		next if exists $connected_connections{$element}{$connection_point->{X}}{$connection_point->{Y}} ;
		
		$self->{PIXMAP}->draw_rectangle # little box
						(
						$gc,
						TRUE,
						(($connection_point->{X} + $element->{X}) * $character_width) + ($character_width / 3),
						(($connection_point->{Y} + $element->{Y}) * $character_height) + ($character_height / 3),
						$character_width / 3 , $character_height / 3
						);
		}
		
	for my $extra_point ($element->get_extra_points())
		{
		if(exists $extra_point ->{COLOR})
			{
			$gc->set_foreground($self->get_color($extra_point ->{COLOR}));
			}
		else
			{
			$gc->set_foreground($self->get_color('extra_point'));
			}
			
		$self->{PIXMAP}->draw_rectangle
						(
						$gc,
						FALSE,
						(($extra_point ->{X}  + $element->{X}) * $character_width),
						(($extra_point ->{Y}  + $element->{Y}) * $character_height),
						$character_width, $character_height 
						);
		}
	}

# draw new connections
for my $new_connection (@{$self->{NEW_CONNECTIONS}})
	{
	$gc->set_foreground($self->get_color('new_connection'));
	
	my $end_connection = $new_connection->{CONNECTED}->get_named_connection($new_connection->{CONNECTOR}{NAME}) ;
	
	$self->{PIXMAP}->draw_rectangle
					(
					$gc,
					FALSE,
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
		
	$gc->set_foreground($self->get_color('selection_rectangle')) ;
	$self->{PIXMAP}->draw_rectangle($gc, FALSE,$start_x, $start_y, $width, $height);
	
	delete $self->{SELECTION_RECTANGLE}{END_X} ;
	}

$widget->window->draw_drawable
		(
		$widget->style->fg_gc($widget->state),
		$self->{PIXMAP},
		$event->area->x, $event->area->y,
		$event->area->x, $event->area->y,
		$event->area->width, $event->area->height
		);

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

my $asciio_event =
	{
	TYPE =>  $event->type(),
	STATE => $event->state() ,
	MODIFIERS => get_key_modifiers($event),
	BUTTON => -1,
	KEY_VALUE => -1,
	COORDINATES => [-1, -1],
	} ;

$asciio_event->{BUTTON} = $event->button() if ref $event eq 'Gtk2::Gdk::Event::Button' ;
if
	(
	ref $event eq "Gtk2::Gdk::Event::Motion" 
	|| ref $event eq "Gtk2::Gdk::Event::Button" 
	)
	{
	$asciio_event->{COORDINATES} = [$self->closest_character($event->coords())]  ;
	}

$asciio_event->{KEY_VALUE} = $event->keyval() if ref $event eq "Gtk2::Gdk::Event::Key" ;

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
	my $layout = $self->{widget}->create_pango_layout('M') ;
	return $layout->get_pixel_size() ;
	}
}

#-----------------------------------------------------------------------------

sub get_color 
{
my ($self, $name) = @_;

unless (exists $self->{ALLOCATED_COLORS}{$name}) 
	{
	my $color  ;
	
	if('ARRAY' eq  ref $name) 
		{
		$color = Gtk2::Gdk::Color->new( map {$_ * 257} @{$name}) ;
		}
	elsif(exists $self->{COLORS}{$name}) 
		{
		if('ARRAY' eq ref $self->{COLORS}{$name})
			{
			$color = Gtk2::Gdk::Color->new( map {$_ * 257} @{ $self->{COLORS}{$name}}) ;
			}
		else
			{
			$color = Gtk2::Gdk::Color->parse($self->{COLORS}{$name});
			}
		}
	else
		{
		$color = Gtk2::Gdk::Color->parse($name);
		}
	
	$color = Gtk2::Gdk::Color->new( map {$_ * 257} (255, 0, 0)) unless defined $color ;
	$self->{widget}->get_colormap->alloc_color($color,TRUE,TRUE) ;
	
	$self->{ALLOCATED_COLORS}{$name} = $color ;
	}
	
return($self->{ALLOCATED_COLORS}{$name}) ;
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

