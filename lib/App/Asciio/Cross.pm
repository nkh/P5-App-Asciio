
package App::Asciio ;

$|++ ;

use strict;
use warnings;
use utf8;

use Clone;

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
    $cross_elements_cache{$char->[0]} = create_box(NAME => 'cross filler', TEXT_ONLY => $char->[0], AUTO_SHRINK => 1, RESIZABLE => 0, EDITABLE => 0, CROSS_ENUM => 2);
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

sub select_cross_filler_elements_from_selected_elements
{
my ($self) = @_;

my @selected_elements = $self->get_selected_elements(1) ;

@selected_elements = @{$self->{ELEMENTS}} unless(@selected_elements) ;

$self->deselect_all_elements() ;

for my $element (@selected_elements)
{
    $element->{SELECTED} = ++$self->{SELECTION_INDEX} if (defined($element->{CROSS_ENUM}) && ($element->{CROSS_ENUM} == 2));
}
}

#-----------------------------------------------------------------------------

sub select_cross_elements_from_selected_elements
{
my ($self) = @_;

my @selected_elements = $self->get_selected_elements(1) ;

@selected_elements = @{$self->{ELEMENTS}} unless(@selected_elements) ;

$self->deselect_all_elements() ;

for my $element (@selected_elements)
{
    $element->{SELECTED} = ++$self->{SELECTION_INDEX} if (defined($element->{CROSS_ENUM}) && ($element->{CROSS_ENUM} == 3));
}
}

#-----------------------------------------------------------------------------

sub select_normal_elements_from_selected_elements
{
my ($self) = @_;

my @selected_elements = $self->get_selected_elements(1) ;

@selected_elements = @{$self->{ELEMENTS}} unless(@selected_elements) ;

$self->deselect_all_elements() ;

for my $element (@selected_elements)
{
    $element->{SELECTED} = ++$self->{SELECTION_INDEX} if (! defined($element->{CROSS_ENUM}) || ($element->{CROSS_ENUM} == 0));
}
}

#-----------------------------------------------------------------------------

sub select_normal_filler_elements_from_selected_elements
{
my ($self) = @_;

my @selected_elements = $self->get_selected_elements(1) ;

@selected_elements = @{$self->{ELEMENTS}} unless(@selected_elements) ;

$self->deselect_all_elements() ;

for my $element (@selected_elements)
{
    $element->{SELECTED} = ++$self->{SELECTION_INDEX} if (defined($element->{CROSS_ENUM}) && ($element->{CROSS_ENUM} == 1));
}
}

#-----------------------------------------------------------------------------

sub switch_to_normal_elements_from_selected_elements
{
my ($self) = @_;

my @selected_elements = $self->get_selected_elements(1) ;

unless(@selected_elements)
	{
	@selected_elements = @{$self->{ELEMENTS}} ;
	print("switch all elements to normal elements!\n") ;
	}
else
	{
	print("switch selected elements to normal elements!\n") ;
	}

for my $element (@selected_elements)
{
    $element->{CROSS_ENUM} = undef if (defined($element->{CROSS_ENUM}) && ($element->{CROSS_ENUM} == 3));
	$element->{CROSS_ENUM} = 1 if (defined($element->{CROSS_ENUM}) && ($element->{CROSS_ENUM} == 2));
}
}

#-----------------------------------------------------------------------------

sub switch_to_cross_elements_from_selected_elements
{
my ($self) = @_;

my @selected_elements = $self->get_selected_elements(1) ;

unless(@selected_elements)
	{
	@selected_elements = @{$self->{ELEMENTS}} ;
	print("switch all elements to corss elements!\n") ;
	}
else
	{
	print("switch selected elements to corss elements!\n") ;
	}

for my $element (@selected_elements)
{
    $element->{CROSS_ENUM} = 3 if (! defined($element->{CROSS_ENUM}) || ($element->{CROSS_ENUM} == 0));
	$element->{CROSS_ENUM} = 2 if (defined($element->{CROSS_ENUM}) && ($element->{CROSS_ENUM} == 1));
}
}

#-----------------------------------------------------------------------------

