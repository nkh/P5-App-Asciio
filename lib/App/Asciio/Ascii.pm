
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
	my $return_line = '' ;
	my $black_flg = 0 ;
	for my $character (split '', $deal_line) {
		if($black_flg == 1) {
			$black_flg = 0;
		} else {
			if(physical_length($character) != 1) {
				$black_flg = 1;
			}
			$return_line .= $character;
		}
	}
	return $return_line;
}

sub transform_elements_to_ascii_array
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
				if(physical_length($character) != length($character)) {
					$character_index = $character_index + 2;
				} else {
					$character_index ++ ;
				}
				}
				
			$line_index++ ;
			}
		}
	}

my @ascii;

for my $line (@lines)
	{
	my $ascii_line = join('', map {defined $_ ? $_ : ' '} @{$line})  ;
	if(defined $ascii_line) {
		my $write_line = del_black_in_line($ascii_line);
		push @ascii, $write_line;
	} else {
		push @ascii, $ascii_line;
	}
	}

return(@ascii) ;
}			

#-----------------------------------------------------------------------------

1 ;
