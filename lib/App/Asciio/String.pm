
package App::Asciio::String ;

require Exporter ;
@ISA = qw(Exporter) ;
@EXPORT = 
	qw(
	unicode_display_width
	make_vertical_text
	get_keyboard_layout
	normalize_file_name
	register_unicode_display_width_overrides
	) ;

#-----------------------------------------------------------------------------

use strict ; use warnings ;
use utf8 ;
use Encode qw(decode FB_CROAK) ;
use Unicode::GCString ;

use App::Asciio::Markup ;

#-----------------------------------------------------------------------------

use Memoize ;
memoize('unicode_display_width') ;

#-----------------------------------------------------------------------------

my %WIDTH_OVERRIDES ;
my $WIDTH_OVERRIDES_REGEX = undef ;
my $WIDTH_BACKEND = undef ;

my @LANGUAGE_WIDTH_HANDLERS =
	(
	\&arabic_width_preprocess,
	);

#-----------------------------------------------------------------------------

sub register_width_backend
{
my ($backend) = @_ ;
$WIDTH_BACKEND = $backend ;
}

#-----------------------------------------------------------------------------

sub register_unicode_display_width_overrides
{
my ($overrides) = @_ ;

while (my ($char, $width) = each %$overrides)
	{
	$WIDTH_OVERRIDES{$char} = $width ;
	}

if (%WIDTH_OVERRIDES)
	{
	my $chars = join "", map { quotemeta($_) } keys %WIDTH_OVERRIDES ;
	$WIDTH_OVERRIDES_REGEX = qr/[$chars]/ ;
	}
}

#-----------------------------------------------------------------------------

sub unicode_display_width
{
my $string = shift ;

$string = $USE_MARKUP_CLASS->delete_markup_characters($string) ;

# If there is width calculation backend -> use it directly
if ($WIDTH_BACKEND)
	{
	return $WIDTH_BACKEND->($string) ;
	}
else
	{
	my ($override_width, $lang_width) = (0, 0) ;
	my $rest = $string ;
	
	if ($WIDTH_OVERRIDES_REGEX)
		{
		while ($rest =~ /($WIDTH_OVERRIDES_REGEX)/g)
			{
			my $char = $1 ;
			$override_width += $WIDTH_OVERRIDES{$char} ;
			}
		
		$rest =~ s/$WIDTH_OVERRIDES_REGEX//g ;
		}
	
	# If there is no width calculation backend,
	# fall back directly to the default calculation method.
	for my $handler (@LANGUAGE_WIDTH_HANDLERS)
		{
		$rest = $handler->($rest) ;
		}
	
	return Unicode::GCString->new($rest, Context => "NONEASTASIAN")->columns + $override_width ;
	}
}

#-----------------------------------------------------------------------------

