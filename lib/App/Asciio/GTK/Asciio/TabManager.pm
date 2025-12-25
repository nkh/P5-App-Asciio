
package App::Asciio::GTK::Asciio::TabManager ;

use strict ; use warnings ;

use Glib qw(TRUE FALSE);

use App::Asciio::Actions::File ;
use App::Asciio::GTK::Asciio::DnD ;
use App::Asciio::GTK::Asciio::HelpWidget ;
use App::Asciio::GTK::Asciio::TabManager::WebApi ;
use App::Asciio::GTK::Asciio::TabbedAsciio ;
use App::Asciio::Options ;
use App::Asciio::Server ;
use App::Asciio::Setup ;


use Archive::Tar ;
use File::Basename ;
use Module::Util qw(find_installed) ;
use Sereal::Decoder ;
use Sereal::Encoder ;

# ----------------------------------------------------------------------------

sub new
{
my ($class) = @_ ;

my $vbox = Gtk3::Box->new('vertical', 0) ;

my $notebook = Gtk3::Notebook->new() ;
$notebook->set_scrollable(TRUE) ; 

my $self = bless
{
	vbox             => $vbox,
	notebook         => $notebook,
	tab_counter      => 0,
	help_page_num    => -1,
	storage          => {},
	asciios          => [],
	help_widget      => undef,
	labels_visible   => TRUE,
	redirect_events  => -1, # redirect to all_tabs
	MODIFIED         => 0,
	TITLE            => undef,
	LOADED_DOCUMENTS => {},
}, $class ;

$vbox->pack_start($notebook, TRUE, TRUE, 0) ;

my $asciio_config = $self->start_ui() ;

my (undef, $web_server_pid) = App::Asciio::Server::start_web_server($self, $asciio_config->{WEB_PORT} // 4444, \&web_callback) ; 
$self->{web_server_pid} = $web_server_pid ;

$vbox->set_can_focus(TRUE) ;

$vbox->set_events
	([qw/
	exposure-mask
	leave-notify-mask
	button-press-mask
	button-release-mask
	pointer-motion-mask
	key-press-mask
	key-release-mask
	/]);


$self->setup_event_redirection() ;

return $self ;
}

sub setup_event_redirection
{
my ($self) = @_ ;

my $already_forwarding = 0 ;

$self->{vbox}->signal_connect
		(
		'key-press-event' => 
			sub
			{
			my ($widget, $event) = @_ ;
			
			return FALSE if $already_forwarding ;
			
			# print "TabManager [key-press-event], redirect: $self->{redirect_events}\n" ;
			
			my $page_num = $self->{redirect_events} == -1 ? $self->{notebook}->get_current_page() : $self->{redirect_events} ;
			
			if ($page_num >= 0)
				{
				my $scrolled_window = $self->{notebook}->get_nth_page($page_num) ;
				my @children        = $scrolled_window->get_children() ;
				my $viewport        = $children[0] if @children ;
				
				if ($viewport)
					{
					my $custom_widget = $viewport->get_child() ;
					
					if ($custom_widget)
						{
						$already_forwarding = 1 ;
						$custom_widget->signal_emit('key-press-event', $event) ;
						$already_forwarding = 0 ;
						}
					}
				}
			
			return TRUE ;
			}
		) ;
}

# ----------------------------------------------------------------------------

sub redirect_events
{
# redirect all key events to the current tab

my ($self, $on) = @_ ;

$self->{redirect_events} = $on ? $self->{notebook}->get_current_page() : -1 ;
}

# ----------------------------------------------------------------------------

sub get_widget
{
my ($self) = @_ ;
return $self->{vbox} ;
}

# ----------------------------------------------------------------------------

sub start_ui
{
my ($self) = @_ ;

my ($command_line_switch_parse_ok, $command_line_parse_message, $config)
	= App::Asciio::ParseSwitches(undef, [@ARGV], 0) ;

die "Asciio Error: '$command_line_parse_message'!" unless $command_line_switch_parse_ok ;

if($config->{TARGETS}->@*)
	{
	for my $target ($config->{TARGETS}->@*)
		{
		$self->read_asciio_file($target) ;
		}
	
	if (1 == $config->{TARGETS}->@*)
		{
		$self->set_title($config->{TARGETS}[0]) ;
		}
	
	$self->focus_tab(0) ;
	}
else
	{
	$self->create_tab() ;
	}

$self->{MODIFIED} = 0 ;
return $config  ;
}

# ----------------------------------------------------------------------------

sub create_tab
{
my ($self, $asciio_data) = @_ ;

my ($asciio, $asciio_config)  = App::Asciio::GTK::Asciio::TabbedAsciio->new($asciio_data) ;

$asciio->set_can_focus(FALSE) ;
$asciio->setup_dnd ;

my ($character_width, $character_height) = $asciio->get_character_size() ;
$asciio->set_size_request($asciio->{CANVAS_WIDTH} * $character_width, $asciio->{CANVAS_HEIGHT} * $character_height);

my %signal_handlers =
	(
	close_tab              => sub { my ($w, $asciio) = @_ ; $self->{MODIFIED}++ ; $self->delete_current_tab($asciio, 1, 1) ; },
	close_tab_no_save      => sub { my ($w, $asciio) = @_ ; $self->{MODIFIED}++ ; $self->delete_current_tab($asciio, 0, 1) ; },
	copy_tab               => sub { my ($w, $data)   = @_ ; $self->{MODIFIED}++ ; $self->create_tab($data) ;                 },
	focus_tab              => sub { my ($w, $index)  = @_ ;                       $self->focus_tab($index) ;                 },
	# get_all_asciios 
	# get_keys         
	# get_kv           
	last_tab               => sub { my ($w)          = @_ ; $self->last_tab() ;                                              },
	move_tab_left          => sub { my ($w)          = @_ ; $self->{MODIFIED}++ ; $self->move_tab_left() ;                   },
	move_tab_right         => sub { my ($w)          = @_ ; $self->{MODIFIED}++ ; $self->move_tab_right() ;                  },
	new_tab                => sub { my ($w, $data)   = @_ ; $self->{MODIFIED}++ ; $self->create_tab() ;                      },
	next_tab               => sub { my ($w)          = @_ ;                       $self->next_tab() ;                        },
	open_project           => sub { my ($w, $data)   = @_ ;                       $self->open_project($data, 1) ;            },
	previous_tab           => sub { my ($w)          = @_ ;                       $self->previous_tab() ;                    },
	quit_app               => sub { my ($w)          = @_ ;                       $self->quit_application(1) ;               },
	quit_app_no_save       => sub { my ($w)          = @_ ;                       $self->quit_application(0) ;               },
	hide_all_bindings_help => sub { my ($w)          = @_ ;                       $self->hide_all_bindings_help() ;          },
	show_all_bindings_help => sub { my ($w)          = @_ ;                       $self->show_all_bindings_help() ;          },
	rename_tab             => sub { my ($w, $name)   = @_ ; $self->{MODIFIED}++ ; $self->rename_tab($name) ;                 },
	# send_to_asciio  
	# set_kv           
	read                   => sub { my ($w, $file)   = @_ ;                       $self->read($file) ;                       },
	save_project           => sub { my ($w, $as)     = @_ ;                       $self->save_project($as) ;                 },
	show_help_tab          => sub { my ($w)          = @_ ;                       $self->show_help_tab() ;                   },
	toggle_tab_labels      => sub { my ($w)          = @_ ;                       $self->toggle_tab_labels() ;               },
	# event management
	redirect_events        => sub { my ($w, $on)     = @_ ;                       $self->redirect_events($on) ;              },
	) ;

while (my ($signal, $sub) = each %signal_handlers)
	{
	$asciio->signal_connect($signal, $sub) 
	}

my $label = $self->create_tab_label($asciio->get_title() // 'untitled_' . $self->{tab_counter}) ;

my $scroller = Gtk3::ScrolledWindow->new() ;
$scroller->set_policy('automatic', 'automatic') ;  # show scrollbars as needed
$scroller->set_hexpand(TRUE) ;
$scroller->set_vexpand(TRUE) ;
$scroller->add($asciio) ;

$asciio->set_hexpand(TRUE); $asciio->set_vexpand(TRUE) ;

# my $page_num = $self->{notebook}->append_page($scroller, $label) ;
# push @{$self->{asciios}}, $asciio ;
my $current_page = $self->{notebook}->get_current_page() ;
my $page_num = $self->{notebook}->insert_page($scroller, $label, $current_page + 1) ;
$self->{tab_counter}++ ;

splice $self->{asciios}->@*, $current_page + 1, 0, $asciio ;

$self->{labels_visible} = $self->{tab_counter} == 1 ? FALSE : TRUE ;
$self->{notebook}->set_show_tabs($self->{labels_visible}) ;

# use small margins around tab labels
my $css_provider = Gtk3::CssProvider->new() ;
$css_provider->load_from_data("tab { padding-left: 3px; padding-right: 3px; padding-top: 2px; padding-bottom: 2px; }") ;
$self->{notebook}->get_style_context()->add_provider($css_provider, Gtk3::STYLE_PROVIDER_PRIORITY_APPLICATION) ;

$scroller->show_all() ;

$self->{notebook}->set_current_page($page_num) ;
$asciio->grab_focus() ;

return ($asciio_config, $asciio) ;
}

sub create_tab_label
{
my ($self, $text) = @_ ;

my $max_chars    = 35 ;
my $text_length  = length($text) ;
my $display_text = $text ;

if ($text_length > $max_chars)
	{
	# Shorten from the left
	$display_text = '...' . substr($text, -($max_chars - 3)) ;
	}

my $label = Gtk3::Label->new($display_text) ;
$label->set_single_line_mode(TRUE) ;

$label->set_width_chars(0) ;
$label->set_margin_start(0) ;
$label->set_margin_end(0) ;
$label->set_margin_top(0) ;
$label->set_margin_bottom(0) ;

return $label ;
}

# ----------------------------------------------------------------------------

sub delete_current_tab
{
my ($self, $asciio, $save_document, $quit) = @_ ;

my $n_pages = $self->{notebook}->get_n_pages() ;

if(defined $asciio)
	{
	my $page = -1 ;
	
	for my $i (0 .. $#{$self->{asciios}})
		{
		if ($self->{asciios}[$i] == $asciio)
			{
			$page = $i ;
			last ;
			}
		}
	
	return if -1 == $page ;
	
	$page++ if -1 != $self->{help_page_num} && $self->{help_page_num} <= $page ;
	
	splice @{$self->{asciios}}, $page, 1 ;
	
	$self->{notebook}->remove_page($page) ;
	$self->{tab_counter}-- ;
	
	if ($self->{help_page_num} > $page)
		{
		$self->{help_page_num}-- ;
		}
	
	$self->quit_application() if $quit && $n_pages - 1 == 0 ;
	}
else
	{
	my $current_page = $self->{notebook}->get_current_page() ;
	
	if ($current_page == $self->{help_page_num})
		{
		$self->{notebook}->remove_page($current_page) ;
		$self->{help_page_num} = -1 ;
		$self->{help_widget}   = undef ;
		return ;
		}
	
	my $asciio = $self->{asciios}[$current_page] ;
	my $saved  = $save_document ? App::Asciio::Actions::File::save($asciio) : 1 ;
	
	if($saved)
		{
		for my $i (0 .. $#{$self->{asciios}})
			{
			if ($self->{asciios}[$i] == $asciio)
				{
				splice @{$self->{asciios}}, $i, 1 ;
				last ;
				}
			}
		}
	
	$self->{notebook}->remove_page($current_page) ;
	$self->{tab_counter}-- ;
	}
}

# ----------------------------------------------------------------------------

sub quit_application
{
my ($self, $save_documents) = @_ ;

if ($save_documents)
	{
	my $asciio_modified = 0 ;
	
	for my $asciio ($self->{asciios}->@*)
		{
		if($asciio->get_modified_state())
			{
			$asciio_modified++ ;
			last ;
			}
		}
	
	if( $self->{MODIFIED} || $asciio_modified )
		{
		my $user_answer = App::Asciio::GTK::Asciio::display_quit_dialog(undef, 'asciio', 'Project modified. Save it and exit?') ;
		
		if($user_answer eq 'save_and_quit')
			{
			my $project_name = $self->get_title() // App::Asciio::GTK::Asciio::get_file_name(undef, 'save') ;
			
			if(defined $project_name && $project_name ne q[])
				{
				if(-e $project_name)
					{
					my $override = App::Asciio::GTK::Asciio::display_yes_no_cancel_dialog
								(
								undef,
								"Override file!",
								"File '$project_name' exists!\nOverride file?"
								) ;
								
					$project_name = undef unless $override eq 'yes' ;
					}
				
				if(defined $project_name && $project_name ne q[])
					{
					my $saved = $self->write_asciio_project($project_name) ;
					$user_answer = 'ok' if defined $saved ;
					}
				}
			
			# todo: do we need to save the individual documents too?
			# my $saved = $save_documents ? App::Asciio::Actions::File::save($asciio) : 1 ;
			}
		
		$self->exit() if $user_answer eq 'ok'
		}
	else
		{
		$self->exit() ;
		}
	}
else
	{
	$self->exit() ;
	}
}

sub exit
{
my ($self) = @_ ;

kill 'HUP', $self->{web_server_pid} ;
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
}

# ----------------------------------------------------------------------------

sub next_tab
{
my ($self) = @_ ;

my $current = $self->{notebook}->get_current_page() ;
my $n_pages = $self->{notebook}->get_n_pages() ;
my $next    = ($current + 1) % $n_pages ;

$self->{notebook}->set_current_page($next) ;
}

# ----------------------------------------------------------------------------

sub previous_tab
{
my ($self) = @_ ;

my $current = $self->{notebook}->get_current_page() ;
my $n_pages = $self->{notebook}->get_n_pages() ;
my $prev    = ($current - 1 + $n_pages) % $n_pages ;

$self->{notebook}->set_current_page($prev) ;
}

# ----------------------------------------------------------------------------

sub last_tab
{
my ($self) = @_ ;

my $n_pages = $self->{notebook}->get_n_pages() ;
$self->{notebook}->set_current_page($n_pages - 1) ;
}

# ----------------------------------------------------------------------------

sub focus_tab
{
my ($self, $index) = @_ ;

my $n_pages = $self->{notebook}->get_n_pages() ;

if ($index < $n_pages)
	{
	$self->{notebook}->set_current_page($index) ;
	}
else
	{
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
	$self->{notebook}->reorder_child
				(
				$self->{notebook}->get_nth_page($current),
				$current + 1
				) ;
	
	my $asciio = splice $self->{asciios}->@*, $current, 1 ;
	splice $self->{asciios}->@*, $current + 1, 0, $asciio ;
	
	if ($self->{help_page_num} == $current)
		{
		$self->{help_page_num} = $current + 1 ;
		}
	elsif ($self->{help_page_num} == $current + 1)
		{
		$self->{help_page_num} = $current ;
		}
	}
}

# ----------------------------------------------------------------------------

sub move_tab_left
{
my ($self) = @_ ;

my $current = $self->{notebook}->get_current_page() ;

if ($current > 0)
	{
	$self->{notebook}->reorder_child
				(
				$self->{notebook}->get_nth_page($current),
				$current - 1
				) ;
	
	my $asciio = splice $self->{asciios}->@*, $current, 1 ;
	splice $self->{asciios}->@*, $current - 1, 0, $asciio ;
	
	if ($self->{help_page_num} == $current)
		{
		$self->{help_page_num} = $current - 1 ;
		}
	elsif ($self->{help_page_num} == $current - 1)
		{
		$self->{help_page_num} = $current ;
		}
	}
}

# ----------------------------------------------------------------------------

sub toggle_tab_labels
{
my ($self) = @_ ;

$self->{labels_visible} = !$self->{labels_visible} ;
$self->{notebook}->set_show_tabs($self->{labels_visible}) ;
}

# ----------------------------------------------------------------------------

sub hide_all_bindings_help
{
my ($self, $name) = @_ ;

$_->set_use_bindings_completion(0) for $self->{asciios}->@* ;
}

# ----------------------------------------------------------------------------

sub show_all_bindings_help
{
my ($self, $name) = @_ ;

$_->set_use_bindings_completion(1) for $self->{asciios}->@* ;
}

# ----------------------------------------------------------------------------

sub rename_tab
{
my ($self, $name) = @_ ;

my $current = $self->{notebook}->get_current_page() ;
my $tab     = $self->{notebook}->get_nth_page($current) ;

my $new_label = $self->create_tab_label($name) ;
$self->{notebook}->set_tab_label($tab, $new_label) ;
$new_label->show() ;

# my $asciio = $self->{asciios}[$current] ;
# $asciio->set_title($name) ;
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
	}
else
	{
	}
}

# ----------------------------------------------------------------------------

sub read
{
my ($self, $file) = @_ ;
$self->open_project($file, 0) ;
}

# ----------------------------------------------------------------------------

sub open_project
{
my ($self, $project_name, $delete_tabs) = @_ ;

if(! $delete_tabs || $self->save_project(undef))
	{
	$project_name = App::Asciio::GTK::Asciio::get_file_name($self, 'open') unless (defined $project_name && $project_name ne q[]) ;
	
	if(defined $project_name && $project_name ne q[] && -e $project_name)
		{
		if($delete_tabs)
			{
			$self->delete_current_tab(undef, 0, 0) for $self->{notebook}->get_n_pages() ;
			}
		
		$self->read_asciio_file($project_name) ;
		
		$self->set_title($project_name) if $delete_tabs ;
		$self->{MODIFIED} = 0 if $delete_tabs ;
		}
	}
}

# ----------------------------------------------------------------------------

sub save_project
{
my ($self, $as) = @_ ;

my $asciio_modified = 0 ;

for my $asciio ($self->{asciios}->@*)
	{
	if($asciio->get_modified_state())
		{
		$asciio_modified++ ;
		last ;
		}
	}

return(1) unless $self->{MODIFIED} || $asciio_modified ;

my $project_name  ;

if(! defined $as )
	{
	$project_name = $self->get_title() // App::Asciio::GTK::Asciio::get_file_name(undef, 'save as') ;
	}
elsif( '' eq $as )
	{
	$project_name = App::Asciio::GTK::Asciio::get_file_name(undef, 'save as') ;
	}
else
	{
	$project_name = $as ;
	}

my $saved ;

if(defined $project_name && $project_name ne q[])
	{
	if(-e $project_name)
		{
		my $override = App::Asciio::GTK::Asciio::display_yes_no_cancel_dialog
					(
					undef,
					"Override file!",
					"File '$project_name' exists!\nOverride file?"
					) ;
		
		$project_name = undef unless $override eq 'yes' ;
		}
	
	if(defined $project_name && $project_name ne q[])
		{
		$saved = $self->write_asciio_project($project_name) ;
		
		if ($saved)
			{
			$self->set_title($project_name) ;
			$self->{MODIFIED} = 0 ;
			}
		}
	}

return $saved ;
}

# ----------------------------------------------------------------------------

sub write_asciio_project
{
my ($self, $project_name) = @_ ;

$self->set_title($project_name) ;

my $saved = 1 ;
my $tar = Archive::Tar->new ;

my $project_data = { tabs => scalar($self->{asciios}->@*), documents => [], } ; 
my $index = -1 ;
my %seen_titles ;

for my $asciio ($self->{asciios}->@*)
	{
	$index++ ;
	my $serialized_asciio = $asciio->serialize_self() ;
	
	my $title = $asciio->get_title() // ('untitled_' . $index) ;
	
	while ($seen_titles{$title})
		{
		$title .= int(rand(100)) ;
		}
	
	$seen_titles{$title}++ ;
	
	push $project_data->{documents}->@*, $title ;
	$asciio->set_modified_state(0) ;
	
	$tar->add_data
		(
		$title,
		$serialized_asciio,
		{
		mode  => 0644,   mtime => time,
		uid   => 0,      gid => 0,
		uname => 'root', gname => 'root',
		}) or do { $saved = 0 ; print STDERR "asciio: add_data error at entry index: $index" . $tar->error ; }  ;
	}

$tar->add_data
	(
	'asciio_project',
	Sereal::Encoder->new->encode($project_data),
	{
	mode  => 0644,   mtime => time,
	uid   => 0,      gid => 0,
	uname => 'root', gname => 'root',
	},
	) or do { $saved = 0 ; print STDERR "asciio: add_data error: " . $tar->error ; } ;

$tar->write($project_name) or do { $saved = 0 ; print STDERR "asciio: write error: " . $tar->error ; } ;

open(my $fh, '>>', $project_name) or do { $saved = 0 ; print STDERR  "Could not open file '$project_name' for appending magic: $!" ; } ;
print $fh 'application/x-asciio-project' ;
close $fh ;

$self->{MODIFIED} = 0 if $saved ;

return $saved ;
}

# ----------------------------------------------------------------------------

sub read_asciio_file
{
my ($self, $project_name) = @_  ;

my $tar = Archive::Tar->new($project_name) or print STDERR "Can't open '$project_name': " . Archive::Tar->error() . "\n";

if($tar)
	{
	my %documents = map { $_ => 1 } grep { $_ ne 'asciio_project' } $tar->list_files ;
	
	my $serialized_asciio_project = $tar->get_content('asciio_project') ;
	my $asciio_project            = eval { Sereal::Decoder->new->decode($serialized_asciio_project) } ;
	
	if ($@)
		{
		print STDERR "Error: deserializing '$project_name': $@" 
		}
	else
		{
		for my $document_name ($asciio_project->{documents}->@*) 
			{
			my ($config, $asciio) = $self->create_tab({serialized => $tar->get_content($document_name)}) ;
			
			while (exists $self->{LOADED_DOCUMENTS}{$document_name})
				{
				$document_name .= '_' . int(rand(100)) ;
				}
			
			$self->{LOADED_DOCUMENTS}{$document_name}++ ;
			
			$self->rename_tab($document_name) ;
			
			$asciio->set_title($document_name) ;
			$asciio->set_modified_state(0) ;
			}
		}
	}
else
	{
	my ($config, $asciio) = $self->create_tab() ;
	my $document_name     = $asciio->load_file($project_name) ;
	
	while (exists $self->{LOADED_DOCUMENTS}{$document_name})
		{
		$document_name .= '_' . int(rand(100)) ;
		}
	
	$self->{LOADED_DOCUMENTS}{$document_name}++ ;
	
	$self->rename_tab($document_name) ;
	
	$asciio->set_title($document_name) ;
	$asciio->set_modified_state(0) ;
	}
}

#-----------------------------------------------------------------------------

sub set_title
{
my ($self, $title) = @_;

if(defined $title) 
	{
	if (defined $self->{TITLE})
		{
		if ($self->{TITLE} ne $title)
			{
			$self->{TITLE} = $title ;
			$self->{MODIFIED}++ ;
			}
		}
	else
		{
		$self->{TITLE} = $title ;
		$self->{MODIFIED}++ ;
		}
	}
}

sub get_title
{
my ($self) = @_;
Encode::_utf8_on($self->{TITLE});
$self->{TITLE} ;
}

# ----------------------------------------------------------------------------

1 ;

