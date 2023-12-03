
package App::Asciio::Actions::Presentation ;

use strict ; use warnings ;
use File::Slurp ;

#----------------------------------------------------------------------------------------------

{
my @stack ;

sub load_slides
{
my ($self, $file_name) = @_ ;

# get file name for slides definitions
$file_name = $self->get_file_name('open') unless defined $file_name ;

if(defined $file_name && $file_name ne q{})
	{
	my $slides = do $file_name or die $@ ;
	
	return unless  defined $slides and 'ARRAY' eq ref $slides ;
	
	@stack = [0, $slides] ;
	run_slide($self, $slides) ;
	}
}

#----------------------------------------------------------------------------------------------

sub run_slide
{
my ($self, $slide) = @_ ;

# use Data::TreeDumper ;
# print DumpTree \@stack, 'stack:' ;

if(defined $slide)
	{
	for my $element ($slide->@*)
		{
		# print "running element: $element '" . ref($element) . "' $slide\n" ;
		
		if('' eq ref($element))
			{
			clear_all()->($self),
			box(0, 0, '', $element, 1)->($self),
			$self->update_display() ;
			}
		
		if('CODE' eq ref($element))
			{
			$element->($self) ;
			$self->update_display() ;
			}
		
		if('ARRAY' eq ref($element))
			{
			# print "PUSH $element\n" ;
			
			push @stack, [0, $element] ;
			run_slide($self, $element) ;
			
			last ;
			}
		
		if('HASH' eq ref($element))
			{
			$stack[-1][2] = $element ;
			print "Asciio: slide has scripts\n" ;
			}
		
		$stack[-1][0]++ ;
		}
	}
}

#----------------------------------------------------------------------------------------------

sub next_slide
{
my ($self) = @_ ;

if(@stack)
	{
	my ($index, $slide) = $stack[-1]->@* ;
	
	# print "$index < " . $slide->@* . "\n" ;
	
	if($index < $slide->@*)
		{
		# print "NEXT\n" ;
		$stack[-1][0]++ ;
		
		my $next_slide = $slide->[$index + 1] ;
		
		if('ARRAY' eq ref($next_slide))
			{
			# print "PUSH $next_slide\n" ;
			push @stack, [0, $next_slide] ;
			}
		
		run_slide($self, $next_slide) ;
		}
	else
		{
		if(@stack > 1)
			{
			# print "POP\n" ;
			pop @stack ;
			
			next_slide($self) ;
			}
		}
	}
}

#----------------------------------------------------------------------------------------------

sub previous_slide
{
my ($self) = @_ ;

use Data::TreeDumper ;
print DumpTree \@stack, 'stack:' ;

if(@stack)
	{
	@stack = [ $stack[0]->@* ] ;

	
	my $slides = $stack[0][1] ;
	my $index  = $stack[0][0] >= $stack[0][1]->@* ? $stack[0][0] - 2 : $stack[0][0] - 1 ; 
	
print "new index: $index\n" ;

	if($index >= 0)
		{
		$stack[0][0] = $index ; 
		
		push @stack, [0, $slides->[$index]] ;
		run_slide($self, $slides->[$index]) 
		}
	}
}

#----------------------------------------------------------------------------------------------

sub first_slide
{
my ($self) = @_ ;

if(@stack)
	{
	@stack = [0, $stack[0][1]] ;
	run_slide($self, $stack[0][1]) ;
	}
}

#----------------------------------------------------------------------------------------------

sub run_script
{
my ($self, $script_args) = @_ ;

if(defined $stack[-1][2])
	{
	my $scripts = $stack[-1][2] ;
	
	if(exists $scripts->{$script_args->[0]})
		{
		$scripts->{$script_args->[0]}($self, $script_args) ;
		$self->use_action_group('<< slides leader >>') ;
		}
	}
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

