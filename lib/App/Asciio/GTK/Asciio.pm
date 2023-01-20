
package App::Asciio::GTK::Asciio ;

use base qw(App::Asciio) ;

$|++ ;

use strict;
use warnings;

use Glib ':constants';
use Gtk3 -init;

use List::MoreUtils qw(minmax) ;

use App::Asciio::GTK::Asciio::stripes::editable_arrow2;
use App::Asciio::GTK::Asciio::stripes::wirl_arrow ;
use App::Asciio::GTK::Asciio::stripes::section_wirl_arrow ;
use App::Asciio::GTK::Asciio::stripes::editable_box2;
use App::Asciio::stripes::rhombus;

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

$gc->select_font_face($self->{FONT_FAMILY}, 'normal', 'normal');
# $gc->set_font_size($self->{FONT_SIZE});
$gc->set_line_width(1);

my ($character_width, $character_height) = $self->get_character_size() ;
my $character_lift = $character_height / 3 ;
my ($widget_width, $widget_height) = ($widget->get_allocated_width(), $widget->get_allocated_height()) ;

# draw background
my $grid_rendering = $self->{RENDERING}{GRID} ;

unless (defined $grid_rendering)
	{
	my $surface = Cairo::ImageSurface->create('argb32', $widget_width, $widget_height);
	my $gc = Cairo::Context->create($surface);
		
	$gc->select_font_face($self->{FONT_FAMILY}, 'normal', 'normal');
	$gc->set_font_size($self->{FONT_SIZE});

	$gc->set_source_rgb(@{$self->get_color('background')});
	$gc->rectangle(0, 0, $widget->get_allocated_width, $widget->get_allocated_height);
	$gc->fill;
	
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
		}
		
	$gc->stroke;
	$grid_rendering = $self->{RENDERING}{GRID} = $surface ;
	}

$gc->set_source_surface($grid_rendering, 0, 0);
$gc->paint;
$gc->show_page;

# draw elements
my $element_index = 0 ;

