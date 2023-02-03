
#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Select next element'                           => ['000-<Tab>',          \&App::Asciio::Actions::ElementsManipulation::select_next_element                      ],
	
	'Move selected elements left'                   => ['000-<Left>',         \&App::Asciio::Actions::ElementsManipulation::move_selection_left                      ],
	'Move selected elements right'                  => ['000-<Right>',        \&App::Asciio::Actions::ElementsManipulation::move_selection_right                     ],
	'Move selected elements up'                     => ['000-<Up>',           \&App::Asciio::Actions::ElementsManipulation::move_selection_up                        ],
	'Move selected elements down'                   => ['000-<Down>',         \&App::Asciio::Actions::ElementsManipulation::move_selection_down                      ],
	



	'Toggle mouse'                                  => ["000-'",                \&toggle_mouse                                               ] ,
	
	'Mouse left-click'                              => ['000-ö',                \&mouse_left_click                                           ] ,
	'Mouse shift-left-click'                        => ['000-Ö',                \&mouse_shift_left_click                                     ] ,
	'Mouse ctl-left-click'                          => ['C00-ö',                \&mouse_ctl_left_click                                       ] ,
	'Mouse alt-left-click'                          => ['0A0-ö',                \&mouse_alt_left_click                                       ] ,

	'Mouse right-click'                             => ['000-ä',                \&mouse_right_click                                          ] ,
	
	'Mouse drag left'                               => ['0A0-A-Left',           \&mouse_drag_left                                            ] ,
	'Mouse drag right'                              => ['0A0-A-Right',          \&mouse_drag_right                                           ] ,
	'Mouse drag up'                                 => ['0A0-A-Up',             \&mouse_drag_up                                              ] ,
	'Mouse drag down'                               => ['0A0-A-Down',           \&mouse_drag_down                                            ] ,

	) ;


#----------------------------------------------------------------------------------------------

my %lookup =
	(
	'Help'                                           => ':h',
	'Display keyboard mapping'                       => ':k',
	'Display commands'                               => ':c',
	'Display action files'                           => ':f',
	
	'Open'                                           => ':e',
	'Save'                                           => ':w',
	'SaveAs'                                         => ':W',
	'Quit'                                           => ':q',
	'Quit no save'                                   => ':Q',
	
	'Undo'                                           => 'u',
	'Redo'                                           => '®',
	
	'Import from primary to box'                     => 'iy',
	'Import from clipboard to box'                   => 'iY',
	'External command output in a box'               => 'ix',
	'External command output in a box no frame'      => 'iX',
	'Insert from file'                               => 'if',
	
	'Add arrow'                                      => 'ia',
	'Append multi_wirl section'                      => 'as',
	'Insert multi_wirl section'                      => 'aS',
	'Prepend multi_wirl section'                     => 'a?',
	'Remove last section from multi_wirl'            => 'a?',
	'Change arrow direction'                         => 'ad',
	'Flip arrow start and end'                       => 'aa',
	'Add group object type 1'                        => 'ig',
	'Add group object type 2'                        => 'ig',
	'Ungroup group-object'                           => 'lu',
	
	'Add box'                                        => 'ib',
	'Create multiple box elements from description'  => 'iM',
	'Create multiple text elements from description' => 'iT',
	
	'Add connector'                                  => 'ic',
	'Add if'                                         => 'ii',
	'Add process'                                    => 'ip',
	'Add vertical ruler'                             => 'ir',
	'Add horizontal ruler'                           => 'iR',
	'Delete rulers'                                  => 'dr',
	'Add text'                                       => 'it',
	'Add angled arrow'                               => 'iA',
	'Add shrink box'                                 => 'iT',
	
	'Group selected elements'                        => 'lg',
	'Ungroup selected elements'                      => 'lu',
	'Move selected elements to the back'             => 'lb',
	'Move selected elements to the front'            => 'lf',
	'Temporary move selected element to the front'   => 'lF',
	
	'Edit selected element'                          => 'Return',
	'Change elements foreground color'               => 'ec',
	'Change elements background color'               => 'eC',
	'Select all elements'                            => '',
	'Select connected elements'                      => '',
	
	'Deselect all elements'                          => '',
	'Select next element'                            => 'n',
	'Select previous element'                        => 'N',
	'Delete selected elements'                       => 'dd',
	
	'Insert from clipboard'                          => 'p',
	'Copy to clipboard'                              => 'y',
	'Export to clipboard & primary as ascii'         => 'Y',
	
	'Move selected elements down'                    => 'j',
	'Move selected elements left'                    => 'h',
	'Move selected elements right'                   => 'l',
	'Move selected elements up'                      => 'k',
	
	'Toggle mouse'                                   => "'",
	'Mouse right-click'                              => 'ö',
	'Mouse left-click'                               => 'ä',
	'Mouse shift-left-click'                         => '',
	'Mouse alt-left-click'                           => '',
	'Mouse ctl-left-click'                           => '',
	'Mouse drag down'                                => 'J',
	'Mouse drag left'                                => 'H',
	'Mouse drag right'                               => 'L',
	'Mouse drag up'                                  => 'K',
	'Mouse on element id'                            => 'ge',
	'Quick link'                                     => 'shift+button_press-1',
	
	'Change AsciiO background color'                 => 'zc',
	'Change grid color'                              => 'zC',
	'Flip grid display'                              => 'zg',
	'Flip color scheme'                              => 'zs',
	'Flip transparent element background'            => 'zt',
	'Zoom out'                                       => '-',
	'Zoom in'                                        => '+',
	
	'Align bottom'                                   => 'Ab',
	'Align center'                                   => 'Ac',
	'Align left'                                     => 'Al',
	'Align middle'                                   => 'Am',
	'Align right'                                    => 'Ar',
	'Align top'                                      => 'At',
	
	'Load slides'                                    => 'Sl',
	'previous slide'                                 => 'SN',
	'next slide'                                     => 'Sn',
	'first slide'                                    => 'Sg',
	
	'Display undo stack statistics'                  => 'DS',
	'Dump self'                                      => 'Ds' ,
	'Dump all elements'                              => 'De',
	'Dump selected elements'                         => 'DE',
	'Display numbered objects'                       => 'Dt',
	'Test'                                           => 'Do',
	) ;

