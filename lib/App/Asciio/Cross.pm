
package App::Asciio::Cross ;

$|++ ;

use strict;
use warnings;
use utf8;

use Clone;

use List::Util qw(first) ;
use List::MoreUtils qw(any) ;

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
			'┌', '┐', '└', '┘', '┅', '┄', '┆', '┇'
			) ;

my %diagonal_cross_chars = map {$_, 1} ('\\', '/', '╱', '╲', '╳') ;

my %unicode_left_thin_chars    = map {$_, 1} ('─', '┼', '├', '┬', '┴', '╭', '╰', '╫', '╨', '╥', '╟', '╙', '╓', '┎', '┖', '┞', '┟', '┠', '┭', '┰', '┱', '┵', '┸', '┹', '┽', '╀', '╁', '╂', '╃', '╅', '╉', '┌', '└', '┄') ;
my %unicode_right_thin_chars   = map {$_, 1} ('─', '┼', '┤', '┬', '┴', '╮', '╯', '╫', '╨', '╥', '╢', '╜', '╖', '┒', '┚', '┦', '┧', '┨', '┮', '┰', '┲', '┶', '┸', '┺', '┾', '╀', '╁', '╂', '╄', '╆', '╊', '┐', '┘', '┄') ;
my %unicode_up_thin_chars      = map {$_, 1} ('│', '┼', '┤', '├', '┬', '╭', '╮', '╪', '╤', '╡', '╞', '╕', '╒', '┍', '┑', '┝', '┞', '┡', '┥', '┦', '┩', '┭', '┮', '┯', '┽', '┾', '┿', '╀', '╃', '╄', '╇', '┌', '┐', '┆') ;
my %unicode_down_thin_chars    = map {$_, 1} ('│', '┼', '┤', '├', '┴', '╯', '╰', '╪', '╧', '╡', '╞', '╛', '╘', '┕', '┙', '┝', '┟', '┢', '┥', '┧', '┪', '┵', '┶', '┷', '┽', '┾', '┿', '╁', '╅', '╆', '╈', '└', '┘', '┆') ;

my %unicode_left_double_chars  = map {$_, 1} ('═', '╬', '╠', '╦', '╩', '╔', '╚', '╪', '╧', '╤', '╞', '╘', '╒') ;
my %unicode_right_double_chars = map {$_, 1} ('═', '╬', '╣', '╦', '╩', '╗', '╝', '╪', '╧', '╤', '╡', '╛', '╕') ;
my %unicode_up_double_chars    = map {$_, 1} ('║', '╬', '╣', '╠', '╦', '╔', '╗', '╫', '╥', '╢', '╟', '╖', '╓') ;
my %unicode_down_double_chars  = map {$_, 1} ('║', '╬', '╣', '╠', '╩', '╝', '╚', '╫', '╨', '╢', '╟', '╜', '╙') ;

my %unicode_left_bold_chars    = map {$_, 1} ('━', '╋', '┣', '┳', '┻', '┏', '┗', '┍', '┕', '┝', '┡', '┢', '┮', '┯', '┲', '┶', '┷', '┺', '┾', '┿', '╄', '╆', '╇', '╈', '╊', '┅') ;
my %unicode_right_bold_chars   = map {$_, 1} ('━', '╋', '┫', '┳', '┻', '┓', '┛', '┑', '┙', '┥', '┩', '┪', '┭', '┯', '┱', '┵', '┷', '┹', '┽', '┿', '╃', '╅', '╇', '╈', '╉', '┅') ;
my %unicode_up_bold_chars      = map {$_, 1} ('┃', '╋', '┫', '┣', '┳', '┏', '┓', '┎', '┒', '┟', '┠', '┢', '┧', '┨', '┪', '┰', '┱', '┲', '╁', '╂', '╅', '╆', '╈', '╉', '╊', '┇') ;
my %unicode_down_bold_chars    = map {$_, 1} ('┃', '╋', '┫', '┣', '┻', '┛', '┗', '┖', '┚', '┞', '┠', '┡', '┦', '┨', '┩', '┸', '┹', '┺', '╀', '╂', '╃', '╄', '╇', '╉', '╊', '┇') ;

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

#-----------------------------------------------------------------------------
sub flip_cross_mode
{
my ($asciio) = @_ ;

undef %normal_char_cache ;
undef %diagonal_char_cache ;

$asciio->{USE_CROSS_MODE} ^= 1 ;

$asciio->update_display ;
}

