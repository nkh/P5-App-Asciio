
package App::Asciio::Actions::Multiwirl ;

use strict ;
use warnings ;
use utf8 ;

use Clone ;
use App::Asciio::Toolfunc ;

#----------------------------------------------------------------------------------------------

sub insert_wirl_arrow_section
{
my ($self) = @_ ;
my $element = ($self->get_selected_elements(1))[0] ;

if(defined $element && 'App::Asciio::stripes::section_wirl_arrow' eq ref $element)
	{
	$self->create_undo_snapshot() ;
	
	my $x_offset = $self->{MOUSE_X} - $element->{X} ;
	my $y_offset = $self->{MOUSE_Y} - $element->{Y} ;
	
	$self->delete_connections_containing($element) ;
	
	$element->insert_section($x_offset, $y_offset) ;
	
	$self->connect_elements($element) ;
	
	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

sub prepend_section
{
my ($self) = @_ ;
my $element = ($self->get_selected_elements(1))[0] ;

if(defined $element && 'App::Asciio::stripes::section_wirl_arrow' eq ref $element)
	{
	$self->create_undo_snapshot() ;
	
	$self->delete_connections_containing($element) ;
	
	my $x_offset = $self->{MOUSE_X} - $element->{X} ;
	my $y_offset = $self->{MOUSE_Y} - $element->{Y} ;
	
	$element->prepend_section($x_offset, $y_offset) ;
	
	$self->move_elements($x_offset, $y_offset, $element) ;
	
	$self->update_display() ;
	}
}


#----------------------------------------------------------------------------------------------

sub append_section
{
my ($self) = @_ ;
my $element = ($self->get_selected_elements(1))[0] ;

if(defined $element && 'App::Asciio::stripes::section_wirl_arrow' eq ref $element)
	{
	add_section_to_section_wirl_arrow
		(
		$self,
		{
			ELEMENT => $element,
			X => $self->{MOUSE_X} - $element->{X},
			Y => $self->{MOUSE_Y} - $element->{Y},
		}
		) ;
	}
}

#----------------------------------------------------------------------------------------------

sub add_section_to_section_wirl_arrow
{
my ($self, $data) = @_ ;

$self->create_undo_snapshot() ;

$self->delete_connections_containing($data->{ELEMENT}) ;

$data->{ELEMENT}->append_section($data->{X}, $data->{Y}) ;

$self->connect_elements($data->{ELEMENT}) ;

$self->call_hook('CANONIZE_CONNECTIONS', $self->{CONNECTIONS}, $self->get_character_size()) ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub remove_last_section_from_section_wirl_arrow
{
my ($self, $data) = @_ ;
my $element = ($self->get_selected_elements(1))[0] ;

if(defined $element && 'App::Asciio::stripes::section_wirl_arrow' eq ref $element)
	{
	$self->create_undo_snapshot() ;
	
	$self->delete_connections_containing($element) ;
	
	$element->remove_last_section() ;
	
	$self->connect_elements($element) ;
	
	$self->call_hook('CANONIZE_CONNECTIONS', $self->{CONNECTIONS}, $self->get_character_size()) ;
	
	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

sub remove_first_section_from_section_wirl_arrow
{
my ($self, $data) = @_ ;
my $element = ($self->get_selected_elements(1))[0] ;

if(defined $element && 'App::Asciio::stripes::section_wirl_arrow' eq ref $element)
	{
	$self->create_undo_snapshot() ;
	
	$self->delete_connections_containing($element) ;
	
	my ($second_arrow_x_offset, $second_arrow_y_offset) = $element->remove_first_section() ;
	
	$self->move_elements($second_arrow_x_offset, $second_arrow_y_offset, $element) ;
	
	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

sub multi_wirl_context_menu
{
my ($self, $popup_x, $popup_y) = @_ ;

my @context_menu_entries ;

my $element = ($self->get_selected_elements(1))[0] ;

if(defined $element && 'App::Asciio::stripes::section_wirl_arrow' eq ref $element)
	{
	my ($x, $y) = ($popup_x - $element->{X} , $popup_y - $element->{Y}) ;
	
	push @context_menu_entries, [ '/append section', \&add_section_to_section_wirl_arrow, {ELEMENT => $element, X => $x, Y => $y,} ] ;
	
	$element->is_connection_allowed('start')
		? push @context_menu_entries, ["/arrow connection/start doesn't connect", sub {$element->allow_connection('start',0) ;}]
		: push @context_menu_entries, ["/arrow connection/start connects",        sub {$element->allow_connection('start',1) ;}] ;
		
	$element->is_connection_allowed('end')
		? push @context_menu_entries, ["/arrow connection/end doesn't connect", sub {$element->allow_connection('end',0) ;}]
		: push @context_menu_entries, ["/arrow connection/end connects",        sub {$element->allow_connection('end',1) ;}] ;
		
	push @context_menu_entries, 
		[
		$element->is_autoconnect_enabled() ? '/disable autoconnection' :  '/enable autoconnection', 
			sub 
				{
				$self->create_undo_snapshot() ;
				$element->enable_autoconnect(! $element->is_autoconnect_enabled()) ;
				$self->update_display() ;
				}
		],
		[
		$element->are_diagonals_allowed() ? '/no diagonals' :  '/allow diagonals', 
			sub { $element->allow_diagonals(! $element->are_diagonals_allowed()) }
		],
		[ '/arrow type/dash',                      \&change_arrow_type, { ELEMENT => $element, TYPE => 'dash',               X => $x, Y => $y } ] ,
		[ '/arrow type/dash_no_arrow',             \&change_arrow_type, { ELEMENT => $element, TYPE => 'dash_no_arrow',      X => $x, Y => $y } ] ,
		[ '/arrow type/dot',                       \&change_arrow_type, { ELEMENT => $element, TYPE => 'dot',                X => $x, Y => $y } ],
		[ '/arrow type/dot_no_arrow',              \&change_arrow_type, { ELEMENT => $element, TYPE => 'dot_no_arrow',       X => $x, Y => $y } ],
		[ '/arrow type/octo',                      \&change_arrow_type, { ELEMENT => $element, TYPE => 'octo',               X => $x, Y => $y } ],
		[ '/arrow type/star',                      \&change_arrow_type, { ELEMENT => $element, TYPE => 'star',               X => $x, Y => $y } ],
		[ '/arrow type/unicode',                   \&change_arrow_type, { ELEMENT => $element, TYPE => 'unicode',            X => $x, Y => $y } ],
		[ '/arrow type/unicode_bold',              \&change_arrow_type, { ELEMENT => $element, TYPE => 'unicode_bold',       X => $x, Y => $y } ],
		[ '/arrow type/unicode_double_line',       \&change_arrow_type, { ELEMENT => $element, TYPE => 'unicode_double_line',X => $x, Y => $y } ],
		[ '/arrow type/unicode_no_arrow',          \&change_arrow_type, { ELEMENT => $element, TYPE => 'unicode_no_arrow',   X => $x, Y => $y } ],
		[ '/arrow type/unicode_hollow_dot',        \&change_arrow_type, { ELEMENT => $element, TYPE => 'unicode_hollow_dot', X => $x, Y => $y } ] ;
	}

return @context_menu_entries ;
}

#----------------------------------------------------------------------------------------------

sub arrow_connection
{
my ($self, $arguments) = @_ ;

$arguments->{ELEMENT}->allow_connection($arguments->{WHICH}, $arguments->{CONNECT}) ;
}

#----------------------------------------------------------------------------------------------

my %arrow_types = 
(
	dash =>
	[
		['origin',       '',  '*',   '',  '',  '', 1],
		['up',          '|',  '|',   '',  '', '^', 1],
		['down',        '|',  '|',   '',  '', 'v', 1],
		['left',        '-',  '-',   '',  '', '<', 1],
		['upleft',      '|',  '|',  '.', '-', '<', 1],
		['leftup',      '-',  '-', '\'', '|', '^', 1],
		['downleft',    '|',  '|', '\'', '-', '<', 1],
		['leftdown',    '-',  '-',  '.', '|', 'v', 1],
		['right',       '-',  '-',   '',  '', '>', 1],
		['upright',     '|',  '|',  '.', '-', '>', 1],
		['rightup',     '-',  '-', '\'', '|', '^', 1],
		['downright',   '|',  '|', '\'', '-', '>', 1],
		['rightdown',   '-',  '-',  '.', '|', 'v', 1],
		['45',          '/',  '/',   '',  '', '^', 1],
		['135',        '\\', '\\',   '',  '', 'v', 1],
		['225',         '/',  '/',   '',  '', 'v', 1],
		['315',        '\\', '\\',   '',  '', '^', 1],
	],
	dash_no_arrow =>
	[
		['origin',      '',  '*',   '',  '',  '', 1],
		['up',         '|',  '|',   '',  '', '.', 1],
		['down',       '|',  '|',   '',  '', '.', 1],
		['left',       '-',  '-',   '',  '', '.', 1],
		['upleft',     '|',  '|',  '.', '-', '.', 1],
		['leftup',     '-',  '-', '\'', '|', '.', 1],
		['downleft',   '|',  '|', '\'', '-', '.', 1],
		['leftdown',   '-',  '-',  '.', '|', '.', 1],
		['right',      '-',  '-',   '',  '', '.', 1],
		['upright',    '|',  '|',  '.', '-', '.', 1],
		['rightup',    '-',  '-', '\'', '|', '.', 1],
		['downright',  '|',  '|', '\'', '-', '.', 1],
		['rightdown',  '-',  '-',  '.', '|', '.', 1],
		['45',         '/',  '/',   '',  '', '.', 1],
		['135',       '\\', '\\',   '',  '', '.', 1],
		['225',        '/',  '/',   '',  '', '.', 1],
		['315',      ' \\', '\\',   '',  '', '.', 1],
	],
	dot =>
	[
		['origin',     '', '*',   '',  '',  '', 1],
		['up',        '.', '.',   '',  '', '^', 1],
		['down',      '.', '.',   '',  '', 'v', 1],
		['left',      '.', '.',   '',  '', '<', 1],
		['upleft',    '.', '.',  '.', '.', '<', 1],
		['leftup',    '.', '.', '\'', '.', '^', 1],
		['downleft',  '.', '.', '\'', '.', '<', 1],
		['leftdown',  '.', '.',  '.', '.', 'v', 1],
		['right',     '.', '.',   '',  '', '>', 1],
		['upright',   '.', '.',  '.', '.', '>', 1],
		['rightup',   '.', '.', '\'', '.', '^', 1],
		['downright', '.', '.', '\'', '.', '>', 1],
		['rightdown', '.', '.',  '.', '.', 'v', 1],
		['45',        '.', '.',   '',  '', '^', 1],
		['135',       '.', '.',   '',  '', 'v', 1],
		['225',       '.', '.',   '',  '', 'v', 1],
		['315',       '.', '.',   '',  '', '^', 1],
	],
	dot_no_arrow =>
	[
		['origin',     '', '*',   '',  '',  '', 1],
		['up',        '.', '.',   '',  '', '.', 1],
		['down',      '.', '.',   '',  '', '.', 1],
		['left',      '.', '.',   '',  '', '.', 1],
		['upleft',    '.', '.',  '.', '.', '.', 1],
		['leftup',    '.', '.', '\'', '.', '.', 1],
		['downleft',  '.', '.', '\'', '.', '.', 1],
		['leftdown',  '.', '.',  '.', '.', '.', 1],
		['right',     '.', '.',   '',  '', '.', 1],
		['upright',   '.', '.',  '.', '.', '.', 1],
		['rightup',   '.', '.', '\'', '.', '.', 1],
		['downright', '.', '.', '\'', '.', '.', 1],
		['rightdown', '.', '.',  '.', '.', '.', 1],
		['45',        '.', '.',   '',  '', '.', 1],
		['135',       '.', '.',   '',  '', '.', 1],
		['225',       '.', '.',   '',  '', '.', 1],
		['315',       '.', '.',   '',  '', '.', 1],
	],
	star =>
	[
		['origin',     '', '*', '',   '',  '', 1],
		['up',        '*', '*', '',   '', '^', 1],
		['down',      '*', '*', '',   '', 'v', 1],
		['left',      '*', '*', '',   '', '<', 1],
		['upleft',    '*', '*', '*', '*', '<', 1],
		['leftup',    '*', '*', '*', '*', '^', 1],
		['downleft',  '*', '*', '*', '*', '<', 1],
		['leftdown',  '*', '*', '*', '*', 'v', 1],
		['right',     '*', '*',  '',  '', '>', 1],
		['upright',   '*', '*', '*', '*', '>', 1],
		['rightup',   '*', '*', '*', '*', '^', 1],
		['downright', '*', '*', '*', '*', '>', 1],
		['rightdown', '*', '*', '*', '*', 'v', 1],
		['45',        '*', '*',  '',  '', '^', 1],
		['135',       '*', '*',  '',  '', 'v', 1],
		['225',       '*', '*',  '',  '', 'v', 1],
		['315',       '*', '*',  '',  '', '^', 1],
	],
	octo =>
	[
		['origin',    '', '#',  '',  '',  '', 1],
		['up',       '#', '#',  '',  '', '^', 1],
		['down',     '#', '#',  '',  '', 'v', 1],
		['left',     '#', '#',  '',  '', '<', 1],
		['upleft',   '#', '#', '#', '#', '<', 1],
		['leftup',   '#', '#', '#', '#', '^', 1],
		['downleft', '#', '#', '#', '#', '<', 1],
		['leftdown', '#', '#', '#', '#', 'v', 1],
		['right',    '#', '#',  '',  '', '>', 1],
		['upright',  '#', '#', '#', '#', '>', 1],
		['rightup',  '#', '#', '#', '#', '^', 1],
		['downright','#', '#', '#', '#', '>', 1],
		['rightdown','#', '#', '#', '#', 'v', 1],
		['45',       '#', '#',  '',  '', '^', 1],
		['135',      '#', '#',  '',  '', 'v', 1],
		['225',      '#', '#',  '',  '', 'v', 1],
		['315',      '#', '#',  '',  '', '^', 1],
	],
	unicode =>
	[
		['origin',      '',  '*',  '',  '',  '', 1],
		['up',         '│',  '│',  '',  '', '^', 1],
		['down',       '│',  '│',  '',  '', 'v', 1],
		['left',       '─',  '─',  '',  '', '<', 1],
		['upleft',     '│',  '│', '╮', '─', '<', 1],
		['leftup',     '─',  '─', '╰', '│', '^', 1],
		['downleft',   '│',  '│', '╯', '─', '<', 1],
		['leftdown',   '─',  '─', '╭', '│', 'v', 1],
		['right',      '─',  '─',  '',  '', '>', 1],
		['upright',    '│',  '│', '╭', '─', '>', 1],
		['rightup',    '─',  '─', '╯', '│', '^', 1],
		['downright',  '│',  '│', '╰', '─', '>', 1],
		['rightdown',  '─',  '─', '╮', '│', 'v', 1],
		['45',         '/',  '/',  '',  '', '^', 1],
		['135',       '\\', '\\',  '',  '', 'v', 1],
		['225',        '/',  '/',  '',  '', 'v', 1],
		['315',       '\\', '\\',  '',  '', '^', 1],
	],
	unicode_bold =>
	[
		['origin',      '',  '*',  '',  '',  '', 1],
		['up',         '┃',  '┃',  '',  '', '^', 1],
		['down',       '┃',  '┃',  '',  '', 'v', 1],
		['left',       '━',  '━',  '',  '', '<', 1],
		['upleft',     '┃',  '┃', '┓', '━', '<', 1],
		['leftup',     '━',  '━', '┗', '┃', '^', 1],
		['downleft',   '┃',  '┃', '┛', '━', '<', 1],
		['leftdown',   '━',  '━', '┏', '┃', 'v', 1],
		['right',      '━',  '━',  '',  '', '>', 1],
		['upright',    '┃',  '┃', '┏', '━', '>', 1],
		['rightup',    '━',  '━', '┛', '┃', '^', 1],
		['downright',  '┃',  '┃', '┗', '━', '>', 1],
		['rightdown',  '━',  '━', '┓', '┃', 'v', 1],
		['45',         '/',  '/',  '',  '', '^', 1],
		['135',       '\\', '\\',  '',  '', 'v', 1],
		['225',        '/',  '/',  '',  '', 'v', 1],
		['315',       '\\', '\\',  '',  '', '^', 1],
	],
	unicode_double_line =>
	[
		['origin',      '',  '*',  '',  '',  '', 1],
		['up',         '║',  '║',  '',  '', '^', 1],
		['down',       '║',  '║',  '',  '', 'v', 1],
		['left',       '═',  '═',  '',  '', '<', 1],
		['upleft',     '║',  '║', '╗', '═', '<', 1],
		['leftup',     '═',  '═', '╚', '║', '^', 1],
		['downleft',   '║',  '║', '╝', '═', '<', 1],
		['leftdown',   '═',  '═', '╔', '║', 'v', 1],
		['right',      '═',  '═',  '',  '', '>', 1],
		['upright',    '║',  '║', '╔', '═', '>', 1],
		['rightup',    '═',  '═', '╝', '║', '^', 1],
		['downright',  '║',  '║', '╚', '═', '>', 1],
		['rightdown',  '═',  '═', '╗', '║', 'v', 1],
		['45',         '/',  '/',  '',  '', '^', 1],
		['135',       '\\', '\\',  '',  '', 'v', 1],
		['225',        '/',  '/',  '',  '', 'v', 1],
		['315',       '\\', '\\',  '',  '', '^', 1],
	],
	unicode_no_arrow =>
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
	unicode_hollow_dot =>
	[
		['origin',     '', '*',  '',  '',  '', 1],
		['up',        '∘', '∘',  '',  '', '^', 1],
		['down',      '∘', '∘',  '',  '', 'v', 1],
		['left',      '∘', '∘',  '',  '', '<', 1],
		['upleft',    '∘', '∘', '∘', '∘', '<', 1],
		['leftup',    '∘', '∘', '∘', '∘', '^', 1],
		['downleft',  '∘', '∘', '∘', '∘', '<', 1],
		['leftdown',  '∘', '∘', '∘', '∘', 'v', 1],
		['right',     '∘', '∘',  '', '',  '>', 1],
		['upright',   '∘', '∘', '∘', '∘', '>', 1],
		['rightup',   '∘', '∘', '∘', '∘', '^', 1],
		['downright', '∘', '∘', '∘', '∘', '>', 1],
		['rightdown', '∘', '∘', '∘', '∘', 'v', 1],
		['45',        '∘', '∘',  '',  '', '^', 1],
		['135',       '∘', '∘',  '',  '', 'v', 1],
		['225',       '∘', '∘',  '',  '', 'v', 1],
		['315',       '∘', '∘',  '',  '', '^', 1],
	],
	angled_arrow_dash =>
	[
		# name: $start, $body, $connection, $body_2, $end, $vertical, $diagonal_connection
		['origin'     , '*',  '?', '?', '?', '?', '?', '?', 1],
		['up'         , "'",  '|', '?', '?', '.', '?', '?', 1],
		['down'       , '.',  '|', '?', '?', "'", '?', '?', 1],
		['left'       , '-',  '-', '?', '?', '-', '?', '?', 1],
		['right'      , '-',  '-', '?', '?', '-', '?', '?', 1],
		['up-left'    , "'", '\\', '.', '-', '-', '|', "'", 1],
		['left-up'    , '-', '\\', "'", '-', '.', '|', "'", 1],
		['down-left'  , '.',  '/', "'", '-', '-', '|', "'", 1],
		['left-down'  , '-',  '/', '.', '-', "'", '|', "'", 1],
		['up-right'   , "'",  '/', '.', '-', '-', '|', "'", 1],
		['right-up'   , '-',  '/', "'", '-', '.', '|', "'", 1],
		['down-right' , '.', '\\', "'", '-', '-', '|', "'", 1],
		['right-down' , '-', '\\', '.', '-', "'", '|', "'", 1],
	],
	angled_arrow_unicode =>
	[
		['origin'     , '*',  '?', '?', '?', '?', '?', '?', 1],
		['up'         , "'",  '│', '?', '?', '.', '?', '?', 1],
		['down'       , '.',  '│', '?', '?', "'", '?', '?', 1],
		['left'       , '─',  '─', '?', '?', '─', '?', '?', 1],
		['right'      , '─',  '─', '?', '?', '─', '?', '?', 1],
		['up-left'    , "'", '\\', '.', '─', '─', '│', "'", 1],
		['left-up'    , '─', '\\', "'", '─', '.', '│', "'", 1],
		['down-left'  , '.',  '/', "'", '─', '─', '│', "'", 1],
		['left-down'  , '─',  '/', '.', '─', "'", '│', "'", 1],
		['up-right'   , "'",  '/', '.', '─', '─', '│', "'", 1],
		['right-up'   , '─',  '/', "'", '─', '.', '│', "'", 1],
		['down-right' , '.', '\\', "'", '─', '─', '│', "'", 1],
		['right-down' , '─', '\\', '.', '─', "'", '│', "'", 1],
	],
) ;


sub change_arrow_type
{
my ($self, $data, $atomic_operation) = @_ ;

$atomic_operation //= 1 ;

if(exists $arrow_types{$data->{TYPE}})
	{
	$self->create_undo_snapshot() if $atomic_operation ;
	
	my $new_type = Clone::clone($arrow_types{$data->{TYPE}}) ;
	
	$data->{ELEMENT}->set_arrow_type($new_type) ;
	
	$self->update_display() if $atomic_operation ;
	}
}

#----------------------------------------------------------------------------------------------
sub git_mode_change_arrow_type
{
my ($self, $data) = @_ ;

my $new_type = Clone::clone($arrow_types{$data->{TYPE}}) ;

print("now git mode angled arrow type " . $data->{TYPE} . "\n") ;

use App::Asciio::Actions::Git ;
App::Asciio::Actions::Git->git_mode_change_arrow_type($new_type) ;
}


#----------------------------------------------------------------------------------------------

sub angled_arrow_context_menu
{
my ($self, $popup_x, $popup_y) = @_ ;

my @context_menu_entries ;

my $element = ($self->get_selected_elements(1))[0] ;

if(defined $element && 'App::Asciio::stripes::angled_arrow' eq ref $element)
	{
	push @context_menu_entries, 
		[
		$element->is_autoconnect_enabled() ? '/disable autoconnection' :  '/enable autoconnection', 
		sub 
			{
			$self->create_undo_snapshot() ;
			$element->enable_autoconnect(! $element->is_autoconnect_enabled()) ;
			$self->update_display() ;
			}
		],
		[ '/arrow type/dash',             \&change_arrow_type, { ELEMENT => $element, TYPE => 'angled_arrow_dash', } ] ,
		[ '/arrow type/unicode',          \&change_arrow_type, { ELEMENT => $element, TYPE => 'angled_arrow_unicode', } ] ,
		[ '/git mode arrow type/dash',    \&git_mode_change_arrow_type, { TYPE => 'angled_arrow_dash' } ] ,
		[ '/git mode arrow type/unicode', \&git_mode_change_arrow_type, { TYPE => 'angled_arrow_unicode' } ] ;

	}

return @context_menu_entries ;
}

#----------------------------------------------------------------------------------------------

sub interactive_add_section
{
my ($self) = @_ ;

my @selected_elements = $self->get_selected_elements(1) ;

if(0 == @selected_elements)
	{
	App::Asciio::Actions::Elements::add_element($self, ['Asciio/wirl_arrow', 0]),
	}
elsif(1 == @selected_elements)
	{
	if(ref $selected_elements[0] eq 'App::Asciio::stripes::section_wirl_arrow')
		{
		my $arrow = $selected_elements[0] ;
		
		App::Asciio::Actions::Multiwirl::add_section_to_section_wirl_arrow
			(
			$self,
			{
				ELEMENT => $arrow,
				X => $self->{MOUSE_X} - $arrow->{X},
				Y => $self->{MOUSE_Y} - $arrow->{Y},
			}
			) ;
		
		$self->update_display() ;
		}
	else
		{
		# add multi wirl from element to mouse
		my $element = $selected_elements[0] ;
		
		$self->create_undo_snapshot() ;
		
		my $arrow = $self->add_new_element_named('Asciio/wirl_arrow', $element->{X}, $element->{Y}) ;
		
		move_last_section_to($self, $arrow, $self->{MOUSE_X}, $self->{MOUSE_Y}) ;
		
		$self->deselect_all_elements() ;
		$self->select_elements(1, $arrow) ;
		$self->update_display() ;
		}
	}
}

#----------------------------------------------------------------------------------------------

sub move_last_section_to
{
my ($self, $arrow, $x, $y) = @_ ;

if($self->is_connected($arrow))
	{
	# disconnect current connections
	$self->delete_connections_containing($arrow) ;
	}

my $last_section = $arrow->get_number_of_sections() - 1 ;

my $end_section = $arrow->{ARROWS}[-1] ;
my $offset = $arrow->{POINTS_OFFSETS}[-1] ;

$arrow->move_connector
	(
	"endsection_$last_section",
	$x - (($arrow->{X} + $offset->[0]) + $end_section->{END_X}),
	$y - (($arrow->{Y} + $offset->[1]) + $end_section->{END_Y})
	) ;

# $self->call_hook('CANONIZE_CONNECTIONS', $self->{CONNECTIONS}, $self->get_character_size()) ;

$self->connect_elements($arrow, @{$self->{ELEMENTS}}) ;
}

#----------------------------------------------------------------------------------------------

1 ;

