
return
	[
	compose
		(
		box(1, 1,'', <<EOT), 
Dateisystem
EOT


		process(13, 10,<<EOT), 
vhost.random.domain
vhost2.random.domain
Webserver: Apache2
Ports: 80 (http)
EOT
		),

	] ;

#-------------------------------------------------------------------------------------------------------------------------------

sub box
{
my ($x, $y, $title, $text, $select) = @_ ;

return
	sub
		{
		my ($self) = @_ ;

		my $element = $self->add_new_element_named('stencils/asciio/box', $x, $y) ;

		$element->set_text($title, $text) ;

		$self->select_elements($select, $element) ;
		
		return $element ;
		} ;
}

#-------------------------------------------------------------------------------------------------------------------------------

sub process
{
my ($x, $y, $text, $select) = @_ ;

return
	sub
		{
		my ($self) = @_ ;

		my $element = $self->add_new_element_named('stencils/asciio/boxes/process', $x, $y) ;

		$element->set_text($text) ;

		$self->select_elements($select, $element) ;
		
		return $element ;
		} ;
}

#-------------------------------------------------------------------------------------------------------------------------------

sub compose
{
my (@elements) = @_ ;

return
	sub
		{
		my ($self) = @_ ;
		
		for my $element (@elements) 
			{
			$element->($self) ;
			}
		} ;
}

#-------------------------------------------------------------------------------------------------------------------------------