sub switch_cross_mode
{

my ($self) = @_;

if($self->{CROSS_MODE} == 1)
	{
    $self->{CROSS_MODE} = 0;
	print("exit cross mode\n");
	}
else 
	{
    $self->{CROSS_MODE} = 1;
	print("enter cross mode\n");
	}

$self->set_title($self->get_title()) ;

}

#-----------------------------------------------------------------------------
# ascii: + X . '
# unicode: ┼ ┤ ├ ┬ ┴ ╭ ╮ ╯ ╰ ╳ 
# todo: 1. performance problem
#       2. ⍀ ⌿ these two symbols are not necessary
#       3. char color
#       4. Support for other tab symbols, including arrows and boxes

{

my %normal_char_cache;
my %diagonal_char_cache;
my $undef_char = 'Ȝ';


my @normal_char_func = (
	['+', \&scene_cross, 0],
	['.', \&scene_dot, 0],
	['\'',\&scene_apostrophe, 0],
	
	# todo: bold thin mix 45 chars
	#       such as: ┮ ┪ ┪ ┡ ... ...
	#       Due to the low degree of recognition, 
	#       it will not be implemented for the time 
	#       being, but it is enough for now
	# double thin mix filler
	# Naming rules: first horizontal and then vertical
	['╫', \&scene_unicode_mix_cross_thin_double, 0],
	['╪', \&scene_unicode_mix_cross_double_thin, 0],
	['╨', \&scene_unicode_mix_cross_lose_down_thin_double, 0],
	['╧', \&scene_unicode_mix_cross_lose_down_double_thin, 0],
	['╥', \&scene_unicode_mix_cross_lose_up_thin_double, 0],
	['╤', \&scene_unicode_mix_cross_lose_up_double_thin, 0],
	['╢', \&scene_unicode_mix_cross_lose_right_thin_double, 0],
	['╡', \&scene_unicode_mix_cross_lose_rigth_double_thin, 0],
	['╟', \&scene_unicode_mix_cross_lose_left_thin_double, 0],
	['╞', \&scene_unicode_mix_cross_lose_left_double_thin, 0],
	['╜', \&scene_unicode_mix_thin_left_double_up, 0],
	['╛', \&scene_unicode_mix_double_left_thin_up, 0],
	['╙', \&scene_unicode_mix_thin_right_double_up, 0],
	['╘', \&scene_unicode_mix_double_right_thin_up, 0],
	['╖', \&scene_unicode_mix_thin_left_double_down, 0],
	['╕', \&scene_unicode_mix_double_left_thin_down, 0],
	['╓', \&scene_unicode_mix_thin_right_double_down, 0],
	['╒', \&scene_unicode_mix_double_right_thin_down, 0],

	# pure filler
	['┼', \&scene_unicode_cross, 0],
	['┤', \&scene_unicode_cross_lose_right, 0],
	['├', \&scene_unicode_cross_lose_left, 0],
	['┬', \&scene_unicode_cross_lose_up, 0],
	['┴', \&scene_unicode_cross_lose_down, 0],
	['╭', \&scene_unicode_right_down, 0],
	['╮', \&scene_unicode_left_down, 0],
	['╯', \&scene_unicode_left_up, 0],
	['╰', \&scene_unicode_right_up, 0],
	['╋', \&scene_unicode_cross, 1],
	['┫', \&scene_unicode_cross_lose_right, 1],
	['┣', \&scene_unicode_cross_lose_left, 1],
	['┳', \&scene_unicode_cross_lose_up, 1],
	['┻', \&scene_unicode_cross_lose_down, 1],
	['┏', \&scene_unicode_right_down, 1],
	['┓', \&scene_unicode_left_down, 1],
	['┛', \&scene_unicode_left_up, 1],
	['┗', \&scene_unicode_right_up, 1],
	['╬', \&scene_unicode_cross, 2],
	['╣', \&scene_unicode_cross_lose_right, 2],
	['╠', \&scene_unicode_cross_lose_left, 2],
	['╦', \&scene_unicode_cross_lose_up, 2],
	['╩', \&scene_unicode_cross_lose_down, 2],
	['╔', \&scene_unicode_right_down, 2],
	['╗', \&scene_unicode_left_down, 2],
	['╝', \&scene_unicode_left_up, 2],
	['╚', \&scene_unicode_right_up, 2],
) ;

my @diagonal_char_func = (
	['X', \&scene_x],
	['╳', \&scene_unicode_x],
) ;

my %cross_filler_chars = map {$_, 1} ( 
	'-', '|', '.', '\'', '\\', '/', 
	'─', '│', '┼', '┤', '├', '┬', '┴', '╭', '╮', '╯', '╰',
	'━', '┃', '╋', '┫', '┣', '┳', '┻', '┏', '┓', '┛', '┗', 
	'═', '║', '╬', '╣', '╠', '╦', '╩', '╔', '╗', '╝', '╚',
	'╫', '╪', '╨', '╧', '╥', '╤', '╢', '╡', '╟', '╞', '╜', 
	'╛', '╙', '╘', '╖', '╕', '╓', '╒') ;

my %unicode_left_chars_thin    = map {$_, 1} ('─',      '┼',      '├', '┬', '┴', '╭',            '╰') ;
my %unicode_left_chars_bold    = map {$_, 1} ('━',      '╋',      '┣', '┳', '┻', '┏',            '┗') ;
my %unicode_left_chars_double  = map {$_, 1} ('═',      '╬',      '╠', '╦', '╩', '╔',            '╚') ;
my %unicode_right_chars_thin   = map {$_, 1} ('─',      '┼', '┤',      '┬', '┴',      '╮', '╯'      ) ;
my %unicode_right_chars_bold   = map {$_, 1} ('━',      '╋', '┫',      '┳', '┻',      '┓', '┛'      ) ;
my %unicode_right_chars_double = map {$_, 1} ('═',      '╬', '╣',      '╦', '╩',      '╗', '╝'      ) ;
my %unicode_up_chars_thin      = map {$_, 1} (     '│', '┼', '┤', '├', '┬',      '╭', '╮'           ) ;
my %unicode_up_chars_bold      = map {$_, 1} (     '┃', '╋', '┫', '┣', '┳',      '┏', '┓'           ) ;
my %unicode_up_chars_double    = map {$_, 1} (     '║', '╬', '╣', '╠', '╦',      '╔', '╗'           ) ;
my %unicode_down_chars_thin    = map {$_, 1} (     '│', '┼', '┤', '├',      '┴',            '╯', '╰') ;
my %unicode_down_chars_bold    = map {$_, 1} (     '┃', '╋', '┫', '┣',      '┻',            '┛', '┗') ;
my %unicode_down_chars_double  = map {$_, 1} (     '║', '╬', '╣', '╠',      '╩',            '╝', '╚') ;
my %unicode_mix_left_thin_chars    = map {$_, 1} ('╫', '╨', '╥', '╟', '╙', '╓') ;
my %unicode_mix_right_thin_chars   = map {$_, 1} ('╫', '╨', '╥', '╢', '╜', '╖') ;
my %unicode_mix_up_thin_chars      = map {$_, 1} ('╪', '╤', '╡', '╞', '╕', '╒') ;
my %unicode_mix_down_thin_chars    = map {$_, 1} ('╪', '╧', '╡', '╞', '╛', '╘') ;
my %unicode_mix_left_double_chars  = map {$_, 1} ('╪', '╧', '╤', '╞', '╘', '╒') ;
my %unicode_mix_right_double_chars = map {$_, 1} ('╪', '╧', '╤', '╡', '╛', '╕') ;
my %unicode_mix_up_double_chars    = map {$_, 1} ('╫', '╥', '╢', '╟', '╖', '╓') ;
my %unicode_mix_down_double_chars  = map {$_, 1} ('╫', '╨', '╢', '╟', '╜', '╙') ;

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

#~ this func is slow
($old_cross_elements, $ascii_array_ref, $index_ref) = $self->transform_elements_to_ascii_two_dimensional_array_for_cross_mode();
@ascii_array = @{$ascii_array_ref} ;

my ($row, $col, $scene_func, @elements_to_be_add, $cross_index) ;
my ($up, $down, $left, $right, $char_45, $char_135, $char_225, $char_315, $normal_key, $diagonal_key);
for $cross_index (@{$index_ref})
	{
	($row, $col) = ($cross_index->[0], $cross_index->[1]) ;
	next unless((exists($cross_filler_chars{$ascii_array[$row][$col]})));

	($up, $down, $left, $right) = ($ascii_array[$row-1][$col], $ascii_array[$row+1][$col], $ascii_array[$row][$col-1], $ascii_array[$row][$col+1]);

	$normal_key = ($up || $undef_char) . ($down || $undef_char) . ($left || $undef_char) . ($right || $undef_char);

	unless(exists($normal_char_cache{$normal_key}))
	{
		$scene_func = first { $_->[1]($up, $down, $left, $right, $_->[2]) } @normal_char_func;
		$normal_char_cache{$normal_key} = ($scene_func) ? $scene_func->[0] : '';
	}

	if($normal_char_cache{$normal_key}) {
		$old_key = $col . '-' . $row;
		if(exists($old_cross_elements->{$old_key}) && ($old_cross_elements->{$old_key} eq $normal_char_cache{$normal_key}))
		{
			if($normal_char_cache{$normal_key} ne $ascii_array[$row][$col])
			{
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

$self->delete_elements(grep{ defined($_->{CROSS_ENUM}) && ($_->{CROSS_ENUM} == 2) 
	&& !(defined $not_delete_cross_fillers{$_->{X} . '-' . $_->{Y} . '-' . $_->{TEXT_ONLY}}) } @{$self->{ELEMENTS}}) ;
$self->create_cross_fillers(@elements_to_be_add) if(@elements_to_be_add)  ;
}

#-----------------------------------------------------------------------------
# +
sub scene_cross
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($up) && defined($down) && defined($left) && defined($right)) ;

return (($up eq '|' || $up eq '.' || $up eq '\'') &&
		($down eq '|' || $down eq '.' || $down eq '\'') &&
		($left eq '-' || $left eq '.' || $left eq '\'') &&
		($right eq '-' || $right eq '.' || $right eq '\'')) ;

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

return 0 if((defined($up) && $up eq '|') && (defined($down) && $down eq '|') && 
			(defined($left) && $left eq '-') && (defined($right) && $right eq '-'));

return (((defined($left) && $left eq '-') && (defined($down) && $down eq '|')) || 
	   ((defined($right) && $right eq '-') && (defined($down) && $down eq '|'))) ;
}

#-----------------------------------------------------------------------------
# '
#       |          |       |
#       |          |       |
#       '---    ---'    ---'---
sub scene_apostrophe
{
my ($up, $down, $left, $right, $index) = @_;

return 1 if(((defined($up) && $up eq '|') && (defined($right) && $right eq '-')) && 
			!(defined($down) && $down eq '|')) ;

return ((defined($up) && $up eq '|') && (defined($left) && $left eq '-') && 
		!((defined($down) && $down eq '|') || (defined($right) && $right eq '|'))) ;

}

#-----------------------------------------------------------------------------
# ┼
sub scene_unicode_cross
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($up) && defined($down) && defined($left) && defined($right)) ;

return (exists($unicode_up_chars[$index]{$up}) &&
		exists($unicode_down_chars[$index]{$down}) &&
		exists($unicode_left_chars[$index]{$left}) &&
		exists($unicode_right_chars[$index]{$right})) ;
}

