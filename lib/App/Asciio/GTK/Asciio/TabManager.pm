
package App::Asciio::GTK::Asciio::TabManager ;

use Glib qw(TRUE FALSE);

use App::Asciio::Setup ;
use App::Asciio::Server ;
# use App::Asciio::GTK::Asciio::DnD ;
use App::Asciio::GTK::Asciio::TabbedAsciio ;
use App::Asciio::GTK::Asciio::HelpWidget ;

use Module::Util qw(find_installed) ;
use File::Basename ;

# ----------------------------------------------------------------------------

sub new
{
my ($class) = @_ ;

my $vbox = Gtk3::Box->new('vertical', 0) ;

my $toolbar = Gtk3::Box->new('horizontal', 5) ;
$toolbar->set_margin_start(5) ;
$toolbar->set_margin_end(5) ;
$toolbar->set_margin_top(5) ;
$toolbar->set_margin_bottom(5) ;

my $add_button    = Gtk3::Button->new_with_label('New Tab (+)') ;
my $delete_button = Gtk3::Button->new_with_label('Delete Tab (-)') ;
my $help_button   = Gtk3::Button->new_with_label('Help (h)') ;
my $quit_button   = Gtk3::Button->new_with_label('Quit (q)') ;

$toolbar->pack_start($add_button, FALSE, FALSE, 0) ;
$toolbar->pack_start($delete_button, FALSE, FALSE, 0) ;
$toolbar->pack_start($quit_button, FALSE, FALSE, 0) ;
$toolbar->pack_start($help_button, FALSE, FALSE, 0) ;

my $notebook = Gtk3::Notebook->new() ;

my $statusbar  = Gtk3::Statusbar->new() ;
my $context_id = $statusbar->get_context_id('worker_signals') ;

my $self = bless
	{
	vbox           => $vbox,
	notebook       => $notebook,
	statusbar      => $statusbar,
	context_id     => $context_id,
	add_button     => $add_button,
	delete_button  => $delete_button,
	quit_button    => $quit_button,
	help_button    => $help_button,
	toolbar        => $toolbar,
	tab_counter    => 0,
	help_page_num  => -1,
	storage        => {},
	asciios        => [],
	help_widget    => undef,
	labels_visible => TRUE,
	}, $class ;

$vbox->pack_start($toolbar, FALSE, FALSE, 0) ;
$vbox->pack_start($notebook, TRUE, TRUE, 0) ;
$vbox->pack_start($statusbar, FALSE, FALSE, 0) ;

$add_button->signal_connect
	(
	clicked => sub
		{
		$self->create_tab() ;
		$self->update_status("Created new tab") ;
		}
	) ;

$delete_button->signal_connect ( clicked => sub { $self->delete_current_tab() ; }) ;
$quit_button->signal_connect ( clicked => sub { $self->quit_application() ; }) ;
$help_button->signal_connect ( clicked => sub { $self->show_help_tab() ; }) ;

$self->create_tab() ;
$self->update_status("Application started") ;

return $self ;
}

# ----------------------------------------------------------------------------

sub get_widget
{
my ($self) = @_ ;
return $self->{vbox} ;
}

# ----------------------------------------------------------------------------

sub update_status
{
my ($self, $message) = @_ ;
$self->{statusbar}->pop($self->{context_id}) ;
$self->{statusbar}->push($self->{context_id}, $message) ;
}

# ----------------------------------------------------------------------------

