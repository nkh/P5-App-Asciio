
package App::Asciio;

$|++ ;

use strict;
use warnings;

#-----------------------------------------------------------------------------

sub transform_elements_to_ascii_buffer_keep_empty_lines
{
my ($self, @elements)  = @_ ;

my $text = join("\n", $self->transform_elements_to_ascii_array(@elements)) . "\n" ;

return($text) ;
}

#-----------------------------------------------------------------------------

sub transform_elements_to_ascii_buffer
{
my ($self, @elements)  = @_ ;

my $text = join("\n", $self->transform_elements_to_ascii_array(@elements)) . "\n" ;
$text =~ s/^\n+|\n\K\n+$//g ;

return($text) ;
}

#-----------------------------------------------------------------------------

sub transform_elements_to_wiki_buffer
{
my ($self, @elements)  = @_ ;

my $text = join("\n", $self->transform_elements_to_wiki_array(@elements)) . "\n" ;
$text =~ s/^\n+|\n\K\n+$//g ;

return($text) ;
}

#-----------------------------------------------------------------------------

sub del_black_in_line
{
my ($deal_line) = @_ ;
my ($return_line, $char_len) = ('', 1) ;

for my $character (split '', $deal_line)
	{
	if($char_len != 1)
		{
		$char_len -= 1;
		}
	else
		{
		$char_len = usc_length($character) ;
		$return_line .= $character;
		}
	}

return $return_line;
}