#-----------------------------------------------------------------------------
# ┤
sub scene_unicode_cross_lose_right
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($up) && defined($down) && defined($left)) ;

return 0 if(defined($right) && exists($unicode_right_chars[$index]{$right})) ;

return (exists($unicode_up_chars[$index]{$up}) &&
		exists($unicode_down_chars[$index]{$down}) &&
		exists($unicode_left_chars[$index]{$left})) ;
}

#-----------------------------------------------------------------------------
# ├
sub scene_unicode_cross_lose_left
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($up) && defined($down) && defined($right)) ;

return 0 if(defined($left) && exists($unicode_left_chars[$index]{$left})) ;

return (exists($unicode_up_chars[$index]{$up}) &&
		exists($unicode_down_chars[$index]{$down}) &&
		exists($unicode_right_chars[$index]{$right})) ;
}

#-----------------------------------------------------------------------------
# ┬
sub scene_unicode_cross_lose_up
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($down) && defined($left) && defined($right)) ;

return 0 if(defined($up) && exists($unicode_up_chars[$index]{$up})) ;

return (exists($unicode_down_chars[$index]{$down}) &&
		exists($unicode_left_chars[$index]{$left}) &&
		exists($unicode_right_chars[$index]{$right})) ;
}

#-----------------------------------------------------------------------------
# ┴
sub scene_unicode_cross_lose_down
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($up) && defined($left) && defined($right)) ;

