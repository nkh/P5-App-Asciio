
#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'box_context_menu' => ['box_context_menu',  undef, undef,  \&box_context_menu],
	) ;


#----------------------------------------------------------------------------------------------

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

my %box_types = 
	(
	dash =>
		[
			[1, 'top', '.', '-', '.', 1, ],
			[0, 'title separator', '|', '-', '|', 1, ],
			[1, 'body separator', '| ', '|', ' |', 1, ], 
			[1, 'bottom', '\'', '-', '\'', 1, ],
		],
	dot =>
		[
			[1, 'top', '.', '.', '.', 1, ],
			[0, 'title separator', '.', '.', '.', 1, ],
			[1, 'body separator', '. ', '.', ' .', 1, ], 
			[1, 'bottom', '.', '.', '.', 1, ],
		],
	star =>
		[
			[1, 'top', '*', '*', '*', 1, ],
			[0, 'title separator', '*', '*', '*', 1, ],
			[1, 'body separator', '* ', '*', ' *', 1, ], 
			[1, 'bottom', '*', '*', '*', 1, ],
		],
	) ;

#----------------------------------------------------------------------------------------------

sub box_context_menu
{
my ($self, $popup_x, $popup_y) = @_ ;
my @context_menu_entries ;

my ($character_width, $character_height) = $self->get_character_size() ;

my @selected_elements = $self->get_selected_elements(1) ;

if(@selected_elements == 1 && 'App::Asciio::stripes::editable_box2' eq ref $selected_elements[0])
	{
	my $element = $selected_elements[0] ;
	
	my ($x, $y) = $self->closest_character($popup_x - ($element->{X} * $character_width) , $popup_y - ($element->{Y} * $character_height)) ;
	
	push @context_menu_entries, 
		[
		'/Rotate text', 
		sub {$element->rotate_text() ;},
		] ;
		
	push @context_menu_entries, 
		[
		'/box selected element', 
		\&box_selected_element,
		{ ELEMENT => $element},
		] ;
		
	push @context_menu_entries, 
		[
			'/Box type/dash', 
			\&change_box_type,
			{
			ELEMENT => $element, 
			TYPE => 'dash',
			}
		], 
		
		[
			'/Box type/dot', 
			\&change_box_type,
			{
			ELEMENT => $element, 
			TYPE => 'dot',
			}
		], 
		[
			'/Box type/star', 
			\&change_box_type,
			{
			ELEMENT => $element, 
			TYPE => 'star',
			}
		] ;
		
	push @context_menu_entries, 
		[
		$element->is_autoconnect_enabled() ? '/disable autoconnection' :  '/enable autoconnection', 
		sub 
			{
			$self->create_undo_snapshot() ;
			$element->enable_autoconnect(! $element->is_autoconnect_enabled()) ;
			$self->update_display() ;
			}
		] ;
		
	if($element->is_border_connection_allowed())
		{
		push @context_menu_entries, ["/Disable border connection", sub {$element->allow_border_connection(0) ;}] ;
		}
	else
		{
		push @context_menu_entries, ["/Enable border connection", sub {$element->allow_border_connection(1) ;}] ;
		}
		
	if($element->is_auto_shrink())
		{
		push @context_menu_entries, ["/Disable auto shrink", sub {$element->flip_auto_shrink() ;}] ;
		}
	else
		{
		push @context_menu_entries, ["/Enable auto shrink", sub {$element->shrink() ; $element->flip_auto_shrink() ; }] ;
		}
	}
	
return(@context_menu_entries) ;
}

#----------------------------------------------------------------------------------------------

sub change_box_type
{
my ($self, $data) = @_ ;

use Clone ;

if(exists $box_types{$data->{TYPE}})
	{
	$self->create_undo_snapshot() ;
	
	my $element_type = $data->{ELEMENT}->get_box_type() ;
	
	my $new_type = Clone::clone($box_types{$data->{TYPE}}) ;
	
	for (my $frame_element_index = 0 ; $frame_element_index < @{$new_type} ; $frame_element_index++)
		{
		$new_type->[$frame_element_index][$DISPLAY] = $element_type->[$frame_element_index][$DISPLAY] 
		}
		
	$data->{ELEMENT}->set_box_type($new_type) ;
	
	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

sub box_selected_element
{
my ($self, $data) = @_ ;

$self->create_undo_snapshot() ;

my $element_type = $data->{ELEMENT}->get_box_type() ;
my ($title, $text) = $data->{ELEMENT}->get_text() ;

for (0 .. $#$element_type)
	{
	next if $_ == $TITLE_SEPARATOR && $title eq '' ;
	
	$element_type->[$_][$DISPLAY] = 1 ;
	}

$data->{ELEMENT}->set_box_type($element_type) ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------
