
package App::Asciio::Cross ;

$|++ ;

use strict;
use warnings;
use utf8;

use Clone;

use List::Util qw(first) ;
use List::MoreUtils qw(any) ;
use App::Asciio::Toolfunc ;

#-----------------------------------------------------------------------------

sub transform_elements_to_ascii_array_for_cross_overlay
{
my ($self, $asciio, $cross_filler_chars, $start_x, $end_x, $start_y, $end_y)  = @_ ;

my (@lines, @cross_point_index, %cross_point_index_hash, $cross_point) ;

for my $element (@{$asciio->{ELEMENTS}})
	{
	next if(any {$_ eq ref($element)} @{$asciio->{CROSS_MODE_IGNORE}}) ;

	for my $strip (@{$element->get_stripes()})
		{
		my $line_index = 0 ;

		for my $sub_strip (split("\n", $strip->{TEXT}))
			{
			my $y =  $element->{Y} + $strip->{Y_OFFSET} + $line_index ;
			if((defined $start_y) && ($y < $start_y || $y >= $end_y))
				{
				$line_index++ ;
				next ;
				}

			if($asciio->{USE_MARKUP_MODE})
			{
				$sub_strip =~ s/(<[bius]>)+([^<]+)(<\/[bius]>)+/$2/g ;
				$sub_strip =~ s/<span link="[^<]+">([^<]+)<\/span>/$1/g ;
			}

			my $character_index = 0 ;
			
			for my $character (split '', $sub_strip)
				{
				my $x =  $element->{X} + $strip->{X_OFFSET} + $character_index ;
				if((defined $start_x) && ($x < $start_x || $x >= $end_x))
					{
					$character_index += usc_length($character);
					next ;
					}
				
				if($x >= 0 && $y >= 0)
					{
					$cross_point = $y . '-' . $x ;

					# The characters retained in the array are characters that may be crossing, 
					# and other characters are discarded
					if(exists $cross_filler_chars->{$character})
						{
						if(defined $lines[$y][$x])
							{
							push @{$lines[$y][$x]}, $character ;
							}
						else
							{
							$lines[$y][$x] = [$character] ;
							}
						}
					else
						{
						delete $lines[$y][$x] if(defined $lines[$y][$x]) ;
						}
					
					# The cross point is the number of array elements greater than 1
					if((defined $lines[$y][$x]) && (scalar @{$lines[$y][$x]} > 1))
						{
						$cross_point_index_hash{$cross_point} = 1 ;
						}
					else
						{
						delete $cross_point_index_hash{$cross_point} if(defined $cross_point_index_hash{$cross_point}) ;
						}
					}
				$character_index += usc_length($character);
				}
			
			$line_index++ ;
			}
		}
	}

for(keys %cross_point_index_hash)
	{
	push @cross_point_index, [map {int} split('-', $_)] ;
	}

return(\@lines, \@cross_point_index) ;
}

#-----------------------------------------------------------------------------
# ascii: + X . '
# unicode: ┼ ┤ ├ ┬ ┴ ╭ ╮ ╯ ╰ ╳ 
# todo: 1. performance problem