return 0 if(defined($down) && exists($unicode_down_chars[$index]{$down})) ;

return (exists($unicode_up_chars[$index]{$up}) &&
		exists($unicode_left_chars[$index]{$left}) &&
		exists($unicode_right_chars[$index]{$right})) ;
}

#-----------------------------------------------------------------------------
# ╭
sub scene_unicode_right_down
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($down) && defined($right)) ;

return 0 if((defined($up) && exists($unicode_up_chars[$index]{$up})) || 
			(defined($left) && exists($unicode_left_chars[$index]{$left}))) ;

return (exists($unicode_down_chars[$index]{$down}) &&
		exists($unicode_right_chars[$index]{$right})) ;
}

#-----------------------------------------------------------------------------
# ╮
sub scene_unicode_left_down
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($down) && defined($left)) ;

return 0 if ((defined($up) && exists($unicode_up_chars[$index]{$up})) ||
			 (defined($right) && exists($unicode_right_chars[$index]{$right})));

return (exists($unicode_down_chars[$index]{$down}) &&
		exists($unicode_left_chars[$index]{$left})) ;
}

#-----------------------------------------------------------------------------
# ╯
sub scene_unicode_left_up
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($up) && defined($left)) ;

return 0 if((defined($down) && exists($unicode_down_chars[$index]{$down})) || 
			(defined($right) && exists($unicode_right_chars[$index]{$right}))) ;

