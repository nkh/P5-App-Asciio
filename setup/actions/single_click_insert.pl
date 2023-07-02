
my $click_choice_element = ['Asciio/box', 0] ;

sub click_choice_add_element { App::Asciio::Actions::Elements::add_element($_[0], $click_choice_element) ; }
sub click_element_choice { $click_choice_element = $_[1] ; }

#----------------------------------------------------------------------------------------------

register_action_handlers
(

'insert on click' =>
	{
	SHORTCUTS => '0A0-i',
	ESCAPE_KEY => '000-Escape',
	
	'Mouse motion'             => ['000-motion_notify',  \&App::Asciio::Actions::Mouse::mouse_motion                                          ], 
	
	'click element insert'     => [ '000-button-press-1',  \&click_choice_add_element                         ],
	'click element arrow'      => [ '000-a',               \&click_element_choice, ['Asciio/angled_arrow', 0] ],
	'click element box'        => [ '000-b',               \&click_element_choice, ['Asciio/box', 0]          ],
	'click element text'       => [ '000-t',               \&click_element_choice, ['Asciio/text', 0]         ],
	
	},

) ;
