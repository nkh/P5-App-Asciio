
package App::Asciio::Actions::Presentation ;

use strict ; use warnings ;

use Data::UUID;
use File::Path qw(make_path);

#----------------------------------------------------------------------------------------------

use App::Asciio::Actions::Tabs ;
use App::Asciio::GTK::Asciio ;
use App::Asciio::Utils::Scripting ;

#----------------------------------------------------------------------------------------------

sub tag_all
{
my ($self, $tag_data) = @_ ;

my $asciios = App::Asciio::Actions::Tabs::get_asciios($self) ;

for (@$asciios)
	{
	if(defined $tag_data)
		{
		$_->{TAGS}{SLIDE} = $tag_data ;
		
		my $ug = Data::UUID->new ;
		$_->{TAGS}{SLIDE}{UUID} = $ug->create() ;
		}
	else
		{
		delete $_->{TAGS}{SLIDE} ;
		}
	
	$_->signal_emit('rename_asciio_tab', $_, $_->get_title()) ;
	}

$self->run_actions(['000-Escape']) ;
}

#----------------------------------------------------------------------------------------------

sub tag
{
my ($self, $tag_data) = @_ ;

if(defined $tag_data)
	{
	$self->{TAGS}{SLIDE} = $tag_data ;
	
	my $ug = Data::UUID->new ;
	$self->{TAGS}{SLIDE}{UUID} = $ug->create() ;
	}
else
	{
	delete $self->{TAGS}{SLIDE} ;
	}

$self->signal_emit('rename_tab', $self->get_title()) ;
$self->run_actions(['000-Escape']) ;
}

#----------------------------------------------------------------------------------------------

sub set_slide_time
{
my ($self, $time) = @_ ;

if(defined $self->{TAGS}{SLIDE})
	{
	$time   = $self->get_user_text('Slide time')  unless defined $time ;
	$time //= 1 ;
	
	$self->{TAGS}{SLIDE}{TIME} = $time 
	}
}

#----------------------------------------------------------------------------------------------

my ($slideshow_delay, $slideshow_timer, $current_slide_time) = (500, undef) ;
my ($last_slide, $take_screenshots) ;

#----------------------------------------------------------------------------------------------

sub set_default_slide_time
{
my ($self, $time) = @_ ;

$time   = $self->get_user_text('Default_slide time') unless defined $time ;
$time //= 500 ;
$time   = 500 if $time < 0 or $time > 10_000 ;

$slideshow_delay = $time ;
}

#----------------------------------------------------------------------------------------------

sub escape_slideshow
{
my ($self) = @_ ;

Glib::Source->remove($slideshow_timer) if defined $slideshow_timer ;
$slideshow_timer = undef ;

($last_slide, $take_screenshots) = (undef, undef) ;

App::Asciio::Actions::Tabs::show_all_bindings_help($self) ; #todo: if it was set before
App::Asciio::Actions::Tabs::redirect_events($self, 0) ;
}

#----------------------------------------------------------------------------------------------

sub start_automatic_slideshow
{
my ($self, $time) = @_ ;

unless(defined $self->{TAGS}{SLIDE} && scalar(keys $self->{TAGS}{SLIDE}->%*))
	{
	$self->run_actions(['000-Escape']) ;
	return  ;
	} ;

$slideshow_delay = $time if defined $time ;

$time = $self->{TAGS}{SLIDE}{TIME} ;
$time //= $slideshow_delay ;

$current_slide_time = $time ;
$slideshow_timer = Glib::Timeout->add ($time, sub { $self->run_actions('next_slideshow_slide') ; return 0 ; }) ;

App::Asciio::Actions::Tabs::hide_all_bindings_help($self) ;
App::Asciio::Actions::Tabs::redirect_events($self, 1) ;
}

#----------------------------------------------------------------------------------------------