sub transform_elements_to_ascii_two_dimensional_array
{
my ($self, $format, @elements)  = @_ ;

@elements = @{$self->{ELEMENTS}} unless @elements ;

my @lines ;
my @new_lines ;
my %markup_coordinate ;

for my $element (@elements)
	{
	for my $strip (@{$element->get_stripes()})
		{
		my $line_index = 0 ;

		for my $sub_strip (split("\n", $strip->{TEXT}))
			{
			my $origin_strip = $sub_strip ;
			my $y =  $element->{Y} + $strip->{Y_OFFSET} + $line_index ;

			if($self->{MARKUP_MODE})
			{
				$sub_strip =~ s/(<[bius]>)+([^<]+)(<\/[bius]>)+/$2/g ;
				$sub_strip =~ s/<span link="[^<]+">([^<]+)<\/span>/$1/g ;
				if($format)
					{
					my $ori_x = 0;
					while($origin_strip =~ /(<\/?[bius]>)+|<\/span>|<span link="[^<]+">/g)
						{
						my $sub_str = substr($origin_strip, 0, pos($origin_strip));
						$ori_x = $element->{X} + $strip->{X_OFFSET} + usc_length($sub_str) ;
						my $fit_str = $&;
						$fit_str =~ s/<\/?b>/\*\*/g;
						$fit_str =~ s/<\/?u>/__/g;
						$fit_str =~ s/<\/?i>/\/\//g;
						$fit_str =~ s/<\/?s>/~~/g;
						# link [[link|link description]]
						if($fit_str =~ /<span link="[^<]+">/)
							{
							$fit_str =~ s/<span link="([^<]+)">/$1/g;
							$fit_str = '[[' . $fit_str . '|';
							}
						if($fit_str =~ /<\/span>/)
							{
							$fit_str = ']]';
							}
						$markup_coordinate{$y . '-' . $ori_x} = $fit_str if($ori_x >= 0 && $y >=0);
						}
					}
			}

			my $character_index = 0 ;
			
			for my $character (split '', $sub_strip)
				{
				my $x =  $element->{X} + $strip->{X_OFFSET} + $character_index ;
				
				$lines[$y][$x] = $character if ($x >= 0 && $y >= 0) ;
				$character_index += usc_length($character);
				}
			
			$line_index++ ;
			}
		}
	}

if($self->{MARKUP_MODE} && $format)
	{
	my $new_col;
	for my $row (0 .. $#lines)
		{
		$new_col = 0;
		for my $col (0 .. ($#{$lines[$row]} + 2))
			{
			if(exists($markup_coordinate{$row . '-' . $col}))
				{
				for my $single_char (split '', $markup_coordinate{$row . '-' . $col})
					{
					$new_lines[$row][$new_col] = $single_char;
					$new_col += usc_length($single_char);
					}
				}
			$new_lines[$row][$new_col] = $lines[$row][$col] if(defined($lines[$row][$col]));
			$new_col += 1;
			}
		}
	return(@new_lines);
	}
return(@lines) ;
}

sub transform_elements_to_ascii_two_dimensional_array_for_cross_mode
{
my ($self)  = @_ ;

my @cross_x_rulers = grep {$_->{NAME} eq "CROSS_X"} @{$self->{RULER_LINES}};
my @cross_y_rulers = grep {$_->{NAME} eq "CROSS_Y"} @{$self->{RULER_LINES}};

my ($max_x, $max_y) = ($self->{widget}->get_allocated_width(), $self->{widget}->get_allocated_height()) ;

my ($cross_x_start, $cross_x_end, $cross_y_start, $cross_y_end);

if(scalar(@cross_x_rulers) == 2)
	{
	$cross_x_start = min(map {$_->{POSITION}} @cross_x_rulers);
	$cross_x_end = max(map {$_->{POSITION}} @cross_x_rulers);
	}
elsif(scalar(@cross_x_rulers) == 1)
	{
	$cross_x_start = 0;
	$cross_x_end = $cross_x_rulers[0]->{POSITION};
	}
else
	{
	$cross_x_start = 0;
	$cross_x_end = $max_x;
	}

if(scalar(@cross_y_rulers) == 2)
	{
	$cross_y_start = min(map {$_->{POSITION}} @cross_y_rulers);
	$cross_y_end = max(map {$_->{POSITION}} @cross_y_rulers);
	}
elsif(scalar(@cross_y_rulers) == 1)
	{
	$cross_y_start = 0;
	$cross_y_end = $cross_y_rulers[0]->{POSITION};
	}
else
	{
	$cross_y_start = 0;
	$cross_y_end = $max_y;
	}

my (@lines, %cross_elements_location) ;

for my $element (grep {(defined $_->{CROSS_ENUM}) && ($_->{CROSS_ENUM} > 1) && ($cross_y_start < $_->{Y} < $cross_y_end) && ($cross_x_start < $_->{X} < $cross_x_end)} @{$self->{ELEMENTS}})
	{
	if((defined($element->{CROSS_ENUM})) && ($element->{CROSS_ENUM} == 2))
		{
		$cross_elements_location{$element->{X} . '-' . $element->{Y}} = $element->{TEXT_ONLY};
		next;
		}
	for my $strip (@{$element->get_stripes()})
		{
		my $line_index = 0 ;

		for my $sub_strip (split("\n", $strip->{TEXT}))
			{
			my $y =  $element->{Y} + $strip->{Y_OFFSET} + $line_index ;

			if($self->{MARKUP_MODE})
			{
				$sub_strip =~ s/(<[bius]>)+([^<]+)(<\/[bius]>)+/$2/g ;
				$sub_strip =~ s/<span link="[^<]+">([^<]+)<\/span>/$1/g ;
			}

			my $character_index = 0 ;
			
			for my $character (split '', $sub_strip)
				{
				my $x =  $element->{X} + $strip->{X_OFFSET} + $character_index ;
				
				$lines[$y][$x] = $character if ($x >= 0 && $y >= 0) ;
				$character_index += usc_length($character);
				}
			
			$line_index++ ;
			}
		}
	}

return($cross_x_start, $cross_x_end, $cross_y_start, $cross_y_end, \%cross_elements_location, @lines) ;
}

#-----------------------------------------------------------------------------

sub transform_elements_to_array
{
my ($self, $format, @elements)  = @_ ;

my @lines = $self->transform_elements_to_ascii_two_dimensional_array($format, @elements) ;

my @ascii ;

for my $line (@lines)
	{
	my $ascii_line = join('', map {defined $_ ? $_ : ' '} @{$line})  ;
	if(defined $ascii_line)
		{
		my $write_line = del_black_in_line($ascii_line) ;
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

return($self->transform_elements_to_array(0, @elements));
}

#-----------------------------------------------------------------------------

sub transform_elements_to_wiki_array
{
my ($self, @elements)  = @_ ;

return($self->transform_elements_to_array(1, @elements));
}
#-----------------------------------------------------------------------------

1 ;
