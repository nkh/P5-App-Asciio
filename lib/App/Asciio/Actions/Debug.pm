
package App::Asciio::Actions::Debug ;

use strict ; use warnings ;

#----------------------------------------------------------------------------------------------

use List::Util qw(min max sum) ;
use Tree::Trie ;

#----------------------------------------------------------------------------------------------

sub dump_self
{
my ($self) = @_ ;

my $size = sum(map { length } @{$self->{DO_STACK}}) || 0 ;

local $self->{DO_STACK} = scalar(@{$self->{DO_STACK}})  . " [$size]";

#~ print STDERR Data::TreeDumper::DumpTree $self ;
$self->show_dump_window($self, 'asciio') ;
}

#----------------------------------------------------------------------------------------------

sub dump_selected_elements
{
my ($self) = @_ ;

#~ print STDERR Data::TreeDumper::DumpTree [$self->get_selected_elements(1)] ;
$self->show_dump_window([$self->get_selected_elements(1)], 'asciio selected elements') ;
}

#----------------------------------------------------------------------------------------------

sub dump_all_elements
{
my ($self) = @_ ;

#~ print STDERR Data::TreeDumper::DumpTree $self->{ELEMENTS} ;
$self->show_dump_window($self->{ELEMENTS}, 'asciio elements') ;
}

#----------------------------------------------------------------------------------------------

use App::Asciio::Utils::Animation ;
use Data::TreeDumper ;

sub dump_animation_data
{
my ($self) = @_ ;

$self->{ANIMATION}{TOP_DIRECTORY}   //= $self->{SCRIPTS_PATH} // '.' ;
$self->{ANIMATION}{SLIDE_DIRECTORY} //= $self->{ANIMATION}{TOP_DIRECTORY} ;

my $scriptignore = -e "$self->{ANIMATION}{TOP_DIRECTORY}/.scriptignorex" // 0 ;

print STDERR <<EOP ;
scripts paths: $self->{SCRIPTS_PATHS}             
animation directory: $self->{ANIMATION}{TOP_DIRECTORY}
slide directory: $self->{ANIMATION}{SLIDE_DIRECTORY} 
.scriptignore : $scriptignore

scripts:
EOP

my $r = App::Asciio::Utils::Animation::scan_directories([$self->{ANIMATION}{SLIDE_DIRECTORY}], 1) ;

print DumpTree $r, 'r:' ;
}

#----------------------------------------------------------------------------------------------

sub test
{
my ($self) = @_ ;

$self->create_undo_snapshot() ;
$self->run_actions_by_name(['Insert', 0, 0, 'insert_error.asciio']) ;
$self->update_display() ;
}

sub test
{
my ($self) = @_ ;

$self->create_undo_snapshot() ;

my $bins     = $self->get_id_filtered_elements('la', 'pointer') ;
my $element  = $bins->[0][0] ;
my $element2 = $bins->[1][0] ;

use Time::HiRes qw(sleep) ;
use App::Asciio::Utils::Animation ;

if($element)
	{
	my @points = App::Asciio::Utils::Animation::get_line_points($element->{X}, $element->{Y}, 0, 0) ;
	
	for my $coordinate (@points)
		{
		@{$element}{qw/X Y/} = ($coordinate->@*) ;
		
		sleep 0.007 ;
		$self->update_display(1) ;
		}
	}

my @circle_points = App::Asciio::Utils::Animation::get_circle_points($element2->{X} - 5, $element2->{Y} - 5, $element2->{X}, $element2->{Y}) ;

for my $coordinate (@circle_points)
	{
	@{$element2}{qw/X Y/} = ($coordinate->@*) ;
	
	sleep 0.10 ;
	$self->update_display(1) ;
	}

# use Data::TreeDumper ;
# print DumpTree \@circle_points ;
# print DumpTree $bins, 'bins:', MAX_DEPTH => 2 ;
}

#----------------------------------------------------------------------------------------------

1 ;

