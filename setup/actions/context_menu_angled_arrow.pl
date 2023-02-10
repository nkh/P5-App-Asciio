
use App::Asciio::Actions::Multiwirl ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Angled arrow context_menu'  => ['000-000', sub { 1 }, undef, \&angled_arrow_context_menu ],
	) ;

#----------------------------------------------------------------------------------------------

sub angled_arrow_context_menu
{
my ($self, $popup_x, $popup_y) = @_ ;
my @context_menu_entries ;

my @selected_elements = $self->get_selected_elements(1) ;

if(@selected_elements == 1 && 'App::Asciio::stripes::angled_arrow' eq ref $selected_elements[0])
	{
	my $element = $selected_elements[0] ;
	
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
	}

return(@context_menu_entries) ;
}