return (exists($unicode_up_chars[$index]{$up}) &&
		exists($unicode_left_chars[$index]{$left})) ;
}

#-----------------------------------------------------------------------------
# ╰
sub scene_unicode_right_up
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($up) && defined($right)) ;

return 0 if((defined($left) && exists($unicode_left_chars[$index]{$left})) || 
			(defined($down) && exists($unicode_down_chars[$index]{$down})));

return (exists($unicode_up_chars[$index]{$up}) &&
		exists($unicode_right_chars[$index]{$right})) ;
}

#-----------------------------------------------------------------------------
# ╫
sub scene_unicode_mix_cross_thin_double
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($up) && defined($down) && defined($left) && defined($right)) ;

return ((exists($unicode_up_chars[2]{$up}) || exists($unicode_mix_up_double_chars{$up})) &&
		(exists($unicode_down_chars[2]{$down}) || exists($unicode_mix_down_double_chars{$down})) &&
		(exists($unicode_left_chars[0]{$left}) || exists($unicode_mix_left_thin_chars{$left})) &&
		(exists($unicode_right_chars[0]{$right}) || exists($unicode_mix_right_thin_chars{$right}))) ;

}

#-----------------------------------------------------------------------------
# ╪
sub scene_unicode_mix_cross_double_thin
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($up) && defined($down) && defined($left) && defined($right)) ;

return ((exists($unicode_up_chars[0]{$up}) || exists($unicode_mix_up_thin_chars{$up})) &&
		(exists($unicode_down_chars[0]{$down}) || exists($unicode_mix_down_thin_chars{$down})) &&
		(exists($unicode_left_chars[2]{$left}) || exists($unicode_mix_left_double_chars{$left})) &&
		(exists($unicode_right_chars[2]{$right}) || exists($unicode_mix_right_double_chars{$right}))) ;

}

#-----------------------------------------------------------------------------
# ╨
sub scene_unicode_mix_cross_lose_down_thin_double
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($up) && defined($left) && defined($right)) ;

return 0 if(defined($down) && (exists($unicode_down_chars[2]{$down}) || exists($unicode_mix_down_double_chars{$down}))) ;

