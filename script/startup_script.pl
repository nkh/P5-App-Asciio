
use App::Asciio::stripes::editable_box2 ;

my $box = new App::Asciio::stripes::editable_box2
				({
				TEXT_ONLY => 'box',
				TITLE => '',
				EDITABLE => 1,
				RESIZABLE => 1,
				}) ;

$self->add_element_at($box, 5, 5) ;

# run an action defined in the setup/action directory
#~ $self->run_actions_by_name(['Save', undef, undef, 'close_test.txt']) ;

