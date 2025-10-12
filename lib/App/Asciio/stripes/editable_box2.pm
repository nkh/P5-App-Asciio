
package App::Asciio::stripes::editable_box2 ;
use parent qw/App::Asciio::stripes::single_stripe/ ;

use strict;
use warnings;

use List::Util qw(min max) ;
use Readonly ;
use Clone ;

use App::Asciio::String ;

#-----------------------------------------------------------------------------

Readonly my $DEFAULT_BOX_TYPE => 
	[
	[1, 'top',              '.', '-',  '.', 1, ],
	[0, 'title separator',  '|', '-',  '|', 1, ],
	[1, 'body separator',  '| ', '|', ' |', 1, ], 
	[1, 'bottom',          '\'', '-', '\'', 1, ],
	[1, 'fill-character',  '',   ' ', '',   1, ],
	]  ;

sub new
{
my ($class, $element_definition) = @_ ;

my $self = bless  {}, __PACKAGE__ ;

$self->setup
	(
	$element_definition->{TEXT_ONLY},
	$element_definition->{TITLE},
	$element_definition->{BOX_TYPE} // Clone::clone($DEFAULT_BOX_TYPE),
	1, 1,
	$element_definition->{RESIZABLE},
	$element_definition->{EDITABLE},
	$element_definition->{AUTO_SHRINK},
	) ;

return $self ;
}

#-----------------------------------------------------------------------------

sub setup
{
my ($self, $text_only, $title_text, $box_type, $end_x, $end_y, $resizable, $editable, $auto_shrink) = @_ ;

my $fill_char = ' ';

if(defined $box_type->[4][3] && $box_type->[4][3] ne '')
{
    $fill_char = substr($box_type->[4][3], 0, 1);
}

my ($text_width,  @lines) = (0) ;

for my $line (split("\n", $text_only))
	{
	$text_width  = max($text_width, unicode_length($line)) ;
	push @lines, $line ;
	}

my ($title_width,  @title_lines) = (0) ;

$title_text = '' unless defined $title_text ;

for my $title_line (split("\n", $title_text))
	{
	$title_width  = max($title_width, unicode_length($title_line)) ;
	push @title_lines, $title_line ;
	}

my ($extra_width, $extra_height) = get_box_frame_size_overhead($box_type) ;

my $display_title = (defined $title_text and $title_text ne '') ? 1 : 0 ;
$text_width  = max($text_width, $title_width)  if $display_title;

if($auto_shrink)
	{
	($end_x, $end_y) = (-5, -5) ;
	}

$end_x = max($end_x, $text_width + $extra_width, $title_width + $extra_width) ;
$end_y = max($end_y, scalar(@lines) + $extra_height + scalar(@title_lines)) ;

my ($box_top, $box_left, $box_right, $box_bottom, $title_separator, $title_left, $title_right) = get_box_frame_elements($box_type, $end_x) ;

my $text = $box_top ;

for my $title_line (@title_lines)
	{
	my $pading =  ($end_x - (unicode_length($title_left . $title_line . $title_right))) ;
	my $left_pading =  int($pading / 2) ;
	my $right_pading = $pading - $left_pading ;
	
	$text .= $title_left . ($fill_char x $left_pading) . $title_line . ($fill_char x $right_pading) . $title_right ."\n" ;
	}

$text .= $title_separator ;

for my $line (@lines)
	{
	$text .= $box_left . $line . ($fill_char x ($end_x - (unicode_length($line) + $extra_width))) . $box_right . "\n" ;
	}
	
for (1 .. ($end_y - (@lines + $extra_height + @title_lines)))
	{
	$text .= $box_left .  ($fill_char x ($end_x - $extra_width)) . $box_right . "\n" ;
	}

$text .= $box_bottom ;

my ($text_begin_x, $text_begin_y, $title_separator_exist) = (0, 0, 0) ;
$text_begin_y++ if($box_top) ;
$text_begin_x = unicode_length($box_left);
$title_separator_exist = 1 if($title_separator);

unless (defined $self->{CONNECTORS})
	{
	for my $connector 
		(
		# X   SCALE_X OFFSET_X    Y   SCALE_Y  OFFSET_Y   NAME
		[ 0,  50,     0 ,         -1, -1,      0 ,        'top_center'    ],
		[ 0,  50,     0 ,         0,  100,     0 ,        'bottom_center' ],
		[ -1, -1,     0 ,         0,  50,      0 ,        'left_center'   ],
		[ 0,  100,    0 ,         0,  50,      0 ,        'right_center'  ],
		)
		{
		$self->add_connector($connector) ;
		}
	}

my $connectors = $self->scale_connectors($self->{CONNECTORS}, $end_x, $end_y,) ;

$self->set
	(
	TEXT                  => $text,
	TITLE                 => $title_text,
	WIDTH                 => $end_x,
	HEIGHT                => $end_y,
	TEXT_ONLY             => $text_only,
	TEXT_BEGIN_X          => $text_begin_x,
	TEXT_BEGIN_Y          => $text_begin_y,
	TITLE_SEPARATOR_EXIST => $title_separator_exist,
	BOX_TYPE              => $box_type,
	RESIZABLE             => $resizable,
	EDITABLE              => $editable,
	AUTO_SHRINK           => $auto_shrink,
	STRIPES               => [ {X_OFFSET => 0, Y_OFFSET => 0, WIDTH => $end_x, HEIGHT => $end_y, TEXT => $text } ],
	EXTENTS               => [ 0, 0, $end_x, $end_y ],
	CONNECTORS            => $connectors,
	) ;
}

