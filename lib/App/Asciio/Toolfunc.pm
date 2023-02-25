
package App::Asciio::Toolfunc ;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(set_double_width_qr usc_length make_vertical_text);

use strict;
use warnings;
use utf8;

#-----------------------------------------------------------------------------
{

my $DOUBLE_WIDTH_QR ;

sub set_double_width_qr
{
my ($self) = @_ ;
die "DOUBLE_WIDTH_QR not set" unless defined $self->{DOUBLE_WIDTH_QR} ;
$DOUBLE_WIDTH_QR = $self->{DOUBLE_WIDTH_QR} ;
}

sub usc_length
{
my ($string) = @_ ;

return length($string) + ($string =~ s/$DOUBLE_WIDTH_QR/x/g) ;
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
