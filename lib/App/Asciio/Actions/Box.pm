
package App::Asciio::Actions::Box ;

use strict ;
use warnings ;
use utf8 ;

use Clone ;

#----------------------------------------------------------------------------------------------

use Readonly ;

Readonly my $TOP => 0 ;
Readonly my $TITLE_SEPARATOR => 1 ;
Readonly my $BODY_SEPARATOR => 2 ;
Readonly my $BOTTOM => 3;

Readonly my $DISPLAY => 0 ;
Readonly my $NAME => 1 ;
Readonly my $LEFT => 2 ;
Readonly my $BODY => 3 ;
Readonly my $RIGHT => 4 ;

my %box_types = 
	(
	dash =>
		[
			[1, 'top',             '.', '-',   '.', 1, ],
			[0, 'title separator', '|', '-',   '|', 1, ],
			[1, 'body separator',  '| ', '|', ' |', 1, ], 
			[1, 'bottom',          '\'', '-', '\'', 1, ],
			[1, 'fill-character',  '',   ' ', '',   1, ],
		],
	dot =>
		[
			[1, 'top',             '.',  '.',  '.', 1, ],
			[0, 'title separator', '.',  '.',  '.', 1, ],
			[1, 'body separator',  '. ', '.', ' .', 1, ], 
			[1, 'bottom',          '.',  '.',  '.', 1, ],
			[1, 'fill-character',  '',   ' ', '',   1, ],
		],
	star =>
		[
			[1, 'top',             '*',  '*',  '*', 1, ],
			[0, 'title separator', '*',  '*',  '*', 1, ],
			[1, 'body separator',  '* ', '*', ' *', 1, ], 
			[1, 'bottom',          '*',  '*',  '*', 1, ],
			[1, 'fill-character',  '',   ' ', '',   1, ],
		],
	unicode =>
		[
			[1, 'top',             '╭', '─',   '╮', 1, ],
			[0, 'title separator', '│', '─',   '│', 1, ],
			[1, 'body separator',  '│ ', '│', ' │', 1, ], 
			[1, 'bottom',          '╰', '─',   '╯', 1, ],
			[1, 'fill-character',  '',   ' ', '',   1, ],
		],
	unicode_with_filler_type1 =>
		[
			[1, 'top',             '╭', '─',   '╮', 1, ],
			[0, 'title separator', '│', '─',   '│', 1, ],
			[1, 'body separator',  '│ ', '│', ' │', 1, ], 
			[1, 'bottom',          '╰', '─',   '╯', 1, ],
			[1, 'fill-character',  '',   '█', '',   1, ],
		],
	unicode_with_filler_type2 =>
		[
			[1, 'top',             '╭', '─',   '╮', 1, ],
			[0, 'title separator', '│', '─',   '│', 1, ],
			[1, 'body separator',  '│ ', '│', ' │', 1, ], 
			[1, 'bottom',          '╰', '─',   '╯', 1, ],
			[1, 'fill-character',  '',   '▒', '',   1, ],
		],
	unicode_with_filler_type3 =>
		[
			[1, 'top',             '╭', '─',   '╮', 1, ],
			[0, 'title separator', '│', '─',   '│', 1, ],
			[1, 'body separator',  '│ ', '│', ' │', 1, ], 
			[1, 'bottom',          '╰', '─',   '╯', 1, ],
			[1, 'fill-character',  '',   '░', '',   1, ],
		],
	unicode_with_filler_type4 =>
		[
			[1, 'top',             '╭', '─',   '╮', 1, ],
			[0, 'title separator', '│', '─',   '│', 1, ],
			[1, 'body separator',  '│ ', '│', ' │', 1, ], 
			[1, 'bottom',          '╰', '─',   '╯', 1, ],
			[1, 'fill-character',  '',   '▚', '',   1, ],
		],
	unicode_bold =>
		[
			[1, 'top',             '┏', '━',   '┓', 1, ],
			[0, 'title separator', '┃', '━',   '┃', 1, ],
			[1, 'body separator',  '┃ ', '┃', ' ┃', 1, ], 
			[1, 'bottom',          '┗', '━',   '┛', 1, ],
			[1, 'fill-character',  '',   ' ', '',   1, ],
		],
	unicode_double_line =>
		[
			[1, 'top',             '╔', '═',   '╗', 1, ],
			[0, 'title separator', '║', '═',   '║', 1, ],
			[1, 'body separator',  '║ ', '║', ' ║', 1, ], 
			[1, 'bottom',          '╚', '═',   '╝', 1, ],
			[1, 'fill-character',  '',   ' ', '',   1, ],
		],
	unicode_hollow_dot =>
		[
			[1, 'top',             '∘',  '∘',  '∘', 1, ],
			[0, 'title separator', '∘',  '∘',  '∘', 1, ],
			[1, 'body separator',  '∘ ', '∘', ' ∘', 1, ], 
			[1, 'bottom',          '∘',  '∘',  '∘', 1, ],
			[1, 'fill-character',  '',   ' ', '',   1, ],
		],
	unicode_math_parantheses =>
		[
			[1, 'top',             '⎛', ' ',   '⎞', 1, ],
			[0, 'title separator', '│', '─',   '│', 1, ],
			[1, 'body separator',  '⎜ ', '│', ' ⎟', 1, ], 
			[1, 'bottom',          '⎝', ' ',   '⎠', 1, ],
			[1, 'fill-character',  '',   ' ', '',   1, ],
		],
	math_parantheses =>
		[
			[1, 'top',             '/', ' ',  '\\', 1, ],
			[0, 'title separator', '│', '─',   '│', 1, ],
			[1, 'body separator',  '│ ', '│', ' │', 1, ], 
			[1, 'bottom',          '\\', ' ',  '/', 1, ],
			[1, 'fill-character',  '',   ' ', '',   1, ],
		],
	rhombus_normal =>
		[
			[1, 'top',             ',', '\'',   ',', 1, ], 
			[1, 'top-middle',    ',\'',   '', '\',', 1, ],
			[1, 'middle',          ':',   '',   ':', 1, ],
			[1, 'middle-bottom', '\',',   '', ',\'', 1, ],
			[1, 'bottom',         '\'',  ',',  '\'', 1, ] ,
			[1, 'fill-character','',     ' ', '',    1, ] ,
		],
	rhombus_normal_with_filler_star =>
		[
			[1, 'top',             ',', '\'',   ',', 1, ], 
			[1, 'top-middle',    ',\'',   '', '\',', 1, ],
			[1, 'middle',          ':',   '',   ':', 1, ],
			[1, 'middle-bottom', '\',',   '', ',\'', 1, ],
			[1, 'bottom',         '\'',  ',',  '\'', 1, ] ,
			[1, 'fill-character','',     '*', '',    1, ] ,
		],
	rhombus_sparseness =>
		[
			[1, 'top',            ',', '\'',  ',', 1, ], 
			[1, 'top-middle',    ', ',   '', ' ,', 1, ],
			[1, 'middle',         ':',   '',  ':', 1, ],
			[1, 'middle-bottom', ' ,',   '', ', ', 1, ],
			[1, 'bottom',        '\'',  ',', '\'', 1, ] ,
			[1, 'fill-character','',     ' ', '',    1, ] ,
		],
	rhombus_unicode_slash =>
		[
			[1, 'top',            ' ',  ',',  ' ', 1, ], 
			[1, 'top-middle',    '／',   '', '＼', 1, ],
			[1, 'middle',         '❬',   '',  '❭', 1, ],
			[1, 'middle-bottom', '＼',   '', '／', 1, ],
			[1, 'bottom',         ' ', '\'',  ' ', 1, ] ,
			[1, 'fill-character','',     ' ', '',    1, ] ,
		],
	ellipse_normal =>
		[
			#~  default bottom low middle high fix single
			[1, 'up-center-point',    '-', '', '', '', '', '_', '',  1, ], 
			[1, 'down-center-point',  '.', '', '', '', '', '\'', '-',  1, ], 
			[1, 'left-center-point',  '|', '', '', '', '', '(', '',  1, ], 
			[1, 'rigth-center-point', '|', '', '', '', '', ')', '',  1, ], 
			[1, 'left-up-area',       '/',  '_', '.', '-', '\'', ':', '!',  1, ], 
			[1, 'right-up-area',      '\\', '_', '.', '-', '\'', ':', '!',  1, ], 
			[1, 'left-down-area',     '\\', '_', '.', '-', '\'', ':', '!',  1, ], 
			[1, 'right-down-area',    '/',  '_', '.', '-', '\'', ':', '!',  1, ], 
			[1, 'fill-character',     ' ',  '', '', '', '', '', '',  1, ], 
		] ,
	ellipse_normal_with_filler_star =>
		[
			#~  default bottom low middle high fix single
			[1, 'up-center-point',    '-', '', '', '', '', '_', '',  1, ], 
			[1, 'down-center-point',  '.', '', '', '', '', '\'', '-',  1, ], 
			[1, 'left-center-point',  '|', '', '', '', '', '(', '',  1, ], 
			[1, 'rigth-center-point', '|', '', '', '', '', ')', '',  1, ], 
			[1, 'left-up-area',       '/',  '_', '.', '-', '\'', ':', '!',  1, ], 
			[1, 'right-up-area',      '\\', '_', '.', '-', '\'', ':', '!',  1, ], 
			[1, 'left-down-area',     '\\', '_', '.', '-', '\'', ':', '!',  1, ], 
			[1, 'right-down-area',    '/',  '_', '.', '-', '\'', ':', '!',  1, ], 
			[1, 'fill-character',     '*',  '', '', '', '', '', '',  1, ], 
		] ,
	triangle_up_normal =>
		[
			['top',    '.',             ], 
			['middle', '/', '\\',       ],
			['bottom', '\'', '-', '\'', ] ,
		] ,
	triangle_up_dot =>
		[
			['top',    '.',             ], 
			['middle', '.',  '.',       ],
			['bottom', '\'', '.', '\'', ] ,
		] ,
	triangle_down_normal =>
		[
			['top',     '.', '-', '.', ], 
			['middle', '\\', '/',      ],
			['bottom', '\'',           ] ,
		] ,
	triangle_down_dot =>
		[
			['top',    '.', '.', '.', ], 
			['middle', '.', '.',      ],
			['bottom', '\'',          ] ,
		] ,
	) ;