{

my ($undef_char, %normal_char_cache, %diagonal_char_cache) = ('w') ;

my @normal_char_func = (
	['+', \&scene_cross,      0],
	['.', \&scene_dot,        0],
	['\'',\&scene_apostrophe, 0],
	
	# todo: bold thin mix 45 chars
	#       such as: ┮ ┪ ┪ ┡ ... ...
	#       Due to the low degree of recognition, 
	#       it will not be implemented for the time 
	#       being, but it is enough for now
	# double thin mix filler
	# Naming rules: first horizontal and then vertical
	['╫', \&scene_unicode_mix_cross_thin_double,            0],
	['╪', \&scene_unicode_mix_cross_double_thin,            0],
	['╨', \&scene_unicode_mix_cross_lose_down_thin_double,  0],
	['╧', \&scene_unicode_mix_cross_lose_down_double_thin,  0],
	['╥', \&scene_unicode_mix_cross_lose_up_thin_double,    0],
	['╤', \&scene_unicode_mix_cross_lose_up_double_thin,    0],
	['╢', \&scene_unicode_mix_cross_lose_right_thin_double, 0],
	['╡', \&scene_unicode_mix_cross_lose_rigth_double_thin, 0],
	['╟', \&scene_unicode_mix_cross_lose_left_thin_double,  0],
	['╞', \&scene_unicode_mix_cross_lose_left_double_thin,  0],
	['╜', \&scene_unicode_mix_thin_left_double_up,          0],
	['╛', \&scene_unicode_mix_double_left_thin_up,          0],
	['╙', \&scene_unicode_mix_thin_right_double_up,         0],
	['╘', \&scene_unicode_mix_double_right_thin_up,         0],
	['╖', \&scene_unicode_mix_thin_left_double_down,        0],
	['╕', \&scene_unicode_mix_double_left_thin_down,        0],
	['╓', \&scene_unicode_mix_thin_right_double_down,       0],
	['╒', \&scene_unicode_mix_double_right_thin_down,       0],

	# pure filler
	['┼', \&scene_unicode_cross,             0],
	['┤', \&scene_unicode_cross_lose_right,  0],
	['├', \&scene_unicode_cross_lose_left,   0],
	['┬', \&scene_unicode_cross_lose_up,     0],
	['┴', \&scene_unicode_cross_lose_down,   0],
	['╭', \&scene_unicode_right_down,        0],
	['╮', \&scene_unicode_left_down,         0],
	['╯', \&scene_unicode_left_up,           0],
	['╰', \&scene_unicode_right_up,          0],
	['╋', \&scene_unicode_cross,             1],
	['┫', \&scene_unicode_cross_lose_right,  1],
	['┣', \&scene_unicode_cross_lose_left,   1],
	['┳', \&scene_unicode_cross_lose_up,     1],
	['┻', \&scene_unicode_cross_lose_down,   1],
	['┏', \&scene_unicode_right_down,        1],
	['┓', \&scene_unicode_left_down,         1],
	['┛', \&scene_unicode_left_up,           1],
	['┗', \&scene_unicode_right_up,          1],
	['╬', \&scene_unicode_cross,             2],
	['╣', \&scene_unicode_cross_lose_right,  2],
	['╠', \&scene_unicode_cross_lose_left,   2],
	['╦', \&scene_unicode_cross_lose_up,     2],
	['╩', \&scene_unicode_cross_lose_down,   2],
	['╔', \&scene_unicode_right_down,        2],
	['╗', \&scene_unicode_left_down,         2],
	['╝', \&scene_unicode_left_up,           2],
	['╚', \&scene_unicode_right_up,          2],
) ;

my @diagonal_char_func = (
	['X', \&scene_x],
	['╳', \&scene_unicode_x],
) ;

my %all_cross_filler_chars = map {$_, 1} 
				( 
				'-', '|', '.', '\'', '\\', '/', '+', '╱', '╲', '╳',
				'─', '│', '┼', '┤', '├', '┬', '┴', '╭', '╮', '╯', '╰',
				'━', '┃', '╋', '┫', '┣', '┳', '┻', '┏', '┓', '┛', '┗', 
				'═', '║', '╬', '╣', '╠', '╦', '╩', '╔', '╗', '╝', '╚',
				'╫', '╪', '╨', '╧', '╥', '╤', '╢', '╡', '╟', '╞', '╜', 
				'╛', '╙', '╘', '╖', '╕', '╓', '╒', '<', '>', '^', 'v',
				) ;

my %diagonal_cross_filler_chars = map {$_, 1} ('\\', '/', '╱', '╲', '╳') ;

my %unicode_left_chars_thin        = map {$_, 1} ('─',    '┼',    '├',    '┬',    '┴',    '╭',    '╰') ;
my %unicode_left_chars_bold        = map {$_, 1} ('━',    '╋',    '┣',    '┳',    '┻',    '┏',    '┗') ;
my %unicode_left_chars_double      = map {$_, 1} ('═',    '╬',    '╠',    '╦',    '╩',    '╔',    '╚') ;
my %unicode_right_chars_thin       = map {$_, 1} ('─',    '┼', '   ┤',    '┬',    '┴',    '╮',    '╯') ;
my %unicode_right_chars_bold       = map {$_, 1} ('━',    '╋',    '┫',    '┳',    '┻',    '┓',    '┛') ;
my %unicode_right_chars_double     = map {$_, 1} ('═',    '╬',    '╣',    '╦',    '╩',    '╗',    '╝') ;
my %unicode_up_chars_thin          = map {$_, 1} ('│',    '┼',    '┤',    '├',    '┬',    '╭',    '╮') ;
my %unicode_up_chars_bold          = map {$_, 1} ('┃',    '╋',    '┫',    '┣',    '┳',    '┏',    '┓') ;
my %unicode_up_chars_double        = map {$_, 1} ('║',    '╬',    '╣',    '╠',    '╦',    '╔',    '╗') ;
my %unicode_down_chars_thin        = map {$_, 1} ('│',    '┼',    '┤',    '├',    '┴',    '╯',    '╰') ;
my %unicode_down_chars_bold        = map {$_, 1} ('┃',    '╋',    '┫',    '┣',    '┻',    '┛',    '┗') ;
my %unicode_down_chars_double      = map {$_, 1} ('║',    '╬',    '╣',    '╠',    '╩',    '╝',    '╚') ;

my %unicode_mix_left_thin_chars    = map {$_, 1} ('╫',    '╨',    '╥',    '╟',    '╙',    '╓') ;
my %unicode_mix_right_thin_chars   = map {$_, 1} ('╫',    '╨',    '╥',    '╢',    '╜',    '╖') ;
my %unicode_mix_up_thin_chars      = map {$_, 1} ('╪',    '╤',    '╡',    '╞',    '╕',    '╒') ;
my %unicode_mix_down_thin_chars    = map {$_, 1} ('╪',    '╧',    '╡',    '╞',    '╛',    '╘') ;
my %unicode_mix_left_double_chars  = map {$_, 1} ('╪',    '╧',    '╤',    '╞',    '╘',    '╒') ;
my %unicode_mix_right_double_chars = map {$_, 1} ('╪',    '╧',    '╤',    '╡',    '╛',    '╕') ;
my %unicode_mix_up_double_chars    = map {$_, 1} ('╫',    '╥',    '╢',    '╟',    '╖',    '╓') ;
my %unicode_mix_down_double_chars  = map {$_, 1} ('╫',    '╨',    '╢',    '╟',    '╜',    '╙') ;

my @unicode_left_chars  = ({%unicode_left_chars_thin},  {%unicode_left_chars_bold},  {%unicode_left_chars_double})  ;
my @unicode_right_chars = ({%unicode_right_chars_thin}, {%unicode_right_chars_bold}, {%unicode_right_chars_double}) ;
my @unicode_up_chars    = ({%unicode_up_chars_thin},    {%unicode_up_chars_bold},    {%unicode_up_chars_double})    ;
my @unicode_down_chars  = ({%unicode_down_chars_thin},  {%unicode_down_chars_bold},  {%unicode_down_chars_double})  ;

sub get_cross_mode_overlays
{
my ($self, $asciio, $start_x, $end_x, $start_y, $end_y) = @_;

my ($ascii_array_ref, @ascii_array, $index_ref);

#~ this sub is slow
($ascii_array_ref, $index_ref) = $self->transform_elements_to_ascii_array_for_cross_overlay($asciio, \%all_cross_filler_chars, $start_x, $end_x, $start_y, $end_y);
@ascii_array = @{$ascii_array_ref} ;

# use Data::TreeDumper ;
# print DumpTree [$ascii_array_ref, $index_ref] ;

my ($row, $col, $scene_func, @elements_to_be_add) ;
my ($up, $down, $left, $right, $char_45, $char_135, $char_225, $char_315, $normal_key, $diagonal_key);
for(@{$index_ref})
	{
	($row, $col) = ($_->[0], $_->[1]) ;
	
	($up, $down, $left, $right) = ($ascii_array[$row-1][$col], $ascii_array[$row+1][$col], $ascii_array[$row][$col-1], $ascii_array[$row][$col+1]);
	
	$normal_key = ((defined $up) ? join('o', @{$up}) : $undef_char) . '_' 
		. ((defined $down) ? join('o', @{$down}) : $undef_char) . '_' 
		. ((defined $left) ? join('o', @{$left}) : $undef_char) . '_' 
		. ((defined $right) ? join('o', @{$right}) : $undef_char) ;
	
	unless(exists($normal_char_cache{$normal_key}))
		{
		$scene_func = first { $_->[1]($up, $down, $left, $right, $_->[2]) } @normal_char_func;
		$normal_char_cache{$normal_key} = ($scene_func) ? $scene_func->[0] : '';
		}
	
	if($normal_char_cache{$normal_key})
		{
		if($normal_char_cache{$normal_key} ne $ascii_array[$row][$col][-1])
		{
		push @elements_to_be_add, [$col, $row, $normal_char_cache{$normal_key}];
		}
		
		next;
		}
	
	next unless(exists $diagonal_cross_filler_chars{$ascii_array[$row][$col][-1]}) ;
	
	($char_45, $char_135, $char_225, $char_315) = ($ascii_array[$row-1][$col+1], $ascii_array[$row+1][$col+1], $ascii_array[$row+1][$col-1], $ascii_array[$row-1][$col-1]);
	
	$diagonal_key = ((defined $char_45) ? join('o', @{$char_45}) : $undef_char) . '_' 
		. ((defined $char_135) ? join('o', @{$char_135}) : $undef_char) . '_' 
		. ((defined $char_225) ? join('o', @{$char_225}) : $undef_char) . '_' 
		. ((defined $char_315) ? join('o', @{$char_315}) : $undef_char) ;
	
	unless(exists($diagonal_char_cache{$diagonal_key}))
		{
		$scene_func = first { $_->[1]($char_45, $char_135, $char_225, $char_315) } @diagonal_char_func;
		$diagonal_char_cache{$diagonal_key} = ($scene_func) ? $scene_func->[0] : '';
		}
	
	if($diagonal_char_cache{$diagonal_key} && ($diagonal_char_cache{$diagonal_key} ne $ascii_array[$row][$col][-1]))
		{
		push @elements_to_be_add, [$col, $row, $diagonal_char_cache{$diagonal_key}];
		}
	}

return @elements_to_be_add ;
}

#-----------------------------------------------------------------------------
# +
sub scene_cross
{
my ($up, $down, $left, $right, $index) = @_;

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
my ($up, $down, $left, $right, $index) = @_;

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
my ($up, $down, $left, $right, $index) = @_;

return 1 if(((defined($up) && (any {$_ eq '|'} @{$up})) && (defined($right) && (any {$_ eq '-'} @{$right}))) && 
			!(defined($down) && (any {$_ eq '|'} @{$down}))) ;

return ((defined($up) && (any {$_ eq '|'} @{$up})) && (defined($left) && (any {$_ eq '-'} @{$left})) && 
		!((defined($down) && (any {$_ eq '|'} @{$down})) || (defined($right) && (any {$_ eq '|'} @{$right})))) ;

}

#-----------------------------------------------------------------------------
# ┼
sub scene_unicode_cross
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $up && defined $down && defined $left && defined $right ;

return (any {exists $unicode_up_chars[$index]{$_}} @{$up})
	&& (any {exists $unicode_down_chars[$index]{$_}} @{$down})
	&& (any {exists $unicode_left_chars[$index]{$_}} @{$left})
	&& (any {exists $unicode_right_chars[$index]{$_}} @{$right}) ;

}