return ((exists($unicode_up_chars[2]{$up}) || exists($unicode_mix_up_double_chars{$up})) &&
		(exists($unicode_left_chars[0]{$left}) || exists($unicode_mix_left_thin_chars{$left})) &&
		(exists($unicode_right_chars[0]{$right}) || exists($unicode_mix_right_thin_chars{$right}))) ;

}

#-----------------------------------------------------------------------------
# ╧
sub scene_unicode_mix_cross_lose_down_double_thin
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($up) && defined($left) && defined($right)) ;

return 0 if(defined($down) && (exists($unicode_down_chars[0]{$down}) || exists($unicode_mix_down_thin_chars{$down}))) ;

return ((exists($unicode_up_chars[0]{$up}) || exists($unicode_mix_up_thin_chars{$up})) &&
		(exists($unicode_left_chars[2]{$left}) || exists($unicode_mix_left_double_chars{$left})) &&
		(exists($unicode_right_chars[2]{$right}) || exists($unicode_mix_right_double_chars{$right}))) ;

}

#-----------------------------------------------------------------------------
# ╥
sub scene_unicode_mix_cross_lose_up_thin_double
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($down) && defined($left) && defined($right)) ;

return 0 if(defined($up) && (exists($unicode_up_chars[2]{$up}) || exists($unicode_mix_up_double_chars{$up}))) ;

return ((exists($unicode_down_chars[2]{$down}) || exists($unicode_mix_down_double_chars{$down})) &&
		(exists($unicode_left_chars[0]{$left}) || exists($unicode_mix_left_thin_chars{$left})) &&
		(exists($unicode_right_chars[0]{$right}) || exists($unicode_mix_right_thin_chars{$right}))) ;

}

#-----------------------------------------------------------------------------
# ╤
sub scene_unicode_mix_cross_lose_up_double_thin
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($down) && defined($left) && defined($right)) ;

return 0 if(defined($up) && (exists($unicode_up_chars[0]{$up}) || exists($unicode_mix_up_thin_chars{$up}))) ;

return ((exists($unicode_down_chars[0]{$down}) || exists($unicode_mix_down_thin_chars{$down})) &&
		(exists($unicode_left_chars[2]{$left}) || exists($unicode_mix_left_double_chars{$left})) &&
		(exists($unicode_right_chars[2]{$right}) || exists($unicode_mix_right_double_chars{$right}))) ;

}

#-----------------------------------------------------------------------------
# ╢
sub scene_unicode_mix_cross_lose_right_thin_double
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($up) && defined($down) && defined($left)) ;

return 0 if(defined($right) && (exists($unicode_right_chars[0]{$right}) || exists($unicode_mix_right_thin_chars{$right}))) ;

return ((exists($unicode_up_chars[2]{$up}) || exists($unicode_mix_up_double_chars{$up})) &&
		(exists($unicode_down_chars[2]{$down}) || exists($unicode_mix_down_double_chars{$down})) &&
		(exists($unicode_left_chars[0]{$left}) || exists($unicode_mix_left_thin_chars{$left}))) ;

}

#-----------------------------------------------------------------------------
# ╡
sub scene_unicode_mix_cross_lose_rigth_double_thin
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($up) && defined($down) && defined($left)) ;

return 0 if(defined($right) && (exists($unicode_right_chars[2]{$right}) || exists($unicode_mix_right_double_chars{$right}))) ;

return ((exists($unicode_up_chars[0]{$up}) || exists($unicode_mix_up_thin_chars{$up})) &&
		(exists($unicode_down_chars[0]{$down}) || exists($unicode_mix_down_thin_chars{$down})) &&
		(exists($unicode_left_chars[2]{$left}) || exists($unicode_mix_left_double_chars{$left}))) ;

}

#-----------------------------------------------------------------------------
# ╟
sub scene_unicode_mix_cross_lose_left_thin_double
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($up) && defined($down) && defined($right)) ;

return 0 if(defined($left) && (exists($unicode_left_chars[0]{$left}) || exists($unicode_mix_left_thin_chars{$left}))) ;

