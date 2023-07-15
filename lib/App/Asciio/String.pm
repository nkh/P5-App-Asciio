
package App::Asciio::String ;

require Exporter ;
@ISA = qw(Exporter) ;
@EXPORT = qw(
	use_markup
	unicode_length
	make_vertical_text
	) ;

#-----------------------------------------------------------------------------

use strict ; use warnings ;
use utf8 ;

#-----------------------------------------------------------------------------

use Memoize ;
memoize('unicode_length') ;

sub unicode_length
{
my ($string) = @_ ;

# no more reference to MARUP

my $east_asian_double_width_chars_cnt = grep {$_ =~ /\p{EA=W}|\p{EA=F}/} split('', $string) ;
my $nonspacing_chars_cnt = grep {$_ =~ /\p{gc:Mn}/} split('', $string) ;

return length($string) + $east_asian_double_width_chars_cnt - $nonspacing_chars_cnt ;
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
 
package App::Asciio ;

sub unicode_length
{
my ($self, $string) = @_ ;

# Markup is not part of Unicode, handle it in Asciio
$string =~ s/<span link="[^<]+">|<\/span>|<\/?[bius]>//g if $self->{USE_MARKUP_MODE} ;

return App::Asciio::String::unicode_length($string) ;
}

#-----------------------------------------------------------------------------

1 ;
