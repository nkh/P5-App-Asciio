
use App::Asciio::Actions::Mouse ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Quick link'              => ['00S-button_press-1', \&App::Asciio::Actions::Mouse::quick_link] ,
	
	# 'left button pressed'     => ['000-button_press-1', \&left_button_pressed                    ] ,

	'Toggle mouse'            => ['000-apostrophe',     \&toggle_mouse                           ] ,

	'Mouse left-click'        => ['000-odiaeresis',     \&mouse_left_click                       ] ,
	'Mouse shift-left-click'  => ['00S-Odiaeresis',     \&mouse_shift_left_click                 ] ,

	'Mouse right-click'       => ['000-adiaeresis',     \&mouse_right_click                      ] ,
	
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
		STATE => {},
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
		STATE => {},
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