return ((exists($unicode_up_chars[2]{$up}) || exists($unicode_mix_up_double_chars{$up})) &&
		(exists($unicode_down_chars[2]{$down}) || exists($unicode_mix_down_double_chars{$down})) &&
		(exists($unicode_right_chars[0]{$right}) || exists($unicode_mix_right_thin_chars{$right}))) ;

}

#-----------------------------------------------------------------------------
# ╞
sub scene_unicode_mix_cross_lose_left_double_thin
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($up) && defined($down) && defined($right)) ;

return 0 if(defined($left) && (exists($unicode_left_chars[2]{$left}) || exists($unicode_mix_left_double_chars{$left}))) ;

return ((exists($unicode_up_chars[0]{$up}) || exists($unicode_mix_up_thin_chars{$up})) &&
		(exists($unicode_down_chars[0]{$down}) || exists($unicode_mix_down_thin_chars{$down})) &&
		(exists($unicode_right_chars[2]{$right}) || exists($unicode_mix_right_double_chars{$right}))) ;

}

#-----------------------------------------------------------------------------
# ╜
sub scene_unicode_mix_thin_left_double_up
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($up) && defined($left)) ;

return 0 if((defined($down) && (exists($unicode_down_chars[2]{$down}) || exists($unicode_mix_down_double_chars{$down}))) || 
			(defined($right) && (exists($unicode_right_chars[0]{$right}) || exists($unicode_mix_right_thin_chars{$right})))) ;

return ((exists($unicode_up_chars[2]{$up}) || exists($unicode_mix_up_double_chars{$up})) &&
		(exists($unicode_left_chars[0]{$left}) || exists($unicode_mix_left_thin_chars{$left}))) ;

}

#-----------------------------------------------------------------------------
# ╛
sub scene_unicode_mix_double_left_thin_up
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($up) && defined($left)) ;

return 0 if((defined($down) && (exists($unicode_down_chars[0]{$down}) || exists($unicode_mix_down_thin_chars{$down}))) || 
			(defined($right) && (exists($unicode_right_chars[2]{$right}) || exists($unicode_mix_right_double_chars{$right})))) ;

return ((exists($unicode_up_chars[0]{$up}) || exists($unicode_mix_up_thin_chars{$up})) &&
		(exists($unicode_left_chars[2]{$left}) || exists($unicode_mix_left_double_chars{$left}))) ;

}

#-----------------------------------------------------------------------------
# ╙
sub scene_unicode_mix_thin_right_double_up
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($up) && defined($right)) ;

return 0 if((defined($left) && (exists($unicode_left_chars[0]{$left}) || exists($unicode_mix_left_thin_chars{$left}))) || 
			(defined($down) && (exists($unicode_down_chars[2]{$down}) || exists($unicode_mix_down_double_chars{$down}))));

return ((exists($unicode_up_chars[2]{$up}) || exists($unicode_mix_up_double_chars{$up})) &&
		(exists($unicode_right_chars[0]{$right}) || exists($unicode_mix_right_thin_chars{$right}))) ;

}

#-----------------------------------------------------------------------------
# ╘
sub scene_unicode_mix_double_right_thin_up
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($up) && defined($right)) ;

return 0 if((defined($left) && (exists($unicode_left_chars[2]{$left}) || exists($unicode_mix_left_double_chars{$left}))) || 
			(defined($down) && (exists($unicode_down_chars[0]{$down}) || exists($unicode_mix_down_thin_chars{$down}))));

return ((exists($unicode_up_chars[0]{$up}) || exists($unicode_mix_up_thin_chars{$up})) &&
		(exists($unicode_right_chars[2]{$right}) || exists($unicode_mix_right_double_chars{$right}))) ;

}

#-----------------------------------------------------------------------------
# ╖
sub scene_unicode_mix_thin_left_double_down
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($down) && defined($left)) ;

return 0 if ((defined($up) && (exists($unicode_up_chars[2]{$up}) || exists($unicode_mix_up_double_chars{$up}))) ||
			 (defined($right) && (exists($unicode_right_chars[0]{$right}) || exists($unicode_mix_right_thin_chars{$right}))));

return ((exists($unicode_down_chars[2]{$down}) || exists($unicode_mix_down_double_chars{$down})) &&
		(exists($unicode_left_chars[0]{$left}) || exists($unicode_mix_left_thin_chars{$left}))) ;

}

