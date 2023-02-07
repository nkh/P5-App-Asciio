
package App::Asciio::Text ;

use base qw(App::Asciio) ;

$|++ ;

use strict;
use warnings;

use List::MoreUtils qw(minmax) ;

use App::Asciio::Text::Asciio::stripes::editable_arrow2;
use App::Asciio::Text::Asciio::stripes::wirl_arrow ;
use App::Asciio::Text::Asciio::stripes::section_wirl_arrow ;
use App::Asciio::Text::Asciio::stripes::editable_box2;
use App::Asciio::Text::Asciio::stripes::editable_exec_box;
use App::Asciio::stripes::rhombus;

use App::Asciio::Text::Asciio::Dialogs ;
use App::Asciio::Text::Asciio::Menues ;

#-----------------------------------------------------------------------------

our $VERSION = '0.01' ;

#-----------------------------------------------------------------------------

=head1 NAME 

=cut

sub new
{
my ($class, $width, $height) = @_ ;

my $self = App::Asciio->new($class) ;
bless $self, $class ;

return($self) ;
}

#-----------------------------------------------------------------------------

use Term::Size::Any qw(chars) ;
# use Term::ANSIColor ;

sub update_display 
{
my ($self) = @_;

$self->SUPER::update_display() ;

my ($COLS, $ROWS) = chars ;

print "\e[?25l" ; # hide cursor
print "\e[2J\e[H" ;

print "\e[1;50H$self->{MOUSE_Y} $self->{MOUSE_X}" ;

# draw background
if($self->{DISPLAY_GRID})
	{
	my $grid_rendering = $self->{CACHE}{"GRID-$COLS-$ROWS"} ;
	
	unless (defined $grid_rendering)
		{
		my $surface= '' ;
		
		if($self->{DISPLAY_GRID})
			{
			for my $line (0 .. $ROWS)
				{
				next if $line % 10 ;
				
				# $gc->set_source_rgb(@{$self->get_color($color)});
				
				$surface .= "\e[$line;0H\e[2;49;90m" . '-' x $COLS ;
				}
			
			for my $line (0 .. $COLS)
				{
				next if $line % 10 ;
				
				# $gc->set_source_rgb(@{$self->get_color($color)});
				
				$surface .= "\e[$_;${line}H\e[2;49;90m" . '|' for (1 .. $ROWS) ;
				}
			
			$surface .= "\e[m" ;
			}
	
		$grid_rendering = $self->{CACHE}{"GRID-$COLS-$ROWS"} = $surface ;
		}
	
	print $grid_rendering ;
	}

# draw ruler lines
for my $line (@{$self->{RULER_LINES}})
	{
	# $gc->set_source_rgb(@{$self->get_color('ruler_line')});
	
	if($line->{TYPE} eq 'VERTICAL')
		{
		print "\e[$_;$line->{POSITION}H\e[2;49;96m" . '|' for (1 .. $ROWS) ;
		}
	else
		{
		my $column = 0 ;
		my $line =  $line->{POSITION} ;
		
		print "\e[$line;${column}H\e[2;49;96m" . '-' x $COLS ;
		}
	
	print "\e[m" ;
	}

# draw elements
my $element_index = 0 ;

for my $element (@{$self->{ELEMENTS}})
	{
	$element_index++ ;
	my $is_selected = $element->{SELECTED} // 0 ;
	$is_selected = 1 if $is_selected > 0 ;
	
	my ($background_color, $foreground_color) =  $element->get_colors() ;
	
	if($is_selected)
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
	
	my $color_set = $is_selected . '-'
			. ($background_color // 'undef') . '-' . ($foreground_color // 'undef') . '-' 
			. ($self->{OPAQUE_ELEMENTS} // 1) . '-' . ($self->{NUMBERED_OBJECTS} // 0) ; 
	
	my $renderings = $element->{CACHE}{RENDERING}{$color_set} ;
	
	unless (defined $renderings)
		{
		my @renderings ;
		
		my $stripes = $element->get_stripes() ;
		# $self->update_quadrants($element) ;
		
		for my $strip (@{$stripes})
			{
			my $line_index = 0 ;
			
			for my $line (split /\n/, $strip->{TEXT})
				{
				$line = "$line-$element" if $self->{NUMBERED_OBJECTS} ; # don't share rendering with other objects
				
				my $surface = '';
				
				unless (exists $self->{CACHE}{STRIPS}{$color_set}{$line})
					{
					# $gc->set_source_rgb(@{$foreground_color});
					$surface .= "\e[7;49;94m" if $is_selected ;
					
					if($self->{NUMBERED_OBJECTS})
						{
						$surface .= ' ' x ( $strip->{WIDTH} - length("$element_index)")) . $element_index ;
						}
					else
						{
						$surface .= $line ;
						}
					
					$surface .= "\e[m" ;
					
					$self->{CACHE}{STRIPS}{$color_set}{$line} = $surface ; # keep reference
					}
				
				my $strip_rendering = $self->{CACHE}{STRIPS}{$color_set}{$line} ;
				push @renderings, [$strip_rendering, $strip->{X_OFFSET}, $strip->{Y_OFFSET} + $line_index++] ;
				}
			}
		
		$renderings = $element->{CACHE}{RENDERING}{$color_set} = \@renderings ;
		}
	
	for my $rendering (@$renderings)
		{
		my $column = $element->{X} + $rendering->[1] + 1;
		my $line =  $element->{Y} + $rendering->[2] + 1 ;
		print "\e[$line;${column}H" . $rendering->[0] ;
		}
	}

# draw connections
my (%connected_connections, %connected_connectors) ;

# $gc->set_source_rgb(@{$self->get_color('connector_point')});
my $connector_point_rendering = "\e[32mO\e[m" ;

# $gc->set_source_rgb(@{$self->get_color('connection_point')});
my $connection_point_rendering = "\e[33mo\e[m" ;

# $gc->set_source_rgb(@{$self->get_color('extra_point')});
my $extra_point_rendering = "\e[34m#\e[m" ;

if ($self->{MOUSE_TOGGLE})
	{
	for my $element (grep {$self->is_over_element($_, $self->{MOUSE_X}, $self->{MOUSE_Y}, 1)} @{$self->{ELEMENTS}})
		{
		for my $connector ($element->get_connector_points())
			{
			next if exists $connected_connectors{$element}{$connector->{X}}{$connector->{Y}} ;
			
			my $column = $element->{X} + $connector->{X} + 1 ;
			my $line = $connector->{Y} + $element->{Y} + 1 ;
			print "\e[$line;${column}H" . $connector_point_rendering;
			}
			
		for my $extra_point ($element->get_extra_points())
			{
			my $column = $extra_point->{X}  + $element->{X} + 1 ;
			my $line = $extra_point->{Y} + $element->{Y} + 1 ;
			print "\e[$line;${column}H" . $extra_point_rendering;
			}
		
		for my $connection_point ($element->get_connection_points())
			{
			next if exists $connected_connections{$element}{$connection_point->{X}}{$connection_point->{Y}} ;
			
			my $column = $connection_point->{X} + $element->{X} + 1 ;
			my $line = $connection_point->{Y} + $element->{Y} + 1 ;
			print "\e[$line;${column}H" . $connection_point_rendering;
			}
		}
	
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
			
			my $connection_rendering = "\e[31mc\e[m" ;
			
			my $column = $connector->{X} + $connection->{CONNECTED}{X} + 1 ;
			my $line = $connector->{Y}  + $connection->{CONNECTED}{Y} + 1 ;
			print "\e[$line;${column}H" . $connection_rendering;
			}
		}
	}

# draw new connections
my $connection_rendering = "\e[31mc\e[m" ;
for my $new_connection (@{$self->{NEW_CONNECTIONS}})
	{
	my $end_connection = $new_connection->{CONNECTED}->get_named_connection($new_connection->{CONNECTOR}{NAME}) ;
	
	# $gc->set_source_rgb(@{$self->get_color('new_connection')});
	my $column = $end_connection->{X} + $new_connection->{CONNECTED}{X} + 1 ;
	my $line = $end_connection->{Y} + $new_connection->{CONNECTED}{Y} + 1 ;
	print "\e[$line;${column}H" . $connection_rendering;
	}

delete $self->{NEW_CONNECTIONS} ;

# draw selection rectangle
if(0) #defined $self->{SELECTION_RECTANGLE}{END_X})
	{
	my $start_x = $self->{SELECTION_RECTANGLE}{START_X} ;
	my $start_y = $self->{SELECTION_RECTANGLE}{START_Y} ;
	my $width   = $self->{SELECTION_RECTANGLE}{END_X} - $self->{SELECTION_RECTANGLE}{START_X} ;
	my $height  = $self->{SELECTION_RECTANGLE}{END_Y} - $self->{SELECTION_RECTANGLE}{START_Y} ; 
	
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
		
	# $gc->set_source_rgb(@{$self->get_color('selection_rectangle')}) ;
	
	print "\e[$start_y;${start_x}H" . "\e[30m" . ( '-' x $width) ;
	print "\e[$start_y;" . ($start_x + $width) . "H" . "\e[30m" . ( '-' x $width) ;
	print "\e[$_;${start_x}H" . "\e[30m" . '|' for ( $start_y .. $start_y + $height) ;
	print "\e[$_;" . ($start_x + $width) . "H" . "\e[30m" . '|' for ( $start_y .. $start_y + $height) ;
	
	delete $self->{SELECTION_RECTANGLE}{END_X} ;
	}

if ($self->{MOUSE_TOGGLE})
	{
	# $gc->set_source_rgb(@{$self->get_color('mouse_rectangle')}) ;
	
	my $line = $self->{MOUSE_Y} + 1 ; my $column = $self->{MOUSE_X} + 1 ;
	print "\e[$line;${column}H\e[31mX" ; 
	}
	
print "\e[m" ;

return ;
}

