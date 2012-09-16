
#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Load slides'=> ['C00-l', \&load_slides] ,
	'previous slide' => ['C00-Left', \&previous_slide],
	'next slide' => ['C00-Right', \&next_slide],
	'first slide' => ['C00-Up', \&first_slide],
	) ;

#----------------------------------------------------------------------------------------------

my ($slides, $current_slide) ;

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
	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

