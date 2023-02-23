
package App::Asciio::Actions::Align ;

#----------------------------------------------------------------------------------------------

use List::Util qw(min max) ;

#----------------------------------------------------------------------------------------------

sub align
{
my ($self, $alignment) = @_ ;

$self->create_undo_snapshot() ;

my @elements_to_move =  grep {my @connectors = $_->get_connector_points() ; @connectors == 0 } $self->get_selected_elements(1) ;

for ($alignment)
	{
	$_ eq 'left' and do
		{
		my $left = min( map{$_->{X}} @elements_to_move) ;
			
		for my $element (@elements_to_move)
			{
			$self->move_elements($left - $element->{X},0, $element) ;
			}
		last ;
		} ;
	
	$_ eq 'center' and do
		{
		my $left = min( map{$_->{X}} @elements_to_move) ;
		my $right = max
					(
					map
						{
						my ($w, $h) = $_->get_size() ;
						
						$_->{X} + $w ;
						} @elements_to_move
					) ;
					
		my $center = int(($left + $right) / 2) ;
		
		# find element which center is closes to geometric center
		my $closest_element = undef ;
		my $closest_element_distance =  1_000_000 ;
		my $closest_center ;
		
		for my $element (@elements_to_move)
			{
			my ($w, $h)  = $element->get_size() ;
			
			my $element_center = $element->{X} + int($w / 2) ;
			my $center_to_center_distance = abs($center - $element_center) ;
			
			if($center_to_center_distance <$closest_element_distance)
				{
				$closest_element = $element ;
				$closest_element_distance = $center_to_center_distance;
				$closest_center = $element_center ;
				}
			}
			
		for my $element (@elements_to_move)
			{
			next if $element == $closest_element ;
			
			my ($w, $h)  = $element->get_size() ;
			my $element_center = $element->{X} + int($w / 2) ;
			
			$self->move_elements($closest_center - $element_center, 0, $element) ;
			}
		last ;
		} ;
	
	$_ eq 'right' and do
		{
		my $right = max
					(
					map
						{
						my ($w, $h) = $_->get_size() ;
						
						$_->{X} + $w ;
						} @elements_to_move
					) ;
			
		for my $element (@elements_to_move)
			{
			my ($w, $h)  = $element->get_size() ;
			$self->move_elements($right - ($element->{X} + $w), 0, $element) ;
			}
		last ;
		} ;
	
	$_ eq 'top' and do
		{
		my $top = min( map{$_->{Y}} @elements_to_move) ;
			
		for my$element (@elements_to_move)
			{
			$self->move_elements(0, $top - $element->{Y}, $element) ;
			}
		last ;
		} ;
	
	$_ eq 'middle' and do
		{
		my $top = min( map{$_->{Y}} @elements_to_move) ;
		my $bottom = max
					(
					map
						{
						my ($w, $h) = $_->get_size() ;
						
						$_->{Y} + $h ;
						} @elements_to_move
					) ;
					
		my $center = int(($top + $bottom) / 2) ;
		
		# find element which center is closes to geometric center
		my $closest_element = undef ;
		my $closest_element_distance =  1_000_000 ;
		my $closest_center ;
		
		for my $element (@elements_to_move)
			{
			my ($w, $h)  = $element->get_size() ;
			
			my $element_center = $element->{Y} + int($h / 2) ;
			my $center_to_center_distance = abs($center - $element_center) ;
			
			if($center_to_center_distance <$closest_element_distance)
				{
				$closest_element = $element ;
				$closest_element_distance = $center_to_center_distance;
				$closest_center = $element_center ;
				}
			}
			
		for my $element (@elements_to_move)
			{
			next if $element == $closest_element ;
			
			my ($w, $h)  = $element->get_size() ;
			my $element_center = $element->{Y} + int($h / 2) ;
			
			$self->move_elements(0, $closest_center - $element_center, $element) ;
			}
		last ;
		} ;
	
	$_ eq 'bottom' and do
		{
		my $bottom = max
					(
					map
						{
						my ($w, $h) = $_->get_size() ;
						
						$_->{Y} + $h ;
						} @elements_to_move
					) ;
			
		for my $element (@elements_to_move)
			{
			my ($w, $h)  = $element->get_size() ;
			$self->move_elements(0, $bottom - ($element->{Y} + $h), $element) ;
			}
		last ;
		} ;
	}

$self->update_display() ;
}

1 ;

