
package App::Asciio::Actions::Animation ;

use strict ; use warnings ;

use File::Slurper qw(read_text write_text) ;
use List::Util qw(max) ;
use File::Path qw(make_path);
use Data::TreeDumper ;

#----------------------------------------------------------------------------------------------

use App::Asciio::Utils::Animation ;

#----------------------------------------------------------------------------------------------

sub reset_slide
{
# needs undo snapshot that can be tagged as scripts call APIs that also call undo_snapshot
}

#----------------------------------------------------------------------------------------------

sub set_snapshot_directory
{
# per slide, can be shared with other slides
# sub start_automatic_slideshow_once
}

#----------------------------------------------------------------------------------------------

sub take_snapshot
{
my ($self, $file_name) = @_ ;

my $now = localtime ;
   $now =~ s/\s+/_/g ;

$file_name //= "asciio_snapshot_" . $now . ".png" ;

$self->save_with_type($self->{ELEMENTS}, 'png', $file_name) ;
$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub get_scripts
{
my ($self, $search) = @_ ;

my $tries = scan_script_directory($self, $self->{ANIMATION}{SLIDE_DIRECTORY}) ;
return $tries->{tries_per_file}->lookup($search) ;
}

sub run_script
{
my ($self, $file) = @_ ;

my $tries = scan_script_directory($self, $self->{ANIMATION}{SLIDE_DIRECTORY}) ;
my %found = $tries->{tries_per_file}->lookup_data($file) ;

if(1 == $found{$file}->@*)
	{
	use App::Asciio::Utils::Scripting ;
	
	App::Asciio::Utils::Scripting::run_external_script($self, "./$found{$file}[0]/$file") ;
	}
else
	{
	print DumpTree \%found, 'Error: multiple directories:' ;
	}
}

#----------------------------------------------------------------------------------------------

sub scan_script_directory
{
my ($self, $directory) = @_ ;
$self->update_display(1) ; # called in ENTER_GROUP and the group has HIDE => 1, update over previous bindings help

$directory //= $self->{ANIMATION}{SLIDE_DIRECTORY} // $self->{ANIMATION}{TOP_DIRECTORY} // $self->{SCRIPTS_PATHS} // '.' ;

return App::Asciio::Utils::Animation::scan_directories([$directory], 1) ;
}

#----------------------------------------------------------------------------------------------

sub run_first
{
my ($self) = @_ ;

my $tries = scan_script_directory($self, $self->{ANIMATION}{SLIDE_DIRECTORY}) ;
my @found = sort grep { $_ !~ /^00/ } grep { $_ =~ /^\d\d/ } $tries->{tries_per_file}->lookup('') ;

$self->{ANIMATION}{NUMBERED_SCRIPTS}       = \@found ;
$self->{ANIMATION}{NUMBERED_SCRIPTS_INDEX} = 0 ;

if(@found)
	{
	App::Asciio::Utils::Scripting::run_external_script($self, "./$self->{ANIMATION}{SLIDE_DIRECTORY}/$found[0]") ;
	}
}

#----------------------------------------------------------------------------------------------

sub run_next
{
my ($self) = @_ ;

unless(defined $self->{ANIMATION}{NUMBERED_SCRIPTS} and $self->{ANIMATION}{NUMBERED_SCRIPTS}->@*)
	{
	run_first($self) ;
	return ;
	}

my $script = $self->{ANIMATION}{NUMBERED_SCRIPTS}[$self->{ANIMATION}{NUMBERED_SCRIPTS_INDEX} + 1] ;

if($script)
	{
	App::Asciio::Utils::Scripting::run_external_script($self, "./$self->{ANIMATION}{SLIDE_DIRECTORY}/$script") ;
	$self->{ANIMATION}{NUMBERED_SCRIPTS_INDEX}++ ;
	}
}

#----------------------------------------------------------------------------------------------

sub run_previous
{
my ($self) = @_ ;

unless(defined $self->{ANIMATION}{NUMBERED_SCRIPTS} and $self->{ANIMATION}{NUMBERED_SCRIPTS}->@*)
	{
	run_first($self) ;
	return ;
	}

if($self->{ANIMATION}{NUMBERED_SCRIPTS_INDEX} > 0)
	{
	my $script = $self->{ANIMATION}{NUMBERED_SCRIPTS}[$self->{ANIMATION}{NUMBERED_SCRIPTS_INDEX} - 1] ;
	
	App::Asciio::Utils::Scripting::run_external_script($self, "./$self->{ANIMATION}{SLIDE_DIRECTORY}/$script") ;
	
	$self->{ANIMATION}{NUMBERED_SCRIPTS_INDEX}-- ;
	}
}

#----------------------------------------------------------------------------------------------

sub rerun
{
my ($self) = @_ ;

unless(defined $self->{ANIMATION}{NUMBERED_SCRIPTS} and $self->{ANIMATION}{NUMBERED_SCRIPTS}->@*)
	{
	run_first($self) ;
	return ;
	}

my $script = $self->{ANIMATION}{NUMBERED_SCRIPTS}[$self->{ANIMATION}{NUMBERED_SCRIPTS_INDEX}] ;

App::Asciio::Utils::Scripting::run_external_script($self, "./$self->{ANIMATION}{SLIDE_DIRECTORY}/$script") ;
}

#----------------------------------------------------------------------------------------------

sub set_slide_directory
{
my ($self, $directory) = @_ ;

unless ($directory)
	{
	$directory = $self->get_user_text('Slide directory') ;
	}

if (defined $directory and $ directory ne '')
	{
	my $slide_directory = "$self->{ANIMATION}{TOP_DIRECTORY}/$directory" ;
	
	$self->{ANIMATION}{SLIDE_DIRECTORY} = $slide_directory ;
	
	unless(-e $slide_directory)
		{
		mkpath $slide_directory
		write_text("$slide_directory/animation_example", "use strict ; use warnings ;\n") ;
		}
	}
}

#----------------------------------------------------------------------------------------------

sub set_on_load_script
{
my ($self, $file_name) = @_ ;
$self->{ANIMATION}{ON_LOAD} = $file_name ;
}

#----------------------------------------------------------------------------------------------

my $message_element ;
my $counter = 0 ;

#----------------------------------------------------------------------------------------------

sub show_previous_message
{
my ($self) = @_ ;

$counter-- ;
show_message($self, $counter) ;
}

sub show_next_message
{
my ($self) = @_ ;

$counter++ ;
show_message($self, $counter) ;
}

#----------------------------------------------------------------------------------------------

sub show_message
{
my ($asciio, $counter) = @_ ;

$asciio->delete_elements($message_element) ;

if(defined $ENV{ASCIIO_MESSAGES} && -d $ENV{ASCIIO_MESSAGES} && -f "$ENV{ASCIIO_MESSAGES}/$counter")
	{
	my @lines = read_text "$ENV{ASCIIO_MESSAGES}/$counter" ;
	
	chomp(my $title = $lines[0]) ;
	my $text = join '', grep { defined $_ } @lines[1 .. @lines] ;
	
	$message_element = $asciio->add_new_element_named('Asciio/box', 0, 0) ;
	$message_element->set_text($title, $text) ;
	}

$asciio->update_display() ;
}

#----------------------------------------------------------------------------------------------

1 ;

