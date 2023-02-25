
package App::Asciio::Toolfunc ;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(usc_length make_vertical_text global_double_width_char_expr_qr_set);

use strict;
use warnings;
use utf8;

#-----------------------------------------------------------------------------

my $EXPR_QR;

#-----------------------------------------------------------------------------

sub global_double_width_char_expr_qr_set
{
	my ($in_expr_qr) = @_;
	$EXPR_QR = qr/$in_expr_qr/;
}

#-----------------------------------------------------------------------------

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