#-----------------------------------------------------------------------------
# ┤
sub scene_unicode_cross_lose_right
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $up && defined $down && defined $left ;

return 0 if defined $right && (any {exists $unicode_right_chars[$index]{$_}} @{$right}) ;

return (any {exists $unicode_up_chars[$index]{$_}} @{$up}) 
	&& (any {exists $unicode_down_chars[$index]{$_}} @{$down}) 
	&& (any {exists $unicode_left_chars[$index]{$_}} @{$left}) ;
}

#-----------------------------------------------------------------------------
# ├
sub scene_unicode_cross_lose_left
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $up && defined $down && defined $right ;

return 0 if defined $left && (any {exists $unicode_left_chars[$index]{$_}} @{$left}) ;

return (any {exists $unicode_up_chars[$index]{$_}} @{$up}) 
	&& (any {exists $unicode_down_chars[$index]{$_}} @{$down}) 
	&& (any {exists $unicode_right_chars[$index]{$_}} @{$right}) ;
}

#-----------------------------------------------------------------------------
# ┬
sub scene_unicode_cross_lose_up
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $down && defined $left && defined $right ;

return 0 if defined $up && (any {exists $unicode_up_chars[$index]{$_}} @{$up}) ;

return (any {exists $unicode_down_chars[$index]{$_}} @{$down}) 
	&& (any {exists $unicode_left_chars[$index]{$_}} @{$left}) 
	&& (any {exists $unicode_right_chars[$index]{$_}} @{$right}) ;
}

