package AI::Pathfinding::AStar::Obstacle::Map;
use base AI::Pathfinding::AStar;

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

sub getSurrounding
{
my ($self, $source, $target) = @_;

my ($x, $y) = split(/\./, $source);

return if($x < 1 || $x > $self->{width} || $y < 1 || $y > $self->{height}) ;

my $map = $self->{map};
my $surrounding = [];

my ($orthogonal_cost, $diagonal_cost, $extra_cost) = @{$self}{qw/orthogonal_cost diagonal_cost extra_cost/} ;

for my $node (($x+1).'.'.$y, $x.'.'.($y+1), ($x-1).'.'.$y, $x.'.'.($y-1))
	{
	my ($node_x, $node_y) = split(/\./, $node);
	next if($node_x < 1 || $node_x > $self->{width} || $node_y < 1 || $node_y >= $self->{height}) ;
	
	unless (exists $map->{$node})
		{
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
				$extra_cost_sum += $extra_cost if exists $map->{$node_neighbor} ;
				}
			}
		
		if($self->{display_search})
			{
			my ($NY1, $NX2) = ($node_y +1, $node_x + 2) ;
			print "\e[$NY1;${NX2}H\e[2;30;32m?\e[m";
			}
		
		push @$surrounding, [$node, $orthogonal_cost + $extra_cost_sum, calc_heuristic($node, $target)] ;
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

usleep 1000 if $self->{display_search} ;

return $surrounding;
}

#-------------------------------------------------------------------------------

my ($XHK, $XNHK, $YHK, $YNHK) = (1, 1, 1, 1);

sub calc_heuristic
{
my ($source, $target) = @_;

my ($x1, $y1) = split(/\./, $source);
my ($xt, $yt) = split(/\./, $target);

my $heuristic =   $x1 < $xt ? ($xt - $x1) * $XHK : ($x1 - $xt) * $XNHK
		+ $y1 < $yt ? ($yt - $y1) * $YHK : ($y1 - $yt) * $YNHK ;

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

while (@routes > 1)
	{
	my ($start, $end) = ($routes[0], $routes[1]) ;
	shift @routes ;
	
	my ($SX, $SY) = split(/\./, $start);
	my ($EX, $EY) = split(/\./, $end);
	
	($XHK, $XNHK, $YHK, $YNHK) = (1, 1, 1, 1);
	
	if ($SX < $EX) { $XHK = $options->{XHK} // 1 } else { $XNHK = $options->{XNHK} // 1 }
	if ($SY < $EY) { $YHK = $options->{YNHK} // 1 } else { $YNHK = $options->{YNHK} // 1 }
	
	my $color = shift @colors ;
	
	my $t0 = Time::HiRes::gettimeofday();
	my $path = $g->findPath($start, $end) ;
	my $t1 = Time::HiRes::gettimeofday();
	$routing_time += $t1 -$t0 ;
	
	for my $position (@{$path})
		{
		my ($x, $y) = split(/\./, $position);
		
		$g->set_obstacle($x, $y) if $options->{obstruct} ;
		
		$y += 1 ; # account for horizontal ruler
		$x += 2 ; # account for vertical ruler
		
		print "\e[$y;${x}H\e[${color}mx\e[m" if $display_map;
		}
	
	my ($SY1, $SX2) = ($SY +1, $SX + 2) ;
	my ($EY1, $EX2) = ($EY +1, $EX + 2) ;
	
	print "\e[$SY1;${SX2}H\e[${color}mS\e[m" if $display_map;
	print "\e[$EY1;${EX2}H\e[${color}mE\e[m" if $display_map;
	}

my $status_line = $g->{height} + 2 ;
print "\e[$status_line;0H\e[m" if $display_map;
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
	'keep_clear'        => \$options->{keep_clear},
	'no_map_display'    => \$options->{no_map_display},
	'obstruct'          => \$options->{obstruct},
	'display_search'    => \$options->{display_search},
	'orthogonal_cost:i' => \$options->{orthogonal_cost},
	'diagonal_cost:i'   => \$options->{diagonal_cost},
	'extra_cost:i'      => \$options->{extra_cost},
	'XHK:i'             => \$options->{XHK},
	'XNHK:i'            => \$options->{XNHK},
	'YHK:i'             => \$options->{YHK},
	'YNHK:i'            => \$options->{YNHK},
	) or die("Error in command line arguments\n");

my $g = AI::Pathfinding::AStar::Obstacle::Map->new
		({
		keep_clear      => $options->{keep_clear},
		display_search  => $options->{display_search},
		orthogonal_cost => $options->{orthogonal_cost} // 10,
		diagonal_cost   => $options->{diagonal_cost} // 140,
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