#----------------------------------------------------------------------------------------------

use Scalar::Util ;
use App::Asciio::stripes::exec_box ;

sub box_context_menu
{
my ($self, $popup_x, $popup_y) = @_ ;
my @context_menu_entries ;

my ($character_width, $character_height) = $self->get_character_size() ;

my @selected_elements = $self->get_selected_elements(1) ;
my $element = $selected_elements[0] ;

if (@selected_elements == 1 && ('App::Asciio::stripes::triangle_up' eq ref $element))
	{
	push @context_menu_entries, 
		[ '/box type/normal', \&change_box_type, { ELEMENT => $element, TYPE => 'triangle_up_normal' } ], 
		[ '/box type/dot',    \&change_box_type, { ELEMENT => $element, TYPE => 'triangle_up_dot' } ] ;
	}

if (@selected_elements == 1 && ('App::Asciio::stripes::triangle_down' eq ref $element))
	{
	push @context_menu_entries, 
		[ '/box type/normal', \&change_box_type, { ELEMENT => $element, TYPE => 'triangle_down_normal' } ], 
		[ '/box type/dot',    \&change_box_type, { ELEMENT => $element, TYPE => 'triangle_down_dot' } ] ;
	}

if(@selected_elements == 1 && ($element->isa('App::Asciio::stripes::editable_box2') || 'App::Asciio::stripes::rhombus' eq ref $element || 'App::Asciio::stripes::ellipse' eq ref $element))
	{
	if('App::Asciio::stripes::rhombus' eq ref $element)
		{
		push @context_menu_entries, 
			[ '/box type/normal',                  \&change_box_type, { ELEMENT => $element, TYPE => 'rhombus_normal' } ], 
			[ '/box type/normal_with_filler_star', \&change_box_type, { ELEMENT => $element, TYPE => 'rhombus_normal_with_filler_star' } ], 
			[ '/box type/unicode_slash',           \&change_box_type, { ELEMENT => $element, TYPE => 'rhombus_unicode_slash' } ], 
			[ '/box type/sparseness',              \&change_box_type, { ELEMENT => $element, TYPE => 'rhombus_sparseness' } ] ;
		}
	if('App::Asciio::stripes::ellipse' eq ref $element)
		{
		push @context_menu_entries, 
			[ '/box type/normal',                  \&change_box_type, { ELEMENT => $element, TYPE => 'ellipse_normal' } ], 
			[ '/box type/normal_with_filler_star', \&change_box_type, { ELEMENT => $element, TYPE => 'ellipse_normal_with_filler_star' } ] ;
		}
	elsif($element->isa('App::Asciio::stripes::editable_box2'))
		{
		push @context_menu_entries, 
			[ '/box selected element',              \&box_selected_element, { ELEMENT => $element} ],
			[ '/box type/dash',                     \&change_box_type,      { ELEMENT => $element, TYPE => 'dash' } ], 
			[ '/box type/dot',                      \&change_box_type,      { ELEMENT => $element, TYPE => 'dot' } ], 
			[ '/box type/star',                     \&change_box_type,      { ELEMENT => $element, TYPE => 'star' } ],
			[ '/box type/math_parantheses',         \&change_box_type,      { ELEMENT => $element, TYPE => 'math_parantheses' } ],
			[ '/box type/unicode',                  \&change_box_type,      { ELEMENT => $element, TYPE => 'unicode' } ], 
			[ '/box type/unicode_bold',             \&change_box_type,      { ELEMENT => $element, TYPE => 'unicode_bold' } ], 
			[ '/box type/unicode_double_line',      \&change_box_type,      { ELEMENT => $element, TYPE => 'unicode_double_line' } ], 
			[ '/box type/unicode_with_filler_type1',\&change_box_type,      { ELEMENT => $element, TYPE => 'unicode_with_filler_type1' } ], 
			[ '/box type/unicode_with_filler_type2',\&change_box_type,      { ELEMENT => $element, TYPE => 'unicode_with_filler_type2' } ], 
			[ '/box type/unicode_with_filler_type3',\&change_box_type,      { ELEMENT => $element, TYPE => 'unicode_with_filler_type3' } ], 
			[ '/box type/unicode_with_filler_type4',\&change_box_type,      { ELEMENT => $element, TYPE => 'unicode_with_filler_type4' } ], 
			[ '/box type/unicode_hollow_dot',       \&change_box_type,      { ELEMENT => $element, TYPE => 'unicode_hollow_dot' } ], 
			[ '/box type/unicode_math_parantheses', \&change_box_type,      { ELEMENT => $element, TYPE => 'unicode_math_parantheses' } ] ;
		}

	# git mode connector
	if($element->isa('App::Asciio::stripes::editable_box2') && (defined $element->{NAME}) && ($element->{NAME} =~ /connector*/))
		{
		for my $connector_char (@{$self->{GIT_MODE_CONNECTOR_CHAR_LIST}})
			{
			push @context_menu_entries, [ '/git mode connector type/' . $connector_char,  \&git_mode_set_connector_char,  $connector_char ] ;
			}
		}
	
	push @context_menu_entries,
		[ '/rotate text', sub { $element->rotate_text() ; $self->update_display() ; } ],
		[
		$element->is_autoconnect_enabled() ? '/disable autoconnection' :  '/enable autoconnection', 
		
		sub 
			{
			$self->create_undo_snapshot() ;
			$element->enable_autoconnect(! $element->is_autoconnect_enabled()) ;
			$self->update_display() ;
			}
		] ;
	
	$element->is_border_connection_allowed()
		? push @context_menu_entries, ["/disable border connection", sub {$element->allow_border_connection(0) ;}]
		: push @context_menu_entries, ["/enable border connection",  sub {$element->allow_border_connection(1) ;}] ;
	
	$element->is_auto_shrink()
		? push @context_menu_entries, ["/disable auto shrink", sub {$element->flip_auto_shrink() ;}]
		: push @context_menu_entries, ["/enable auto shrink",  sub {$element->shrink() ; $element->flip_auto_shrink() ; }] ;
	}

return @context_menu_entries ;
}