#-----------------------------------------------------------------------------
# ┴
sub scene_unicode_cross_lose_down
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $up && defined $left && defined $right ;

return 0 if defined $down && (any {exists $unicode_down_chars[$index]{$_}} @{$down}) ;

return (any {exists $unicode_up_chars[$index]{$_}} @{$up}) 
	&& (any {exists $unicode_left_chars[$index]{$_}} @{$left}) 
	&& (any {exists $unicode_right_chars[$index]{$_}} @{$right}) ;
}

#-----------------------------------------------------------------------------
# ╭
sub scene_unicode_right_down
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $down && defined $right ;

return 0 if (defined $up && (any {exists $unicode_up_chars[$index]{$_}} @{$up})) 
	|| (defined $left && (any {exists $unicode_left_chars[$index]{$_}} @{$left}))  ;

return (any {exists $unicode_down_chars[$index]{$_}} @{$down}) 
	&& (any {exists $unicode_right_chars[$index]{$_}} @{$right}) ;
}

#-----------------------------------------------------------------------------
# ╮
sub scene_unicode_left_down
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $down && defined $left ;

return 0 if (defined $up && (any {exists $unicode_up_chars[$index]{$_}} @{$up})) 
	|| (defined $right && (any {exists $unicode_right_chars[$index]{$_}} @{$right})) ;

