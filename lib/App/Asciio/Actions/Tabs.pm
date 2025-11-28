
package App::Asciio::Actions::Tabs ;

use strict ; use warnings ;

use Glib qw(TRUE FALSE);

#-----------------------------------------------------------------------------

sub show_help_tab
{
my ($self) = @_ ;
$self->signal_emit('show_help_tab') ;
}

#-----------------------------------------------------------------------------

sub last_tab
{
my ($self) = @_ ;
$self->signal_emit('last_tab') ;
}

#-----------------------------------------------------------------------------

sub move_tab_right
{
my ($self) = @_ ;
$self->signal_emit('move_tab_right') ;
$self->update_display() ;
}

#-----------------------------------------------------------------------------

sub move_tab_left
{
my ($self) = @_ ;
$self->signal_emit('move_tab_left') ;
$self->update_display() ;
}

#-----------------------------------------------------------------------------

sub next_tab
{
my ($self) = @_ ;
$self->signal_emit('',) ;
}

#-----------------------------------------------------------------------------

sub quit_all
{
my ($self) = @_ ;
$self->signal_emit('quit') ;
}

#-----------------------------------------------------------------------------

sub toggle_tab_labels
{
my ($self) = @_ ;
$self->signal_emit('toggle_tab_labels',) ;
$self->update_display() ;
}

#-----------------------------------------------------------------------------

sub toggle_toolbar
{
my ($self) = @_ ;
$self->signal_emit('toggle_toolbar',) ;
}

#-----------------------------------------------------------------------------

sub new_tab
{
my ($self) = @_ ;
$self->signal_emit('new_tab', {}) ;
}

#-----------------------------------------------------------------------------

sub copy_tab
{
my ($self, $data) = @_ ;
$self->signal_emit('copy_tab', { data  => $data }) ;
}

#-----------------------------------------------------------------------------

sub next_tab
{
my ($self) = @_ ;
$self->signal_emit('next_tab') ;
}

#-----------------------------------------------------------------------------

sub previous_tab
{
my ($self) = @_ ;
$self->signal_emit('previous_tab') ;
}

#-----------------------------------------------------------------------------

sub focus_tab
{
my ($self, $tab_index) = @_ ;
$self->signal_emit('focus_tab', $tab_index) ;
$self->update_display ;
}


#-----------------------------------------------------------------------------

sub delete_tab
{
my ($self) = @_ ;
}

#-----------------------------------------------------------------------------

# sub rename
# {
# my ($self) = @_ ;
# my ($self, $tab_name) = @_ ;
# }

#-----------------------------------------------------------------------------

1 ;

