
package App::Asciio;

$|++ ;

use strict; use warnings;

use App::Asciio::Cross ;
use App::Asciio::String ;
use App::Asciio::Markup ;
use App::Asciio::ZBuffer ;

use Readonly ;
Readonly my $EXPORT_PLAIN_TEXT => 0 ;
Readonly my $EXPORT_MARKUP  => 1 ;

use List::Util qw(min) ;

#-----------------------------------------------------------------------------

sub transform_elements_to_ascii_buffer
{
my ($self, @elements)  = @_ ;

my $text = join("\n", $self->transform_elements_to_ascii_array(@elements)) . "\n" ;
$text =~ s/^\n+|\n\K\n+$//g ;

return($text) ;
}

#-----------------------------------------------------------------------------

sub transform_elements_to_ascii_buffer_aligned_left
{
my ($self, @elements)  = @_ ;

my @lines           = $self->transform_elements_to_ascii_array(@elements) ;
my @non_empty_lines = grep { length($_) }  @lines ;

my $empty_columns   = min(map { /(\s+)/ ; length($1 // '') } @non_empty_lines) ;
   $empty_columns //= 0 ;

my $text = join("\n", map { length($_) ? substr($_, $empty_columns) : '' } @lines) . "\n" ;

$text =~ s/^\n+|\n\K\n+$//g ;

return($text) ;
}

#-----------------------------------------------------------------------------

sub transform_elements_to_markup_buffer
{
my ($self, @elements)  = @_ ;

my $text = join("\n", $self->transform_elements_to_markup(@elements)) . "\n" ;
$text =~ s/^\n+|\n\K\n+$//g ;

return($text) ;
}

#-----------------------------------------------------------------------------

sub transform_elements_to_characters_array
{
my ($self, $format, @elements)  = @_ ;

@elements = @{$self->{ELEMENTS}} unless @elements ;

my @lines ;
my (%markup_coordinate, %sub_markup_coordinate) ;

for my $element (@elements)
	{
	for my $strip (@{$element->get_stripes()})
		{
		my $line_index = 0 ;
		
		for my $sub_strip (split("\n", $strip->{TEXT}))
			{
			my $origin_strip = $sub_strip ;
			my $y =  $element->{Y} + $strip->{Y_OFFSET} + $line_index ;
			
			$sub_strip = $USE_MARKUP_CLASS->delete_markup_characters($sub_strip) ;
			
			if($format != $EXPORT_PLAIN_TEXT)
				{
				%sub_markup_coordinate = $USE_MARKUP_CLASS->get_markup_coordinates($element->{X}, $origin_strip, $strip->{X_OFFSET}, $y) ;
				while (my ($key, $value) = each %sub_markup_coordinate)
					{
					$markup_coordinate{$key} = ${value} ;
					}
				}
			
			my $character_index = 0 ;
			
			for my $character (split '', $sub_strip)
				{
				my $x =  $element->{X} + $strip->{X_OFFSET} + $character_index ;
				
				if($x >= 0 && $y >= 0)
					{
					if($character =~ /\p{gc:Mn}/)
						{
						push @{$lines[$y][$x-1]}, $character ;
						}
					else
						{
						$lines[$y][$x] = [$character] ;
						}
					}
				
				my $character_length = unicode_length($character) ;
				$character_index += $character_length ;
				}
			
			$line_index++ ;
			}
		}
	}

# If there is cross overlay, the characters of the cross need to be exported
if($self->{USE_CROSS_MODE})
	{
	my $zbuffer = App::Asciio::ZBuffer->new(1, @{$self->{ELEMENTS}}) ;

	for(App::Asciio::Cross::get_cross_mode_overlays($zbuffer))
		{
		$lines[$_->[1]][$_->[0]] = [$_->[2]] if defined $lines[$_->[1]][$_->[0]] ;
		}
	}
if($format != $EXPORT_PLAIN_TEXT)
	{
	return $USE_MARKUP_CLASS->get_markup_characters_array(\%markup_coordinate, @lines) ; 
	}
return @lines ;

}

#-----------------------------------------------------------------------------

sub transform_elements_to_array
{
my ($self, $format, @elements)  = @_ ;

my @lines = $self->transform_elements_to_characters_array($format, @elements) ;

my @ascii ;

for my $line (@lines)
	{
	my $ascii_line = join('', map {defined $_ ? join('', @{$_}) : ' '} @{$line})  ;
	if(defined $ascii_line)
		{
		my ($write_line, $char_len) = ('', 1) ;
		
		for my $character (split '', $ascii_line)
			{
			if($char_len > 1)
				{
				$char_len -= 1;
				}
			else
				{
				# single char
				$char_len = unicode_length($character) ;
				$write_line .= $character;
				}
			}
		
		push @ascii, $write_line;
		}
	else
		{
		push @ascii, $ascii_line ;
		}
	}

return(@ascii) ;
}

#-----------------------------------------------------------------------------

sub transform_elements_to_ascii_array
{
my ($self, @elements)  = @_ ;

return($self->transform_elements_to_array($EXPORT_PLAIN_TEXT, @elements));
}

#-----------------------------------------------------------------------------

sub transform_elements_to_markup
{
my ($self, @elements)  = @_ ;

return($self->transform_elements_to_array($EXPORT_MARKUP, @elements));
}

#-----------------------------------------------------------------------------

sub get_text_rectangle 
{
my ($self, $coordinates) = @_;

return ("", 0, 0, 0, 0) unless %$coordinates ;

my ($min_x, $min_y, $max_x, $max_y) = (1e9, 1e9, -1e9, -1e9) ;

for my $key (keys %$coordinates) 
	{
	my ($y, $x) = split /;/, $key;
	
	$min_x = $x < $min_x ? $x : $min_x ;
	$max_x = $x > $max_x ? $x : $max_x ;
	$min_y = $y < $min_y ? $y : $min_y ;
	$max_y = $y > $max_y ? $y : $max_y ;
	}

my @rectangle ;

for my $y ($min_y .. $max_y) 
	{
	my $x = $min_x ;
	
	while ($x <= $max_x)
		{
		$rectangle[$y - $min_y][$x - $min_x] = $coordinates->{"$y;$x"} // ' ' ;
		my $char_length                      = unicode_length($coordinates->{"$y;$x"} // ' ') ;
		$x                                  += $char_length ;
		
		if($char_length == 0)
			{
			warn "found nonspacing char(" . $coordinates->{"$y;$x"} . ")here\n" ;
			$x++ ;
			}
		}
	}

my $output = "";
for my $row (@rectangle) 
	{
	$output .= join('', grep { defined $_ } @$row) . "\n" ;
	}

return ($output, $min_x, $min_y, $max_x - $min_x + 1, $max_y - $min_y + 1) ;
}

#-----------------------------------------------------------------------------

1 ;
