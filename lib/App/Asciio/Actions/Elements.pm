package App::Asciio::Actions::Elements ;

use strict ;
use warnings ;
use Encode ;
use utf8 ;

use File::Slurper qw(read_text) ;
use File::HomeDir ;

use App::Asciio::Actions::Box ;
use App::Asciio::Actions::Multiwirl ;
use App::Asciio::stripes::section_wirl_arrow ;

#----------------------------------------------------------------------------------------------

sub add_element
{
my ($self, $name_and_edit) = @_ ;

$self->create_undo_snapshot() ;

$self->deselect_all_elements() ;

my ($name, $edit, $x, $y) = @{$name_and_edit} ;

my $element = $self->add_new_element_named($name, $x // $self->{MOUSE_X}, $y // $self->{MOUSE_Y}) ;

if($edit)
	{
	$element->edit($self);
	$self->{EDIT_SEMAPHORE} = 3 if((defined $self->{EDIT_TEXT_INLINE}) && ($self->{EDIT_TEXT_INLINE} != 0)) ;
	}

$self->select_elements(1, $element);

$self->update_display() ;

return $element ;
}

#----------------------------------------------------------------------------------------------

sub add_element_connected
{
my ($self, $name_and_edit) = @_ ;

$self->create_undo_snapshot() ;

my ($name, $edit, $x, $y) = @{$name_and_edit} ;

my $element = $self->add_new_element_named($name, $x // $self->{MOUSE_X}, $y // $self->{MOUSE_Y}) ;

if($edit)
	{
	$element->edit($self);
	$self->{EDIT_SEMAPHORE} = 3 if((defined $self->{EDIT_TEXT_INLINE}) && ($self->{EDIT_TEXT_INLINE} != 0)) ;
	}

use App::Asciio::Actions::Mouse ;
App::Asciio::Actions::Mouse::connect_to_destination_element($self, $element, $x, $y) ;

$self->deselect_all_elements() ;
$self->select_elements(1, $element);

$self->update_display() ;

return $element ;
}

#----------------------------------------------------------------------------------------------

sub add_multiple_element_connected
{
my ($self, $name_and_edit) = @_ ;
my ($name, $edit, $x, $y) = @{$name_and_edit} ;

$self->create_undo_snapshot() ;

my @selected_elements = $self->get_selected_elements(1) ;

my @new_elements = add_multiple_elements($self, $name) ;

$self->deselect_all_elements() ;

for my $selected_element(@selected_elements)
	{
	for my $new_element (reverse @new_elements)
		{
		$self->select_elements(1, $selected_element);
		App::Asciio::Actions::Mouse::connect_to_destination_element($self, $new_element, $x, $y) ;
		$self->select_elements(0, $selected_element);
		}
	}

$self->select_elements(1, @new_elements);
}

#----------------------------------------------------------------------------------------------

sub add_multiple_elements
{
my ($self, $type) = @_ ;

my $text = $self->display_edit_dialog('multiple objects from input', "\ntext", $self) ;

my @new_elements ;

if(defined $text && $text ne '')
	{
	$self->create_undo_snapshot() ;
	
	my ($current_x, $current_y) = ($self->{MOUSE_X}, $self->{MOUSE_Y}) ;
	my ($separator) = split("\n", $text) ;
	
	$text =~ s/$separator\n// ;
	
	for my $element_text (split("$separator\n", $text))
		{
		chomp $element_text ;
		
		my $new_element = add_element($self, [$type, 0]) ;
		$new_element->set_text('', $element_text) ;
		
		@$new_element{'X', 'Y'} = ($current_x, $current_y) ;
		$current_x += $new_element->{WIDTH} + $self->{COPY_OFFSET_X} ; 
		$current_y += $new_element->{HEIGHT} + $self->{COPY_OFFSET_Y} ;
		
		push @new_elements , $new_element ;
		}
	
	$self->deselect_all_elements() ;
	$self->select_elements(1, @new_elements) ;
	$self->update_display() ;
	}

return @new_elements ;
}

#----------------------------------------------------------------------------------------------

sub open_stencil
{
my ($self, $file_name) = @_ ;

unless (defined $file_name)
	{
	# pick a file
	$file_name = $self->get_file_name ;
	}

if(defined $file_name && $file_name ne '')
	{
	# check path
	system "asciio '$file_name' &" ;
	}

}

#----------------------------------------------------------------------------------------------

sub open_user_stencil
{
my ($self, $file_name) = @_ ;

my $user_stencils_path = File::HomeDir->my_home() . '/.config/Asciio/stencils' ;

if(defined $file_name)
	{
	$file_name = "$user_stencils_path/$file_name" ;
	}
else
	{
	# pick a file
	$file_name = $self->get_file_name('', 'save', $user_stencils_path) ;
	}

if(defined $file_name && $file_name ne '')
	{
	# todo: check path
	system "asciio '$file_name' &" ;
	}

}

#----------------------------------------------------------------------------------------------


sub add_help_box
{
my ($self) = @_ ;

$self->create_undo_snapshot() ;

my $help_path = File::HomeDir->my_home() . '/.config/Asciio/help_box' ;

if(-e $help_path)
	{
	my $help_text = read_text($help_path, {bin_mode => ':utf8'});
	
	Encode::_utf8_on($help_text);
	$help_text =~ s/\t/$self->{TAB_AS_SPACES}/g;
	$help_text =~ s/\r//g;
	
	my $new_element = new App::Asciio::stripes::editable_box2
						({
						TEXT_ONLY => $help_text,
						TITLE => '',
						EDITABLE => 1,
						RESIZABLE => 0,
						}) ;
	
	$new_element->{SAVE_ON_EDIT} = $help_path ;
	
	@$new_element{'X', 'Y', 'SELECTED'} = ($self->{MOUSE_X}, $self->{MOUSE_Y}, 0) ;
	$self->add_elements($new_element) ;
	
	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

my @headless_arrows =
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
	['up-right',    '|',  '|',  '.', '-', '-', 1],
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

#----------------------------------------------------------------------------------------------

sub add_line
{
my ($self, $line_type) = @_;

$self->create_undo_snapshot();

$self->deselect_all_elements() ;

my $arrow_type = $headless_arrows[$line_type] ;

my $line = new App::Asciio::stripes::section_wirl_arrow
		({
		POINTS => [[5, 0, 'right']],
		DIRECTION => 'left',
		ALLOW_DIAGONAL_LINES => 0,
		EDITABLE => 1,
		RESIZABLE => 1,
		ARROW_TYPE => $arrow_type,
		});

$line->{NAME} = 'line';

$self->add_element_at($line, $self->{MOUSE_X}, $self->{MOUSE_Y});

$self->select_elements(1, $line);

$self->update_display();
}

#----------------------------------------------------------------------------------------------

sub add_non_connecting_line
{
my ($self, $line_type) = @_;

$self->create_undo_snapshot();

$self->deselect_all_elements() ;

my $arrow_type = $headless_arrows[$line_type] ;

my $line = new App::Asciio::stripes::section_wirl_arrow
		({
		POINTS => [[2, 0, 'right']],
		DIRECTION => 'left',
		ALLOW_DIAGONAL_LINES => 0,
		EDITABLE => 1,
		RESIZABLE => 1,
		ARROW_TYPE => $arrow_type,
		});

$line->{NAME} = 'line';
$line->enable_autoconnect(0);
$line->allow_connection('start', 0);
$line->allow_connection('end', 0);

$self->add_element_at($line, $self->{MOUSE_X}, $self->{MOUSE_Y});

$self->select_elements(1, $line);

$self->update_display();
}

#----------------------------------------------------------------------------------------------

1 ;