#-----------------------------------------------------------------------------
# ╕
sub scene_unicode_mix_double_left_thin_down
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($down) && defined($left)) ;

return 0 if ((defined($up) && (exists($unicode_up_chars[0]{$up}) || exists($unicode_mix_up_thin_chars{$up}))) ||
			 (defined($right) && (exists($unicode_right_chars[2]{$right}) || exists($unicode_mix_right_double_chars{$right}))));

return ((exists($unicode_down_chars[0]{$down}) || exists($unicode_mix_down_thin_chars{$down})) &&
		(exists($unicode_left_chars[2]{$left}) || exists($unicode_mix_left_double_chars{$left}))) ;


}

#-----------------------------------------------------------------------------
# ╓
sub scene_unicode_mix_thin_right_double_down
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($down) && defined($right)) ;

return 0 if((defined($up) && (exists($unicode_up_chars[2]{$up}) || exists($unicode_mix_up_double_chars{$up}))) || 
			(defined($left) && (exists($unicode_left_chars[0]{$left}) || exists($unicode_mix_left_thin_chars{$left})))) ;

return ((exists($unicode_down_chars[2]{$down}) || exists($unicode_mix_down_double_chars{$down})) &&
		(exists($unicode_right_chars[0]{$right}) || exists($unicode_mix_right_thin_chars{$right}))) ;

}

#-----------------------------------------------------------------------------
# ╒
sub scene_unicode_mix_double_right_thin_down
{
my ($up, $down, $left, $right, $index) = @_;

return 0 unless(defined($down) && defined($right)) ;

return 0 if((defined($up) && (exists($unicode_up_chars[0]{$up}) || exists($unicode_mix_up_thin_chars{$up}))) || 
			(defined($left) && (exists($unicode_left_chars[2]{$left}) || exists($unicode_mix_left_double_chars{$left})))) ;

return ((exists($unicode_down_chars[0]{$down}) || exists($unicode_mix_down_thin_chars{$down})) &&
		(exists($unicode_right_chars[2]{$right}) || exists($unicode_mix_right_double_chars{$right}))) ;

}

#-----------------------------------------------------------------------------
# X
sub scene_x
{
my ($char_45, $char_135, $char_225, $char_315) = @_;

return 0 unless(defined($char_45) && defined($char_135) && defined($char_225) && defined($char_315));

return (($char_45 eq '/' || $char_45 eq '^') && 
		($char_135 eq '\\' || $char_135 eq 'v') && 
		($char_225 eq '/' || $char_225 eq 'v') && 
		($char_315 eq '\\' || $char_315 eq '^')) ;

}

#-----------------------------------------------------------------------------
# ╳
sub scene_unicode_x
{
my ($char_45, $char_135, $char_225, $char_315) = @_;

return 0 unless(defined($char_45) && defined($char_135) && defined($char_225) && defined($char_315));

return (($char_45 eq '╱' || $char_45 eq '^') && 
		($char_135 eq '╲' || $char_135 eq 'v') && 
		($char_225 eq '╱' || $char_225 eq 'v') && 
		($char_315 eq '╲' || $char_315 eq '^')) ;
}

}

#----------------------------------------------------------------------------------------------

sub create_line
{
my ($self, $all_type) = @_;

my ($line_type, $cross_type) = @{$all_type} ;

my $arrow_type ;

if($line_type == 0)
	{
	$arrow_type = [
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
			] ;
	}
elsif($line_type == 1)
	{
		$arrow_type = [
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
			] ;
	}
elsif($line_type == 2)
	{
		$arrow_type = [
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
			] ;
	}
elsif($line_type == 3)
	{
		$arrow_type = [
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
			] ;
	}

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
	$my_line_obj->{CROSS_ENUM} = 3;
	}
$my_line_obj->{NAME} = 'line';
$my_line_obj->enable_autoconnect(0);
$my_line_obj->allow_connection('start', 0);
$my_line_obj->allow_connection('end', 0);

$self->add_element_at($my_line_obj, $self->{MOUSE_X}, $self->{MOUSE_Y});

}

#-----------------------------------------------------------------------------


1 ;

