package AI::Pathfinding::AStar::AStarNode;
use base 'Heap::Elem';

use strict;

sub new
{
my $proto = shift;
my $class = ref($proto) || $proto;

my ($id,$g,$h) = @_;

my $self = {};
$self->{id}     = $id;
$self->{g}      = $g;
$self->{h}      = $h;
$self->{f}      = $g+$h;
$self->{parent} = undef;
$self->{cost}   = 0;
$self->{inopen} = 0;
$self->{heap} = undef;

bless ($self, $class);
return $self;
}

sub heap
{
my ($self, $val) = @_;
$self->{heap} = $val if (defined $val);
return $self->{heap};
}

sub cmp
{
my $self = shift;
my $other = shift;
return ($self->{f} <=> $other->{f});
}

#-------------------------------------------------------------------------------

package AI::Pathfinding::AStar;

use 5.006;
use strict;
use warnings;
use Carp;

our $VERSION = '0.10';

use Heap::Binomial;

# use AI::Pathfinding::AStar::AStarNode;
my $nodes;

sub _init
{
my $self = shift;
croak "no getSurrounding() method defined" unless $self->can("getSurrounding");

return $self->SUPER::_init(@_);
}

sub doAStar
{
	my ($map, $target, $open, $nodes, $max, $all_paths) = @_;
	
	my $n = 0;
	my $direction = 2 ;
	FLOOP: while ( (defined $open->top()) && ($all_paths ? 1 : ($open->top()->{id} ne $target) )) {
		
		#allow incremental calculation
		last FLOOP if (defined($max) and (++$n == $max));
		
		my $curr_node = $open->extract_top();
		$curr_node->{inopen} = 0;
		my $G = $curr_node->{g};
		
		my ($x, $y) = split(/\./, $curr_node->{id});
		
		#get surrounding squares
		my $surr_nodes = $map->getSurrounding($curr_node->{id}, $target, $direction);
		foreach my $node (reverse @$surr_nodes) {
			my ($surr_id, $surr_cost, $surr_h) = @$node;
			
			#skip the node if it's in the CLOSED list
			next if ( (exists $nodes->{$surr_id}) && (! $nodes->{$surr_id}->{inopen}) );
			
			#add it if we haven't seen it before
			if (! exists $nodes->{$surr_id}) {
				my $surr_node = AI::Pathfinding::AStar::AStarNode->new($surr_id,$G+$surr_cost,$surr_h);
				$surr_node->{parent} = $curr_node;
				$surr_node->{cost}   = $surr_cost;
				$surr_node->{inopen} = 1;
				$nodes->{$surr_id}   = $surr_node;
				$open->add($surr_node);
			}
			else {
				#otherwise it's already in the OPEN list
				#check to see if it's cheaper to go through the current
				#square compared to the previous path
				my $surr_node = $nodes->{$surr_id};
				my $currG     = $surr_node->{g};
				my $possG     = $G + $surr_cost;
				if ($possG < $currG) {
					#change the parent
					$surr_node->{parent} = $curr_node;
					$surr_node->{g}      = $possG;
					$open->decrease_key($surr_node);
				
				my ($sx, $sy) = split(/\./, $surr_node->{id});
				
				if($sy == $y - 1)    { $direction = 0 }
				elsif($sx == $x + 1) { $direction = 1 }
				elsif($sy == $y + 1) { $direction = 2 }
				elsif($sx == $x - 1) { $direction = 3 }
				}
			}
		}
	}
}

sub fillPath
{
my ($map,$open,$nodes,$target) = @_;
my $path = [];

my $curr_node = (exists $nodes->{$target}) ? $nodes->{$target} : $open->top();

my $cost = 0 ;

# use Data::TreeDumper ;
# print DumpTree $curr_node, '', DISPLAY_OBJECT_TYPE => 0, DISPLAY_ADDRESS => 0, FILTER => sub { my ($s) = @_ ; return 'HASH', undef, qw/id parent/ } ;

while (defined $curr_node)
	{
	unshift @$path, $curr_node->{id};
	$cost += $curr_node->{cost};
	$curr_node = $curr_node->{parent};
	}

return($path, $cost) ;
}