return (any {exists $unicode_down_chars[$index]{$_}} @{$down}) 
	&& (any {exists $unicode_left_chars[$index]{$_}} @{$left}) ;
}

#-----------------------------------------------------------------------------
# ╯
sub scene_unicode_left_up
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $up && defined $left ;

return 0 if (defined $down && (any {exists $unicode_down_chars[$index]{$_}} @{$down})) 
	|| (defined $right && (any {exists $unicode_right_chars[$index]{$_}} @{$right}))  ;

return (any {exists $unicode_up_chars[$index]{$_}} @{$up}) 
	&& (any {exists $unicode_left_chars[$index]{$_}} @{$left}) ;
}

#-----------------------------------------------------------------------------
# ╰
sub scene_unicode_right_up
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $up && defined $right ;

return 0 if (defined $left && (any {exists $unicode_left_chars[$index]{$_}} @{$left})) 
	|| (defined $down && (any {exists $unicode_down_chars[$index]{$_}} @{$down})) ;

return (any {exists $unicode_up_chars[$index]{$_}} @{$up}) 
	&& (any {exists $unicode_right_chars[$index]{$_}} @{$right}) ;
}

#-----------------------------------------------------------------------------
# ╫
sub scene_unicode_mix_cross_thin_double
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $up && defined $down && defined $left && defined $right ;

return ((any {exists $unicode_up_chars[2]{$_}} @{$up}) || (any {exists $unicode_mix_up_double_chars{$_}} @{$up})) 
	&& ((any {exists $unicode_down_chars[2]{$_}} @{$down}) || (any {exists $unicode_mix_down_double_chars{$_}} @{$down}) ) 
	&& ((any {exists $unicode_left_chars[0]{$_}} @{$left}) || (any {exists $unicode_mix_left_thin_chars{$_}} @{$left}) ) 
	&& ((any {exists $unicode_right_chars[0]{$_}} @{$right}) || (any {exists $unicode_mix_right_thin_chars{$_}} @{$right}) ) ;

}

#-----------------------------------------------------------------------------
# ╪
sub scene_unicode_mix_cross_double_thin
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $up && defined $down && defined $left && defined $right ;

return ((any {exists $unicode_up_chars[0]{$_}} @{$up}) || (any {exists $unicode_mix_up_thin_chars{$_}} @{$up}) ) 
	&& ((any {exists $unicode_down_chars[0]{$_}} @{$down}) || (any {exists $unicode_mix_down_thin_chars{$_}} @{$down}) ) 
	&& ((any {exists $unicode_left_chars[2]{$_}} @{$left}) || (any {exists $unicode_mix_left_double_chars{$_}} @{$left}) ) 
	&& ((any {exists $unicode_right_chars[2]{$_}} @{$right}) || (any {exists $unicode_mix_right_double_chars{$_}} @{$right}) ) ;

}

#-----------------------------------------------------------------------------
# ╨
sub scene_unicode_mix_cross_lose_down_thin_double
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $up && defined $left && defined $right ;

return 0 if(defined $down && (any {exists $unicode_down_chars[2]{$_}} @{$down})) || (any {exists $unicode_mix_down_double_chars{$_}} @{$down}) ;

