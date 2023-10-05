
package App::Asciio::Cross ;

$|++ ;

use strict;
use warnings;
use utf8;

use Clone;

use List::Util qw(first) ;
use List::MoreUtils qw(any) ;

use App::Asciio::String ;
use App::Asciio::Markup ;


sub get_ascii_array_and_crossings
{
my ($asciio, $cross_filler_chars, $start_x, $end_x, $start_y, $end_y)  = @_ ;

my (@lines, @cross_point_index) ;

for my $element (@{$asciio->{ELEMENTS}})
	{
	next if any { $_ eq ref($element) } @{$asciio->{CROSS_MODE_IGNORE}} ;
	
	for my $strip (@{$element->get_stripes()})
		{
		my $line_index = -1 ;
		
		for my $sub_strip (split("\n", $strip->{TEXT}))
			{
			$line_index++ ;
			
			my $y = $element->{Y} + $strip->{Y_OFFSET} + $line_index ;
			
			next if defined $start_y && ($y < $start_y || $y >= $end_y) ;
			
			$sub_strip = $USE_MARKUP_CLASS->delete_markup_characters($sub_strip) ;
			
			my $character_index = 0 ;
			
			for my $character (split '', $sub_strip)
				{
				my $x =  $element->{X} + $strip->{X_OFFSET} + $character_index ;
				
				if((defined $start_x) && ($x < $start_x || $x >= $end_x))
					{
					# skip
					}
				elsif($x >= 0 && $y >= 0)
					{
					# keep the characters that may be crossing in the array 
					# other characters are discarded
					if(exists $cross_filler_chars->{$character})
						{
						if(defined $lines[$y][$x])
							{
							push @{$lines[$y][$x]}, $character ;
							
							push @cross_point_index, [$y, $x] ;
							}
						else
							{
							$lines[$y][$x] = [$character] ;
							}
						
						}
					else
						{
						delete $lines[$y][$x] ;
						}
					}
				
				$character_index += unicode_length($character);
				}
			}
		}
	}

@cross_point_index = grep { defined $lines[$_->[0]][$_->[1]][1] } @cross_point_index ;

return(\@lines, \@cross_point_index) ;
}

#-----------------------------------------------------------------------------
# ascii: + X . '
# unicode: ┼ ┤ ├ ┬ ┴ ╭ ╮ ╯ ╰ ╳ ... ...

use Readonly ;
Readonly my $CHARACTER            => 0 ;
Readonly my $FUNCTION             => 1 ;
Readonly my $CHAR_CATEGORY_INDEXS => 2 ;

