
package App::Asciio;

$|++ ;

use strict;
use warnings;

#-----------------------------------------------------------------------------

sub transform_elements_to_ascii_buffer
{
my ($self, @elements)  = @_ ;

return(join("\n", $self->transform_elements_to_ascii_array(@elements)) . "\n") ;
}

#-----------------------------------------------------------------------------

sub transform_elements_to_ascii_array
{
my ($self, @elements)  = @_ ;

@elements = @{$self->{ELEMENTS}} unless @elements ;

my @lines ;

for my $element (@elements)
	{
	for my $strip ($element->get_mask_and_element_stripes())
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
				
				$character_index ++ ;
				}
				
			$line_index++ ;
			}
		}
	}

my @ascii;

for my $line (@lines)
	{
	my $ascii_line = join('', map {defined $_ ? $_ : ' '} @{$line})  ;
	push @ascii,  $ascii_line;
	}

return(@ascii) ;
}			

#-----------------------------------------------------------------------------

1 ;