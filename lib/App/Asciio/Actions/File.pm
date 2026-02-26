
package App::Asciio::Actions::File ;

use utf8;
use Encode qw(decode encode FB_CROAK) ;

use File::Basename ;
use App::Asciio::String ;

#----------------------------------------------------------------------------------------------

sub save
{
my ($self, $as, $type, $file_name) = @_ ;

$self->update_display() ;

return $self->get_title // 1 unless $self->get_modified_state() || defined $as ;

Encode::_utf8_on($file_name) ;

unless(defined $file_name)
	{
	if((! defined $as) && $self->get_title())
		{
		$file_name = $self->get_title() ;
		}
	else
		{
		$file_name = $self->get_file_name('save')  ;
		
		if(defined $file_name && $file_name ne q[])
			{
			if(-e $file_name)
				{
				my $override = $self->display_yes_no_cancel_dialog
							(
							"Override file!",
							"File '$file_name' exists!\nOverride file?"
							) ;
							
				$file_name = undef unless $override eq 'yes' ;
				}
			}
		}
	}

if(defined $file_name && $file_name ne q[])
	{
	my ($base_name, $path, $extension) = File::Basename::fileparse($file_name, ('\..*')) ;
	$extension =~ s/^\.// ;
	
	$type = defined $type ? $type 
				:  $extension ne q{}
					? $extension
					: 'asciio_internal_format' ;
	
	my $cache = $self->{CACHE} ;
	$self->invalidate_rendering_cache() ;
	
	my $elements_to_save = Clone::clone($self->{ELEMENTS}) ;
	$self->{CACHE} = my $cache ;
	
	for my $element (@{$elements_to_save})
		{
		delete $element->{NAME} ;
		}
	
	my $new_title ;
	eval
		{
		$new_title = $self->save_with_type($elements_to_save, $type, $file_name) ;
		} ;
	
	if($@)
		{
		$self->display_message_modal("Can't save file '$file_name':\n$@\n") ;
		$file_name = undef ;
		}
	else
		{
		if(defined $new_title)
			{
			$self->set_title($new_title) ;
			$self->set_modified_state(0) ;
			}
		}
	}

return $file_name ;
} ;


#----------------------------------------------------------------------------------------------

sub open
{
my ($self, $file_name) = @_ ;

$file_name = normalize_file_name($file_name);

my $user_answer = '' ;

if($self->get_modified_state())
	{
	$user_answer = $self->display_yes_no_cancel_dialog('asciio', 'Diagram modified. Save it?') ;
	
	if($user_answer eq 'yes')
		{
		my $file_name = $self->get_file_name('save') ;
		
		my ($base_name, $path, $extension) = File::Basename::fileparse($file_name, ('\..*')) ;
		$extension =~ s/^\.// ;
		
		my $type =  $extension ne q{}
					? $extension
					: 'asciio_internal_format' ;
					
		$self->save_with_type(undef, $type, $file_name) if(defined $file_name && $file_name ne q[]) ;
		}
	}

if($user_answer ne 'cancel')
	{
	$file_name ||= $self->get_file_name('open') ;
	
	if(defined $file_name && $file_name ne q[])
		{
		my $title = $self->load_file($file_name) ;
		
		if($title)
			{
			my ($base_name, $path, $extension) = File::Basename::fileparse($file_name, ('\..*')) ;
			$extension =~ s/^\.// ;
			
			my $type = $extension ne q{}
						? $extension
						: 'asciio_internal_format' ;
						
			$self->set_title($title) if defined $title;
			$self->set_modified_state(0) ;
			$self->update_display() ;
			}
		else
			{
			my $element  = $self->add_new_element_named('Asciio/box', 0, 0) ;
			my $box_type = $element->get_box_type() ;
			$box_type->[1][0] = 1 ; # title separator
			$element->set_box_type($box_type) ;
			$element->set_background_color([1, 0.4, 0.4]) ;
			
			$element->set_text('Warning!', "'$file_name' isn't a valid asciio file.");
			
			$self->update_display(1) ;
			}
		}
	}
}

#----------------------------------------------------------------------------------------------