sub start_automatic_slideshow_once
{
my ($self, $time_screenshots) = @_ ;

unless(defined $self->{TAGS}{SLIDE} && scalar(keys $self->{TAGS}{SLIDE}->%*))
	{
	$self->run_actions(['000-Escape']) ;
	return  ;
	} ;

if($self->{ANIMATION}{SLIDE_DIRECTORY} ne $self->{ANIMATION}{TOP_DIRECTORY})
	{
	if (-e "$self->{ANIMATION}{SLIDE_DIRECTORY}/00_on_load")
		{
		App::Asciio::Utils::Scripting::run_external_script($self, "./$self->{ANIMATION}{SLIDE_DIRECTORY}/00_on_load") ;
		}
	}

my ($time, $screenshots) = $time_screenshots->@* ;

$slideshow_delay = $time if defined $time ;

$time = $self->{TAGS}{SLIDE}{TIME} ;
$time //= $slideshow_delay ;

$current_slide_time = $time ;
$slideshow_timer    = Glib::Timeout->add ($time, sub { $self->run_actions('next_slideshow_slide') ; return 0 ; }) ;
$last_slide         = $self ;
$take_screenshots   = $screenshots ;

if($take_screenshots)
	{
	mkpath('snapshots') unless -e 'snapshots' ;
	
	my $file_name = "snapshots/". sprintf("%03d", $take_screenshots) . "_time_${current_slide_time}_screenshot.png" ;
	
	$self->save_with_type($self->{ELEMENTS}, 'png', $file_name) ;
	$take_screenshots++ ;
	}

App::Asciio::Actions::Tabs::hide_all_bindings_help($self) ;
App::Asciio::Actions::Tabs::redirect_events($self, 1) ;
}

#----------------------------------------------------------------------------------------------

sub next_slideshow_slide
{
my ($self, $time) = @_ ;

my $asciio = App::Asciio::Actions::Tabs::next_tagged_tab($self, 'SLIDE') ;

if($asciio == $last_slide)
	{
	$self->run_actions(['000-Escape']) ;
	return  ;
	}

$time //= $asciio->{TAGS}{SLIDE}{TIME} ;
$time //= $slideshow_delay ;

$current_slide_time = $time ;
$slideshow_timer    = Glib::Timeout->add ( $time, sub { $self->run_actions('next_slideshow_slide') ; return 0 ; } ) ;

if($take_screenshots)
	{
	my $file_name = "snapshots/". sprintf("%03d", $take_screenshots) . "_time_${current_slide_time}_screenshot.png" ;
	
	$asciio->save_with_type($self->{ELEMENTS}, 'png', $file_name) ;
	$take_screenshots++ ;
	}
}

#----------------------------------------------------------------------------------------------

sub start_manual_slideshow
{
my ($self, $time) = @_ ;
$time //= 500 ;

# App::Asciio::Actions::Tabs::hide_all_bindings_help($self) ;
App::Asciio::Actions::Tabs::redirect_events($self, 1) ;
}

#----------------------------------------------------------------------------------------------

sub next_slide
{
my ($self) = @_ ;
App::Asciio::Actions::Tabs::next_tagged_tab($self, 'SLIDE') ;
}

#----------------------------------------------------------------------------------------------

sub previous_slide
{
my ($self) = @_ ;
App::Asciio::Actions::Tabs::previous_tagged_tab($self, 'SLIDE') ;
}

#----------------------------------------------------------------------------------------------

sub first_slide
{
my ($self) = @_ ;
# App::Asciio::Actions::Tabs::first_tagged_tab($self, 'SLIDE') ;
}

#----------------------------------------------------------------------------------------------

sub slower_speed
{
my ($self) = @_ ;
$slideshow_delay *= 1.5 unless $slideshow_delay > 10_000 ;
print "delay: $slideshow_delay\n" ;
}

#----------------------------------------------------------------------------------------------

sub faster_speed
{
my ($self) = @_ ;
$slideshow_delay /= 1.5 unless $slideshow_delay < 2 ;
print "delay: $slideshow_delay\n" ;
}

#----------------------------------------------------------------------------------------------

sub pause 
{
my ($self) = @_ ;

if(defined $slideshow_timer)
	{
	Glib::Source->remove($slideshow_timer) ;
	undef $slideshow_timer ;
	}
else
	{
	$slideshow_timer = Glib::Timeout->add ($slideshow_delay, sub { $self->run_actions('next_slideshow_slide') ; return 0 ; }) ;
	}
}

#----------------------------------------------------------------------------------------------

1 ;

