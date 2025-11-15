
package App::Asciio::Boxes ;

use strict ; use warnings ;
use utf8 ;

use Clone ;

#----------------------------------------------------------------------------------------------

use Exporter qw( import ) ;

use constant TOP             => 0 ;
use constant TITLE_SEPARATOR => 1 ;
use constant BODY_SEPARATOR  => 2 ;
use constant BOTTOM          => 3 ;

use constant DISPLAY         => 0 ;
use constant NAME            => 1 ;
use constant LEFT            => 2 ;
use constant BODY            => 3 ;
use constant RIGHT           => 4 ;

our @EXPORT_OK = qw(TOP TITLE_SEPARATOR BODY_SEPARATOR BOTTOM DISPLAY NAME LEFT BODY RIGHT) ;
our %EXPORT_TAGS = ( const => [ qw(TOP TITLE_SEPARATOR BODY_SEPARATOR BOTTOM DISPLAY NAME LEFT BODY RIGHT) ] );

#----------------------------------------------------------------------------------------------

{

use Clone ;

use Readonly ;

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
	unicode_imaginary =>
		[
			[1, 'top',             '┌', '┄',   '┐', 1, ],
			[0, 'title separator', '┆', '┄',   '┆', 1, ],
			[1, 'body separator',  '┆ ', '┆', ' ┆', 1, ], 
			[1, 'bottom',          '└', '┄',   '┘', 1, ],
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
	unicode_bold_imaginary =>
		[
			[1, 'top',             '┏', '┅',   '┓', 1, ],
			[0, 'title separator', '┇', '┅',   '┇', 1, ],
			[1, 'body separator',  '┇ ', '┇', ' ┇', 1, ], 
			[1, 'bottom',          '┗', '┅',   '┛', 1, ],
			[1, 'fill-character',  '',   ' ', '',   1, ],
		],
	unicode_double =>
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

sub change_type
{
my ($self, $type_definition, $create_undo_snapshot) = @_ ;

$create_undo_snapshot //= 1 ;

my $new_type = defined $type_definition->{USER_TYPE}
			? $type_definition->{USER_TYPE}          # use the type passed as argument
			: $box_types{$type_definition->{TYPE}} ; # use a predefined type

if(defined $new_type)
	{
	$self->create_undo_snapshot() if $create_undo_snapshot ;
	
	my $element_type = $type_definition->{ELEMENT}->get_box_type() ;
	
	my $new_type = Clone::clone($new_type) ;
	
	for (my $frame_element_index = 0 ; $frame_element_index < @{$new_type} ; $frame_element_index++)
		{
		$new_type->[$frame_element_index][DISPLAY] = $element_type->[$frame_element_index][DISPLAY] 
		}
		
	$type_definition->{ELEMENT}->set_box_type($new_type) ;
	
	$self->update_display() if $create_undo_snapshot ;
	}
}

}

# ------------------------------------------------------------------------------

1 ;