#----------------------------------------------------------------------------------------------

sub change_box_type
{
my ($self, $data, $atomic_operation) = @_ ;

$atomic_operation //= 1 ;

if(exists $box_types{$data->{TYPE}})
	{
	$self->create_undo_snapshot() if $atomic_operation ;
	
	my $element_type = $data->{ELEMENT}->get_box_type() ;
	
	my $new_type = Clone::clone($box_types{$data->{TYPE}}) ;
	
	for (my $frame_element_index = 0 ; $frame_element_index < @{$new_type} ; $frame_element_index++)
		{
		$new_type->[$frame_element_index][$DISPLAY] = $element_type->[$frame_element_index][$DISPLAY] 
		}
		
	$data->{ELEMENT}->set_box_type($new_type) ;
	
	$self->update_display() if $atomic_operation ;
	}
}

#----------------------------------------------------------------------------------------------
sub git_mode_set_connector_char
{
my ($self, $set_char) = @_ ;
print("now git mode connector char " . $set_char . "\n") ;

use App::Asciio::Actions::Git ;
App::Asciio::Actions::Git->git_mode_set_connector_char($set_char) ;
}

#----------------------------------------------------------------------------------------------

sub box_selected_element
{
my ($self, $data) = @_ ;

$self->create_undo_snapshot() ;

my $element_type = $data->{ELEMENT}->get_box_type() ;
my ($title, $text) = $data->{ELEMENT}->get_text() ;

for (0 .. $#$element_type)
	{
	next if $_ == $TITLE_SEPARATOR && $title eq '' ;
	
	$element_type->[$_][$DISPLAY] = 1 ;
	}

$data->{ELEMENT}->set_box_type($element_type) ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

1 ;

