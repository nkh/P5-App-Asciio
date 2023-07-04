
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

# If there is an overlay, the characters of the overlay need to be exported
for($self->get_overlays())
	{
	$lines[$_->[1]][$_->[0]] = $_->[2] if defined $lines[$_->[1]][$_->[0]] ;
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

sub transform_elements_to_ascii_array_for_cross_overlay
{
my ($self, $cross_filler_chars)  = @_ ;

my (@lines, @cross_point_index, %cross_point_index_hash, $cross_point) ;

for my $element (grep {defined $_->{CROSS_FLAG}} @{$self->{ELEMENTS}})
	{
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
				
				if($x >= 0 && $y >= 0)
					{
					$cross_point = $y . '-' . $x ;

					# The characters retained in the array are characters that may be crossing, 
					# and other characters are discarded
					if(exists $cross_filler_chars->{$character})
						{
						if(defined $lines[$y][$x])
							{
							push @{$lines[$y][$x]}, $character ;
							}
						else
							{
							$lines[$y][$x] = [$character] ;
							}
						}
					else
						{
						delete $lines[$y][$x] if(defined $lines[$y][$x]) ;
						}
					
					# The cross point is the number of array elements greater than 1
					if((defined $lines[$y][$x]) && (scalar @{$lines[$y][$x]} > 1))
						{
						$cross_point_index_hash{$cross_point} = 1 ;
						}
					else
						{
						delete $cross_point_index_hash{$cross_point} if(defined $cross_point_index_hash{$cross_point}) ;
						}
					}
				$character_index += usc_length($character);
				}
			
			$line_index++ ;
			}
		}
	}

for(keys %cross_point_index_hash)
	{
	push @cross_point_index, [map {int} split('-', $_)] ;
	}

return(\@lines, \@cross_point_index) ;
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
