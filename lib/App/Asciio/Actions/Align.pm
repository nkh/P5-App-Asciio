
package App::Asciio::Actions::Align ;

use strict ; use warnings ;

#----------------------------------------------------------------------------------------------

use List::Util qw(min max) ;

#----------------------------------------------------------------------------------------------

sub align
{
my ($self, $alignment) = @_ ;

$self->create_undo_snapshot() ;

my @elements_to_move = grep { my @connectors = $_->get_connector_points() ; @connectors == 0 }
				grep { ! defined $_->{GROUP} || 0 == $_->{GROUP}->@* }
					$self->get_selected_elements(1) ;

my %groups ;
for my $element (
		grep { my @connectors = $_->get_connector_points() ; @connectors == 0 }
			grep { defined $_->{GROUP} } $self->get_selected_elements(1)
		)
	{
	my $element_group = $element->{GROUP}[-1] ;

	if(defined $element_group)
		{
		
		$groups{$element_group}{X}      = min $element->{X}, $groups{$element_group}{X} // 10_000 ;
		$groups{$element_group}{Y}      = min $element->{Y}, $groups{$element_group}{Y} // 10_000 ;
		
		my ($w, $h)    = $element->get_size() ;
		
		$groups{$element_group}{RIGHT}  = max($element->{X} + $w, ($groups{$element_group}{RIGHT} // 0)) ;
		$groups{$element_group}{BOTTOM} = max($element->{Y} + $h, ($groups{$element_group}{BOTTOM} // 0)) ;
		
		push $groups{$element_group}{elements}->@*, $element ;
		}
	}

for ($alignment)
	{
	$_ eq 'left' and do
		{
		my $left = min( (map{$_->{X}} @elements_to_move), (map { $_->{X} } values %groups)) ;
			
		for my $element (@elements_to_move)
			{
			$self->move_elements($left - $element->{X},0, $element) ;
			}
		
		for my $group (values %groups)
			{
			for my $element ($group->{elements}->@*)
				{
				$self->move_elements($left - $group->{X},0, $element) ;
				}
			}
		last ;
		} ;
	
	$_ eq 'right' and do
		{
		my $right = max(
				(
				map
					{
					my ($w, $h) = $_->get_size() ;
					
					$_->{X} + $w ;
					} @elements_to_move
				) ,
				map { $_->{RIGHT} } values %groups
				) ;
			
		for my $element (@elements_to_move)
			{
			my ($w, $h)  = $element->get_size() ;
			$self->move_elements($right - ($element->{X} + $w), 0, $element) ;
			}
		
		for my $group (values %groups)
			{
			for my $element ($group->{elements}->@*)
				{
				$self->move_elements($right - ($group->{RIGHT}), 0, $element) ;
				}
			}
		last ;
		} ;
	
	$_ eq 'top' and do
		{
		my $top = min( (map{$_->{Y}} @elements_to_move), (map { $_->{Y} } values %groups)) ;
			
		for my$element (@elements_to_move)
			{
			$self->move_elements(0, $top - $element->{Y}, $element) ;
			}
		
		for my $group (values %groups)
			{
			for my $element ($group->{elements}->@*)
				{
				$self->move_elements(0, $top - $group->{Y}, $element) ;
				}
			}
		last ;
		} ;
	
	$_ eq 'bottom' and do
		{
		my $bottom = max(
				(
				map
					{
					my ($w, $h) = $_->get_size() ;
					
					$_->{Y} + $h ;
					} @elements_to_move
				) ,
				(map { $_->{BOTTOM} } values %groups)
				) ;
		
		for my $element (@elements_to_move)
			{
			my ($w, $h)  = $element->get_size() ;
			$self->move_elements(0, $bottom - ($element->{Y} + $h), $element) ;
			}
		
		for my $group (values %groups)
			{
			for my $element ($group->{elements}->@*)
				{
				$self->move_elements(0, $bottom - ($group->{BOTTOM}), $element) ;
				}
			}
		last ;
		} ;
	
	$_ eq 'vertical' and do
		{
		my $left = min( (map{$_->{X}} @elements_to_move), (map { $_->{X} } values %groups)) ;
		my $right = max(
				(
				map
					{
					my ($w, $h) = $_->get_size() ;
					
					$_->{X} + $w ;
					} @elements_to_move
				) ,
				map { $_->{RIGHT} } values %groups
				) ;
				
		my $center = int(($left + $right) / 2) ;
		
		for my $element (@elements_to_move)
			{
			my ($w, $h)  = $element->get_size() ;
			my $element_center = $element->{X} + int($w / 2) ;
			
			$self->move_elements($center - $element_center, 0, $element) ;
			}
		
		for my $group (values %groups)
			{
			my $group_center = $group->{X} + int(($group->{RIGHT} - $group->{X})/ 2) ;
			
			for my $element ($group->{elements}->@*)
				{
				$self->move_elements($center - $group_center, 0, $element) ;
				}
			}
		last ;
		} ;
	
	$_ eq 'horizontal' and do
		{
		my $top = min( (map{$_->{Y}} @elements_to_move), (map{$_->{Y}} values %groups)) ;
		my $bottom = max(
				(
				map
					{
					my ($w, $h) = $_->get_size() ;
					
					$_->{Y} + $h ;
					} @elements_to_move
				),
				map { $_->{BOTTOM} } values %groups
				) ;
				
		my $center = int(($top + $bottom) / 2) ;
		
		for my $element (@elements_to_move)
			{
			my ($w, $h)  = $element->get_size() ;
			my $element_center = $element->{Y} + int($h / 2) ;
			
			$self->move_elements(0, $center - $element_center, $element) ;
			}
		
		for my $group (values %groups)
			{
			my $group_center = $group->{Y} + int(($group->{BOTTOM} - $group->{Y})/ 2) ;
			
			for my $element ($group->{elements}->@*)
				{
				$self->move_elements(0, $center - $group_center, $element) ;
				}
			}
		last ;
		} ;
	}

$self->update_display() ;
}

1 ;

