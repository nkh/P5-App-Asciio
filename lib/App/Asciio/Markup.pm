
package App::Asciio::Markup ;

require Exporter ;
@ISA = qw(Exporter) ;
@EXPORT = qw(
	$USE_MARKUP_CLASS
	) ;

$|++ ;

use strict;
use warnings;
use utf8;

use App::Asciio::String ;


our ($USE_MARKUP_CLASS) ;
$USE_MARKUP_CLASS = App::Asciio::Markup->new() ;

#-----------------------------------------------------------------------------

sub new {
	my $class = shift ;
	my $self = {} ;
	bless $self, $class ;
	return $self ;
}

#-----------------------------------------------------------------------------

sub use_markup
{
my ($use_it) = @_ ;

if($use_it eq 'zimwiki')
	{
	$USE_MARKUP_CLASS = App::Asciio::Zimwiki->new() ;
	}
else
	{
	$USE_MARKUP_CLASS = App::Asciio::Markup->new() ;
	}
}

#-----------------------------------------------------------------------------

sub delete_markup_characters { my ($self, $string) = @_ ; return $string ; }

#-----------------------------------------------------------------------------

sub get_markup_coordinates { ; }

#-----------------------------------------------------------------------------

sub get_markup_characters_array
{
my ($self, $markup_coordinate, @lines) = @_ ;

return (@lines) ;
}

#-----------------------------------------------------------------------------

sub ui_show_markup_characters
{
my ($self, $layout, $font_size, $line) = @_ ;

$layout->set_text($line) ;
}

#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------

package App::Asciio::Zimwiki ;
use base qw/App::Asciio::Markup/ ;

use Memoize ;
memoize('convert_markup_string') ;
memoize('del_markup_characters') ;

#-----------------------------------------------------------------------------

sub is_markup_string
{
my ($string) = @_;

return (   $string =~ /(<[bius]>)+([^<]+)(<\/[bius]>)+/ 
		|| $string =~ /<span link="[^<]+">([^<]+)<\/span>/) ;
}

#-----------------------------------------------------------------------------

sub del_markup_characters
{
my ($string) = @_;

$string =~ s/<span link="[^<]+">|<\/span>|<\/?[bius]>//g ;

return $string;
}

#-----------------------------------------------------------------------------

sub delete_markup_characters
{
my ($self, $string) = @_;

return del_markup_characters($string);
}

#-----------------------------------------------------------------------------
sub get_markup_coordinates
{
my ($self, $element_x, $strip_line, $strip_x, $y) = @_ ;

my %markup_coordinate ;

if(is_markup_string($strip_line))
	{
	my $ori_x = 0;
	while($strip_line =~ /(<\/?[bius]>)+|<\/span>|<span link="[^<]+">/g)
		{
		my $sub_str = substr($strip_line, 0, pos($strip_line));
		$ori_x = $element_x + $strip_x + App::Asciio::String::unicode_length($sub_str) ;
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
sub get_markup_characters_array
{
my ($self, $markup_coordinate, @lines) = @_ ;
my (@new_lines, $new_col) ;

for my $row (0 .. $#lines)
	{
	$new_col = 0;
	for my $col (0 .. ($#{$lines[$row]} + 2))
		{
		if(exists($markup_coordinate->{$row . '-' . $col}))
			{
			for my $single_char (split '', $markup_coordinate->{$row . '-' . $col})
				{
				$new_lines[$row][$new_col] = [$single_char];
				# single char
				$new_col += App::Asciio::String::unicode_length($single_char);
				}
			}
		$new_lines[$row][$new_col] = $lines[$row][$col] if(defined($lines[$row][$col]));
		$new_col += 1;
		}
	}
return(@new_lines);
}

#-----------------------------------------------------------------------------
#~ link fomart: <span link="">something</span>
#~ convert to:  <span underline="double">something</span>
#~ bold fomart: <b>something</b>
#~ convert to: <span font_desc="$font_size - 1" weight="bold">something</span>
#~ the above just for display,not really change
# :TODO: At present, some font sizes cannot be aligned even if they are reduced by 1. The specific rules have not yet been clarified. Currently, we only solve the problem under certain font sizes.
sub convert_markup_string
{
my ($font_size, $string) = @_ ;

my $use_markup_formart = 0 ;

if(is_markup_string($string))
	{
	$use_markup_formart = 1 ;
	$string =~ s/<span link="[^<]+">([^<]+)<\/span>/<span underline="double">$1<\/span>/g;
	# convert bold fonts to precise size control 
	$font_size -= 1 ;
	$string =~ s/(<b>)((<[ius]>)*)([^<]+)((<\/[ius]>)*)(<\/b>)/<span font_desc="$font_size" weight="bold">$2$4$5<\/span>/g ;
	}

return ($use_markup_formart, $string) ;
}

#-----------------------------------------------------------------------------

sub ui_show_markup_characters
{
my ($self, $layout, $font_size, $line) = @_ ;

my ($use_mark_up, $markup_line) = convert_markup_string($font_size, $line) ;

if($use_mark_up)
	{
	$layout->set_markup($markup_line) ;
	}
else
	{
	$layout->set_text($line) ;
	}
}


#-----------------------------------------------------------------------------

1 ;

