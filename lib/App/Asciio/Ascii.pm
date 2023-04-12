
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
my ($self, @elements)  = @_ ;

@elements = @{$self->{ELEMENTS}} unless @elements ;

my @lines ;

for my $element (@elements)
	{
	for my $strip (@{$element->get_stripes()})
		{
		my $line_index = 0 ;
		for my $sub_strip (split("\n", $strip->{TEXT}))
			{
			my $character_index = 0 ;
			
			for my $character (split '', $sub_strip)
				{
				my $x =  $element->{X} + $strip->{X_OFFSET} + $character_index ;
				my $y =  $element->{Y} + $strip->{Y_OFFSET} + $line_index ;
				
				$lines[$y][$x] = $character if ($x >= 0 && $y >= 0) ;
				$character_index += usc_length($character);
				}
			
			$line_index++ ;
			}
		}
	}
return(@lines) ;

}

#-----------------------------------------------------------------------------

sub transform_elements_to_ascii_array
{
my ($self, @elements)  = @_ ;

my @lines = $self->transform_elements_to_ascii_two_dimensional_array(@elements) ;

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

1 ;
