
package App::Asciio::Actions::Presentation ;

#----------------------------------------------------------------------------------------------

my ($slides, $current_slide) ;

#----------------------------------------------------------------------------------------------

sub get_slides { return $slides ; }

#----------------------------------------------------------------------------------------------

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

1 ;

