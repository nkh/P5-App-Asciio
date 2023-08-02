
package App::Asciio::Markup ;

require Exporter ;
@ISA = qw(Exporter) ;
@EXPORT = qw(
	use_markup
	is_markup_string
	delete_markup_characters
	convert_markup_string
	get_unicode_length
	get_markup_coordinates) ;

$|++ ;

use strict;
use warnings;
use utf8;

use App::Asciio::String ;

use Memoize ;
memoize('get_unicode_length') ;
memoize('convert_markup_string') ;


my ($use_markup_mode) ;

#-----------------------------------------------------------------------------

sub use_markup
{
my ($use_it) = @_ ;
$use_markup_mode = $use_it ; 
}

#-----------------------------------------------------------------------------

sub is_markup_string
{
my ($string) = @_;

return (   $string =~ /(<[bius]>)+([^<]+)(<\/[bius]>)+/ 
		|| $string =~ /<span link="[^<]+">([^<]+)<\/span>/) ;
}

#-----------------------------------------------------------------------------

sub delete_markup_characters
{
my ($string) = @_;
if($use_markup_mode)
	{
	$string =~ s/<span link="[^<]+">|<\/span>|<\/?[bius]>//g ;
	}
return $string;
}

#-----------------------------------------------------------------------------
#~ link fomart: <span link="">something</span>
#~ convert to:  <span underline="double">something</span>
sub convert_markup_string
{
my ($string) = @_ ;

my $use_markup_formart = 0 ;

if($use_markup_mode && ($string =~ /<span link="[^<]+">([^<]+)<\/span>/ || $string =~ /<\/?[bius]>/))
	{
	$use_markup_formart = 1 ;
	# just for display,not really change
	$string =~ s/<span link="[^<]+">([^<]+)<\/span>/<span underline="double">$1<\/span>/g;
	}

return ($use_markup_formart, $string) ;
}

#-----------------------------------------------------------------------------

sub get_unicode_length
{
my ($string) = @_ ;

return unicode_length(delete_markup_characters($string)) ;
}

#-----------------------------------------------------------------------------
sub get_markup_coordinates
{
my ($element_x, $strip_line, $strip_x, $y) = @_ ;

my %markup_coordinate ;

if($use_markup_mode)
	{
	my $ori_x = 0;
	while($strip_line =~ /(<\/?[bius]>)+|<\/span>|<span link="[^<]+">/g)
		{
		my $sub_str = substr($strip_line, 0, pos($strip_line));
		$ori_x = $element_x + $strip_x + get_unicode_length($sub_str) ;
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

return %markup_coordinate ;

}

#-----------------------------------------------------------------------------

1 ;

