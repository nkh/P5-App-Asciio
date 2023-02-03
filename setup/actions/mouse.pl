
use App::Asciio::Actions::Mouse ;
use App::Asciio::Actions::Multiwirl ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Quick link'              => ['00S-button_press-1', \&App::Asciio::Actions::Mouse::quick_link                    ] ,
	'Insert flex point'       => ['0A0-button_press-1', \&App::Asciio::Actions::Multiwirl::insert_wirl_arrow_section ],
	
	# 'left button pressed'     => ['000-button_press-1', \&left_button_pressed                                        ] ,

	'Toggle mouse'            => ['000-apostrophe',     \&toggle_mouse                                               ] ,

	'Mouse left-click'        => ['000-odiaeresis',     \&mouse_left_click                                           ] ,
	'Mouse shift-left-click'  => ['00S-Odiaeresis',     \&mouse_shift_left_click                                     ] ,
	'Mouse ctl-left-click'    => ['C00-odiaeresis',     \&mouse_ctl_left_click                                       ] ,
	'Mouse alt-left-click'    => ['0A0-odiaeresis',     \&mouse_alt_left_click                                       ] ,

	'Mouse right-click'       => ['000-adiaeresis',     \&mouse_right_click                                          ] ,
	
	'Mouse drag left'         => ['00S-Left',           \&mouse_drag_left                                            ] ,
	'Mouse drag right'        => ['00S-Right',          \&mouse_drag_right                                           ] ,
	'Mouse drag up'           => ['00S-Up',             \&mouse_drag_up                                              ] ,
	'Mouse drag down'         => ['00S-Down',           \&mouse_drag_down                                            ] ,

	'Mouse on element id'     => ['000-m',              \&mouse_on_element_id                                        ] ,
	#~ 'C00-button_release' => ['', ] ,
	#~ 'C00-motion_notify' =>['', ] ,
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