return ((any {exists $unicode_up_chars[2]{$_}} @{$up}) || (any {exists $unicode_mix_up_double_chars{$_}} @{$up}) ) 
	&& ((any {exists $unicode_left_chars[0]{$_}} @{$left}) || (any {exists $unicode_mix_left_thin_chars{$_}} @{$left}) ) 
	&& ((any {exists $unicode_right_chars[0]{$_}} @{$right}) || (any {exists $unicode_mix_right_thin_chars{$_}} @{$right}) ) ;

}

#-----------------------------------------------------------------------------
# ╧
sub scene_unicode_mix_cross_lose_down_double_thin
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $up && defined $left && defined $right ;

return 0 if(defined $down && (any {exists $unicode_down_chars[0]{$_}} @{$down})) || (any {exists $unicode_mix_down_thin_chars{$_}} @{$down}) ;

return ((any {exists $unicode_up_chars[0]{$_}} @{$up}) || (any {exists $unicode_mix_up_thin_chars{$_}} @{$up}) ) 
	&& ((any {exists $unicode_left_chars[2]{$_}} @{$left}) || (any {exists $unicode_mix_left_double_chars{$_}} @{$left}) ) 
	&& ((any {exists $unicode_right_chars[2]{$_}} @{$right}) || (any {exists $unicode_mix_right_double_chars{$_}} @{$right}) ) ;

}

#-----------------------------------------------------------------------------
# ╥
sub scene_unicode_mix_cross_lose_up_thin_double
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $down && defined $left && defined $right ;

return 0 if(defined $up && (any {exists $unicode_up_chars[2]{$_}} @{$up})) || (any {exists $unicode_mix_up_double_chars{$_}} @{$up}) ;

return ((any {exists $unicode_down_chars[2]{$_}} @{$down}) || (any {exists $unicode_mix_down_double_chars{$_}} @{$down}) ) 
	&& ((any {exists $unicode_left_chars[0]{$_}} @{$left}) || (any {exists $unicode_mix_left_thin_chars{$_}} @{$left})) 
	&& ((any {exists $unicode_right_chars[0]{$_}} @{$right}) || (any {exists $unicode_mix_right_thin_chars{$_}} @{$right})) ;

}

#-----------------------------------------------------------------------------
# ╤
sub scene_unicode_mix_cross_lose_up_double_thin
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $down && defined $left && defined $right ;

return 0 if(defined $up && (any {exists $unicode_up_chars[0]{$_}} @{$up})) || (any {exists $unicode_mix_up_thin_chars{$_}} @{$up}) ;

return ((any {exists $unicode_down_chars[0]{$_}} @{$down}) || (any {exists $unicode_mix_down_thin_chars{$_}} @{$down}) ) 
	&& ((any {exists $unicode_left_chars[2]{$_}} @{$left}) || (any {exists $unicode_mix_left_double_chars{$_}} @{$left}) ) 
	&& ((any {exists $unicode_right_chars[2]{$_}} @{$right}) || (any {exists $unicode_mix_right_double_chars{$_}} @{$right}) ) ;

}

#-----------------------------------------------------------------------------
# ╢
sub scene_unicode_mix_cross_lose_right_thin_double
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $up && defined $down && defined $left ;

return 0 if(defined $right && (any {exists $unicode_right_chars[0]{$_}} @{$right})) || (any {exists $unicode_mix_right_thin_chars{$_}} @{$right}) ;

return ((any {exists $unicode_up_chars[2]{$_}} @{$up}) || (any {exists $unicode_mix_up_double_chars{$_}} @{$up}) ) 
	&& ((any {exists $unicode_down_chars[2]{$_}} @{$down}) || (any {exists $unicode_mix_down_double_chars{$_}} @{$down}) ) 
	&& ((any {exists $unicode_left_chars[0]{$_}} @{$left}) || (any {exists $unicode_mix_left_thin_chars{$_}} @{$left})) ;

}

#-----------------------------------------------------------------------------
# ╡
sub scene_unicode_mix_cross_lose_rigth_double_thin
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $up && defined $down && defined $left ;

return 0 if(defined $right && (any {exists $unicode_right_chars[2]{$_}} @{$right})) || (any {exists $unicode_mix_right_double_chars{$_}} @{$right}) ;