for my $element (@{$self->{ELEMENTS}})
	{
	$element_index++ ;
	# do not draw elements that are outside changed area
	
	my $renderings = $element->{RENDERING}[$element->{SELECTED} // 0] ;
	my @renderings ;
	
	unless (defined $renderings)
		{
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
		my @mask_and_element_stripes = $element->get_mask_and_element_stripes() ;
		
		for my $mask_and_element_strip (@mask_and_element_stripes)
			{
			my $line_index = 0 ;
			for my $line (split /\n/, $mask_and_element_strip->{TEXT})
				{
				unless (exists $self->{RENDERING}{STRIPS}[$element->{SELECTED} // 0]{$line})
					{
					my $surface = Cairo::ImageSurface->create('argb32', $mask_and_element_strip->{WIDTH} * $character_width, $character_height);
					
					my $gc = Cairo::Context->create($surface);
					$gc->select_font_face($self->{FONT_FAMILY}, 'normal', 'normal');
					$gc->set_font_size($self->{FONT_SIZE});
					$gc->set_source_rgba(@{$background_color}, $self->{OPAQUE_ELEMENTS});
					$gc->rectangle(0, 0, $mask_and_element_strip->{WIDTH} * $character_width, $character_height);
					$gc->fill();
					
					$gc->set_source_rgb(@{$foreground_color});
					
					if($self->{NUMBERED_OBJECTS})
						{
						$gc->set_line_width(1);
						$gc->rectangle(0, 0, $mask_and_element_strip->{WIDTH} * $character_width, $character_height);
						$gc->move_to(0, $character_height - $character_lift);
						$gc->show_text($element_index);
						$gc->stroke;
						}
					else
						{
						my $char_index = 0 ;
						for my $char (split //, $line)
							{
							# raw positioning (that previously used Pango) needs polishing, can be addition
							$gc->move_to($char_index++ * $character_width, $character_height - $character_lift);
							$gc->show_text($char);
							}
							
						$gc->stroke;
						}
					
					$self->{RENDERING}{STRIPS}[$element->{SELECTED} // 0]{$line} = $surface ; # keep reference
					}
				
				my $strip_rendering = $self->{RENDERING}{STRIPS}[$element->{SELECTED} // 0]{$line} ;
				push @renderings, [$strip_rendering, $mask_and_element_strip->{X_OFFSET}, $mask_and_element_strip->{Y_OFFSET} + $line_index++] ;
				}
			}
		
		$renderings = $element->{RENDERING}[$element->{SELECTED} // 0] = \@renderings ;
		}
	
	for my $rendering (@$renderings)
		{
		$gc->set_source_surface
			(
			$rendering->[0],
			($element->{X} + $rendering->[1]) * $character_width, # can be single addition
			($element->{Y} + $rendering->[2]) * $character_height
			);
		
		$gc->paint;
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
	}
$gc->stroke() ;

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
		$connector ||= $connection->{CONNECTED}->get_named_connection($connection->{CONNECTOR}{NAME}) ;
		
		unless (defined $self->{RENDERING}{CONNECTION})
			{
			my $surface = Cairo::ImageSurface->create('argb32', $character_width, $character_height);
			
			my $gc = Cairo::Context->create($surface);
			$gc->set_line_width(1);
			$gc->set_source_rgb(@{$self->get_color('connection')});
			$gc->rectangle(0, 0, $character_width, $character_height);
			$gc->stroke() ;
			
			$self->{RENDERING}{EXTRA_POINT} = $surface ;
			}
		
		my $connection_rendering = $self->{RENDERING}{EXTRA_POINT} ;
		
		$gc->set_source_surface
			(
			$connection_rendering,
			($connector->{X} + $connection->{CONNECTED}{X}) * $character_width,
			($connector->{Y}  + $connection->{CONNECTED}{Y}) * $character_height,
			);
		
		$gc->paint;
		}
	}
	
# draw connectors and connection points
unless (defined $self->{RENDERING}{CONNECTOR_POINT})
	{
	my $surface = Cairo::ImageSurface->create('argb32', $character_width, $character_height);
	
	my $gc = Cairo::Context->create($surface);
	$gc->set_line_width(1);
	$gc->set_source_rgb(@{$self->get_color('connector_point')});
	$gc->rectangle(0, 0, $character_width, $character_height);
	$gc->stroke() ;
	
	$self->{RENDERING}{CONNECTOR_POINT} = $surface ;
	}
my $connector_point_rendering = $self->{RENDERING}{CONNECTOR_POINT} ;

unless (defined $self->{RENDERING}{CONNECTION_POINT})
	{
	my $surface = Cairo::ImageSurface->create('argb32', $character_width, $character_height);
	
	my $gc = Cairo::Context->create($surface);
	$gc->set_line_width(1);
	$gc->set_source_rgb(@{$self->get_color('connector_point')});
	$gc->set_source_rgb(@{$self->get_color('connection_point')});
	$gc->rectangle($character_width/3, $character_height/3, $character_width/3, $character_height/3);
	$gc->stroke() ;
	
	$self->{RENDERING}{CONNECTION_POINT} = $surface ;
	}
my $connection_point_rendering = $self->{RENDERING}{CONNECTION_POINT} ;

unless (defined $self->{RENDERING}{EXTRA_POINT})
	{
	my $surface = Cairo::ImageSurface->create('argb32', $character_width, $character_height);
	
	my $gc = Cairo::Context->create($surface);
	$gc->set_line_width(1);
	$gc->set_source_rgb(@{$self->get_color('connector_point')});
	$gc->set_source_rgb(@{$self->get_color('extra_point')});
	$gc->rectangle(0, 0, $character_width, $character_height);
	$gc->stroke() ;
	
	$self->{RENDERING}{EXTRA_POINT} = $surface ;
	}
my $extra_point_rendering = $self->{RENDERING}{EXTRA_POINT} ;

for my $element (grep {$self->is_over_element($_, $self->{MOUSE_X}, $self->{MOUSE_Y}, 1)} @{$self->{ELEMENTS}})
	{
	for my $connector ($element->get_connector_points())
		{
		next if exists $connected_connectors{$element}{$connector->{X}}{$connector->{Y}} ;
		
		$gc->set_source_surface
			(
			$connector_point_rendering,
			($element->{X} + $connector->{X}) * $character_width, # can be additions
			($connector->{Y} + $element->{Y}) * $character_height,
			);
		
		$gc->paint;
		}
		
	for my $connection_point ($element->get_connection_points())
		{
		next if exists $connected_connections{$element}{$connection_point->{X}}{$connection_point->{Y}} ;
		
		$gc->set_source_surface
			(
			$connection_point_rendering,
			(($connection_point->{X} + $element->{X}) * $character_width), # can be additions
			(($connection_point->{Y} + $element->{Y}) * $character_height),
			);
		
		$gc->paint;
		}
	
	for my $extra_point ($element->get_extra_points())
		{
		$gc->set_source_surface
			(
			$extra_point_rendering,
			(($extra_point->{X}  + $element->{X}) * $character_width), # can be additions
			(($extra_point->{Y}  + $element->{Y}) * $character_height),
			);
		
		$gc->paint;
		}
	
	$gc->show_page;
	}

# draw new connections
for my $new_connection (@{$self->{NEW_CONNECTIONS}})
	{
	my $end_connection = $new_connection->{CONNECTED}->get_named_connection($new_connection->{CONNECTOR}{NAME}) ;
	
	$gc->set_source_rgb(@{$self->get_color('new_connection')});
	$gc->rectangle
		(
		($end_connection->{X} + $new_connection->{CONNECTED}{X}) * $character_width , # can be additions
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

if ($self->{MOUSE_TOGGLE})
	{
	my $start_x = $self->{MOUSE_X} * $character_width ;
	my $start_y = $self->{MOUSE_Y} * $character_height ;
	
	$gc->set_source_rgb(@{$self->get_color('mouse_rectangle')}) ;
	$gc->rectangle($start_x, $start_y, $character_width, $character_height) ;
	$gc->fill() ;
	$gc->stroke() ;
	}

return TRUE;
}

#-----------------------------------------------------------------------------

sub button_release_event 
{
my ($widget, $event, $self) = @_ ;

$self->SUPER::button_release_event($self->create_asciio_event($event)) ;
}

#-----------------------------------------------------------------------------

sub button_press_event 
{
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

sub create_asciio_event
{
my ($self, $event) = @_ ;

my $event_type= $event->type() ;

my $asciio_event =
	{
	TYPE        => "$event_type",
	STATE       => '',
	MODIFIERS   => get_key_modifiers($event),
	BUTTON      => -1,
	KEY_NAME    => -1,
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

	if($event_type eq "motion-notify")
		{
		$asciio_event->{STATE} = "dragging-button1" if $event->state() >= "button1-mask" ;
		$asciio_event->{STATE} = "dragging-button2" if $event->state() >= "button2-mask" ;
		}
	}

$asciio_event->{KEY_NAME} = Gtk3::Gdk::keyval_name($event->keyval) if $event_type eq 'key-press' ;

return $asciio_event ;
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

sub get_character_size
{
my ($self) = @_ ;
	
if(exists $self->{USER_CHARACTER_WIDTH})
	{
	return ($self->{USER_CHARACTER_WIDTH}, $self->{USER_CHARACTER_HEIGHT}) ;
	}
else
	{
	unless (exists $self->{RENDERING}{CHARACTER_SIZE})
		{
		$self->set_font($self->{FONT_FAMILY}, $self->{FONT_SIZE});
		$self->{RENDERING}{CHARACTER_SIZE} = [$self->{widget}->create_pango_layout('M')->get_pixel_size()] ;
		}
	
	return @{ $self->{RENDERING}{CHARACTER_SIZE} } ;
	}
}

#-----------------------------------------------------------------------------

sub invalidate_rendering_cache
{
my ($self) = @_ ;

for my $element (@{$self->{ELEMENTS}}) 
	{
	delete $element->{RENDERING} ;
	}

delete $self->{RENDERING} ;
}

#----------------------------------------------------------------------------------------------


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

