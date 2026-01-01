
package App::Asciio::Actions::Tabs ;

use strict ; use warnings ;
use Glib qw(TRUE FALSE);

#-----------------------------------------------------------------------------

sub close_tab              { my ($self) = @_             ; $self->signal_emit('close_tab', undef)                                    ;                           }
sub close_tab_no_save      { my ($self) = @_             ; $self->signal_emit('close_tab_no_save', undef)                            ;                           }
sub copy_tab               { my ($self, $data) = @_      ; $self->signal_emit('copy_tab', { serialized => $self->serialize_self() }) ;                           }
sub focus_tab              { my ($self, $tab_index) = @_ ; $self->signal_emit('focus_tab', $tab_index)                               ; $self->update_display   ; }
sub last_tab               { my ($self) = @_             ; $self->signal_emit('last_tab')                                            ;                           }
sub move_tab_left          { my ($self) = @_             ; $self->signal_emit('move_tab_left')                                       ; $self->update_display() ; }
sub move_tab_right         { my ($self) = @_             ; $self->signal_emit('move_tab_right')                                      ; $self->update_display() ; }
sub new_tab                { my ($self) = @_             ; $self->signal_emit('new_tab', {})                                         ;                           }
sub open_project           { my ($self) = @_             ; $self->signal_emit('open_project', '')                                    ;                           }
sub next_tab               { my ($self) = @_             ; $self->signal_emit('next_tab')                                            ;                           }
sub previous_tab           { my ($self) = @_             ; $self->signal_emit('previous_tab')                                        ;                           }
sub quit_app               { my ($self) = @_             ; $self->signal_emit('quit_app')                                            ;                           }
sub quit_app_no_save       { my ($self) = @_             ; $self->signal_emit('quit_app_no_save')                                    ;                           }
sub read                   { my ($self, $file) = @_      ; $self->signal_emit('read', $file)                                         ;                           }
sub save_project           { my ($self, $as) = @_        ; $self->signal_emit('save_project', $as)                                   ;                           }
sub show_help_tab          { my ($self) = @_             ; $self->signal_emit('show_help_tab')                                       ;                           }
sub toggle_tab_labels      { my ($self) = @_             ; $self->signal_emit('toggle_tab_labels')                                   ; $self->update_display() ; }
sub hide_all_bindings_help { my ($self) = @_             ; $self->signal_emit('hide_all_bindings_help')                              ; $self->update_display() ; }
sub show_all_bindings_help { my ($self) = @_             ; $self->signal_emit('show_all_bindings_help')                              ; $self->update_display() ; }

use App::Asciio::GTK::Asciio ;

sub rename_tab        
{
my ($self, $tab_name) = @_  ;

$tab_name = App::Asciio::GTK::Asciio::get_user_text('Rename tab')  unless defined $tab_name ;

$self->set_title($tab_name) if defined $tab_name && $tab_name ne '' ;
}

#-----------------------------------------------------------------------------

1 ;