return ((any {exists $unicode_up_chars[0]{$_}} @{$up}) || (any {exists $unicode_mix_up_thin_chars{$_}} @{$up}) ) 
	&& ((any {exists $unicode_down_chars[0]{$_}} @{$down}) || (any {exists $unicode_mix_down_thin_chars{$_}} @{$down}) ) 
	&& ((any {exists $unicode_left_chars[2]{$_}} @{$left}) || (any {exists $unicode_mix_left_double_chars{$_}} @{$left}) ) ;

}

#-----------------------------------------------------------------------------
# ╟
sub scene_unicode_mix_cross_lose_left_thin_double
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $up && defined $down && defined $right ;

return 0 if(defined $left && (any {exists $unicode_left_chars[0]{$_}} @{$left})) || (any {exists $unicode_mix_left_thin_chars{$_}} @{$left}) ;

return ((any {exists $unicode_up_chars[2]{$_}} @{$up}) || (any {exists $unicode_mix_up_double_chars{$_}} @{$up}) ) 
	&& ((any {exists $unicode_down_chars[2]{$_}} @{$down}) || (any {exists $unicode_mix_down_double_chars{$_}} @{$down}) ) 
	&& ((any {exists $unicode_right_chars[0]{$_}} @{$right}) || (any {exists $unicode_mix_right_thin_chars{$_}} @{$right}) ) ;

}

#-----------------------------------------------------------------------------
# ╞
sub scene_unicode_mix_cross_lose_left_double_thin
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $up && defined $down && defined $right ;

return 0 if(defined $left && (any {exists $unicode_left_chars[2]{$_}} @{$left})) || (any {exists $unicode_mix_left_double_chars{$_}} @{$left}) ;

return ((any {exists $unicode_up_chars[0]{$_}} @{$up}) || (any {exists $unicode_mix_up_thin_chars{$_}} @{$up}) ) 
	&& ((any {exists $unicode_down_chars[0]{$_}} @{$down}) || (any {exists $unicode_mix_down_thin_chars{$_}} @{$down}) ) 
	&& ((any {exists $unicode_right_chars[2]{$_}} @{$right}) || (any {exists $unicode_mix_right_double_chars{$_}} @{$right}) ) ;

}

#-----------------------------------------------------------------------------
# ╜
sub scene_unicode_mix_thin_left_double_up
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $up && defined $left ;

return 0 if( defined $down && ((any {exists $unicode_down_chars[2]{$_}} @{$down}) || (any {exists $unicode_mix_down_double_chars{$_}} @{$down}) )) 
	|| (defined $right && ((any {exists $unicode_right_chars[0]{$_}} @{$right}) || (any {exists $unicode_mix_right_thin_chars{$_}} @{$right}) )) ;

return ((any {exists $unicode_up_chars[2]{$_}} @{$up}) || (any {exists $unicode_mix_up_double_chars{$_}} @{$up}) ) 
	&& ((any {exists $unicode_left_chars[0]{$_}} @{$left}) || (any {exists $unicode_mix_left_thin_chars{$_}} @{$left}) ) ;

}

#-----------------------------------------------------------------------------
# ╛
sub scene_unicode_mix_double_left_thin_up
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $up && defined $left ;

return 0 if( defined $down && ((any {exists $unicode_down_chars[0]{$_}} @{$down}) || (any {exists $unicode_mix_down_thin_chars{$_}} @{$down}) )) 
	|| (defined $right && ((any {exists $unicode_right_chars[2]{$_}} @{$right}) || (any {exists $unicode_mix_right_double_chars{$_}} @{$right}) )) ;

return ((any {exists $unicode_up_chars[0]{$_}} @{$up}) || (any {exists $unicode_mix_up_thin_chars{$_}} @{$up}) ) 
	&& ((any {exists $unicode_left_chars[2]{$_}} @{$left}) || (any {exists $unicode_mix_left_double_chars{$_}} @{$left}) ) ;

}

#-----------------------------------------------------------------------------
# ╙
sub scene_unicode_mix_thin_right_double_up
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $up && defined $right ;

return 0 if( defined $left && ((any {exists $unicode_left_chars[0]{$_}} @{$left}) || (any {exists $unicode_mix_left_thin_chars{$_}} @{$left}) )) 
|| (defined $down && ((any {exists $unicode_down_chars[2]{$_}} @{$down}) || (any {exists $unicode_mix_down_double_chars{$_}} @{$down}) ));

return ((any {exists $unicode_up_chars[2]{$_}} @{$up}) || (any {exists $unicode_mix_up_double_chars{$_}} @{$up}) ) 
	&& ((any {exists $unicode_right_chars[0]{$_}} @{$right}) || (any {exists $unicode_mix_right_thin_chars{$_}} @{$right}) ) ;

}