sub insert
{
my ($self, $x, $y, $file_name) = @_ ;

$file_name ||= $self->get_file_name('open') ;

if(defined $file_name && $file_name ne q[])
	{
	my $asciio = new App::Asciio() ;
	
	use Module::Util qw(find_installed) ;
	use File::Basename ;
	my ($basename, $path, $ext) = File::Basename::fileparse(find_installed('App::Asciio'), ('\..*')) ;
	my $setup_path = $path . $basename . '/setup/' ;
	
	%object_override = (WARN => sub { print STDERR "@_\n" }, ACTION_VERBOSE => sub { print STDERR "$_[0]\n" ; } ) ;
	$asciio->setup([$setup_path .  'setup.ini', ], \%object_override ) ;
	
	my $title = $asciio->load_file($file_name) ;
	
	if($title)
		{
		$asciio->run_actions_by_name('Select all elements', 'Copy to clipboard') ;
		$asciio->invalidate_rendering_cache() ;
		
		use Clone ;
		$self->{CLIPBOARD} = Clone::clone($asciio->{CLIPBOARD}) ; 
		
		$self->run_actions_by_name(['Insert from clipboard', $x, $y]) ;
		}
	else
		{
		my $element  = $self->add_new_element_named('Asciio/box', 0, 0) ;
		my $box_type = $element->get_box_type() ;
		$box_type->[1][0] = 1 ; # title separator
		$element->set_box_type($box_type) ;
		$element->set_background_color([1, 0.4, 0.4]) ;
		
		$element->set_text('Warning!', "'$file_name' isn't a valid asciio file.");
		
		$self->update_display(1) ;
		}
	}
}

#----------------------------------------------------------------------------------------------

sub quit_no_save { my ($self) = @_ ; $self->exit(1) ; }

#----------------------------------------------------------------------------------------------

sub quit
{
my ($self) = @_ ;

if($self->get_modified_state())
	{
	my $user_answer = $self->display_quit_dialog('asciio', 'Diagram modified. Save it and exit?') ;
	
	if($user_answer eq 'save_and_quit')
		{
		my $file_name = $self->get_file_name('save') ;
		
		my ($base_name, $path, $extension) = File::Basename::fileparse($file_name, ('\..*')) ;
		$extension =~ s/^\.// ;
		
		my $type =  $extension ne q{}
					? $extension
					: 'asciio_internal_format' ;
					
		my $saved = $self->save_with_type(undef, $type, $file_name) if(defined $file_name && $file_name ne q[]) ;
		
		$user_answer = 'ok' if defined $saved ;
		}
	
	$self->exit() if $user_answer eq 'ok'
	}
else
	{
	$self->exit() ;
	}
}

# ----------------------------------------------------------------------------

sub read_asciio_file
{
my ($self, $project_name) = @_  ;

use Capture::Tiny qw/capture_merged/ ;

my $tar ;
my ($merged,  @result) = capture_merged
				{ 
				$tar = Archive::Tar->new($project_name) ; 
				} ;

my @asciios ;

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
			push @asciios, $asciio ;
			
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
	print STDERR "Asciio: can't open project '$project_name', trying as asciio document\n";
	
	my ($config, $asciio) = $self->create_tab() ;
	push @asciios, $asciio ;
	
	my $document_name = $asciio->load_file($project_name) ;
	
	if($document_name)
		{
		while (exists $self->{LOADED_DOCUMENTS}{$document_name})
			{
			$document_name .= '_' . int(rand(100)) ;
			}
		
		$self->{LOADED_DOCUMENTS}{$document_name}++ ;
		
		$self->rename_tab($document_name) ;
		
		$asciio->set_title($document_name) ;
		$asciio->set_modified_state(0) ;
		}
	else
		{
		my $element  = $asciio->add_new_element_named('Asciio/box', 0, 0) ;
		my $box_type = $element->get_box_type() ;
		$box_type->[1][0] = 1 ; # title separator
		$element->set_box_type($box_type) ;
		$element->set_background_color([1, 0.4, 0.4]) ;
		
		$element->set_text('Warning!', "'$project_name' isn't a valid asciio file.");
		
		$asciio->update_display(1) ;
		}
	}

return @asciios ;
}

# ----------------------------------------------------------------------------

sub open_project
{
my ($self, $project_name, $delete_tabs) = @_ ;

if(! $delete_tabs || save_project($self, undef))
	{
	$project_name = App::Asciio::GTK::Asciio::get_file_name($self, 'open') unless (defined $project_name && $project_name ne q[]) ;
	
	if(defined $project_name && $project_name ne q[] && -e $project_name)
		{
		if($delete_tabs)
			{
			$self->delete_current_tab(undef, 0, 0) for 1 .. $self->{notebook}->get_n_pages() ;
			}
		
		App::Asciio::Actions::File::read_asciio_file($self, $project_name) ;
		
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
		$saved = App::Asciio::Actions::File::write_asciio_project($self, $project_name) ;
		
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

#----------------------------------------------------------------------------------------------

1 ;

