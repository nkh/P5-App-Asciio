
package App::Asciio ;
use Encode ;

#------------------------------------------------------------------------------------------------------

$|++ ;

#------------------------------------------------------------------------------------------------------

sub run_actions
{
my ($self, @actions) = @_ ;

my @results ;

for my $action (@actions)
	{
	my @arguments ;
	
	if('ARRAY' eq ref $action)
		{
		($action, @arguments) = @{ $action } ;
		}
	
	my ($modifiers, $action_key) = $action =~ /(...-)?(.*)/ ;
	
	my $action = encode('utf8', $action) ;
	
	if(exists $self->{CURRENT_ACTIONS}{$action})
		{
		my $is_group = $self->{CURRENT_ACTIONS}{$action}{IS_GROUP} ;
		
		$self->{ACTION_VERBOSE}->
			(
			sprintf "%-20s %-40s [%s]", "${modifiers}$action_key", $self->{CURRENT_ACTIONS}{$action}{NAME}, $self->{CURRENT_ACTIONS}{$action}{ORIGIN}
			) if $self->{ACTION_VERBOSE} && $self->{CURRENT_ACTIONS}{$action}{NAME} ne 'Mouse motion' ;
		
		if(defined $self->{CURRENT_ACTIONS}{$action}{ARGUMENTS})
			{
			push @results,
				[
				$self->{CURRENT_ACTIONS}{$action}{CODE}->
						(
						$self,
						$self->{CURRENT_ACTIONS}{$action}{ARGUMENTS},
						@arguments,
						) 
				] ;
			}
		else
			{
			push @results,
				[
				$self->{CURRENT_ACTIONS}{$action}{CODE}->($self, @arguments)
				] ;
			}
		
		$self->{CURRENT_ACTIONS} = $self->{ACTIONS} unless $is_group ;
		}
	else
		{
		$self->{ACTION_VERBOSE}->(sprintf "\e[31m%-20s\e[m", "${modifiers}$action_key") if $self->{ACTION_VERBOSE} ; 
		
		$self->{CURRENT_ACTIONS} = $self->{ACTIONS} ;
		$self->update_display() ;
		}
	}
	
return @results ;
}

#------------------------------------------------------------------------------------------------------

sub run_actions_by_name
{
my ($self, @actions) = @_ ;
my @results ;

my $current_actions_by_name = $self->{ACTIONS_BY_NAME} ;

for my $action (@actions)
	{
	my @arguments ;
	
	if('ARRAY' eq ref $action)
		{
		($action, @arguments) = @{ $action } ;
		}
		
	if(exists $current_actions_by_name->{$action})
		{
		if('HASH' eq ref $self->{CURRENT_ACTIONS}{$action})
			{
			$self->{ACTION_VERBOSE}->(sprintf '%20s %s', '', "\e[32m$action [group]\e[0m") if $self->{ACTION_VERBOSE} ;
			$current_actions_by_name = $self->{CURRENT_ACTIONS}{$action} ;
			}
		else
			{
			$self->{ACTION_VERBOSE}->(sprintf '%20s %s', '', "\e[32m$action\e[0m") if $self->{ACTION_VERBOSE} ;
			
			if(defined $current_actions_by_name->{$action}{ARGUMENTS})
				{
				push @results,
					[
					$current_actions_by_name->{$action}{CODE}->
							(
							$self,
							$self->{CURRENT_ACTIONS}{$action}{ARGUMENTS},
							@arguments
							)
					] ;
				}
			else
				{
				push @results,
					[
					$current_actions_by_name->{$action}{CODE}->($self, @arguments)
					] ;
				}
			}
		}
	else
		{
		$self->{ACTION_VERBOSE}->(sprintf '%20s %s', '', "\e[31m$action\e[0m") if $self->{ACTION_VERBOSE} ;
		last ;
		}
	}

return @results ;
}

#------------------------------------------------------------------------------------------------------

sub exists_action
{
my ($self, $action) = @_ ;

return exists $self->{CURRENT_ACTIONS}{$action} ;
}

#------------------------------------------------------------------------------------------------------

1 ;