#-----------------------------------------------------------------------------

sub scale_connectors
{
my ($self, $connectors, $width, $height) = @_ ;

for my $connector ($connectors->@*)
	{
	$connector->{X} = int($width  * $connector->{SCALE_X} / 100) + $connector->{OFFSET_X} if ($connector->{SCALE_X} >= 0) ;
	$connector->{Y} = int($height * $connector->{SCALE_Y} / 100) + $connector->{OFFSET_Y} if ($connector->{SCALE_Y} >= 0) ;
	}

return $connectors ;
}

#-----------------------------------------------------------------------------

use Readonly ;

Readonly my  $TOP => 0 ;
Readonly my  $TITLE_SEPARATOR => 1 ;
Readonly my  $BODY_SEPARATOR => 2 ;
Readonly my  $BOTTOM => 3;

Readonly my  $DISPLAY => 0 ;
Readonly my  $NAME => 1 ;
Readonly my  $LEFT => 2 ;
Readonly my  $BODY => 3 ;
Readonly my  $RIGHT => 4 ;

sub get_box_frame_size_overhead
{
my ($box_type) = @_ ;

my @displayed_elements = grep { $_->[$DISPLAY] } @{$box_type} ;

my $extra_width = $box_type->[$BODY_SEPARATOR][$DISPLAY] 
			? max(0, map { unicode_length($_) } map {$_->[$LEFT]} @displayed_elements)
				+ max(0, map { unicode_length($_) } map {$_->[$RIGHT]} @displayed_elements)
			: 0 ;

my $extra_height = 0 ;

for ($TOP, $TITLE_SEPARATOR, $BOTTOM)
	{
	$extra_height++ if defined $box_type->[$_][$DISPLAY] && $box_type->[$_][$DISPLAY] ;
	}

return($extra_width, $extra_height) ;
}

sub get_box_frame_elements
{
my ($box_type, $width) = @_ ;

my ($box_top, $box_left, $box_right, $box_bottom, $title_separator, $title_left, $title_right) = map {''} (1 .. 7) ;

if($box_type->[$TOP][$DISPLAY])
	{
	my $box_left_and_right_length = unicode_length($box_type->[$TOP][$LEFT]) + unicode_length($box_type->[$TOP][$RIGHT]) ;
	$box_top = $box_type->[$TOP][$LEFT] 
			. ($box_type->[$TOP][$BODY] x ($width - $box_left_and_right_length))   
			. $box_type->[$TOP][$RIGHT] 
			. "\n" ;
	}

$title_left = $box_type->[$TITLE_SEPARATOR][$LEFT] if($box_type->[$BODY_SEPARATOR][$DISPLAY]) ;
$title_right = $box_type->[$TITLE_SEPARATOR][$RIGHT] if($box_type->[$BODY_SEPARATOR][$DISPLAY]) ;

if($box_type->[$TITLE_SEPARATOR][$DISPLAY])
	{
	my $title_left_and_right_length = unicode_length($title_left) + unicode_length($title_right) ;
	
	my $title_separator_body = $box_type->[$TITLE_SEPARATOR][$BODY] ;
	$title_separator_body = ' ' unless defined $title_separator_body ;
	$title_separator_body = ' ' if $title_separator_body eq '' ;
	
	$title_separator = $title_left
			. ($title_separator_body x ($width - $title_left_and_right_length))   
			. $title_right 
			. "\n" ;
	}

$box_left = $box_type->[$BODY_SEPARATOR][$LEFT] if($box_type->[$BODY_SEPARATOR][$DISPLAY]) ;
$box_right = $box_type->[$BODY_SEPARATOR][$RIGHT] if($box_type->[$BODY_SEPARATOR][$DISPLAY]) ;

if($box_type->[$BOTTOM][$DISPLAY])
	{
	my $box_left_and_right_length = unicode_length($box_type->[$BOTTOM][$LEFT]) + unicode_length($box_type->[$BOTTOM][$RIGHT]) ;
	$box_bottom = $box_type->[$BOTTOM][$LEFT] 
			. ($box_type->[$BOTTOM][$BODY] x ($width - $box_left_and_right_length))   
			. $box_type->[$BOTTOM][$RIGHT] ;
	}

return ($box_top, $box_left, $box_right, $box_bottom, $title_separator, $title_left, $title_right) ;
}

