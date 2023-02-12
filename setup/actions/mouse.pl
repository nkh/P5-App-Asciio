
use App::Asciio::Actions::Mouse ;
use App::Asciio::Actions::Multiwirl ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Quick link'              => [['00S-button_press-1', '000-.'], \&App::Asciio::Actions::Mouse::quick_link                    ] ,
	'Insert flex point'       => ['0A0-button_press-1', \&App::Asciio::Actions::Multiwirl::insert_wirl_arrow_section ],
	
	# 'left button pressed'     => ['000-button_press-1', \&left_button_pressed                                        ] ,
	
	'Toggle mouse'            => ['000-apostrophe',     \&App::Asciio::Actions::Mouse::toggle_mouse                  ] ,
	
	'Mouse left-click'        => ['000-odiaeresis',     \&App::Asciio::Actions::Mouse::mouse_left_click              ] ,
	'Mouse shift-left-click'  => ['00S-Odiaeresis',     \&App::Asciio::Actions::Mouse::mouse_shift_left_click        ] ,
	'Mouse ctl-left-click'    => ['C00-odiaeresis',     \&App::Asciio::Actions::Mouse::mouse_ctl_left_click          ] ,
	'Mouse alt-left-click'    => ['0A0-odiaeresis',     \&App::Asciio::Actions::Mouse::mouse_alt_left_click          ] ,
	
	'Mouse right-click'       => ['000-adiaeresis',     \&App::Asciio::Actions::Mouse::mouse_right_click             ] ,
	
	'Mouse drag left'         => ['00S-Left',           \&App::Asciio::Actions::Mouse::mouse_drag_left               ] ,
	'Mouse drag right'        => ['00S-Right',          \&App::Asciio::Actions::Mouse::mouse_drag_right              ] ,
	'Mouse drag up'           => ['00S-Up',             \&App::Asciio::Actions::Mouse::mouse_drag_up                 ] ,
	'Mouse drag down'         => ['00S-Down',           \&App::Asciio::Actions::Mouse::mouse_drag_down               ] ,
	
	'Mouse on element id'     => ['000-m',              \&App::Asciio::Actions::Mouse::mouse_on_element_id           ] ,
	#~ 'C00-button_release' => ['', ] ,
	#~ 'C00-motion_notify' =>['', ] ,
	) ;

#----------------------------------------------------------------------------------------------

