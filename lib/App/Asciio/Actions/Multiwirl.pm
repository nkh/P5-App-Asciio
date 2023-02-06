
package App::Asciio::Actions::Multiwirl ;

#----------------------------------------------------------------------------------------------

sub insert_wirl_arrow_section
{
my ($self) = @_ ;

my @selected_elements = $self->get_selected_elements(1) ;

if(@selected_elements == 1 && 'App::Asciio::stripes::section_wirl_arrow' eq ref $selected_elements[0])
	{
	my $element = $selected_elements[0] ;
	
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

my @selected_elements = $self->get_selected_elements(1) ;

if(@selected_elements == 1 && 'App::Asciio::stripes::section_wirl_arrow' eq ref $selected_elements[0])
	{
	my $element = $selected_elements[0] ;
	
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

my @selected_elements = $self->get_selected_elements(1) ;

if(@selected_elements == 1 && 'App::Asciio::stripes::section_wirl_arrow' eq ref $selected_elements[0])
	{
	my $element = $selected_elements[0] ;
	
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

my @selected_elements = $self->get_selected_elements(1) ;

if(@selected_elements == 1 && 'App::Asciio::stripes::section_wirl_arrow' eq ref $selected_elements[0])
	{
	my $element = $selected_elements[0] ;
	
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

my @selected_elements = $self->get_selected_elements(1) ;

if(@selected_elements == 1 && 'App::Asciio::stripes::section_wirl_arrow' eq ref $selected_elements[0])
	{
	my $element = $selected_elements[0] ;
	
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

my ($character_width, $character_height) = $self->get_character_size() ;

my @selected_elements = $self->get_selected_elements(1) ;

if(@selected_elements == 1 && 'App::Asciio::stripes::section_wirl_arrow' eq ref $selected_elements[0])
	{
	my $element = $selected_elements[0] ;
	
	my ($x, $y) = $self->closest_character($popup_x - ($element->{X} * $character_width) , $popup_y - ($element->{Y} * $character_height)) ;
	
	push @context_menu_entries, 
		[
			'/append section', 
			\&add_section_to_section_wirl_arrow,
			{ELEMENT => $selected_elements[0], X => $x, Y => $y,}
		] ;
		
	if($element->is_connection_allowed('start'))
		{
		push @context_menu_entries, ["/arrow connection/start doesn't connect", sub {$selected_elements[0]->allow_connection('start',0) ;}] ;
		}
	else
		{
		push @context_menu_entries, ["/arrow connection/start connects", sub {$selected_elements[0]->allow_connection('start',1) ;}] ;
		}
		
	if($element->is_connection_allowed('end'))
		{
		push @context_menu_entries, ["/arrow connection/end doesn't connect", sub {$selected_elements[0]->allow_connection('end',0) ;}] ;
		}
	else
		{
		push @context_menu_entries, ["/arrow connection/end connects", sub {$selected_elements[0]->allow_connection('end',1) ;}] ;
		}
		
	push @context_menu_entries, 
		[
		$selected_elements[0]->is_autoconnect_enabled() ? '/disable autoconnection' :  '/enable autoconnection', 
		sub 
			{
			$self->create_undo_snapshot() ;
			$selected_elements[0]->enable_autoconnect(! $selected_elements[0]->is_autoconnect_enabled()) ;
			$self->update_display() ;
			}
		] ;
		
	push @context_menu_entries, 
		[
		$selected_elements[0]->are_diagonals_allowed() ? '/no diagonals' :  '/allow diagonals', 
		sub {$selected_elements[0]->allow_diagonals(! $selected_elements[0]->are_diagonals_allowed()) ;}
		] ;
		
	push @context_menu_entries, 
		[
			'/arrow type/dash', 
			\&change_arrow_type,
			{ELEMENT => $selected_elements[0], TYPE => 'dash', X => $x,	Y => $y,}
		] ,
		[
			'/arrow type/dot', 
			\&change_arrow_type,
			{ELEMENT => $selected_elements[0], TYPE => 'dot', X => $x,	Y => $y,}
		],
		[
			'/arrow type/octo', 
			\&change_arrow_type,
			{ELEMENT => $selected_elements[0], TYPE => 'octo',X => $x,	Y => $y,}
		],
		[
			'/arrow type/star', 
			\&change_arrow_type,
			{ELEMENT => $selected_elements[0], TYPE => 'star', X => $x,	Y => $y, }
		] ;
	}
	
return(@context_menu_entries) ;
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
			['origin', '', '*', '', '', '', 1],
			['up', '|', '|', '', '', '^', 1],
			['down', '|', '|', '', '', 'v', 1],
			['left', '-', '-', '', '', '<', 1],
			['upleft', '|', '|', '.', '-', '<', 1],
			['leftup', '-', '-', '\'', '|', '^', 1],
			['downleft', '|', '|', '\'', '-', '<', 1],
			['leftdown', '-', '-', '.', '|', 'v', 1],
			['right', '-', '-','', '', '>', 1],
			['upright', '|', '|', '.', '-', '>', 1],
			['rightup', '-', '-', '\'', '|', '^', 1],
			['downright', '|', '|', '\'', '-', '>', 1],
			['rightdown', '-', '-', '.', '|', 'v', 1],
			['45', '/', '/', '', '', '^', 1, ],
			['135', '\\', '\\', '', '', 'v', 1, ],
			['225', '/', '/', '', '', 'v', 1, ],
			['315', '\\', '\\', '', '', '^', 1, ],
		],
	dot =>
		[
			['origin', '', '*', '', '', '', 1],
			['up', '.', '.', '', '', '^', 1],
			['down', '.', '.', '', '', 'v', 1],
			['left', '.', '.', '', '', '<', 1],
			['upleft', '.', '.', '.', '.', '<', 1],
			['leftup', '.', '.', '\'', '.', '^', 1],
			['downleft', '.', '.', '\'', '.', '<', 1],
			['leftdown', '.', '.', '.', '.', 'v', 1],
			['right', '.', '.','', '', '>', 1],
			['upright', '.', '.', '.', '.', '>', 1],
			['rightup', '.', '.', '\'', '.', '^', 1],
			['downright', '.', '.', '\'', '.', '>', 1],
			['rightdown', '.', '.', '.', '.', 'v', 1],
			['45', '.', '.', '', '', '^', 1, ],
			['135', '.', '.', '', '', 'v', 1, ],
			['225', '.', '.', '', '', 'v', 1, ],
			['315', '.', '.', '', '', '^', 1, ],
		],
	star =>
		[
			['origin', '', '*', '', '', '', 1],
			['up', '*', '*', '', '', '^', 1],
			['down', '*', '*', '', '', 'v', 1],
			['left', '*', '*', '', '', '<', 1],
			['upleft', '*', '*', '*', '*', '<', 1],
			['leftup', '*', '*', '*', '*', '^', 1],
			['downleft', '*', '*', '*', '*', '<', 1],
			['leftdown', '*', '*', '*', '*', 'v', 1],
			['right', '*', '*','', '', '>', 1],
			['upright', '*', '*', '*', '*', '>', 1],
			['rightup', '*', '*', '*', '*', '^', 1],
			['downright', '*', '*', '*', '*', '>', 1],
			['rightdown', '*', '*', '*', '*', 'v', 1],
			['45', '*', '*', '', '', '^', 1, ],
			['135', '*', '*', '', '', 'v', 1, ],
			['225', '*', '*', '', '', 'v', 1, ],
			['315', '*', '*', '', '', '^', 1, ],
		],
	octo =>
		[
			['origin', '', '#', '', '', '', 1],
			['up', '#', '#', '', '', '^', 1],
			['down', '#', '#', '', '', 'v', 1],
			['left', '#', '#', '', '', '<', 1],
			['upleft', '#', '#', '#', '#', '<', 1],
			['leftup', '#', '#', '#', '#', '^', 1],
			['downleft', '#', '#', '#', '#', '<', 1],
			['leftdown', '#', '#', '#', '#', 'v', 1],
			['right', '#', '#','', '', '>', 1],
			['upright', '#', '#', '#', '#', '>', 1],
			['rightup', '#', '#', '#', '#', '^', 1],
			['downright', '#', '#', '#', '#', '>', 1],
			['rightdown', '#', '#', '#', '#', 'v', 1],
			['45', '#', '#', '', '', '^', 1, ],
			['135', '#', '#', '', '', 'v', 1, ],
			['225', '#', '#', '', '', 'v', 1, ],
			['315', '#', '#', '', '', '^', 1, ],
		],
	) ;


sub change_arrow_type
{
my ($self, $data) = @_ ;

use Clone ;

if(exists $arrow_types{$data->{TYPE}})
	{
	$self->create_undo_snapshot() ;
	
	my $new_type = Clone::clone($arrow_types{$data->{TYPE}}) ;
		
	$data->{ELEMENT}->set_arrow_type($new_type) ;
	
	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

1 ;

