
use strict;
use warnings;
use lib qw(lib lib/stripes) ;

use App::Asciio;
use App::Asciio::stripes::editable_box2 ;

use File::Basename ;
use Module::Util qw(find_installed) ;

#-----------------------------------------------------------------------------

my $asciio = new App::Asciio() ;

my ($basename, $path, $ext) = File::Basename::fileparse(find_installed('App::Asciio'), ('\..*')) ;
my $setup_path = $path . $basename . '/../../../setup/' ;

my $setup_paths = [$setup_path .  'setup.ini'] ;

$asciio->setup($setup_paths) ;

#-----------------------------------------------------------------------------

my ($current_x, $current_y) = (0, 0) ;

for my $element_text (qw(box_1 box_2 box_3))
	{
	my $new_element = new App::Asciio::stripes::editable_box2
						({
						TEXT_ONLY => $element_text,
						TITLE => '',
						EDITABLE => 1,
						RESIZABLE => 1,
						}) ;
						
	$asciio->add_element_at($new_element, $current_x, $current_y) ;
	
	$current_x += $asciio->{COPY_OFFSET_X} ; 
	$current_y += $asciio->{COPY_OFFSET_Y} ;
	}
	
#~ use Data::TreeDumper ;
#~ print DumpTree $asciio->get_cost_map(), 'cost map' ;

package AI::Pathfinding::AStar::Test ;
use base 'AI::Pathfinding::AStar' ;

sub new
{
    my $invocant = shift;
    my $class = ref($invocant) || $invocant;
    my $self = bless {}, $class;

    $self->{map} = shift or die "missing cost_map\n";

    return $self;
}

#get orthoganal neighbours
sub getOrth
{
	my ($source) = @_;

	my @return = ();
	my ($x, $y) = split(/\./, $source);

	push @return, ($x+1).'.'.$y, ($x-1).'.'.$y, $x.'.'.($y+1), $x.'.'.($y-1);
	return @return;
}

#get diagonal neightbours
sub getDiag
{
	my ($source) = @_;

	my @return = ();
	my ($x, $y) = split(/\./, $source);

	push @return, ($x+1).'.'.($y+1), ($x+1).'.'.($y-1), ($x-1).'.'.($y+1), ($x-1).'.'.($y-1);
	return @return;
}

#calculate the Heuristic
sub calcH
{
	my ($source, $target) = @_;

	my ($x1, $y1) = split(/\./, $source);
	my ($x2, $y2) = split(/\./, $target);

	return (abs($x1-$x2) + abs($y1-$y2));
}

#the routine required by AI::Pathfinding::AStar
sub getSurrounding
{
	my ($self, $source, $target) = @_;

	my %map = %{$self->{map}};
	my ($src_x, $src_y) = split(/\./, $source);

	my $surrounding = [];

	#orthogonal moves cost 10, diagonal cost 140
	foreach my $node (getOrth($source))
	{
		if ( (exists $map{$node}) && ($map{$node}) )
			{push @$surrounding, [$node, 10, calcH($node, $target)];}
	}
	foreach my $node (getDiag($source))
	{
		if ( (exists $map{$node}) && ($map{$node}) )
			{push @$surrounding, [$node, 140, calcH($node, $target)];}
	}

	return $surrounding;
}

#------------------------------------------------------------------------

package main ;

my $cost_map = $asciio->get_grid_usage() ;

my $asciio_2 = new App::Asciio() ;
$asciio_2->setup($setup_paths) ;

while( my($key, $value) = each %{$cost_map})
	{
	next if $value == 1 ;
	
	my ($x, $y) = split(/\./, $key) ;
	$asciio_2->add_new_element_named('stencils/asciio/text', $x, $y);
	}

print $asciio_2->transform_elements_to_ascii_buffer() ;
print "\n\n" ;

use List::Util qw(min max) ;

my ($path_start_x, $path_start_y, $path_end_x, $path_end_y) = ((1, 4), (15, 5)) ;
for my $x (0 .. max($path_start_x, $path_end_x) + 2)
	{
	for my $y(0 .. max($path_start_y, $path_end_y) + 2)
		{
		$cost_map->{"$x.$y"} = 1 unless exists $cost_map->{"$x.$y"} ;
		}
	}

my $g = AI::Pathfinding::AStar::Test->new($cost_map) ;
my $routing_path = $g->findPath("$path_start_x.$path_start_y", "$path_end_x.$path_end_y") ;

#~ use Data::TreeDumper ;
#~ print DumpTree $routing_path, 'path' ;

for my $path_element (@{$routing_path})
	{
	my ($x, $y) = split(/\./, $path_element) ;
	my $element = $asciio->add_new_element_named('stencils/asciio/text', $x, $y);
	}
	
print $asciio->transform_elements_to_ascii_buffer() ;




