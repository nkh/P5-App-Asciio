
package App::Asciio ;

$|++ ;

use strict;
use warnings;
use utf8;

use Clone;

use App::Asciio::Toolfunc ;

#-----------------------------------------------------------------------------

{
my %cross_elements_cache;

sub create_cross_fillers
{
my ($self, @char_list) = @_;

my @new_elements;
for my $char (@char_list)
	{
	unless(exists($cross_elements_cache{$char->[0]}))
		{
		# undef or 0: normal element 1: normal filler element 2: cross filler element 3: cross type element
		$cross_elements_cache{$char->[0]} = create_box(NAME => 'cross filler', TEXT_ONLY => $char->[0], AUTO_SHRINK => 1, RESIZABLE => 0, EDITABLE => 0, CROSS_ENUM => ENUM_CROSS_FILLER);
		$cross_elements_cache{$char->[0]}->enable_autoconnect(0);
		}
	
	my $new_element = Clone::clone($cross_elements_cache{$char->[0]});
	@$new_element{'X', 'Y', 'SELECTED'} = ($char->[1], $char->[2], 0);
	
	push @new_elements, $new_element;
	}

	$self->add_elements(@new_elements);
}

}

#-----------------------------------------------------------------------------

sub select_cross_elements_type
{
my ($self, $type) = @_;

my @selected_elements = @{$self->{ELEMENTS}} ;
@selected_elements = $self->get_selected_elements(1) if $self->get_selected_elements(1) ;

if($type == ENUM_NORMAL_ELEMENT)
	{
	for (@selected_elements)
	{
	$_->{SELECTED} = ((! defined $_->{CROSS_ENUM})|| (defined $_->{CROSS_ENUM} && $_->{CROSS_ENUM} == ENUM_NORMAL_ELEMENT)) ? ++$self->{SELECTION_INDEX} : 0  ;
	}
	}
else
	{
	for (@selected_elements)
	{
	$_->{SELECTED} = defined $_->{CROSS_ENUM} && $_->{CROSS_ENUM} == $type ? ++$self->{SELECTION_INDEX} : 0  ;
	}
	}
}

sub select_normal_elements_from_selected_elements
{
	my ($self) = @_ ; 
	$self->select_cross_elements_type(ENUM_NORMAL_ELEMENT); 
}

sub select_normal_filler_elements_from_selected_elements
{
	my ($self) = @_ ; 
	$self->select_cross_elements_type(ENUM_NORMAL_FILLER); 
}


sub select_cross_filler_elements_from_selected_elements
{
	my ($self) = @_ ; 
	$self->select_cross_elements_type(ENUM_CROSS_FILLER); 
}

sub select_cross_elements_from_selected_elements
{
	my ($self) = @_ ; 
	$self->select_cross_elements_type(ENUM_CROSS_ELEMENT); 
}

#-----------------------------------------------------------------------------

sub switch_to_normal_elements_from_selected_elements
{
my ($self) = @_;

my @selected_elements = @{$self->{ELEMENTS}} ;
@selected_elements = $self->get_selected_elements(1) if $self->get_selected_elements(1) ;

for (@selected_elements)
	{
	$_->{CROSS_ENUM} = undef if (defined $_->{CROSS_ENUM} && $_->{CROSS_ENUM} == ENUM_CROSS_ELEMENT) ;
	$_->{CROSS_ENUM} = ENUM_NORMAL_FILLER if defined $_->{CROSS_ENUM} && $_->{CROSS_ENUM} == ENUM_CROSS_FILLER ;
	}
}

#-----------------------------------------------------------------------------

sub switch_to_cross_elements_from_selected_elements
{
my ($self) = @_;

my @selected_elements = @{$self->{ELEMENTS}} ;
@selected_elements = $self->get_selected_elements(1) if $self->get_selected_elements(1) ;

for (@selected_elements)
	{
	$_->{CROSS_ENUM} = ENUM_CROSS_ELEMENT if ((! defined $_->{CROSS_ENUM}) || (defined $_->{CROSS_ENUM} && $_->{CROSS_ENUM} == ENUM_NORMAL_ELEMENT)) ;
	$_->{CROSS_ENUM} = ENUM_CROSS_FILLER if defined $_->{CROSS_ENUM} && $_->{CROSS_ENUM} == ENUM_NORMAL_FILLER ;
	}
}

#-----------------------------------------------------------------------------

sub switch_cross_mode
{

my ($self) = @_;

$self->{CROSS_MODE} ^= 1 ;

$self->set_title($self->get_title()) ;
}

