
package App::Asciio::Actions::File ;
use utf8;
use Encode;

#----------------------------------------------------------------------------------------------

use File::Basename ;

#----------------------------------------------------------------------------------------------

sub save
{
my ($self, $as, $type, $file_name) = @_ ;
Encode::_utf8_on($file_name);

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

$self->update_display() ;

return $file_name ;
} ;


#----------------------------------------------------------------------------------------------

sub open
{
my ($self, $file_name) = @_ ;
$file_name = decode('utf-8', $file_name);

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
		
		my ($base_name, $path, $extension) = File::Basename::fileparse($file_name, ('\..*')) ;
		$extension =~ s/^\.// ;
		
		my $type = $extension ne q{}
					? $extension
					: 'asciio_internal_format' ;
					
		$self->set_title($title) if defined $title;
		$self->set_modified_state(0) ;
		$self->update_display() ;
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
	
	$asciio->load_file($file_name) ;
	$asciio->run_actions_by_name('Select all elements', 'Copy to clipboard') ;
	$asciio->invalidate_rendering_cache() ;
	
	use Clone ;
	$self->{CLIPBOARD} = Clone::clone($asciio->{CLIPBOARD}) ; 
	
	$self->run_actions_by_name(['Insert from clipboard', $x, $y]) ;
	}
}

#----------------------------------------------------------------------------------------------

sub quit_no_save { my ($self) = @_ ; $self->exit() ; }

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

#----------------------------------------------------------------------------------------------

1 ;

