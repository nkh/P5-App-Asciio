
package App::Asciio::Actions::Presentation ;

use strict ; use warnings ;
# use File::Slurper qw(read_text) ;

use App::Asciio::Actions::Tabs ;

#----------------------------------------------------------------------------------------------

my $slideshow_delay = 500 ;
my $slideshow_timer ;

sub start_automatic_slideshow
{
my ($self, $time) = @_ ;

$slideshow_delay = $time if defined $time ;
$time //= $slideshow_delay ;

$slideshow_timer = Glib::Timeout->add ($time, sub { $self->run_actions('next_slideshow_slide') ; return 0 ; }) ;

App::Asciio::Actions::Tabs::hide_all_bindings_help($self) ;
App::Asciio::Actions::Tabs::redirect_events($self, 1) ;
}

#----------------------------------------------------------------------------------------------

sub escape_slideshow
{
my ($self) = @_ ;

Glib::Source->remove($slideshow_timer) if defined $slideshow_timer ;

App::Asciio::Actions::Tabs::show_all_bindings_help($self) ; #todo: if it was set before
App::Asciio::Actions::Tabs::redirect_events($self, 0) ;
}

#----------------------------------------------------------------------------------------------

sub next_slideshow_slide
{
my ($self, $time) = @_ ;
$time //= $slideshow_delay ;

App::Asciio::Actions::Tabs::next_tab($self) ;
$slideshow_timer = Glib::Timeout->add ( $time, sub { $self->run_actions('next_slideshow_slide') ; return 0 ; } ) 
}

#----------------------------------------------------------------------------------------------

sub start_manual_slideshow
{
my ($self, $time) = @_ ;
$time //= 500 ;

App::Asciio::Actions::Tabs::hide_all_bindings_help($self) ;
App::Asciio::Actions::Tabs::redirect_events($self, 1) ;
}

#----------------------------------------------------------------------------------------------

sub next_slide
{
my ($self) = @_ ;
App::Asciio::Actions::Tabs::next_tab($self) ;
}

#----------------------------------------------------------------------------------------------

sub previous_slide
{
my ($self) = @_ ;

App::Asciio::Actions::Tabs::previous_tab($self) ;
}

#----------------------------------------------------------------------------------------------

sub first_slide
{
my ($self) = @_ ;
App::Asciio::Actions::Tabs::focus_tab() ;
}

#----------------------------------------------------------------------------------------------

sub slower_speed
{
my ($self) = @_ ;
$slideshow_delay *= 1.5 ;
}

#----------------------------------------------------------------------------------------------

sub faster_speed
{
my ($self) = @_ ;
$slideshow_delay /= 1.5 ;
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

