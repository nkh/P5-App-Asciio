
#~ use Data::TreeDumper ;

#----------------------------------------------------------------------------------------------

register_hooks
	(
	{ CANONIZE_CONNECTIONS => \&canonize_connections},
	) ;

#----------------------------------------------------------------------------------------------

=pod
    .-------.
    |       |
    |       .---.
    |       | C |   start connector (first character)
    | C     | o |     /
    | O     | n |    /
    | N     | n | .---.                                end connector (last character)
    | N     | e | | --------------------------------.    /
    | E     | c | '---'                             |   /
    | C     | t |              CONNECTED          .-|-./
    | T     | i |                                 | v |
    | E     | o |                                 '---'
    | E     | n |
    |       '---'                             .------------.
    |       |                                 | Connection |
    '-------'                            .----'------------'-----.
                                         |                       |
                                         |       CONNECTEE       |
                                         |                       |
                                         '-----------------------'
=cut

sub canonize_connections
{
my ($connections) = @_ ;

for my $connection (@{$connections})
	{
	if
		(
		ref $connection->{CONNECTED} eq 'App::Asciio::stripes::section_wirl_arrow'
		|| ref $connection->{CONNECTED} eq 'App::Asciio::stripes::angled_arrow'
		&& $connection->{CONNECTED}->is_autoconnect_enabled()
		&& $connection->{CONNECTEE}->is_autoconnect_enabled()
		)
		{
		reconnect_section_wirl_arrow($connection)  ;
		}
	}
}

sub reconnect_section_wirl_arrow
{
my ($connection) = @_ ;

my ($connected, $connectee) = ($connection->{CONNECTED},  $connection->{CONNECTEE}) ;

my @connectors = $connected->get_all_points() ;
my ($start_name, $end_name) = ($connectors[0]{NAME}, $connectors[-1]{NAME}) ;

if($connection->{CONNECTOR}{NAME} eq $end_name)
	{
	# end connector
	my ($connectee_x, $connectee_y, $connectee_width, $connectee_hight) = 
		($connectee->{X}, $connectee->{Y}, $connectee->get_size()) ;

	my $connected_x = $connected->{X} + $connectors[-2]{X};
	my $connected_y = $connected->{Y} + $connectors[-2]{Y};
	
	if($connected_x < $connectee_x)
		{
		# arrow starts on left of the box
		if($connected->get_section_direction(-1) =~ /^right/)
			{
			if($connected_y < $connectee_y)
				{
				reconnect($connection, 'top_center', $end_name) ;
				}
			else
				{
				if($connected_y < $connectee_y + $connectee_hight)
					{
					reconnect($connection, 'left_center', $end_name) ;
					}
				else
					{
					# arrow below, right-up to bottom_center
					reconnect($connection, 'bottom_center', $end_name) ;
					}
				}
			}
		else
			{
			# arrow going up or down
			reconnect($connection, 'left_center', $end_name) ;
			}
		}
	elsif($connected_x < $connectee_x + $connectee_width)
		{
		# arrow starts within width of the box
		if($connected_y < $connectee_y)
			{
			#arrow above, right-down to top_center
			reconnect($connection, 'top_center', $end_name, 'right') ;
			}
		else
			{
			reconnect($connection, 'bottom_center', $end_name) ;
			}
		}
	else
		{
		# arrow starts on right of the box
		if($connected->get_section_direction(-1) =~ /^left/)
			{
			if($connected_y < $connectee_y)
				{
				reconnect($connection, 'top_center', $end_name) ;
				}
			else
				{
				if($connected_y < $connectee_y + $connectee_hight)
					{
					reconnect($connection, 'right_center', $end_name) ;
					}
				else
					{
					reconnect($connection, 'bottom_center', $end_name) ;
					}
				}
			}
		else
			{
			# arrow going up or down
			reconnect($connection, 'right_center', $end_name) ;
			}
		}
	}
else
	{
	# start connector
	my ($connectee_x, $connectee_y, $connectee_width, $connectee_hight) = 
		($connectee->{X}, $connectee->{Y}, $connectee->get_size()) ;

	my $end_connector_x = $connected->{X} + $connectors[1]{X};
	my $end_connector_y = $connected->{Y} + $connectors[1]{Y} ;

	if($end_connector_x < $connectee_x)
		{
		# arrow ends on left of the box
		if($connected->get_section_direction(0) !~ /^left/)
			{
			if($end_connector_y < $connectee_y)
				{
				reconnect($connection, 'top_center', $start_name) ;
				}
			else
				{
				if($end_connector_y < $connectee_y + $connectee_hight)
					{
					reconnect($connection, 'left_center', $start_name) ;
					}
				else
					{
					reconnect($connection, 'bottom_center', $start_name) ;
					}
				}
			}
		else
			{
			reconnect($connection, 'left_center', $start_name) ;
			}
		}
	elsif($end_connector_x < $connectee_x + $connectee_width)
		{
		# arrow starts within width of the box
		if($end_connector_y < $connectee_y)
			{
			reconnect($connection, 'top_center', $start_name) ;
			}
		else
			{
			reconnect($connection, 'bottom_center', $start_name) ;
			}
		}
	else
		{
		# arrow ends on right of the box
		if($connected->get_section_direction(0) !~ /^right/)
			{
			if($end_connector_y < $connectee_y)
				{
				reconnect($connection, 'top_center', $start_name) ;
				}
			else
				{
				if($end_connector_y < $connectee_y + $connectee_hight)
					{
					reconnect($connection, 'right_center', $start_name) ;
					}
				else
					{
					reconnect($connection, 'bottom_center', $start_name) ;
					}
				}
			}
		else
			{
			reconnect($connection, 'right_center', $start_name) ;
			}
		}
	}
}

sub reconnect
{
my($asciio_connection, $connection_name, $connector_name, $hint) = @_ ;

if($asciio_connection->{CONNECTION}{NAME} ne $connection_name)
	{
	my ($connected, $connectee) = ($asciio_connection->{CONNECTED},  $asciio_connection->{CONNECTEE}) ;

	my ($connection) = $connectee->get_named_connection($connection_name) ;
	my ($connector) = $connected->get_named_connection($connector_name) ;

	my $x_offset_to_connection = ($connectee->{X} + $connection->{X}) - ($connected->{X} + $connector->{X}) ;
	my $y_offset_to_connection =  ($connectee->{Y} + $connection->{Y}) - ($connected->{Y} + $connector->{Y}) ;

	# move connector
	#~ print "reconnect: $connection_name $connector_name\n" ;
	my ($x_offset, $y_offset, $width, $height, $new_connector) = 
		$connected->move_connector($connector_name, $x_offset_to_connection, $y_offset_to_connection, $hint) ;
		
	$connected->{X} += $x_offset ;
	$connected->{Y} += $y_offset ;
	
	$asciio_connection->{CONNECTOR} = $new_connector ;
	$asciio_connection->{CONNECTION} = $connection ;
	}
}

	
	