#-----------------------------------------------------------------------------
# ascii: + X . '
# unicode: ┼ ┤ ├ ┬ ┴ ╭ ╮ ╯ ╰ ╳ 
# todo: 1. performance problem

{

my ($undef_char, %normal_char_cache, %diagonal_char_cache) = ('Ȝ') ;

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

my %cross_filler_chars = map {$_, 1} 
				( 
				'-', '|', '.', '\'', '\\', '/', '+', 
				'─', '│', '┼', '┤', '├', '┬', '┴', '╭', '╮', '╯', '╰',
				'━', '┃', '╋', '┫', '┣', '┳', '┻', '┏', '┓', '┛', '┗', 
				'═', '║', '╬', '╣', '╠', '╦', '╩', '╔', '╗', '╝', '╚',
				'╫', '╪', '╨', '╧', '╥', '╤', '╢', '╡', '╟', '╞', '╜', 
				'╛', '╙', '╘', '╖', '╕', '╓', '╒'
				) ;

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


sub delete_cross_elements_cache
{
my ($self) = @_;

my $normal_char_cache_num = keys %normal_char_cache;
my $diagonal_char_cache_num = keys %diagonal_char_cache;

%normal_char_cache = ();
%diagonal_char_cache = ();

print("normal_char_cache_num: " . $normal_char_cache_num. " deleted!" . "\n");
print("diagonal_char_cache_num: " . $diagonal_char_cache_num. " deleted!" . "\n");
}

sub add_cross_fillers
{
my ($self) = @_;

my ($old_cross_elements, $ascii_array_ref, @ascii_array, $old_key, %not_delete_cross_fillers, $index_ref);

#~ this sub is slow
($old_cross_elements, $ascii_array_ref, $index_ref) = $self->transform_elements_to_ascii_two_dimensional_array_for_cross_mode(\%cross_filler_chars);
@ascii_array = @{$ascii_array_ref} ;

my ($row, $col, $scene_func, @elements_to_be_add, $cross_index) ;
my ($up, $down, $left, $right, $char_45, $char_135, $char_225, $char_315, $normal_key, $diagonal_key);
for $cross_index (@{$index_ref})
	{
	($row, $col) = ($cross_index->[0], $cross_index->[1]) ;
	
	($up, $down, $left, $right) = ($ascii_array[$row-1][$col], $ascii_array[$row+1][$col], $ascii_array[$row][$col-1], $ascii_array[$row][$col+1]);
	
	my ($up_key, $down_key, $left_key, $right_key) ;

	$up_key = (defined $up) ? join('o', @{$up}) : $undef_char ;
	$down_key = (defined $down) ? join('o', @{$down}) : $undef_char ;
	$left_key = (defined $left) ? join('o', @{$left}) : $undef_char ;
	$right_key = (defined $right) ? join('o', @{$right}) : $undef_char ;	
	$normal_key = $up_key . '_' . $down_key . '_' . $left_key . '_' . $right_key ;
	
	unless(exists($normal_char_cache{$normal_key}))
		{
		$scene_func = first { $_->[1]($up, $down, $left, $right, $_->[2]) } @normal_char_func;
		$normal_char_cache{$normal_key} = ($scene_func) ? $scene_func->[0] : '';
		}
	
	if($normal_char_cache{$normal_key})
		{
		$old_key = $col . '-' . $row;
		
		if(exists($old_cross_elements->{$old_key}) && ($old_cross_elements->{$old_key} eq $normal_char_cache{$normal_key}))
			{
			if($normal_char_cache{$normal_key} ne $ascii_array[$row][$col])
				{
				# todo: If more than 2 crossing occur, the originally reserved filler may be blocked by 
				#       the characters behind, and the filler need to be forced to move to the foreground. 
				#       Since this situation is relatively rare and will consume CPU resources, 
				#       it will not be implemented for the time being.
				$not_delete_cross_fillers{$old_key . '-' . $normal_char_cache{$normal_key}} = 1;
				}
			}
		else
			{
			if($normal_char_cache{$normal_key} ne $ascii_array[$row][$col])
			{
			push @elements_to_be_add, [$normal_char_cache{$normal_key}, $col, $row];
			}
			}
		
		next;
		}
	
	($char_45, $char_135, $char_225, $char_315) = ($ascii_array[$row-1][$col+1], $ascii_array[$row+1][$col+1], $ascii_array[$row+1][$col-1], $ascii_array[$row-1][$col-1]);
	
	$diagonal_key = ($char_45 || $undef_char) . ($char_135 || $undef_char) . ($char_225 || $undef_char) . ($char_315 || $undef_char);

	my ($char_45_key, $char_135_key, $char_225_key, $char_315_key) ;
	$char_45_key = (defined $char_45) ? join('o', @{$char_45}) : $undef_char ;
	$char_135_key = (defined $char_135) ? join('o', @{$char_135}) : $undef_char ;
	$char_225_key = (defined $char_225) ? join('o', @{$char_225}) : $undef_char ;
	$char_315_key = (defined $char_315) ? join('o', @{$char_315}) : $undef_char ;
	$diagonal_key = $char_45_key . '_' . $char_135_key . '_' . $char_225_key . '_' . $char_315_key ;
	
	unless(exists($diagonal_char_cache{$diagonal_key}))
		{
		$scene_func = first { $_->[1]($char_45, $char_135, $char_225, $char_315) } @diagonal_char_func;
		$diagonal_char_cache{$diagonal_key} = ($scene_func) ? $scene_func->[0] : '';
		}
	
	if($diagonal_char_cache{$diagonal_key})
		{
		$old_key = $col . '-' . $row;
		if(exists($old_cross_elements->{$old_key}) && ($old_cross_elements->{$old_key} eq $diagonal_char_cache{$diagonal_key}))
			{
			if($diagonal_char_cache{$diagonal_key} ne $ascii_array[$row][$col])
				{
				$not_delete_cross_fillers{$old_key . '-' . $diagonal_char_cache{$diagonal_key}} = 1;
				}
			}
		else
			{
			if($diagonal_char_cache{$diagonal_key} ne $ascii_array[$row][$col])
				{
				push @elements_to_be_add, [$diagonal_char_cache{$diagonal_key}, $col, $row];
				}
			}
		}
	}

$self->delete_elements(grep{ defined($_->{CROSS_ENUM})
	&& ($_->{CROSS_ENUM} == ENUM_CROSS_FILLER) 
	&& !(defined $not_delete_cross_fillers{$_->{X} . '-' . $_->{Y} . '-' . $_->{TEXT_ONLY}}) } @{$self->{ELEMENTS}}) ;

$self->create_cross_fillers(@elements_to_be_add) if(@elements_to_be_add)  ;
}

#-----------------------------------------------------------------------------
# +
sub scene_cross
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless defined $up && defined $down && defined $left && defined $right ;

return ((any {$_ eq '|'} @{$up}) || (any {$_ eq '.'} @{$up}) || (any {$_ eq '\''} @{$up}) || (any {$_ eq '+'} @{$up}))
	&& ((any {$_ eq '|'} @{$down}) || (any {$_ eq '.'} @{$down}) || (any {$_ eq '\''} @{$down}) || (any {$_ eq '+'} @{$down}))
	&& ((any {$_ eq '-'} @{$left}) || (any {$_ eq '.'} @{$left}) || (any {$_ eq '\''} @{$left}) || (any {$_ eq '+'} @{$left}))
	&& ((any {$_ eq '-'} @{$right}) || (any {$_ eq '.'} @{$right}) || (any {$_ eq '\''} @{$right}) || (any {$_ eq '+'} @{$right})) ;

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

#----------------------------------------------------------------------------------------------

sub create_line
{
my ($self, $all_type) = @_;

my ($line_type, $cross_type) = @{$all_type} ;

my @arrows =
	(
	[
	['origin',       '',  '*',   '',  '',  '', 1],
	['up',          '|',  '|',   '',  '', '|', 1],
	['down',        '|',  '|',   '',  '', '|', 1],
	['left',        '-',  '-',   '',  '', '-', 1],
	['up-left',     '|',  '|',  '.', '-', '-', 1],
	['left-up',     '-',  '-', '\'', '|', '|', 1],
	['down-left',   '|',  '|', '\'', '-', '-', 1],
	['left-down',   '-',  '-',  '.', '|', '|', 1],
	['right',       '-',  '-',   '',  '', '-', 1],
	['up-right',    '|',  '|',  '.', '-', '_', 1],
	['right-up',    '-',  '-', '\'', '|', '|', 1],
	['down-right',  '|',  '|', '\'', '-', '-', 1],
	['right-down',  '-',  '-',  '.', '|', '|', 1],
	['45',          '/',  '/',   '',  '', '/', 1],
	['135',        '\\', '\\',   '',  '', '\\', 1],
	['225',         '/',  '/',   '',  '', '/', 1],
	['315',        '\\', '\\',   '',  '', '\\', 1],
	],
	[
	['origin',      '',  '*',  '',  '',  '', 1],
	['up',         '│',  '│',  '',  '', '│', 1],
	['down',       '│',  '│',  '',  '', '│', 1],
	['left',       '─',  '─',  '',  '', '─', 1],
	['upleft',     '│',  '│', '╮', '─', '─', 1],
	['leftup',     '─',  '─', '╰', '│', '│', 1],
	['downleft',   '│',  '│', '╯', '─', '─', 1],
	['leftdown',   '─',  '─', '╭', '│', '│', 1],
	['right',      '─',  '─',  '',  '', '─', 1],
	['upright',    '│',  '│', '╭', '─', '─', 1],
	['rightup',    '─',  '─', '╯', '│', '│', 1],
	['downright',  '│',  '│', '╰', '─', '─', 1],
	['rightdown',  '─',  '─', '╮', '│', '│', 1],
	['45',         '/',  '/',  '',  '', '/', 1],
	['135',       '\\', '\\',  '',  '', '\\', 1],
	['225',        '/',  '/',  '',  '', '/', 1],
	['315',       '\\', '\\',  '',  '', '\\', 1],
	], 
	[
	['origin',      '',  '*',  '',  '',  '', 1],
	['up',         '┃',  '┃',  '',  '', '┃', 1],
	['down',       '┃',  '┃',  '',  '', '┃', 1],
	['left',       '━',  '━',  '',  '', '━', 1],
	['upleft',     '┃',  '┃', '┓', '━', '━', 1],
	['leftup',     '━',  '━', '┗', '┃', '┃', 1],
	['downleft',   '┃',  '┃', '┛', '━', '━', 1],
	['leftdown',   '━',  '━', '┏', '┃', '┃', 1],
	['right',      '━',  '━',  '',  '', '━', 1],
	['upright',    '┃',  '┃', '┏', '━', '━', 1],
	['rightup',    '━',  '━', '┛', '┃', '┃', 1],
	['downright',  '┃',  '┃', '┗', '━', '━', 1],
	['rightdown',  '━',  '━', '┓', '┃', '┃', 1],
	['45',         '/',  '/',  '',  '', '/', 1],
	['135',       '\\', '\\',  '',  '', '\\', 1],
	['225',        '/',  '/',  '',  '', '/', 1],
	['315',       '\\', '\\',  '',  '', '\\', 1],
	],
	[
	['origin',      '',  '*',  '',  '',  '', 1],
	['up',         '║',  '║',  '',  '', '║', 1],
	['down',       '║',  '║',  '',  '', '║', 1],
	['left',       '═',  '═',  '',  '', '═', 1],
	['upleft',     '║',  '║', '╗', '═', '═', 1],
	['leftup',     '═',  '═', '╚', '║', '║', 1],
	['downleft',   '║',  '║', '╝', '═', '═', 1],
	['leftdown',   '═',  '═', '╔', '║', '║', 1],
	['right',      '═',  '═',  '',  '', '═', 1],
	['upright',    '║',  '║', '╔', '═', '═', 1],
	['rightup',    '═',  '═', '╝', '║', '║', 1],
	['downright',  '║',  '║', '╚', '═', '═', 1],
	['rightdown',  '═',  '═', '╗', '║', '║', 1],
	['45',         '/',  '/',  '',  '', '/', 1],
	['135',       '\\', '\\',  '',  '', '\\', 1],
	['225',        '/',  '/',  '',  '', '/', 1],
	['315',       '\\', '\\',  '',  '', '\\', 1],
	]
	) ;

my $arrow_type = $arrows[$line_type] ;

my $my_line_obj = new App::Asciio::stripes::section_wirl_arrow
			({
			POINTS => [[1, 0, 'right']],
			DIRECTION => 'left',
			ALLOW_DIAGONAL_LINES => 0,
			EDITABLE => 1,
			RESIZABLE => 1,
			ARROW_TYPE => $arrow_type,
			});

if($cross_type)
	{
	$my_line_obj->{CROSS_ENUM} = ENUM_CROSS_ELEMENT;
	}

$my_line_obj->{NAME} = 'line';
$my_line_obj->enable_autoconnect(0);
$my_line_obj->allow_connection('start', 0);
$my_line_obj->allow_connection('end', 0);

$self->add_element_at($my_line_obj, $self->{MOUSE_X}, $self->{MOUSE_Y});
}

#-----------------------------------------------------------------------------

1 ;