#-----------------------------------------------------------------------------

sub get_selection_action
{
my ($self, $x, $y) = @_ ;
my $action ;

if($self->{AUTO_SHRINK})
	{
	$action = 'move'
	}
else
	{ 
	$action = ($x == $self->{WIDTH} - 1 && $y == $self->{HEIGHT} - 1)
			? ($self->{WIDTH} != 1 || $self->{HEIGHT} != 1)
				? 'resize'
				: 'move'
			: 'move' ;
	}

return($action) ;
}

#-----------------------------------------------------------------------------

sub add_connector
{
my ($self, $connector) = @_ ;
my ($x, $scale_x, $offset_x, $y, $scale_y, $offset_y, $name) = $connector->@* ;

$self->remove_connector($name) ;

push $self->{CONNECTORS}->@*, 
	{
	X => $x, SCALE_X => $scale_x, OFFSET_X => $offset_x,
	Y => $y, SCALE_Y => $scale_y, OFFSET_Y => $offset_y,
	NAME => $name
	} ;
}

#-----------------------------------------------------------------------------

sub remove_connector
{
my ($self, $name) = @_ ;

$self->{CONNECTORS} = [ grep { $_->{NAME} ne $name } $self->{CONNECTORS}->@* ] ;
}

#-----------------------------------------------------------------------------

sub match_connector
{
my ($self, $x, $y) = @_ ;

for my $connector( @{$self->{CONNECTORS}})
	{
	return($connector) if( $x == $connector->{X} && $y == $connector->{Y}) ;
	}

if($self->is_optimize_enabled() && $x >= 0 && $x < $self->{WIDTH} && $y >= 0 && $y < $self->{HEIGHT})
	{
	return {X =>  -1, Y => -1, NAME => 'to_be_optimized'} ;
	}
	
if($self->{ALLOW_BORDER_CONNECTION} && $x >= -1 && $x <= $self->{WIDTH} && $y >= -1 && $y <= $self->{HEIGHT})
	{
	return {X =>  $x, Y => $y, NAME => 'border'} ;
	}

return ;
}

#-----------------------------------------------------------------------------

sub get_connection_points
{
my ($self) = @_ ;

if(exists $self->{CONNECTORS} && defined $self->{CONNECTORS})
	{
	return $self->{CONNECTORS}->@* ;
	}

return ;
}

#-----------------------------------------------------------------------------

sub get_extra_points
{
my ($self) = @_ ;

if($self->{RESIZABLE} && ! $self->is_auto_shrink())
	{
	return {X =>  $self->{WIDTH} - 1, Y => $self->{HEIGHT} - 1, NAME => 'resize'} ;
	}
else
	{
	return ;
	}
}

#-----------------------------------------------------------------------------

sub get_named_connection
{
my ($self, $name) = @_ ;

for my $connector( $self->{CONNECTORS}->@*)
	{
	return $connector if $name eq $connector->{NAME} ;
	}

return ;
}

#-----------------------------------------------------------------------------

sub allow_border_connection { my($self, $allow) = @_ ; $self->{ALLOW_BORDER_CONNECTION} = $allow ; }
sub is_border_connection_allowed { my($self) = @_ ; return $self->{ALLOW_BORDER_CONNECTION} ; }

#-----------------------------------------------------------------------------