# الله	U+FDF2	Allah
# ﷺ	U+FDFA	Sallallahu Alayhi Wasallam
# ﷻ	U+FDFB	Jallajalaluhu
sub arabic_width_preprocess
{
my ($string) = @_;

# SPECIAL CASE: Allah root ligatures (must run BEFORE Mn removal)
#
# Many Arabic fonts render sequences based on the Allah root
#   لل + marks + ه + marks
# as a *single visual glyph*.
#
# Unicode::GCString does NOT know about these ligatures, so we
# manually collapse them into a single placeholder "X" to force
# width = 1.
#
# IMPORTANT:
#   The mark ranges include:
#     - \p{Mn}                → all combining marks (shadda, vowels, etc.)
#     - U+06D6–U+06E8         → Quranic annotation marks
#     - U+06EA–U+06ED         → more Quranic marks
#
#   We EXCLUDE U+06E9 (۩) because it is a standalone
#   symbol that occupies its own cell and must NOT be swallowed
#   by the Allah rule.
$string =~ s/
	\x{0644}\x{0644}                                 # ل + ل
	(?:[\p{Mn}\x{06D6}-\x{06E8}\x{06EA}-\x{06ED}])*  # optional marks
	\x{0647}                                         # ه
	(?:[\p{Mn}\x{06D6}-\x{06E8}\x{06EA}-\x{06ED}])*  # optional marks
	/X/gx ;

# Allah with leading alif (الل…ه…)
#
# Same logic as above, but with an initial alif:
#   ا + ل + ل + marks + ه + marks
#
# This covers forms like:
#   اللّٰهُ
#   اللّٰهُۥ
#   اللّٰهُ۟
#
# This rule also must run BEFORE Mn removal.
$string =~ s/
	\x{0627}\x{0644}\x{0644}              # ا + ل + ل
	(?:[\p{Mn}\x{06D6}-\x{06ED}])*        # optional marks
	\x{0647}                              # ه
	(?:[\p{Mn}\x{06D6}-\x{06ED}])*        # optional marks
	/X/gx ;

# REMOVE ALL Mn (Combining Marks)
#
# After the Allah rules have collapsed their sequences, we can
# safely remove Mn characters. They visually stack on the
# previous base letter and do NOT occupy width in terminals.
#
# If we removed Mn earlier, the Allah patterns would break and
# become impossible to detect.
$string =~ s/\p{Mn}//g;

# ZWJ-BASED LAM-ALEF LIGATURES → width = 2 ("XX")
#
# Pattern:
#   ل + ZWJ* + ا/أ/إ/آ
#
# With ZWJ, many fonts force a *two-cell ligature* for lam-alef.
# We represent this with "XX" to ensure Unicode::GCString counts
# it as width 2.
#
# Must run BEFORE the normal lam-alef rule.
$string =~ s/\x{0644}\x{200D}+\x{0627}/XX/g ; # ل + ZWJ* + ا
$string =~ s/\x{0644}\x{200D}+\x{0623}/XX/g ; # ل + ZWJ* + أ
$string =~ s/\x{0644}\x{200D}+\x{0625}/XX/g ; # ل + ZWJ* + إ
$string =~ s/\x{0644}\x{200D}+\x{0622}/XX/g ; # ل + ZWJ* + آ

# NORMAL LAM-ALEF LIGATURES → width = 1 ("X")
#
# Pattern:
#   لا، لأ، لإ، لآ
#
# These are standard lam-alef ligatures that most fonts render
# as a *single-cell glyph*. We collapse them to "X".
#
# Must run AFTER the ZWJ version to avoid overriding it.
$string =~ s/\x{0644}\x{0627}/X/g ; # ل + ا
$string =~ s/\x{0644}\x{0623}/X/g ; # ل + أ
$string =~ s/\x{0644}\x{0625}/X/g ; # ل + إ
$string =~ s/\x{0644}\x{0622}/X/g ; # ل + آ

# single word ligature
$string =~ s/[\x{FB50}-\x{FDFF}]/X/g;

# FINAL WIDTH CALCULATION
#
# After:
#   - collapsing multi-letter ligatures into X or XX
#   - removing Mn
#
# the string now accurately reflects the *visual* width that
# your terminal/font will display.
#
# Unicode::GCString->columns can now compute the width correctly.
return $string ;
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

sub get_keyboard_layout_from_name
{
my ($keyboard_layout_name) = @_ ; 

no warnings 'qw' ;

my %keyboard_layouts =
	(
	US_QWERTY => 
		{
		keys => [qw(
				~ ! @ # $ % ^ & * ( ) _ +
				` 1 2 3 4 5 6 7 8 9 0 - =
				Q W E R T Y U I O P { } |
				q w e r t y u i o p [ ] \
				A S D F G H J K L : "
				a s d f g h j k l ; '
				Z X C V B N M < > ?
				z x c v b n m , . /
			)],
		
		layout => <<END ,
┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───────┐
│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│BS     │
│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│       │
├───┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─────┤
│ Tab │*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s  │
│     │*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s  │
├─────┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴─────┤
│  CL  │*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│ Enter  │
│      │*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│        │
├──────┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴────────┤
│  Shift  │*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│  Shift  │
│         │*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│         │
└─────────┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴─────────┘
END
		},
	SWE_QWERTY => 
		{
		keys => [qw(
				½ ! " # ¤ % & / ( ) = ? `
				§ 1 2 3 4 5 6 7 8 9 0 + ´
				    @ £ $ €   { [ ] } \
				Q W E R T Y U I O P Å ^ 
				q w e r t y u i o p å ¨ ~
				A S D F G H J K L Ö Ä '
				a s d f g h j k l ö ä *
				> Z X C V B N M , . - 
				< z x c v b n m ; : _
				|             µ
			)],
		
		layout => <<'END',
┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬─────────┐
│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│         │
│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│BS       │
│   │   │*%s│*%s│*%s│*%s│   │*%s│*%s│*%s│*%s│*%s│   │         │
├───┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─────┬───┤
│ Tab │*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s    │   │
│     │*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s *%s│   │
├─────┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬───┬─┘   │
│  CL   │*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│Enter│
│       │*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│     │
├─────┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴───┴─────┤
│Shift│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│  Shift    │
│     │*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│           │
└─────┤*%s├───┴───┴───┴───┴───┴───┤*%s├───┴───┴───┴───────────┘
      └───┘                       └───┘               
END
		},
	) ;

if (exists $keyboard_layouts{$keyboard_layout_name})
	{
	return $keyboard_layouts{$keyboard_layout_name} ;
	}
else
	{
	die "Unknown keyboard layout name: $keyboard_layout_name" ;
	}
}

#-----------------------------------------------------------------------------

sub get_keyboard_layout
{
my ($keyboard_char_map, $keyboard_layout_name) = @_ ;

my $keyboard_layout = get_keyboard_layout_from_name($keyboard_layout_name) ;

my $keyboard_keys = $keyboard_layout->{keys} ;
my $keyboard_layout_template = $keyboard_layout->{layout} ;

my @keyboard_keys_values = 
	map 
		{
		my $key         = $_ ;
		my $char        = $keyboard_char_map->{$key} // '' ;
		my $unicode_len = unicode_display_width($char);
		my $mapped      = $unicode_len == 2 ? $char : $unicode_len == 1 ? " $char" : "  $char" ;
		
		($key, $mapped) ;
		} @$keyboard_keys ;

$keyboard_layout_template =~ s/\*/%s/g ;

return sprintf($keyboard_layout_template, @keyboard_keys_values) ;
}

#----------------------------------------------------------------------------------------------

sub normalize_file_name
{
my ($file_name) = @_;
return undef unless defined $file_name ;

my $normalized ;

# try UTF-8 decoding
eval { $normalized = decode('UTF-8', $file_name, FB_CROAK) ; 1 ; } and return $normalized ;

# try CP936/GBK decoding
eval { $normalized = decode('cp936', $file_name) ; 1 ; } and return $normalized ;

return $file_name ;
}

#-----------------------------------------------------------------------------

1 ;
