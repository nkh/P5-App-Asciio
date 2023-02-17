
package App::Asciio::Text ;

use base qw(App::Asciio) ;

use strict;
use warnings;

use List::MoreUtils qw(minmax) ;
use Term::Size::Any qw(chars) ;
use Term::ANSIColor ;
use Time::HiRes qw(gettimeofday) ;
use Sereal qw(get_sereal_decoder get_sereal_encoder) ;
use Sereal::Encoder qw(SRL_SNAPPY SRL_ZLIB SRL_ZSTD) ;

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

sub render_text
{
my ($text_array, $COLS, $ROWS) = @_ ;

my $rendering = '' ;
my ($text, $previous_color , $color) = ('', '', '') ;

for my $line (1 .. $ROWS)
	{
	my $line_ref = $text_array->[$line] ;
	
	for my $character (1 .. $COLS)
		{
		($text, $color) = @{$line_ref->[$character]} ;
		
		$rendering .= "\e[m$color" if $color ne $previous_color ;
		$previous_color = $color ;
		
		$rendering .= $text ;
		}
	}

print $rendering ;
print "\e[m" ;
}

#-----------------------------------------------------------------------------

my ($grid_setup_text, $background_rendered, $grid_rendered) ;
my $encoder = get_sereal_encoder({compress => SRL_ZLIB}) ;
my $decoder = get_sereal_decoder() ;