#-----------------------------------------------------------------------------
sub get_cross_mode_overlays
{
my ($zbuffer) = @_;

my @overlays ;

return @overlays unless(defined $zbuffer->{intersecting_elements}) ;

my $cross_zbuffer = Clone::clone($zbuffer) ;

while (my ($coordinate, $char_stacks) = each %{ $cross_zbuffer->{intersecting_elements} })
	{
	my $cross_array ;
	my $char_count = 0 ;
	for my $char (@$char_stacks)
		{
		last unless exists $all_cross_chars{$char};
		push @{$cross_array}, $char;
		$char_count++;
		}
	if($char_count >= 2)
		{
		$cross_zbuffer->{intersecting_elements}{$coordinate} = $cross_array ;
		}
	else
		{
		delete $cross_zbuffer->{intersecting_elements}{$coordinate} ;
		}
	}

while( my($coordinate, $elements) = each $cross_zbuffer->{intersecting_elements}->%*)
	{
	my ($Y, $X) = split ';', $coordinate ;

	my $neighbors_stack = $cross_zbuffer->get_neighbors_stack($coordinate) ;

	my ($char_315, $up, $char_45, $right, $char_135, $down, $char_225, $left) = 
		($neighbors_stack->{($Y-1) . ';' . ($X-1)} // [$undef_char],
		$neighbors_stack->{($Y-1) . ';' . $X} // [$undef_char],
		$neighbors_stack->{($Y-1) . ';' . ($X+1)} // [$undef_char],
		$neighbors_stack->{$Y . ';' . ($X+1)} // [$undef_char],
		$neighbors_stack->{($Y+1) . ';' . ($X+1)} // [$undef_char],
		$neighbors_stack->{($Y+1) . ';' . $X} // [$undef_char],
		$neighbors_stack->{($Y+1) . ';' . ($X-1)} // [$undef_char],
		$neighbors_stack->{$Y . ';' . ($X-1)} // [$undef_char]);
	
	my $normal_key = join('_', join('o', @{$up}), join('o', @{$down}), join('o', @{$left}), join('o', @{$right})) ;
	
	unless(exists $normal_char_cache{$normal_key})
		{
		my $scene_func = first { $_->[$FUNCTION]($up, $down, $left, $right, $_->[$CHAR_CATEGORY_INDEXS]) } @normal_char_func;
		$normal_char_cache{$normal_key} = ($scene_func) ? $scene_func->[$CHARACTER] : '';
		}
	
	if($normal_char_cache{$normal_key})
		{
		if($normal_char_cache{$normal_key} ne $elements->[0])
			{
			push @overlays, [$X, $Y, $normal_char_cache{$normal_key}];
			}

		next;
		}
	
	next unless exists $diagonal_cross_chars{$elements->[0]} ;
	
	my $diagonal_key = join('_', join('o', @{$char_45}), join('o', @{$char_135}), join('o', @{$char_225}), join('o', @{$char_315})) ;
	
	unless(exists $diagonal_char_cache{$diagonal_key})
		{
		my $scene_func = first { $_->[$FUNCTION]($char_45, $char_135, $char_225, $char_315) } @diagonal_char_func;
		$diagonal_char_cache{$diagonal_key} = ($scene_func) ? $scene_func->[$CHARACTER] : '';
		}
	
	if($diagonal_char_cache{$diagonal_key} && ($diagonal_char_cache{$diagonal_key} ne $elements->[0]))
		{
		push @overlays, [$X, $Y, $diagonal_char_cache{$diagonal_key}];
		}

	}

return @overlays ;
}

#-----------------------------------------------------------------------------
# +
sub scene_cross 
{
my ($up, $down, $left, $right, $char_category_indexs) = @_;

return 0 unless defined $up && defined $down && defined $left && defined $right;

my %valid_chars = (
	up => { map { $_ => 1 } qw(| . ' + ^) },
	down => { map { $_ => 1 } qw(| . ' + v) },
	left => { map { $_ => 1 } qw(- . ' + <) },
	right => { map { $_ => 1 } qw(- . ' + >) },
);

return (any { $valid_chars{up}{$_} } @$up) 
	&& (any { $valid_chars{down}{$_} } @$down) 
	&& (any { $valid_chars{left}{$_} } @$left) 
	&& (any { $valid_chars{right}{$_} } @$right);
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

