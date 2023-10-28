
package App::Asciio::Actions::Presentation ;

use strict ; use warnings ;
use File::Slurp ;

#----------------------------------------------------------------------------------------------

my ($slides, $current_slide) ;

sub get_slides { return $slides ; }
sub get_current_slide { return $current_slide ; }

#----------------------------------------------------------------------------------------------

sub load_slides
{
my ($self, $file_name) = @_ ;

# get file name for slides definitions
$file_name = $self->get_file_name('open') unless defined $file_name ;

if(defined $file_name && $file_name ne q{})
	{
	# load slides
	$slides = do $file_name or die $@ ;
	$current_slide = 0 ;
	
	# run first slide
	$slides->[$current_slide]->($self) ;
	$self->deselect_all_elements() ;
	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

sub first_slide
{
my ($self) = @_ ;

if($slides)
	{
	$current_slide = 0 ;
	$slides->[$current_slide]->($self) ;
	$self->deselect_all_elements() ;
	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

sub next_slide
{
my ($self) = @_ ;

if($slides && $current_slide != $#$slides)
	{
	$current_slide++ ;
	$slides->[$current_slide]->($self) ;
	$self->deselect_all_elements() ;
	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

sub previous_slide
{
my ($self) = @_ ;

if($slides && $current_slide != 0)
	{
	$current_slide-- ;
	$slides->[$current_slide]->($self) ;
	$self->deselect_all_elements() ;
	$self->update_display() ;
	}
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
	my @lines = read_file "$ENV{ASCIIO_MESSAGES}/$counter" ;
	
	chomp(my $title = $lines[0]) ;
	my $text = join '', grep { defined $_ } @lines[1 .. @lines] ;
	
	$message_element = $asciio->add_new_element_named('Asciio/box', 0, 0) ;
	$message_element->set_text($title, $text) ;
	}

$asciio->update_display() ;
}

#----------------------------------------------------------------------------------------------

1 ;