sub create_tab
{
my ($self, $asciio_data, $argv) = @_ ;

my $asciio = App::Asciio::GTK::Asciio::TabbedAsciio->new($asciio_data) ;

my ($character_width, $character_height) = $asciio->get_character_size() ;
$asciio->set_size_request($asciio->{CANVAS_WIDTH} * $character_width, $asciio->{CANVAS_HEIGHT} * $character_height);

push @{$self->{asciios}}, $asciio ;

$asciio->signal_connect('copy_tab'          => sub { my ($w, $data) = @_ ; $self->create_tab($data) ; $self->update_status("Worker requested copy tab") ; }) ;
$asciio->signal_connect('delete_tab'        => sub { my ($w) = @_ ; $self->delete_current_tab() ; }) ;
$asciio->signal_connect('focus_tab'         => sub { my ($w, $index) = @_ ; $self->focus_tab($index) ; }) ;
$asciio->signal_connect('show_help_tab'     => sub { my ($w) = @_ ; $self->show_help_tab() ; }) ;
$asciio->signal_connect('last_tab'          => sub { my ($w) = @_ ; $self->last_tab() ; }) ;
$asciio->signal_connect('move_tab_left'     => sub { my ($w) = @_ ; $self->move_tab_left() ; }) ;
$asciio->signal_connect('move_tab_right'    => sub { my ($w) = @_ ; $self->move_tab_right() ; }) ;
$asciio->signal_connect('new_tab'           => sub { my ($w, $data) = @_ ; $self->create_tab($data) ; $self->update_status("Worker requested new tab") ; }) ;
$asciio->signal_connect('next_tab'          => sub { my ($w) = @_ ; $self->next_tab() ; }) ;
$asciio->signal_connect('previous_tab'      => sub { my ($w) = @_ ; $self->previous_tab() ; }) ;
$asciio->signal_connect('quit'              => sub { my ($w) = @_ ; $self->quit_application() ; }) ;
$asciio->signal_connect('toggle_tab_labels' => sub { my ($w) = @_ ; $self->toggle_tab_labels() ; }) ;
$asciio->signal_connect('toggle_toolbar'    => sub { my ($w) = @_ ; $self->toggle_toolbar() ; }) ;

# missing signals and handlers

# rename_tab
# send_to_asciio      
# asciio_message      
# get_storage_keys    
# get_storage_value   
# set_storage_value   
# get_all_asciios     
# storage_keys_result 
# storage_value_result
# all_asciios_result  

my $label = Gtk3::Label->new($self->{tab_counter}) ;

my $scroller = Gtk3::ScrolledWindow->new() ;
$scroller->set_policy('automatic', 'automatic') ;  # show scrollbars as needed
$scroller->set_hexpand(TRUE) ;
$scroller->set_vexpand(TRUE) ;
$scroller->add($asciio) ;

$asciio->set_hexpand(TRUE); $asciio->set_vexpand(TRUE) ;

my $page_num = $self->{notebook}->append_page($scroller, $label) ;
$self->{notebook}->set_current_page($page_num) ;

if (!$self->{labels_visible})
	{
	$self->{notebook}->set_show_tabs(FALSE) ;
	}

$scroller->show_all() ;
$asciio->grab_focus() ;

$self->{tab_counter}++ ;

return $tab_counter ;
}

# ----------------------------------------------------------------------------

