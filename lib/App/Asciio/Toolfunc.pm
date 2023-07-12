
package App::Asciio::Toolfunc ;

require Exporter ;
@ISA = qw(Exporter) ;
@EXPORT = qw(
	use_markup
	set_double_width_qr
	usc_length
	make_vertical_text
	) ;

#-----------------------------------------------------------------------------

use strict ; use warnings ;
use utf8 ;

#-----------------------------------------------------------------------------

{

my ($double_width_qr, $use_markup) ;

sub use_markup { my ($use_it) = @_ ; $use_markup = $use_it ; }
sub set_double_width_qr { my ($qr) = @_ ; $double_width_qr = $qr ; }

#-----------------------------------------------------------------------------

sub usc_length
{
my ($string) = @_ ;

$string =~ s/<span link="[^<]+">|<\/span>|<\/?[bius]>//g if $use_markup ;

return length($string) + $string =~ s/$double_width_qr/x/g ;
}

}

#-----------------------------------------------------------------------------

sub make_vertical_text
{
my ($text) = @_ ;

my @lines = map{[split '', $_]} split "\n", $text ;

my $vertical = '' ;
my $found_character = 1 ;
my $index = 0 ;

while($found_character)
	{
	my $line ;
	$found_character = 0 ;
	
	for(@lines)
		{
		if(defined $_->[$index])
			{
			$line.= $_->[$index] ;
			$found_character++ ;
			}
		else
			{
			$line .= ' ' ;
			}
		}
	
	$line =~ s/\s+$//; 
	$vertical .= "$line\n" if $found_character ;
	$index++ ;
	}

return $vertical ;
}

#-----------------------------------------------------------------------------

1 ;