{

my ($undef_char, %normal_char_cache, %diagonal_char_cache) = ('w') ;

my %all_cross_chars = map {$_, 1} 
			( 
			'-', '|', '.', '\'', '\\', '/', '+', '╱', '╲', '╳',
			'─', '│', '┼', '┤', '├', '┬', '┴', '╭', '╮', '╯', '╰',
			'━', '┃', '╋', '┫', '┣', '┳', '┻', '┏', '┓', '┛', '┗', 
			'═', '║', '╬', '╣', '╠', '╦', '╩', '╔', '╗', '╝', '╚',
			'╫', '╪', '╨', '╧', '╥', '╤', '╢', '╡', '╟', '╞', '╜', 
			'╛', '╙', '╘', '╖', '╕', '╓', '╒', '<', '>', '^', 'v',
			'┍', '┎', '┑', '┒', '┕', '┖', '┙', '┚',
			'┝', '┞', '┟', '┠', '┡', '┢',
			'┥', '┦', '┧', '┨', '┩', '┪',
			'┭', '┮', '┯', '┰', '┱', '┲',
			'┵', '┶', '┷', '┸', '┹', '┺',
			'┽', '┾', '┿', '╀', '╁', '╂', '╃',
			'╄', '╅', '╆', '╇', '╈', '╉', '╊',
			) ;

my %diagonal_cross_chars = map {$_, 1} ('\\', '/', '╱', '╲', '╳') ;

my %unicode_left_thin_chars    = map {$_, 1} ('─', '┼', '├', '┬', '┴', '╭', '╰', '╫', '╨', '╥', '╟', '╙', '╓', '┎', '┖', '┞', '┟', '┠', '┭', '┰', '┱', '┵', '┸', '┹', '┽', '╀', '╁', '╂', '╃', '╅', '╉') ;
my %unicode_right_thin_chars   = map {$_, 1} ('─', '┼', '┤', '┬', '┴', '╮', '╯', '╫', '╨', '╥', '╢', '╜', '╖', '┒', '┚', '┦', '┧', '┨', '┮', '┰', '┲', '┶', '┸', '┺', '┾', '╀', '╁', '╂', '╄', '╆', '╊') ;
my %unicode_up_thin_chars      = map {$_, 1} ('│', '┼', '┤', '├', '┬', '╭', '╮', '╪', '╤', '╡', '╞', '╕', '╒', '┍', '┑', '┝', '┞', '┡', '┥', '┦', '┩', '┭', '┮', '┯', '┽', '┾', '┿', '╀', '╃', '╄', '╇') ;
my %unicode_down_thin_chars    = map {$_, 1} ('│', '┼', '┤', '├', '┴', '╯', '╰', '╪', '╧', '╡', '╞', '╛', '╘', '┕', '┙', '┝', '┟', '┢', '┥', '┧', '┪', '┵', '┶', '┷', '┽', '┾', '┿', '╁', '╅', '╆', '╈') ;

my %unicode_left_double_chars  = map {$_, 1} ('═', '╬', '╠', '╦', '╩', '╔', '╚', '╪', '╧', '╤', '╞', '╘', '╒') ;
my %unicode_right_double_chars = map {$_, 1} ('═', '╬', '╣', '╦', '╩', '╗', '╝', '╪', '╧', '╤', '╡', '╛', '╕') ;
my %unicode_up_double_chars    = map {$_, 1} ('║', '╬', '╣', '╠', '╦', '╔', '╗', '╫', '╥', '╢', '╟', '╖', '╓') ;
my %unicode_down_double_chars  = map {$_, 1} ('║', '╬', '╣', '╠', '╩', '╝', '╚', '╫', '╨', '╢', '╟', '╜', '╙') ;

my %unicode_left_bold_chars    = map {$_, 1} ('━', '╋', '┣', '┳', '┻', '┏', '┗', '┍', '┕', '┝', '┡', '┢', '┮', '┯', '┲', '┶', '┷', '┺', '┾', '┿', '╄', '╆', '╇', '╈', '╊') ;
my %unicode_right_bold_chars   = map {$_, 1} ('━', '╋', '┫', '┳', '┻', '┓', '┛', '┑', '┙', '┥', '┩', '┪', '┭', '┯', '┱', '┵', '┷', '┹', '┽', '┿', '╃', '╅', '╇', '╈', '╉') ;
my %unicode_up_bold_chars      = map {$_, 1} ('┃', '╋', '┫', '┣', '┳', '┏', '┓', '┎', '┒', '┟', '┠', '┢', '┧', '┨', '┪', '┰', '┱', '┲', '╁', '╂', '╅', '╆', '╈', '╉', '╊') ;
my %unicode_down_bold_chars    = map {$_, 1} ('┃', '╋', '┫', '┣', '┻', '┛', '┗', '┖', '┚', '┞', '┠', '┡', '┦', '┨', '┩', '┸', '┹', '┺', '╀', '╂', '╃', '╄', '╇', '╉', '╊') ;

my @unicode_cross_chars = (
	{%unicode_left_thin_chars}  , {%unicode_left_double_chars}  , {%unicode_left_bold_chars}  ,
	{%unicode_right_thin_chars} , {%unicode_right_double_chars} , {%unicode_right_bold_chars} ,
	{%unicode_up_thin_chars}    , {%unicode_up_double_chars}    , {%unicode_up_bold_chars}    ,
	{%unicode_down_thin_chars}  , {%unicode_down_double_chars}  , {%unicode_down_bold_chars}
);

# The index here has a one-to-one correspondence with the array unicode_cross_chars.
my $left_thin_index    = 0;
my $left_double_index  = 1;
my $left_bold_index    = 2;
my $right_thin_index   = 3;
my $right_double_index = 4;
my $right_bold_index   = 5;
my $up_thin_index      = 6;
my $up_double_index    = 7;
my $up_bold_index      = 8;
my $down_thin_index    = 9;
my $down_double_index  = 10;
my $down_bold_index    = 11;

my %left_index_map  = map {$_ , 1} ($left_thin_index  , $left_double_index  , $left_bold_index) ;
my %right_index_map = map {$_ , 1} ($right_thin_index , $right_double_index , $right_bold_index) ;
my %up_index_map    = map {$_ , 1} ($up_thin_index    , $up_double_index    , $up_bold_index) ;
my %down_index_map  = map {$_ , 1} ($down_thin_index  , $down_double_index  , $down_bold_index) ;

my @normal_char_func = (
	['+', \&scene_cross,                                           ],
	['.', \&scene_dot,                                             ],
	['\'',\&scene_apostrophe,                                      ],
	
	# Arranging them in order can reduce logical judgment. Because calculations are done sequentially
	# 1. First are cross, 
	# 2. then are corner missing
	# 3. and finally are two corners missing.
	# Therefore, the order of functions in the array cannot be disrupted
	
	# cross functios
	['┽' , \&scene_unicode , [$left_bold_index   , $right_thin_index   , $up_thin_index   , $down_thin_index   ]],
	['┾' , \&scene_unicode , [$left_thin_index   , $right_bold_index   , $up_thin_index   , $down_thin_index   ]],
	['┿' , \&scene_unicode , [$left_bold_index   , $right_bold_index   , $up_thin_index   , $down_thin_index   ]],
	['╀' , \&scene_unicode , [$left_thin_index   , $right_thin_index   , $up_bold_index   , $down_thin_index   ]],
	['╁' , \&scene_unicode , [$left_thin_index   , $right_thin_index   , $up_thin_index   , $down_bold_index   ]],
	['╂' , \&scene_unicode , [$left_thin_index   , $right_thin_index   , $up_bold_index   , $down_bold_index   ]],
	['╃' , \&scene_unicode , [$left_bold_index   , $right_thin_index   , $up_bold_index   , $down_thin_index   ]],
	['╄' , \&scene_unicode , [$left_thin_index   , $right_bold_index   , $up_bold_index   , $down_thin_index   ]],
	['╅' , \&scene_unicode , [$left_bold_index   , $right_thin_index   , $up_thin_index   , $down_bold_index   ]],
	['╆' , \&scene_unicode , [$left_thin_index   , $right_bold_index   , $up_thin_index   , $down_bold_index   ]],
	['╇' , \&scene_unicode , [$left_bold_index   , $right_bold_index   , $up_bold_index   , $down_thin_index   ]],
	['╈' , \&scene_unicode , [$left_bold_index   , $right_bold_index   , $up_thin_index   , $down_bold_index   ]],
	['╉' , \&scene_unicode , [$left_bold_index   , $right_thin_index   , $up_bold_index   , $down_bold_index   ]],
	['╊' , \&scene_unicode , [$left_thin_index   , $right_bold_index   , $up_bold_index   , $down_bold_index   ]],
	['╫' , \&scene_unicode , [$left_thin_index   , $right_thin_index   , $up_double_index , $down_double_index ]],
	['╪' , \&scene_unicode , [$left_double_index , $right_double_index , $up_thin_index   , $down_thin_index   ]],
	['┼' , \&scene_unicode , [$left_thin_index   , $right_thin_index   , $up_thin_index   , $down_thin_index   ]],
	['╋' , \&scene_unicode , [$left_bold_index   , $right_bold_index   , $up_bold_index   , $down_bold_index   ]],
	['╬' , \&scene_unicode , [$left_double_index , $right_double_index , $up_double_index , $down_double_index ]],

	# one corner missing functios
	['┵' , \&scene_unicode , [$left_bold_index    , $right_thin_index   , $up_thin_index     ]],
	['┶' , \&scene_unicode , [$left_thin_index    , $right_bold_index   , $up_thin_index     ]],
	['┷' , \&scene_unicode , [$left_bold_index    , $right_bold_index   , $up_thin_index     ]],
	['┸' , \&scene_unicode , [$left_thin_index    , $right_thin_index   , $up_bold_index     ]],
	['┹' , \&scene_unicode , [$left_bold_index    , $right_thin_index   , $up_bold_index     ]],
	['┺' , \&scene_unicode , [$left_thin_index    , $right_bold_index   , $up_bold_index     ]],
	['┭' , \&scene_unicode , [$left_bold_index    , $right_thin_index   , $down_thin_index   ]],
	['┮' , \&scene_unicode , [$left_thin_index    , $right_bold_index   , $down_thin_index   ]],
	['┯' , \&scene_unicode , [$left_bold_index    , $right_bold_index   , $down_thin_index   ]],
	['┰' , \&scene_unicode , [$left_thin_index    , $right_thin_index   , $down_bold_index   ]],
	['┱' , \&scene_unicode , [$left_bold_index    , $right_thin_index   , $down_bold_index   ]],
	['┲' , \&scene_unicode , [$left_thin_index    , $right_bold_index   , $down_bold_index   ]],
	['┥' , \&scene_unicode , [$left_bold_index    , $up_thin_index      , $down_thin_index   ]],
	['┦' , \&scene_unicode , [$left_thin_index    , $up_bold_index      , $down_thin_index   ]],
	['┧' , \&scene_unicode , [$left_thin_index    , $up_thin_index      , $down_bold_index   ]],
	['┨' , \&scene_unicode , [$left_thin_index    , $up_bold_index      , $down_bold_index   ]],
	['┩' , \&scene_unicode , [$left_bold_index    , $up_bold_index      , $down_thin_index   ]],
	['┪' , \&scene_unicode , [$left_bold_index    , $up_thin_index      , $down_bold_index   ]],
	['┝' , \&scene_unicode , [$right_bold_index   , $up_thin_index      , $down_thin_index   ]],
	['┞' , \&scene_unicode , [$right_thin_index   , $up_bold_index      , $down_thin_index   ]],
	['┟' , \&scene_unicode , [$right_thin_index   , $up_thin_index      , $down_bold_index   ]],
	['┠' , \&scene_unicode , [$right_thin_index   , $up_bold_index      , $down_bold_index   ]],
	['┡' , \&scene_unicode , [$right_bold_index   , $up_bold_index      , $down_thin_index   ]],
	['┢' , \&scene_unicode , [$right_bold_index   , $up_thin_index      , $down_bold_index   ]],
	['╨' , \&scene_unicode , [$left_thin_index    , $right_thin_index   , $up_double_index   ]],
	['╧' , \&scene_unicode , [$left_double_index  , $right_double_index , $up_thin_index     ]],
	['╥' , \&scene_unicode , [$left_thin_index    , $right_thin_index   , $down_double_index ]],
	['╤' , \&scene_unicode , [$left_double_index  , $right_double_index , $down_thin_index   ]],
	['╢' , \&scene_unicode , [$left_thin_index    , $up_double_index    , $down_double_index ]],
	['╡' , \&scene_unicode , [$left_double_index  , $up_thin_index      , $down_thin_index   ]],
	['╟' , \&scene_unicode , [$right_thin_index   , $up_double_index    , $down_double_index ]],
	['╞' , \&scene_unicode , [$right_double_index , $up_thin_index      , $down_thin_index   ]],
	['┤' , \&scene_unicode , [$left_thin_index    , $up_thin_index      , $down_thin_index   ]],
	['├' , \&scene_unicode , [$right_thin_index   , $up_thin_index      , $down_thin_index   ]],
	['┬' , \&scene_unicode , [$left_thin_index    , $right_thin_index   , $down_thin_index   ]],
	['┴' , \&scene_unicode , [$left_thin_index    , $right_thin_index   , $up_thin_index     ]],
	['┫' , \&scene_unicode , [$left_bold_index    , $up_bold_index      , $down_bold_index   ]],
	['┣' , \&scene_unicode , [$right_bold_index   , $up_bold_index      , $down_bold_index   ]],
	['┳' , \&scene_unicode , [$left_bold_index    , $right_bold_index   , $down_bold_index   ]],
	['┻' , \&scene_unicode , [$left_bold_index    , $right_bold_index   , $up_bold_index     ]],
	['╣' , \&scene_unicode , [$left_double_index  , $up_double_index    , $down_double_index ]],
	['╠' , \&scene_unicode , [$right_double_index , $up_double_index    , $down_double_index ]],
	['╦' , \&scene_unicode , [$left_double_index  , $right_double_index , $down_double_index ]],
	['╩' , \&scene_unicode , [$left_double_index  , $right_double_index , $up_double_index   ]],

	# two corners missing
	['╜' , \&scene_unicode , [$left_thin_index    , $up_double_index   ]],
	['╛' , \&scene_unicode , [$left_double_index  , $up_thin_index     ]],
	['╙' , \&scene_unicode , [$right_thin_index   , $up_double_index   ]],
	['╘' , \&scene_unicode , [$right_double_index , $up_thin_index     ]],
	['╖' , \&scene_unicode , [$left_thin_index    , $down_double_index  ]],
	['╕' , \&scene_unicode , [$left_double_index  , $down_thin_index   ]],
	['╓' , \&scene_unicode , [$right_thin_index   , $down_double_index ]],
	['╒' , \&scene_unicode , [$right_double_index , $down_thin_index   ]],
	['┍' , \&scene_unicode , [$right_bold_index   , $down_thin_index   ]],
	['┎' , \&scene_unicode , [$right_thin_index   , $down_bold_index   ]],
	['┑' , \&scene_unicode , [$left_bold_index    , $down_thin_index   ]],
	['┒' , \&scene_unicode , [$left_thin_index    , $down_bold_index   ]],
	['┕' , \&scene_unicode , [$right_bold_index   , $up_thin_index     ]],
	['┖' , \&scene_unicode , [$right_thin_index   , $up_bold_index     ]],
	['┙' , \&scene_unicode , [$left_bold_index    , $up_thin_index     ]],
	['┚' , \&scene_unicode , [$left_thin_index    , $up_bold_index     ]],
	['╭' , \&scene_unicode , [$right_thin_index   , $down_thin_index   ]],
	['╮' , \&scene_unicode , [$left_thin_index    , $down_thin_index   ]],
	['╯' , \&scene_unicode , [$left_thin_index    , $up_thin_index     ]],
	['╰' , \&scene_unicode , [$right_thin_index   , $up_thin_index     ]],
	['┏' , \&scene_unicode , [$right_bold_index   , $down_bold_index   ]],
	['┓' , \&scene_unicode , [$left_bold_index    , $down_bold_index   ]],
	['┛' , \&scene_unicode , [$left_bold_index    , $up_bold_index     ]],
	['┗' , \&scene_unicode , [$right_bold_index   , $up_bold_index     ]],
	['╔' , \&scene_unicode , [$right_double_index , $down_double_index ]],
	['╗' , \&scene_unicode , [$left_double_index  , $down_double_index ]],
	['╝' , \&scene_unicode , [$left_double_index  , $up_double_index   ]],
	['╚' , \&scene_unicode , [$right_double_index , $up_double_index   ]],
) ;

my @diagonal_char_func = (
	['X', \&scene_x],
	['╳', \&scene_unicode_x],
) ;


sub get_cross_mode_overlays
{
my ($asciio, $start_x, $end_x, $start_y, $end_y) = @_;

my ($ascii_array, $crossings) = get_ascii_array_and_crossings($asciio, \%all_cross_chars, $start_x, $end_x, $start_y, $end_y);
my @ascii_array = @{$ascii_array} ;

my @overlays ;

for(@{$crossings})
	{
	my ($row, $col) = @{$_} ;
	
	my ($up,                        $down,                      $left,                      $right) = 
	   ($ascii_array[$row-1][$col], $ascii_array[$row+1][$col], $ascii_array[$row][$col-1], $ascii_array[$row][$col+1]);
	
	my $normal_key = ((defined $up) ? join('o', @{$up}) : $undef_char) . '_' 
			. ((defined $down) ? join('o', @{$down}) : $undef_char) . '_' 
			. ((defined $left) ? join('o', @{$left}) : $undef_char) . '_' 
			. ((defined $right) ? join('o', @{$right}) : $undef_char) ;
	
	unless(exists $normal_char_cache{$normal_key})
		{
		my $scene_func = first { $_->[$FUNCTION]($up, $down, $left, $right, $_->[$CHAR_CATEGORY_INDEXS]) } @normal_char_func;
		$normal_char_cache{$normal_key} = ($scene_func) ? $scene_func->[$CHARACTER] : '';
		}
	
	if($normal_char_cache{$normal_key})
		{
		if($normal_char_cache{$normal_key} ne $ascii_array[$row][$col][-1])
			{
			push @overlays, [$col, $row, $normal_char_cache{$normal_key}];
			}

		next;
		}
	
	next unless exists $diagonal_cross_chars{$ascii_array[$row][$col][-1]} ;
	
	my ($char_45,                     $char_135,                    $char_225,                    $char_315) = 
	   ($ascii_array[$row-1][$col+1], $ascii_array[$row+1][$col+1], $ascii_array[$row+1][$col-1], $ascii_array[$row-1][$col-1]);
	
	my $diagonal_key = ((defined $char_45) ? join('o', @{$char_45}) : $undef_char) . '_' 
				. ((defined $char_135) ? join('o', @{$char_135}) : $undef_char) . '_' 
				. ((defined $char_225) ? join('o', @{$char_225}) : $undef_char) . '_' 
				. ((defined $char_315) ? join('o', @{$char_315}) : $undef_char) ;
	
	unless(exists $diagonal_char_cache{$diagonal_key})
		{
		my $scene_func = first { $_->[$FUNCTION]($char_45, $char_135, $char_225, $char_315) } @diagonal_char_func;
		$diagonal_char_cache{$diagonal_key} = ($scene_func) ? $scene_func->[$CHARACTER] : '';
		}
	
	if($diagonal_char_cache{$diagonal_key} && ($diagonal_char_cache{$diagonal_key} ne $ascii_array[$row][$col][-1]))
		{
		push @overlays, [$col, $row, $diagonal_char_cache{$diagonal_key}];
		}

	}

return @overlays ;
}

#-----------------------------------------------------------------------------
# +
sub scene_cross
{
my ($up, $down, $left, $right, $char_category_indexs) = @_;

return 0 unless defined $up && defined $down && defined $left && defined $right ;

return ((any {$_ eq '|'} @{$up}) || (any {$_ eq '.'} @{$up}) || (any {$_ eq '\''} @{$up}) || (any {$_ eq '+'} @{$up}) || (any {$_ eq '^'} @{$up}))
	&& ((any {$_ eq '|'} @{$down}) || (any {$_ eq '.'} @{$down}) || (any {$_ eq '\''} @{$down}) || (any {$_ eq '+'} @{$down}) || (any {$_ eq 'v'} @{$down}))
	&& ((any {$_ eq '-'} @{$left}) || (any {$_ eq '.'} @{$left}) || (any {$_ eq '\''} @{$left}) || (any {$_ eq '+'} @{$left}) || (any {$_ eq '<'} @{$left}))
	&& ((any {$_ eq '-'} @{$right}) || (any {$_ eq '.'} @{$right}) || (any {$_ eq '\''} @{$right}) || (any {$_ eq '+'} @{$right}) || (any {$_ eq '>'} @{$right})) ;
}

#-----------------------------------------------------------------------------
# .
#                              |   |
#         ---.  .---  ---.---  |   |
#            |  |        |  ---.   .---
#            |  |        |     |   |
sub scene_dot
{
my ($up, $down, $left, $right, $char_category_indexs) = @_;

return 0 if defined $up && (any {$_ eq '|'} @{$up})
		&& defined $down && (any {$_ eq '|'} @{$down})
		&& defined $left && (any {$_ eq '-'} @{$left})
		&& defined $right && (any {$_ eq '-'} @{$right}) ;

return (((defined($left) && (any {$_ eq '-'} @{$left})) && (defined($down) && (any {$_ eq '|'} @{$down}))) || 
	   ((defined($right) && (any {$_ eq '-'} @{$right})) && (defined($down) && (any {$_ eq '|'} @{$down})))) ;
}

#-----------------------------------------------------------------------------
# '
#       |          |       |
#       |          |       |
#       '---    ---'    ---'---
sub scene_apostrophe
{
my ($up, $down, $left, $right, $char_category_indexs) = @_;

return 1 if(((defined($up) && (any {$_ eq '|'} @{$up})) && (defined($right) && (any {$_ eq '-'} @{$right}))) && 
			!(defined($down) && (any {$_ eq '|'} @{$down}))) ;

return ((defined($up) && (any {$_ eq '|'} @{$up})) && (defined($left) && (any {$_ eq '-'} @{$left})) && 
		!((defined($down) && (any {$_ eq '|'} @{$down})) || (defined($right) && (any {$_ eq '|'} @{$right})))) ;

}

sub scene_unicode
{
my ($up, $down, $left, $right, $char_category_indexs) = @_;

for my $char_index (@{$char_category_indexs})
	{
	if(exists $left_index_map{$char_index})
		{
		return 0 unless defined $left;
		return 0 unless any {exists $unicode_cross_chars[$char_index]{$_}} @{$left};
		}
	elsif(exists $right_index_map{$char_index})
		{
		return 0 unless defined $right;
		return 0 unless any {exists $unicode_cross_chars[$char_index]{$_}} @{$right};
		}
	elsif(exists $up_index_map{$char_index})
		{
		return 0 unless defined $up;
		return 0 unless any {exists $unicode_cross_chars[$char_index]{$_}} @{$up};
		}
	else
		{
		return 0 unless defined $down;
		return 0 unless any {exists $unicode_cross_chars[$char_index]{$_}} @{$down};
		}
	}

return 1;

}

#-----------------------------------------------------------------------------
# X
sub scene_x
{
my ($char_45, $char_135, $char_225, $char_315) = @_;

return 0 unless defined $char_45 && defined $char_135 && defined $char_225 && defined $char_315 ;

return (any {$_ eq '/' || $_ eq '^'} @{$char_45})
	&& (any {$_ eq '\\' || $_ eq 'v'} @{$char_135})
	&& (any {$_ eq '/' || $_ eq 'v'} @{$char_225})
	&& (any {$_ eq '\\' || $_ eq '^'} @{$char_315}) ;
}

#-----------------------------------------------------------------------------
# ╳
sub scene_unicode_x
{
my ($char_45, $char_135, $char_225, $char_315) = @_;

return 0 unless defined $char_45 && defined $char_135 && defined $char_225 && defined $char_315 ;

return (any {$_ eq '╱' || $_ eq '^'} @{$char_45})
	&& (any {$_ eq '╲' || $_ eq 'v'} @{$char_135})
	&& (any {$_ eq '╱' || $_ eq 'v'} @{$char_225})
	&& (any {$_ eq '╲' || $_ eq '^'} @{$char_315}) ;
}

}

#-----------------------------------------------------------------------------

1 ;