sub delete_current_tab
{
my ($self) = @_ ;

my $current_page = $self->{notebook}->get_current_page() ;
my $n_pages      = $self->{notebook}->get_n_pages() ;

if ($current_page == $self->{help_page_num})
	{
	$self->{notebook}->remove_page($current_page) ;
	$self->{help_page_num} = -1 ;
	$self->{help_widget}   = undef ;
	$self->update_status("Deleted help tab") ;
	return ;
	}

if ($n_pages > 1)
	{
	my $asciio = $self->{notebook}->get_nth_page($current_page) ;
	for my $i (0 .. $#{$self->{asciios}})
		{
		if ($self->{asciios}[$i] == $asciio)
			{
			splice @{$self->{asciios}}, $i, 1 ;
			last ;
			}
		}
	
	$self->{notebook}->remove_page($current_page) ;
	
	if ($self->{help_page_num} > $current_page)
		{
		$self->{help_page_num}-- ;
		}
	$self->update_status("Deleted tab") ;
	}
else
	{
	$self->update_status("Cannot delete last tab") ;
	}
}

# ----------------------------------------------------------------------------

sub quit_application
{
my ($self) = @_ ;
$self->update_status("Quitting application") ;
Gtk3::main_quit() ;
}

# ----------------------------------------------------------------------------

sub show_help_tab
{
my ($self) = @_ ;

if ($self->{help_page_num} >= 0)
	{
	my $n_pages = $self->{notebook}->get_n_pages() ;
	
	if ($self->{help_page_num} < $n_pages)
		{
		$self->{notebook}->set_current_page($self->{help_page_num}) ;
		$self->{help_widget}->grab_focus() if $self->{help_widget} ;
		$self->update_status("Showing help tab") ;
		return ;
		}
	else
		{
		$self->{help_page_num} = -1 ;
		$self->{help_widget}   = undef ;
		}
	}

my $help_widget = App::Asciio::GTK::Asciio::HelpWidget->new($self) ;
$self->{help_widget} = $help_widget ;
my $label = Gtk3::Label->new('Help') ;

my $page_num = $self->{notebook}->append_page($help_widget->get_widget(), $label) ;
$self->{help_page_num} = $page_num ;

$help_widget->get_widget()->show_all() ;
$self->{notebook}->set_current_page($page_num) ;
$help_widget->grab_focus() ;

$self->update_status("Created help tab") ;
}

# ----------------------------------------------------------------------------

sub next_tab
{
my ($self) = @_ ;

my $current = $self->{notebook}->get_current_page() ;
my $n_pages = $self->{notebook}->get_n_pages() ;
my $next    = ($current + 1) % $n_pages ;

$self->{notebook}->set_current_page($next) ;
$self->update_status("Navigated to next tab") ;
}

# ----------------------------------------------------------------------------

sub previous_tab
{
my ($self) = @_ ;

my $current = $self->{notebook}->get_current_page() ;
my $n_pages = $self->{notebook}->get_n_pages() ;
my $prev    = ($current - 1 + $n_pages) % $n_pages ;

$self->{notebook}->set_current_page($prev) ;
$self->update_status("Navigated to previous tab") ;
}

# ----------------------------------------------------------------------------

sub last_tab
{
my ($self) = @_ ;

my $n_pages = $self->{notebook}->get_n_pages() ;
$self->{notebook}->set_current_page($n_pages - 1) ;
$self->update_status("Navigated to last tab") ;
}

# ----------------------------------------------------------------------------

sub focus_tab
{
my ($self, $index) = @_ ;

my $n_pages = $self->{notebook}->get_n_pages() ;

if ($index < $n_pages)
	{
	$self->{notebook}->set_current_page($index) ;
	$self->update_status("Focused tab at index $index") ;
	}
else
	{
	$self->update_status("Tab index $index does not exist") ;
	}
}

# ----------------------------------------------------------------------------

sub move_tab_right
{
my ($self) = @_ ;

my $current = $self->{notebook}->get_current_page() ;
my $n_pages = $self->{notebook}->get_n_pages() ;

if ($current < $n_pages - 1)
	{
	$self->{notebook}->reorder_child(
		$self->{notebook}->get_nth_page($current),
		$current + 1
	) ;
	
	if ($self->{help_page_num} == $current)
		{
		$self->{help_page_num} = $current + 1 ;
		}
	elsif ($self->{help_page_num} == $current + 1)
		{
		$self->{help_page_num} = $current ;
		}
	
	$self->update_status("Moved tab to the right") ;
	}
else
	{
	$self->update_status("Cannot move last tab to the right") ;
	}
}

# ----------------------------------------------------------------------------

sub move_tab_left
{
my ($self) = @_ ;

my $current = $self->{notebook}->get_current_page() ;

if ($current > 0)
	{
	$self->{notebook}->reorder_child(
		$self->{notebook}->get_nth_page($current),
		$current - 1
	) ;
	
	if ($self->{help_page_num} == $current)
		{
		$self->{help_page_num} = $current - 1 ;
		}
	elsif ($self->{help_page_num} == $current - 1)
		{
		$self->{help_page_num} = $current ;
		}
	
	$self->update_status("Moved tab to the left") ;
	}
else
	{
	$self->update_status("Cannot move first tab to the left") ;
	}
}

# ----------------------------------------------------------------------------

sub toggle_toolbar
{
my ($self) = @_ ;

if ($self->{toolbar}->get_visible())
	{
	$self->{toolbar}->hide() ;
	$self->update_status("Toolbar hidden") ;
	}
else
	{
	$self->{toolbar}->show() ;
	$self->update_status("Toolbar visible") ;
	}
}

# ----------------------------------------------------------------------------

sub toggle_tab_labels
{
my ($self) = @_ ;

$self->{labels_visible} = !$self->{labels_visible} ;
$self->{notebook}->set_show_tabs($self->{labels_visible}) ;

if ($self->{labels_visible})
	{
	$self->update_status("Tab labels visible") ;
	}
else
	{
	$self->update_status("Tab labels hidden") ;
	}
}

# ----------------------------------------------------------------------------

sub get_storage_keys
{
my ($self) = @_ ;
return [keys %{$self->{storage}}] ;
}

# ----------------------------------------------------------------------------

sub get_storage_value
{
my ($self, $key) = @_ ;
return $self->{storage}{$key} ;
}

# ----------------------------------------------------------------------------

sub set_storage_value
{
my ($self, $key, $value) = @_ ;
$self->{storage}{$key} = $value ;
}

# ----------------------------------------------------------------------------

sub get_all_asciios
{
my ($self) = @_ ;
return [@{$self->{asciios}}] ;
}

# ----------------------------------------------------------------------------

sub send_to_asciio
{
my ($self, $asciio_index, $message_type, $data) = @_ ;

if ($asciio_index >= 0 && $asciio_index < scalar @{$self->{asciios}})
	{
	my $asciio = $self->{asciios}[$asciio_index] ;
	$asciio->signal_emit('asciio_message', { type => $message_type, data => $data }) ;
	$self->update_status("Sent message to asciio $asciio_index") ;
	}
else
	{
	$self->update_status("Invalid asciio index: $asciio_index") ;
	}
}

# ----------------------------------------------------------------------------

1 ;

