
package App::Asciio::Toolfunc ;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(usc_length make_vertical_text);

use strict;
use warnings;
use utf8;

# cnt number of cjk characters
# chinese u3400-u4db5 u4e00-u9fa5 
# Japanese u0800-u4e00(Japanese language is temporarily not supported because some symbols are in the Japanese range)
# Korean uac00-ud7ff

#-----------------------------------------------------------------------------

my $EXPR_QR = qr/[\x{3400}-\x{4db5}]|[\x{4e00}-\x{9fa5}]|[\x{ac00}-\x{d7ff}]|[，。！？《》【】：；、／＼]/;

sub usc_length
{
my ($string) = @_ ;

return length($string) + ($string =~ s/$EXPR_QR/x/g) ;
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