#-----------------------------------------------------------------------------

sub key_press_event
{
my ($self, $key_name, $modifiers)= @_;

$self->SUPER::key_press_event
		({
		TYPE        => "key-press",
		STATE       => '',
		MODIFIERS   => $modifiers,
		BUTTON      => -1,
		KEY_NAME    => $key_name,
		COORDINATES => [0, 0],
		}) ;
}

#-----------------------------------------------------------------------------

sub create_asciio_event
{
my ($self, $event) = @_ ;

my $event_type ;

my $asciio_event =
	{
	TYPE        => "event_type",
	STATE       => '',
	MODIFIERS   => get_key_modifiers($event),
	BUTTON      => -1,
	KEY_NAME    => -1,
	COORDINATES => [-1, -1],
	} ;

# $asciio_event->{BUTTON} = $event->button() if ref $event eq 'Gtk3::Gdk::EventButton' ;

# if
# 	(
# 	$event_type eq "motion-notify"
# 	|| ref $event eq "Gtk3::Gdk::EventButton" 
# 	)
# 	{
# 	$asciio_event->{COORDINATES} = [$self->closest_character($event->get_coords())]  ;

# 	if($event_type eq "motion-notify")
# 		{
# 		$asciio_event->{STATE} = "dragging-button1" if $event->state() >= "button1-mask" ;
# 		$asciio_event->{STATE} = "dragging-button2" if $event->state() >= "button2-mask" ;
# 		}
# 	}

# $asciio_event->{KEY_NAME} = Gtk3::Gdk::keyval_name($event->keyval) if $event_type eq 'key-press' ;

return $asciio_event ;
}

#-----------------------------------------------------------------------------

sub get_key_modifiers
{
my ($key) = @_ ;

my $modifiers = '???' ;
return($modifiers) ;
}

#-----------------------------------------------------------------------------

use Term::ReadKey;

sub exit
{
my ($self) = @_ ;

ReadMode('normal') ;
print "\e[2J\e[H" ;
print "\e[?25h" ;
print "\e[?1000h" ;

exit ;
}

#-----------------------------------------------------------------------------

sub get_character_size
{
my ($self) = @_ ;

return 1, 1 ;
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

#----------------------------------------------------------------------------------------------


=head1 DEPENDENCIES


=head1 AUTHOR

	Khemir Nadim ibn Hamouda
	CPAN ID: NKH
	mailto:nadim@khemir.net

=head1 LICENSE AND COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=cut

#------------------------------------------------------------------------------------------------------

"Terinal world domination!"  ;