sub update_display 
{
my ($self) = @_;

$self->SUPER::update_display() ;

my ($COLS, $ROWS) = chars ;
my $rows_cols = "$ROWS-$COLS" ; # cache tag

print "\e[?25l\e[H" ; # hide cursor, reset position to 1,1

my $text_array = [] ;

# draw background
if(defined $background_rendered && $background_rendered eq $rows_cols)
	{
	$text_array = $decoder->decode($grid_setup_text) ;
	}
else
	{
	for my $line (1 .. $ROWS)
		{
		for my $column (1 .. $COLS)
			{
			$text_array->[$line][$column] = [' ', ''] ;
			}
		}
	
	$grid_setup_text = $encoder->encode($text_array) ;
	$background_rendered = $rows_cols ;
	}

if($self->{DISPLAY_GRID})
	{
	unless(defined $grid_rendered && $grid_rendered eq $rows_cols)
		{
		if($self->{DISPLAY_GRID})
			{
			my $color = color($self->get_color('grid')) ;
			
			for my $line (1 .. $ROWS /10)
				{
				for (1 .. $COLS)
					{
					$text_array->[$line * 10][$_] = ['-', $color] ;
					}
				}
			
			for my $line (1 .. $COLS / 10)
				{
				for (1 .. $ROWS)
					{
					$text_array->[$_][$line * 10] = ['|', $color] ;
					}
				}
			}
		
		$grid_setup_text = $encoder->encode($text_array) ;
		$grid_rendered = $rows_cols ;
		}
	}

# draw ruler lines
for my $ruler (@{$self->{RULER_LINES}})
	{
	my $color = color($self->get_color('ruler_line')) ;
	
	if($ruler->{TYPE} eq 'VERTICAL')
		{
		$text_array->[$_][$ruler->{POSITION}] = ['|', $color] for (1 .. $ROWS) ;
		}
	else
		{
		$text_array->[$ruler->{POSITION}][$_] = ['-', $color] for (1 .. $COLS) ;
		}
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
			$background_color = $element->{GROUP}[-1]{GROUP_COLOR} ;
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
				$background_color = $element->{GROUP}[-1]{GROUP_COLOR} ;
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
	
	my $stripes = $element->get_stripes() ;
	# $self->update_quadrants($element) ;
	
	for my $strip (@{$stripes})
		{
		my $line_index = 0 ;
		
		for my $line (split /\n/, $strip->{TEXT})
			{
			my $strip_color  = color($foreground_color) . color($background_color) ;
			   $strip_color .= color($self->get_color('selected_element_background')) if $is_selected ;
			
			my $line_length = length $line ;
			$line = sprintf "%0${line_length}d", $element_index if $self->{NUMBERED_OBJECTS} ;
			
			my $character_index = 0 ;
			
			for (split //, $line)
				{
				$character_index++ ;
				
				my $Y = $element->{Y} + $strip->{Y_OFFSET} + $line_index + 1 ;
				next if $Y < 1 || $Y > $ROWS ;
				
				my $X = $element->{X} + $strip->{X_OFFSET} + $character_index ;
				next if $X < 1 || $X > $COLS ;
				
				$text_array->[$Y][$X] = [$_, $strip_color] ;
				}
			
			$line_index++ ;
			}
		}
	}

# draw connections
my (%connected_connections, %connected_connectors) ;

my $connector_point_color = color($self->get_color('connector_point'));
my $connector_point_rendering = "O" ;

my $connection_point_color = color($self->get_color('connection_point'));
my $connection_point_rendering = "o" ;

my $extra_point_color = color($self->get_color('extra_point'));
my $extra_point_rendering = "#" ;

if ($self->{MOUSE_TOGGLE})
	{
	for my $element (grep {$self->is_over_element($_, $self->{MOUSE_X}, $self->{MOUSE_Y}, 1)} @{$self->{ELEMENTS}})
		{
		for my $connector ($element->get_connector_points())
			{
			next if exists $connected_connectors{$element}{$connector->{X}}{$connector->{Y}} ;
			
			my $column = $element->{X} + $connector->{X} + 1 ;
			my $line = $connector->{Y} + $element->{Y} + 1 ;
			
			unless($column < 1 || $column > $COLS || $line < 1 || $line > $ROWS)
				{
				$text_array->[$line][$column] = [$connector_point_rendering, $connector_point_color] ;
				}
			}
			
		for my $extra_point ($element->get_extra_points())
			{
			my $column = $extra_point->{X}  + $element->{X} + 1 ;
			my $line = $extra_point->{Y} + $element->{Y} + 1 ;
			
			unless($column < 1 || $column > $COLS || $line < 1 || $line > $ROWS)
				{
				$text_array->[$line][$column] = [$extra_point_rendering, $extra_point_color] ;
				}
			}
		
		if($self->{DRAW_CONNECTION_POINTS})
				{
				for my $connection_point ($element->get_connection_points())
					{
					next if exists $connected_connections{$element}{$connection_point->{X}}{$connection_point->{Y}} ;
					
					my $column = $connection_point->{X} + $element->{X} + 1 ;
					my $line = $connection_point->{Y} + $element->{Y} + 1 ;
					
					unless($column < 1 || $column > $COLS || $line < 1 || $line > $ROWS)
						{
						$text_array->[$line][$column] = [$connection_point_rendering, $connection_point_color] ;
						}
				}
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
			
			my $connection_color = color($self->get_color('connection'));
			my $connection_char = $connector->{CHAR} // 'c' ;
			my $connection_rendering = "$connection_char" ;
			
			my $column = $connector->{X} + $connection->{CONNECTED}{X} + 1 ;
			my $line = $connector->{Y}  + $connection->{CONNECTED}{Y} + 1 ;
			
			unless($column < 1 || $column > $COLS || $line < 1 || $line > $ROWS)
				{
				$text_array->[$line][$column] = [$connection_rendering, $connection_color] ;
				}
			}
		}
	}

# draw new connections
my $new_connection_color = color($self->get_color('new_connection'));
my $connection_rendering = "c" ;
for my $new_connection (@{$self->{NEW_CONNECTIONS}})
	{
	my $end_connection = $new_connection->{CONNECTED}->get_named_connection($new_connection->{CONNECTOR}{NAME}) ;
	
	my $column = $end_connection->{X} + $new_connection->{CONNECTED}{X} + 1 ;
	my $line = $end_connection->{Y} + $new_connection->{CONNECTED}{Y} + 1 ;
	
	unless($column < 1 || $column > $COLS || $line < 1 || $line > $ROWS)
			{
			$text_array->[$line][$column] = [$connection_rendering, $new_connection_color] ;
			}
	}

delete $self->{NEW_CONNECTIONS} ;

my $selection_rectangle = '' ;
if(defined $self->{SELECTION_RECTANGLE}{END_X})
	{
	my $start_x = $self->{SELECTION_RECTANGLE}{START_X} + 1 ;
	my $start_y = $self->{SELECTION_RECTANGLE}{START_Y} + 1 ;
	my $end_x   = $self->{SELECTION_RECTANGLE}{END_X} + 1 ;
	my $end_y   = $self->{SELECTION_RECTANGLE}{END_Y} + 1 ;
	
	($start_x, $end_x) = ($end_x, $start_x) if $end_x < $start_x ;
	($start_y, $end_y) = ($end_y, $start_y) if $end_y < $start_y ;
	
	my $width  = $end_x - $start_x + 1 ;
	my $height = $end_y - $start_y + 1 ;
	
	$selection_rectangle = "$start_x - $start_y * $end_x - $end_y" ;
	
	my $color = color($self->get_color('selection_rectangle')) ;
	
	for ($start_y .. $start_y + $height - 1)
		{
		next if $_ < 1 || $_ > $ROWS ;
		
		$text_array->[$_][$start_x] = ['|', $color] if $start_x > 0 && $start_x <= $COLS ;
		$text_array->[$_][$end_x]   = ['|', $color] if $end_x > 1   && $end_x <= $COLS ;
		}
	
	if($start_x <= $COLS && $end_x > 0)
		{ 
		my $top_bottom = '-' x $width ;
		$top_bottom = substr($top_bottom, -$start_x + 1) and $start_x = 1 if $start_x < 1 ;
		$top_bottom = substr($top_bottom, 0, ($COLS - $start_x) + 1) if $end_x > $COLS ;
		
		if($start_y > 0 && $start_y <= $ROWS)
			{
			my $character_index = 0 ;
			for (1 .. length($top_bottom))
				{
				$text_array->[$start_y][$start_x + $character_index] = ['-', $color] ;
				$character_index++ ;
				}
			}
		
		if($end_y > 0 && $end_y <= $ROWS)
			{
			my $character_index = 0 ;
			for (1 .. length($top_bottom))
				{
				$text_array->[$end_y][$start_x + $character_index] = ['-', $color] ;
				$character_index++ ;
				}
			}
		}
	
	delete $self->{SELECTION_RECTANGLE}{END_X} ;
	}

if ($self->{MOUSE_TOGGLE})
	{
	$text_array->[$self->{MOUSE_Y} + 1][$self->{MOUSE_X} + 1] = ['X', color($self->get_color('mouse_rectangle'))]
		unless($self->{MOUSE_X} < 0 || $self->{MOUSE_X} >= $COLS || $self->{MOUSE_Y} < 0 || $self->{MOUSE_Y} >= $ROWS) ;
	}

render_text($text_array, $COLS, $ROWS) ;

if(defined $self->{ACTION_VERBOSE})
	{
	print "\e[2;81H\e[32m$self->{LAST_ACTION} " ;
	print "\e[3;81H$selection_rectangle" ;
	}
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
my ($self, $code) = @_ ;

ReadMode('normal') ;
print "\e[2J\e[H" ;
print "\e[?25h" ;
print "\e[?1000h" ;

exit ($code // 0) ;
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