#----------------------------------------------------------------------------------------------

use List::MoreUtils qw(first_value) ;

sub left_button_pressed
{
my ($self, $event) = @_;

my($x, $y) = @{$event->{COORDINATES}} ;

if($event->{TYPE} eq '2button-press')
	{
	my @element_over = grep { $self->is_over_element($_, $x, $y) } reverse @{$self->{ELEMENTS}} ;
	
	if(@element_over)
		{
		my $selected_element = $element_over[0] ;
		$self->edit_element($selected_element) ;
		$self->update_display();
		}
		
	return 1 ;
	}

if($event->{BUTTON} == 1) 
	{
	my $modifiers = $event->{MODIFIERS} ;
	
	my ($first_element) = first_value {$self->is_over_element($_, $x, $y)} reverse @{$self->{ELEMENTS}} ;
	
	if ($modifiers eq 'C00')
		{
		if(defined $first_element)
			{
			$self->run_actions_by_name('Copy to clipboard', ['Insert from clipboard', 0, 0])  ;
			}
		}
	else
		{
		if(defined $first_element)
			{
			 if ($modifiers eq '00S')
				{
				$self->select_elements_flip($first_element) ;
				}
			else
				{
				unless($self->is_element_selected($first_element))
					{
					# make the element under cursor the only selected element
					$self->select_elements(0, @{$self->{ELEMENTS}}) ;
					$self->select_elements(1, $first_element) ;
					}
				}
			}
		else
			{
			# deselect all
			$self->deselect_all_elements()  if ($modifiers eq '000')  ;
			}
		}
	
	$self->{SELECTION_RECTANGLE} = {START_X => $x , START_Y => $y} ;
	
	$self->update_display();
	}
	
if($event->{BUTTON} == 2) 
	{
	$self->{SELECTION_RECTANGLE} = {START_X => $x , START_Y => $y} ;
	
	$self->update_display();
	}
  
if($event->{BUTTON} == 3) 
	{
	$self->display_popup_menu($event) ; # display_popup_menu is handled by derived Asciio
	}

# $self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub toggle_mouse
{
my ($self) = @_;

$self->{MOUSE_TOGGLE} ^= 1 ;
$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub mouse_left_click
{
my ($self ) = @_;

# use Data::TreeDumper ; print DumpTree \@_ ;

if($self->{MOUSE_TOGGLE})
	{
	App::Asciio::button_press_event
		(
		$self,
		{
		BUTTON => 1,
		COORDINATES => [ $self->{MOUSE_X}, $self->{MOUSE_Y} ], 
		KEY_NAME => -1,
		MODIFIERS => '000',
		STATE => '',
		TYPE => 'button-press'
		},
		) ;
	}
}

#----------------------------------------------------------------------------------------------

sub mouse_shift_left_click
{
my ($self ) = @_;

if($self->{MOUSE_TOGGLE})
	{
	App::Asciio::button_press_event
		(
		$self,
		{
		BUTTON => 1,
		COORDINATES => [ $self->{MOUSE_X}, $self->{MOUSE_Y} ], 
		KEY_NAME => -1,
		MODIFIERS => '00S',
		STATE => '',
		TYPE => 'button-press'
		},
		) ;
	}
}

#----------------------------------------------------------------------------------------------

sub mouse_ctl_left_click
{
my ($self ) = @_;

if($self->{MOUSE_TOGGLE})
	{
	App::Asciio::button_press_event
		(
		$self,
		{
		BUTTON => 1,
		COORDINATES => [ $self->{MOUSE_X}, $self->{MOUSE_Y} ], 
		KEY_NAME => -1,
		MODIFIERS => 'C00',
		STATE => '',
		TYPE => 'button-press'
		},
		) ;
	}
}

#----------------------------------------------------------------------------------------------

sub mouse_alt_left_click
{
my ($self ) = @_;

if($self->{MOUSE_TOGGLE})
	{
	App::Asciio::button_press_event
		(
		$self,
		{
		BUTTON => 1,
		COORDINATES => [ $self->{MOUSE_X}, $self->{MOUSE_Y} ], 
		KEY_NAME => -1,
		MODIFIERS => '0A0',
		STATE => '',
		TYPE => 'button-press'
		},
		) ;
	}
}

#----------------------------------------------------------------------------------------------

sub mouse_right_click
{
my ($self) = @_;

$self->display_popup_menu($self->{EVENT}) ; # display_popup_menu is handled by derived Asciio
}

#----------------------------------------------------------------------------------------------

sub mouse_drag_left()
{
my ($self) = @_ ;

App::Asciio::motion_notify_event
	(
	$self,
	{
	BUTTON => 1,
	COORDINATES => [ $self->{MOUSE_X} - 1 , $self->{MOUSE_Y} ], 
	KEY_NAME => -1,
	MODIFIERS => '00S',
	STATE => "dragging-button1",
	TYPE => 'button-press'
	},
	) ;
}

#----------------------------------------------------------------------------------------------

sub mouse_drag_right()
{
my ($self) = @_ ;

App::Asciio::motion_notify_event
	(
	$self,
	{
	BUTTON => 1,
	COORDINATES => [ $self->{MOUSE_X} + 1 , $self->{MOUSE_Y} ], 
	KEY_NAME => -1,
	MODIFIERS => '000',
	STATE => "dragging-button1",
	TYPE => 'button-press'
	},
	) ;
}

#----------------------------------------------------------------------------------------------

sub mouse_drag_up()
{
my ($self) = @_ ;

App::Asciio::motion_notify_event
	(
	$self,
	{
	BUTTON => 1,
	COORDINATES => [ $self->{MOUSE_X}, $self->{MOUSE_Y} - 1 ], 
	KEY_NAME => -1,
	MODIFIERS => '000',
	STATE => "dragging-button1",
	TYPE => 'button-press'
	},
	) ;


}

#----------------------------------------------------------------------------------------------

sub mouse_drag_down()
{
my ($self) = @_ ;

App::Asciio::motion_notify_event
	(
	$self,
	{
	BUTTON => 1,
	COORDINATES => [ $self->{MOUSE_X} , $self->{MOUSE_Y} + 1 ], 
	KEY_NAME => -1,
	MODIFIERS => '000',
	STATE => "dragging-button1",
	TYPE => 'button-press'
	},
	) ;
}

#----------------------------------------------------------------------------------------------

sub mouse_on_element_id
{
my ($self) = @_ ;

my $id = $self->display_edit_dialog('element id', '') ;
$id = "$id" + 0 ;

return unless exists $self->{ELEMENTS}[$id - 1] ;

my $element = $self->{ELEMENTS}[$id - 1 ] ;
my ($x, $y) = ($element->{X}, $element->{Y}) ;

($self->{MOUSE_X}, $self->{MOUSE_Y}) = ($x, $y) ;
$self->{PREVIOUS_X} = $x ;
$self->{PREVIOUS_Y} = $y ;
# $self->{SELECTION_RECTANGLE}{START_X} = $self->{MOUSE_X} ;
# $self->{SELECTION_RECTANGLE}{END_X} = $self->{MOUSE_X} ;
# $self->{SELECTION_RECTANGLE}{START_Y} = $self->{MOUSE_Y} ;
# $self->{SELECTION_RECTANGLE}{END_Y} = $self->{MOUSE_Y} ;
# $self->{DRAGGING} = '' ;
	
$self->update_display() ;
}