sub findPath
{
my ($map, $start, $target) = @_;

my $nodes = {};
my $curr_node = undef;

my $open = Heap::Binomial->new;
#add starting square to the open list
$curr_node = AI::Pathfinding::AStar::AStarNode->new($start,0,0);  # AStarNode(id,g,h)
$curr_node->{parent} = undef;
$curr_node->{cost}   = 0;
$curr_node->{g}      = 0;
$curr_node->{h}      = 0;
$curr_node->{inopen} = 1;
$nodes->{$start}     = $curr_node;
$open->add($curr_node);

$map->doAStar($target,$open,$nodes,undef);

return $map->fillPath($open,$nodes,$target);
}

sub findPathIncr
{
my ($map, $start, $target, $state, $max) = @_;

my $open = undef;
my $curr_node = undef;;
my $nodes = {};

if (defined($state)) {
	$nodes = $state->{'visited'};
	$open  = $state->{'open'};
	}
else {
	$open = Heap::Binomial->new;
	#add starting square to the open list
	$curr_node = AI::Pathfinding::AStar::AStarNode->new($start,0,0);  # AStarNode(id,g,h)
	$curr_node->{parent} = undef;
	$curr_node->{cost}   = 0;
	$curr_node->{g}      = 0;
	$curr_node->{h}      = 0;
	$curr_node->{inopen} = 1;
	$nodes->{$start} = $curr_node;
	$open->add($curr_node);
	}

$map->doAStar($target,$open,$nodes,$max);

my $path_cost = $map->fillPath($open,$nodes,$target);
$state = {
	'path'    => $path_cost->[0],
	'cost'    => $path_cost->[1],
	'open'    => $open,
	'visited' => $nodes,
	'done'    => defined($nodes->{$target}),
	};

return $state;
}

#-------------------------------------------------------------------------------

package AI::Pathfinding::AStar::Obstacle::Map;
our @ISA = qw/AI::Pathfinding::AStar/ ;

use strict ;
use warnings ;

use Time::HiRes qw/usleep/ ;

#-------------------------------------------------------------------------------

sub new
{
my ($invocant, $setup) = @_;
my $class = ref($invocant) || $invocant;
my $self = bless 
		{
		width => 0,
		height => 0,
		keep_clear => 0,
		do_diagonal => 1, # TODO
		orthogonal_cost => 10,
		diagonal_cost => 140,
		extra_cost => 8,
		%$setup,
		map => {},
		}, $class;

return $self;
}

#-------------------------------------------------------------------------------

sub set_map
{
my ($self, $map, $width, $height) = @_;
$self->{map} = $map;
$self->{width} = $width;
$self->{height} = $height;
}

#-------------------------------------------------------------------------------

sub set_obstacle
{
my ($self, $x, $y) = @_;
$self->{map}{$x . '.' . $y}++;
$self->{width} = $x if $x > $self->{width};
$self->{height} = $y if $y > $self->{height};
}

#-------------------------------------------------------------------------------

sub keep_clear 
{
my ($self, $keep_clear) = @_;
$self->{keep_clear} = $keep_clear;
}

#-------------------------------------------------------------------------------

sub display_search 
{
my ($self, $display_search) = @_;
$self->{display_search} = $display_search;
}

#-------------------------------------------------------------------------------

sub get_visited_nodes
{
my ($self, $source, $target) = @_;
$self->{visited_nodes} // 0 ;
}

#-------------------------------------------------------------------------------

sub findPath
{
my ($map, $start, $target) = @_;

my $nodes = {};
my $curr_node = undef;

my $open = Heap::Binomial->new;
#add starting square to the open list
$curr_node = AI::Pathfinding::AStar::AStarNode->new($start,0,0);  # AStarNode(id,g,h)
$curr_node->{parent} = undef;
$curr_node->{cost}   = 0;
$curr_node->{g}      = 0;
$curr_node->{h}      = 0;
$curr_node->{inopen} = 1;
$nodes->{$start}     = $curr_node;
$open->add($curr_node);

$map->doAStar($target,$open,$nodes,undef);

return $map->fillPath($open,$nodes,$target);
}