sub flip_auto_shrink { my($self) = @_ ; $self->{AUTO_SHRINK} ^= 1 ; }
sub is_auto_shrink { my($self) = @_ ; return $self->{AUTO_SHRINK} ; }

#-----------------------------------------------------------------------------

sub resize
{
my ($self, $reference_x, $reference_y, $new_x, $new_y) = @_ ;

return(0, 0, $self->{WIDTH}, $self->{HEIGHT})  unless $self->{RESIZABLE} ;

my $new_end_x = $new_x ;
my $new_end_y = $new_y ;

if($reference_x == -1 && $reference_y == -1)
	{
	$self->setup
		(
		$self->{TEXT_ONLY},
		$self->{TITLE},
		$self->{BOX_TYPE},
		$self->{WIDTH} + $new_x,
		$self->{HEIGHT} + $new_y,
		$self->{RESIZABLE},
		$self->{EDITABLE},
		$self->{AUTO_SHRINK},
		) ;
	}
else
	{
	if($new_end_x >= 0 && $new_end_y >= 0)
		{
		$self->setup
			(
			$self->{TEXT_ONLY},
			$self->{TITLE},
			$self->{BOX_TYPE},
			$new_end_x + 1,
			$new_end_y + 1,
			$self->{RESIZABLE},
			$self->{EDITABLE},
			$self->{AUTO_SHRINK},
			) ;
		}
	}

return(0, 0, $self->{WIDTH}, $self->{HEIGHT}) ;
}

#-----------------------------------------------------------------------------

sub get_text { my ($self) = @_ ; return($self->{TITLE}, $self->{TEXT_ONLY})  ; }

#-----------------------------------------------------------------------------

sub set_text
{
my ($self, $title, $text) = @_ ;

my @displayed_elements = grep { $_->[$DISPLAY] } @{$self->{BOX_TYPE}} ;
$text = 'edit_me' if($text eq '' && @displayed_elements == 0) ;

$self->setup
	(
	$text,
	$title,
	$self->{BOX_TYPE},
	$self->{WIDTH},
	$self->{HEIGHT},
	$self->{RESIZABLE},
	$self->{EDITABLE},
	$self->{AUTO_SHRINK},
	) ;
}

#-----------------------------------------------------------------------------

sub get_box_type { my ($self) = @_ ; return($self->{BOX_TYPE})  ; }

#-----------------------------------------------------------------------------

sub set_box_type
{
my ($self, $box_type) = @_ ;
$self->setup
	(
	$self->{TEXT_ONLY},
	$self->{TITLE},
	$box_type,
	$self->{WIDTH},
	$self->{HEIGHT},
	$self->{RESIZABLE},
	$self->{EDITABLE},
	$self->{AUTO_SHRINK},
	) ;
}

#-----------------------------------------------------------------------------

sub edit
{
my ($self, $asciio) = @_ ;

return unless $self->{EDITABLE} ;

my $text = $self->{TEXT_ONLY} ;
$text = make_vertical_text($text) if $self->{VERTICAL_TEXT} ;

($text, my $title) = $self->display_box_edit_dialog($self->{TITLE}, $text, $asciio, $self->{X}, $self->{Y}, $self->{TEXT_BEGIN_X}, $self->{TEXT_BEGIN_Y}, $self->{TITLE_SEPARATOR_EXIST}) ;

my $tab_as_space = $asciio->{TAB_AS_SPACES} ;

$text =~ s/\t/$tab_as_space/g ;
$title=~ s/\t/$tab_as_space/g ;

$text = make_vertical_text($text) if $self->{VERTICAL_TEXT} ;

$self->set_text($title, $text) ;
}

#-----------------------------------------------------------------------------

sub rotate_text
{
my ($self) = @_ ;

my $text = make_vertical_text($self->{TEXT_ONLY})  ;

$self->set_text($self->{TITLE}, $text) ;
$self->shrink() ;

$self->{VERTICAL_TEXT} ^= 1 ;
}

#-----------------------------------------------------------------------------

sub shrink
{
my ($self) = @_ ;
$self->setup
	(
	$self->{TEXT_ONLY},
	$self->{TITLE},
	$self->{BOX_TYPE},
	-5,
	-5,
	$self->{RESIZABLE},
	$self->{EDITABLE},
	$self->{AUTO_SHRINK},
	) ;
}

#-----------------------------------------------------------------------------

1 ;