#-----------------------------------------------------------------------------
# ╘
sub scene_unicode_mix_double_right_thin_up
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $up && defined $right ;

return 0 if (defined $left && ((any {exists $unicode_left_chars[2]{$_}} @{$left}) || (any {exists $unicode_mix_left_double_chars{$_}} @{$left}) )) 
	|| (defined $down && ((any {exists $unicode_down_chars[0]{$_}} @{$down}) || (any {exists $unicode_mix_down_thin_chars{$_}} @{$down}) ));

return ((any {exists $unicode_up_chars[0]{$_}} @{$up}) || (any {exists $unicode_mix_up_thin_chars{$_}} @{$up}) ) 
	&& ((any {exists $unicode_right_chars[2]{$_}} @{$right}) || (any {exists $unicode_mix_right_double_chars{$_}} @{$right}) ) ;

}

#-----------------------------------------------------------------------------
# ╖
sub scene_unicode_mix_thin_left_double_down
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $down && defined $left ;

return 0 if (defined $up && ((any {exists $unicode_up_chars[2]{$_}} @{$up}) || (any {exists $unicode_mix_up_double_chars{$_}} @{$up}) )) 
	|| (defined $right && ((any {exists $unicode_right_chars[0]{$_}} @{$right}) || (any {exists $unicode_mix_right_thin_chars{$_}} @{$right}) ));

return ((any {exists $unicode_down_chars[2]{$_}} @{$down}) || (any {exists $unicode_mix_down_double_chars{$_}} @{$down}) ) 
	&& ((any {exists $unicode_left_chars[0]{$_}} @{$left}) || (any {exists $unicode_mix_left_thin_chars{$_}} @{$left}) ) ;

}

#-----------------------------------------------------------------------------
# ╕
sub scene_unicode_mix_double_left_thin_down
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $down && defined $left ;

return 0 if (defined $up && ((any {exists $unicode_up_chars[0]{$_}} @{$up}) || (any {exists $unicode_mix_up_thin_chars{$_}} @{$up}) )) 
	|| (defined $right && ((any {exists $unicode_right_chars[2]{$_}} @{$right}) || (any {exists $unicode_mix_right_double_chars{$_}} @{$right}) ));

return ((any {exists $unicode_down_chars[0]{$_}} @{$down}) || (any {exists $unicode_mix_down_thin_chars{$_}} @{$down}) ) 
	&& ((any {exists $unicode_left_chars[2]{$_}} @{$left}) || (any {exists $unicode_mix_left_double_chars{$_}} @{$left}) ) ;
}

#-----------------------------------------------------------------------------
# ╓
sub scene_unicode_mix_thin_right_double_down
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $down && defined $right ;

return 0 if (defined $up && ((any {exists $unicode_up_chars[2]{$_}} @{$up}) || (any {exists $unicode_mix_up_double_chars{$_}} @{$up}) )) 
	|| (defined $left && ((any {exists $unicode_left_chars[0]{$_}} @{$left}) || (any {exists $unicode_mix_left_thin_chars{$_}} @{$left}) )) ;

return ((any {exists $unicode_down_chars[2]{$_}} @{$down}) || (any {exists $unicode_mix_down_double_chars{$_}} @{$down}) ) 
	&& ((any {exists $unicode_right_chars[0]{$_}} @{$right}) || (any {exists $unicode_mix_right_thin_chars{$_}} @{$right}) ) ;
}

#-----------------------------------------------------------------------------
# ╒
sub scene_unicode_mix_double_right_thin_down
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $down && defined $right ;

return 0 if (defined $up && ((any {exists $unicode_up_chars[0]{$_}} @{$up}) || (any {exists $unicode_mix_up_thin_chars{$_}} @{$up}) ))
		|| (defined $left && ((any {exists $unicode_left_chars[2]{$_}} @{$left}) || (any {exists $unicode_mix_left_double_chars{$_}} @{$left}) )) ;

return ((any {exists $unicode_down_chars[0]{$_}} @{$down}) || (any {exists $unicode_mix_down_thin_chars{$_}} @{$down}) )
	&& ((any {exists $unicode_right_chars[2]{$_}} @{$right}) || (any {exists $unicode_mix_right_double_chars{$_}} @{$right}) ) ;
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

