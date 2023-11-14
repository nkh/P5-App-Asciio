package App::Asciio::ZBuffer ;

use strict; use warnings;
use utf8;

# ------------------------------------------------------------------------------

sub new
{
my ($invocant, @elements) = @_;

my $class = ref($invocant) || $invocant;

my $self = bless { }, $class ;

$self->add_elements(@elements) ;

return $self;
}

# ------------------------------------------------------------------------------

sub add_elements
{
my ($self, @elements) = @_ ;

my $t0 = Time::HiRes::gettimeofday();

for my $element (@elements)
	{
	my $coordinates = $self->get_coordinates($element) ;
	
	while ( my ($coordinate, $char) = each $coordinates->%* )
		{
		if($char eq ' ')
			{
			delete $self->{intersecting_elements}{$coordinate}
			}
		elsif( ($self->{coordinates}{$coordinate} // ' ') ne ' ')
			{
			$self->{intersecting_elements}{$coordinate} = [ $char, $self->{coordinates}{$coordinate} ] ;
			}
		
		$self->{coordinates}{$coordinate} = $char ;
		}
	}

my $t1 = Time::HiRes::gettimeofday();
printf "add time: %0.4f sec.\n", $t1 - $t0 ;
}

# ------------------------------------------------------------------------------

sub get_coordinates
{
my ($self, $element) = @_ ;
my %coordinates ;

for my $strip (@{$element->get_stripes})
	{
	my $line_index = 0 ;
	
	for my $line (split /\n/, $strip->{TEXT})
		{
		my $character_index = 0 ;
		
		for my $char ( split '', $line)
			{
			my $Y = $element->{Y} + $strip->{Y_OFFSET} + $line_index ;
			my $X = $element->{X} + $strip->{X_OFFSET} + $character_index ;
			$coordinates{"$Y;$X"} = $char ; 
			
			$character_index++ ;
			}
		
		$line_index++ ;
		}
	}

return \%coordinates ;
}

# ------------------------------------------------------------------------------

sub render_text
{
my ($self, $COLS, $ROWS) = @_ ;
($COLS, $ROWS) = (15, 10) ;

my $t0 = Time::HiRes::gettimeofday();
my $rendering = '' ;
my ($text, $previous_color , $color) = ('', '', '') ;

while ( my ($coordinate, $char) = each $self->{coordinates}->%*)
	{
	$rendering .= "\e[${coordinate}H$char" ;
	# $rendering .= "${coordinate}->$char\n" ;
	}

print "$rendering\e[m" ;

my $t1 = Time::HiRes::gettimeofday();
printf "render time: %0.4f sec.\n", $t1 - $t0 ;
}

# ------------------------------------------------------------------------------

sub remove_elements
{
# my ($self, @elements) = @_ ;
# my @new_elements ;

# for my $element (@elements)
# 	{
# 	push @new_elements, $element ; 
# 	}
}

# ------------------------------------------------------------------------------

sub update_elements_list
{
# my ($self, @elements) = @_ ;
# my %new_list = map { $_ => $_ } @elements ;

# $self->remove_elements( grep { ! exists $new_list{$_} } keys %{$self->{elements}} ) ;
# $self->add_elements(@elements) ;
}

# ------------------------------------------------------------------------------

sub get_neighbors
{
my ($self, $coordinate) = @_ ;
my ($x, $y)             = split ';', $coordinate ;

return 
	{
	map 
		{
		exists $self->{coordinates}{$_} 
			? (
				$self->{coordinates}{$_} ne ' ' 
					? ($_ => $self->{coordinates}{$_})
					: ()
					) 
			: () }
		($x-1) .';'. ($y-1), $x .';'. ($y-1), ($x+1) .';'. ($y-1), 
		($x-1) .';'. $y,                      ($x+1) .';'. $y, 
		($x-1) .';'. ($y+1), $x .';'. ($y+1), ($x+1) .';'. ($y+1)
	}
}

# ------------------------------------------------------------------------------

sub cross_overlay
{
my ($zbuffer) = @_ ;

use Data::TreeDumper ;

while( my($coordinate, $elements) = each $zbuffer->{intersecting_elements}->%*)
	{
	my $neighbors = $zbuffer->get_neighbors($coordinate) ;
	
	print DumpTree { stack => $elements, neighbors => $neighbors }, $coordinate ;
	# compute overlay
	}
}

# ------------------------------------------------------------------------------

1 ;

__DATA__

element_uniq_id
	do we clone elements?

element has its own 2d_hash
	or a list of characters and then get the character from strips

updating z buffer

	if element was removed, use element "shadow" to decrease position count
		delete element which deletes the element's 2d map

	if element is added, and z buffer already created
		update z buffer with just that element

	if elemnt modified
		delete element and add it

		finding out if element is modified is by asking the element itself
			problem is the element in asciio is the dsame as the shadow element in z buffer
			if element return a hash for it's state we can use the hash to check if it has changed

	if element's depth hs changed
