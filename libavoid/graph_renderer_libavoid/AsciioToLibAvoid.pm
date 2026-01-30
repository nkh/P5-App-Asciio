package AsciioToLibAvoid ;

use strict ;
use warnings ;

use Exporter 'import' ;
our @EXPORT_OK = qw(asciio_node_to_libavoid) ;

# ------------------------------------------------------------------------------

sub asciio_node_to_libavoid
{
my ($node, $node_id, $character_width, $character_height, $port_id_start) = @_ ;

my $char_x            = $node->{X} ;
my $char_y            = $node->{Y} ;
my $node_width_chars  = $node->{WIDTH} ;
my $node_height_chars = $node->{HEIGHT} ;

my $x1 = $char_x * $character_width ;
my $y1 = $char_y * $character_height ;
my $x2 = ($char_x + $node_width_chars) * $character_width ;
my $y2 = ($char_y + $node_height_chars) * $character_height ;

my $node_line = "NODE $node_id $x1 $y1 $x2 $y2 0 0" ;

my $node_width_pixels  = $node_width_chars * $character_width ;
my $node_height_pixels = $node_height_chars * $character_height ;

my $north_x = $node_width_pixels / 2 ;
my $north_y = 0 ;

my $south_x = $node_width_pixels / 2 ;
my $south_y = $node_height_pixels ;

my $west_x = 0 ;
my $west_y = $node_height_pixels / 2 ;

my $east_x = $node_width_pixels ;
my $east_y = $node_height_pixels / 2 ;

my @port_lines ;
push @port_lines, "PORT " . ($port_id_start + 0) . " $node_id NORTH $north_x $north_y" ;
push @port_lines, "PORT " . ($port_id_start + 1) . " $node_id EAST $east_x $east_y" ;
push @port_lines, "PORT " . ($port_id_start + 2) . " $node_id SOUTH $south_x $south_y" ;
push @port_lines, "PORT " . ($port_id_start + 3) . " $node_id WEST $west_x $west_y" ;

return ($node_line, @port_lines) ;
}

1 ;
