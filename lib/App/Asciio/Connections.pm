
package App::Asciio;

$|++ ;

use strict;
use warnings;

use Data::TreeDumper ;

#-----------------------------------------------------------------------------

sub connect_elements
{
my ($self, @elements) = @_ ;

my @possible_connections = $self->get_possible_connections(@elements) ;

$self->add_connections(@possible_connections) ;
}

#-----------------------------------------------------------------------------

sub add_connections
{
my ($self, @connections) = @_ ;

$self->flash_new_connections(@connections) ;

push @{$self->{CONNECTIONS}}, @connections ;
$self->{MODIFIED }++ ;
}

#-----------------------------------------------------------------------------

sub get_possible_connections
{
my ($self, @elements) = @_ ;

my @possible_connections ;
my %connected_connectors ;

for my $element (@elements)
	{
	my @connectors = $element->get_connector_points() ;
	
	last unless @connectors ;
	
	for my $connectee (reverse grep { $_->is_autoconnect_enabled() || $_->is_border_connection_allowed() } @{$self->{ELEMENTS}})
		{
		next if $connectee == $element ; # don't connect to self
		
		for my $connector (@connectors)
			{
			my @connections = $connectee->match_connector
							(
							# translate coordinates to connectee reference
							($element->{X} - $connectee->{X}) +  $connector->{X},
							($element->{Y} - $connectee->{Y}) +  $connector->{Y},
							) ;
			
			# make connection if possible. connect to a single point
			if(defined $connections[0] && ! exists $connected_connectors{$element.$connector->{NAME}})
				{
				push @possible_connections, 
					{
					CONNECTED => $element,
					CONNECTOR =>$connector,
					CONNECTEE => $connectee,
					CONNECTION => $connections[0],
					} ;
				
				$connected_connectors{$element.$connector->{NAME}}++ ;
				next ;
				}
			}
		}
	}

return(@possible_connections) ;
}

#-----------------------------------------------------------------------------

sub get_connections_containing
{
my($self, @elements) = @_ ;

my %elements_to_find = map {$_ => 1} @elements ;
my @connections ;

for my $connection (@{$self->{CONNECTIONS}})
	{
	if(exists $elements_to_find{$connection->{CONNECTED}} || exists $elements_to_find{$connection->{CONNECTEE}})
		{
		push @connections, $connection;
		}
	}

return(@connections) ;
}

#-----------------------------------------------------------------------------

sub delete_connections
{
my($self, @connections) = @_ ;

my %connections_to_delete = map {$_ => 1} @connections ;

for my $connection (@{$self->{CONNECTIONS}})
	{
	if(exists $connections_to_delete{$connection})
		{
		$connection = undef ;
		}
	}

@{$self->{CONNECTIONS}} = grep { defined $_} @{$self->{CONNECTIONS}} ;

$self->{MODIFIED }++ ;
}

#-----------------------------------------------------------------------------

sub delete_connections_containing
{
my($self, @elements) = @_ ;

for my $element(@elements)
	{
	for my $connection (@{$self->{CONNECTIONS}})
		{
		if($connection->{CONNECTED} == $element || $connection->{CONNECTEE} == $element)
			{
			$connection = undef ;
			}
		}
	}

@{$self->{CONNECTIONS}} = grep { defined $_} @{$self->{CONNECTIONS}} ;

$self->{MODIFIED }++ ;
}

#-----------------------------------------------------------------------------

sub is_connectee
{
my($self, $element) = @_ ;

my $connectee = 0 ;

for my $connection (@{$self->{CONNECTIONS}})
	{
	if($connection->{CONNECTEE} == $element)
		{
		$connectee++ ;
		last
		}
	}

return($connectee) ;
}

#-----------------------------------------------------------------------------

sub get_connections_with_connectee
{
my($self, $element) = @_ ;

my(@connections) ;

for my $connection (@{$self->{CONNECTIONS}})
	{
	if($connection->{CONNECTEE} == $element)
		{
		push @connections, $connection ;
		}
	}

return(@connections) ;
}

#-----------------------------------------------------------------------------

sub is_connected
{
my($self, $element) = @_ ;

my $connected = 0 ;

for my $connection (@{$self->{CONNECTIONS}})
	{
	if($connection->{CONNECTED} == $element)
		{
		$connected++ ;
		last
		}
	}

return($connected) ;
}

#-----------------------------------------------------------------------------

sub flash_new_connections
{
my($self, @connections) = @_ ;

push @{$self->{NEW_CONNECTIONS}}, @connections ;
}

#-----------------------------------------------------------------------------


1 ;