{
my $nodes;

sub findAllPaths 
{
my ($map, $start, $target, $keep_nodes) = @_;

$nodes = {} unless $keep_nodes ;
$nodes //= {} ;

my $curr_node = undef;

my $open = Heap::Binomial->new;
#add starting square to the open list
$curr_node = AI::Pathfinding::AStar::AStarNode->new($start,0,0);  # AStarNode(id,g,h)
$curr_node->{parent} = undef;
$curr_node->{cost}   = 0;
$curr_node->{g}      = 0;
$curr_node->{h}      = 0;
$curr_node->{inopen} = 1;
$nodes->{$start}     = $curr_node;
$open->add($curr_node);

$map->doAStar($target,$open,$nodes,undef, 1);

return $map->fillPath($open,$nodes,$target);
}

}

#-------------------------------------------------------------------------------

sub getSurrounding
{
my ($self, $source, $target, $direction) = @_;

my ($x, $y) = split(/\./, $source);

return if($x < 1 || $x > $self->{width} || $y < 1 || $y > $self->{height}) ;

my $display_map = ! $self->{no_map_display} ;

my $map = $self->{map};
my $surrounding = [];

my ($orthogonal_cost, $diagonal_cost, $extra_cost) = @{$self}{qw/orthogonal_cost diagonal_cost extra_cost/} ;

my @direction_to_surroundings =
	(
	[$x .'.'. ($y-1),    ($x+1) .'.'. $y,    ($x-1) .'.'. $y,    $x .'.'. ($y+1)],
	[($x+1) .'.'. $y,    $x .'.'. ($y+1),    $x .'.'. ($y-1),    ($x-1) .'.'. $y],
	[$x .'.'. ($y+1),    ($x+1) .'.'. $y,    ($x-1) .'.'. $y,    $x .'.'. ($y-1)],
	[($x-1) .'.'. $y,    $x .'.'. ($y+1),    $x .'.'. ($y-1),    ($x+1) .'.'. $y],
	) ;

$direction //= 2 ;

for my $node (@{$direction_to_surroundings[$direction]})
	{
	my ($node_x, $node_y) = split(/\./, $node);
	next if($node_x < 1 || $node_x > $self->{width} || $node_y < 1 || $node_y >= $self->{height}) ;
	
	if ((! exists $map->{$node}) || $map->{$node} == 0)
		{
		my $permeable_cost = 0 ;
		$permeable_cost = ($self->{permeable_cost} // 40) if (exists $map->{$node} && $map->{$node} == 0) ;
		
		my $extra_cost_sum = 0;
		
		if($self->{keep_clear})
			{
			for my $node_neighbor 
				(
				($node_x-1).'.'.($node_y-1),
				($node_x)  .'.'.($node_y-1),
				($node_x+1).'.'.($node_y-1),
				($node_x-1).'.'.($node_y),
				($node_x+1).'.'.($node_y),
				($node_x-1).'.'.($node_y+1),
				($node_x)  .'.'.($node_y+1),
				($node_x+1).'.'.($node_y+1),
				)
				{
				if(exists $map->{$node_neighbor})
					{
					$extra_cost_sum += $map->{$node_neighbor} ? $extra_cost : $permeable_cost ;
					}
				}
			}
		
		my $heat = "\e[7;100;31m" ;
		for ($orthogonal_cost + $permeable_cost + $extra_cost_sum)
			{
			$_ < 26 and $heat = "\e[7;101;91m" ; # red
			$_ < 20 and $heat = "\e[7;040;33m" ; # orange
			$_ < 16 and $heat = "\e[7;100;33m" ; # dim orange
			$_ < 12 and $heat = "\e[7;100;93m" ; # dim yellow
			$_ < 8 and $heat  = "\e[7;100;94m" ; # blue
			$_ < 4 and $heat  = "\e[7;100;95m" ; # cyan
			$_ < 2 and $heat  = "\e[7;040;90m" ; # grey
			}
		
		print "\e[" . ($node_y + 1) . ";" . ($node_x + 2) . "H$heat.\e[m" if $self->{display_search} and $display_map ;
		
		$self->{visited_nodes}++ ;
		
		push @$surrounding, [$node, $orthogonal_cost + $permeable_cost + $extra_cost_sum, $self->calc_heuristic($source, $node, $target, $direction)] ;
		}
	}

if($self->{do_diagonal})
	{
	# for my $node ( ($x+1).'.'.($y+1), ($x+1).'.'.($y-1), ($x-1).'.'.($y+1), ($x-1).'.'.($y-1))
	# 		{
	# 		push @$surrounding, [$node, $diagonal_cost, calc_heuristic($node, $target)]
	# 			if exists $map->{$node} && $map->{$node} ;
	# 		}
	}

usleep ($self->{search_sleep} // 1000) if $self->{display_search} ;

return $surrounding;
}

#-------------------------------------------------------------------------------
use List::Util qw/max/;

sub calc_heuristic
{
my ($self, $source, $node, $target, $direction) = @_;

my ($xs, $ys) = split(/\./, $source);
my ($x1, $y1) = split(/\./, $node);
my ($xt, $yt) = split(/\./, $target);

my ($XHK, $XNHK, $YHK, $YNHK) = @{$self}{qw/XHK XNHK YHK YNHK/} ;
my $heuristic =   ($x1 < $xt ? ($xt - $x1) * $XHK : ($x1 - $xt) * $XNHK)
		+ ($y1 < $yt ? ($yt - $y1) * $YHK : ($y1 - $yt) * $YNHK) ;

# my $heuristic =  abs($x1 - $xs) + abs($y1 - $ys) + abs($x1 - $xt) + abs($y1 - $yt) ;

$heuristic > 0 ? $heuristic : 0 ;
}

#-------------------------------------------------------------------------------

package AI::Pathfinding::AStar::Term::Map ;
use strict ;
use warnings ;
use Time::HiRes ;

#-------------------------------------------------------------------------------

sub get_map_from_file_handle
{
my ($data, $options) = @_;

my $display_map = ! $options->{no_map_display} ;

my ($map, $map_text) = ({}, '') ;

my $max_width = 0 ;
my $y = 1;
while (<$data>)
	{
	chomp;
	
	my @cols = split //;
	$max_width = @cols if $max_width < @cols ;
	
	for my $x ( 0 .. $#cols )
		{
		my $cell = $cols[$x];
		my $x_1 = $x + 1;
		
		$map->{$x_1.'.'.$y}++ if $cell ne ' ' ;
		}
	
	$map_text .= sprintf "\e[2;30;31m%-2d\e[m$_\n", $y if $display_map ;
	$y++;
	}

print "\e[2J\e[H" . "\e[2;30;31m  " . ('1234567890' x (1 + ($max_width / 10))) . "\e[m\n" . $map_text
	if $display_map ;

return ($map, $max_width, $y) ;
}

#-------------------------------------------------------------------------------

sub display_routes
{
my ($g, $options, @routes) = @_ ;

my $display_map = ! $options->{no_map_display} ;

my @colors = (31 .. 36) x 5 ;

my $routing_time = 0 ;
my (@routes_text, @path_info) ;

while (@routes > 1)
	{
	my ($start, $end) = ($routes[0], $routes[1]) ;
	shift @routes ;
	
	my ($SX, $SY) = split(/\./, $start);
	my ($EX, $EY) = split(/\./, $end);
	
	my $color = shift @colors ;
	
	my $t0 = Time::HiRes::gettimeofday();
	my ($path, $cost) = $options->{map_all} ? $g->findAllPaths($start, $end) : $g->findPath($start, $end) ;
	my $t1 = Time::HiRes::gettimeofday();
	$routing_time += $t1 -$t0 ;
	
	$a=<STDIN> if $options->{pause} && @routes > 1 ;
	
	push @path_info, scalar(@$path)  . '/' . $cost ;
	
	my $route_text = '';
	for my $position (@{$path})
		{
		my ($x, $y) = split(/\./, $position);
		
		$g->set_obstacle($x, $y) if $options->{obstruct} ;
		
		$y += 1 ; # account for horizontal ruler
		$x += 2 ; # account for vertical ruler
		
		$route_text .= "\e[$y;${x}H\e[${color}m¤\e[m" if $display_map;
		}
	
	my ($SY1, $SX2) = ($SY +1, $SX + 2) ;
	my ($EY1, $EX2) = ($EY +1, $EX + 2) ;
	
	$route_text .= "\e[$SY1;${SX2}H\e[${color}mS\e[m" if $display_map;
	$route_text .= "\e[$EY1;${EX2}H\e[${color}mE\e[m" if $display_map;
	
	push @routes_text, $route_text ;
	}

for (@routes_text)
	{
	$a=<STDIN> if $options->{pause} ;
	print ;
	}

my $status_line = $g->{height} + 2 ;
print "\e[$status_line;0H\e[m" if $display_map;
printf "path lengths: @path_info, visited_nodes: %d\n", $g->get_visited_nodes() if $display_map;
printf "routing time: %.3f\n", $routing_time if $display_map;
}

#-------------------------------------------------------------------------------

package AI::Pathfinding::AStar::Term::Map::Main ;

use strict ;
use warnings ;

use IO::File ;
use Getopt::Long;

my $options = {} ;
GetOptions
	(
	'map=s'             => \$options->{map},
	'map_all'           => \$options->{map_all},
	'keep_clear'        => \$options->{keep_clear},
	'no_map_display'    => \$options->{no_map_display},
	'obstruct'          => \$options->{obstruct},
	'pause'             => \$options->{pause},
	'display_search'    => \$options->{display_search},
	'search_sleep:i'    => \$options->{search_sleep},
	'orthogonal_cost:i' => \$options->{orthogonal_cost},
	'diagonal_cost:i'   => \$options->{diagonal_cost},
	'extra_cost:i'      => \$options->{extra_cost},
	'permeable_cost:i'  => \$options->{permeable_cost},
	'XHK:i'             => \$options->{XHK},
	'XNHK:i'            => \$options->{XNHK},
	'YHK:i'             => \$options->{YHK},
	'YNHK:i'            => \$options->{YNHK},
	) or die("Error in command line arguments\n");

my $g = AI::Pathfinding::AStar::Obstacle::Map->new
		({
		keep_clear      => $options->{keep_clear},
		display_search  => $options->{display_search},
		no_map_display  => $options->{no_map_display},
		search_sleep    => $options->{search_sleep} // 1000,
		orthogonal_cost => $options->{orthogonal_cost} // 10,
		diagonal_cost   => $options->{diagonal_cost} // 140,
		permeable_cost  => $options->{permeable_cost} // 40,
		extra_cost      => $options->{extra_cost} // 8,
		XHK             => $options->{XHK}  // 1,
		XNHK            => $options->{XNHK} // 1,
		YHK             => $options->{YHK}  // 1,
		YNHK            => $options->{YNHK} // 1,
		}) ;

my $map_file  = $options->{map} ? (IO::File->new($options->{map}, 'r') or die "$options->{map}: $!\n") : \*DATA ;

$g->set_map(AI::Pathfinding::AStar::Term::Map::get_map_from_file_handle($map_file, $options)) ;
AI::Pathfinding::AStar::Term::Map::display_routes($g, $options, @ARGV) ;

__DATA__
                                                            
   #          #              #          #                #  
   #    #     #              #    #     #                #  
   #  #    ########          #  #    ########       ########
      #    #     # ####         #    #     #   # ####    #  
      #    #         #          #    #             #        
      #    #                    #    #                      
      #    #########   #        #    #############     #### 
               #       #                 #   #         #    
        #              #          #                         
                       #                                    
   #          #        #     #          #                   
   #    #     #              #    #     #                   
   #  #    ########          #  #    ############      #### 
      #    #     # ####         #    #     #   # ####    #  
      #    #         #          #    #             #        
      #    #                    #    #                      
                       #                                    
   #          #        #     #          #                   
      #    #########            #    #############     #### 
               #                         #   #         #    
        #               #         #                         
      #    #                    #    #                      
      #    #########            #    #############     #### 
               #                         #   #         #    
        #               #         #                         
