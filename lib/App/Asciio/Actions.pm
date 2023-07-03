
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
		my $in_capture = defined $self->{CURRENT_ACTIONS}{ESCAPE_KEY} ;
		
		my $group_tag = $is_group ? defined $self->{CURRENT_ACTIONS}{$action}{ESCAPE_KEY}
						? "[c] "
						: "[g] "
					  : '' ;
		
		my $capture_tag = $in_capture ? "[$self->{CURRENT_ACTIONS}{NAME}] " : '' ;
		
		$self->{ACTION_VERBOSE}->
			(
			sprintf
				(
				"%-30s %-30s [%s]",
				"${modifiers}$action_key $group_tag$capture_tag",
				$self->{CURRENT_ACTIONS}{$action}{NAME},
				$self->{CURRENT_ACTIONS}{$action}{ORIGIN}
				)
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
		
		$self->{CURRENT_ACTIONS} = $self->{ACTIONS} unless $is_group || $in_capture ;
		
		if($is_group && defined $self->{CURRENT_ACTIONS}{ENTER_GROUP})
			{
			$self->{CURRENT_ACTIONS}{ENTER_GROUP}->($self) ;
			}
			
		if(defined $self->{CURRENT_ACTIONS}{ESCAPE_KEY})
			{
			my $escape_key = "escape key: $self->{CURRENT_ACTIONS}{ESCAPE_KEY}" ;
			
			if($action eq $self->{CURRENT_ACTIONS}{ESCAPE_KEY})
				{
				$self->{ACTION_VERBOSE}->("\e[33m[$self->{CURRENT_ACTIONS}{NAME}] leaving\e[m") if $self->{ACTION_VERBOSE} ; 
				$self->{CURRENT_ACTIONS} = $self->{ACTIONS} ;
				}
			}
		}
	else
		{
		if(defined $self->{CURRENT_ACTIONS}{ESCAPE_KEY})
			{
			my $escape_key = "escape key: $self->{CURRENT_ACTIONS}{ESCAPE_KEY}" ;
			
			if($action eq $self->{CURRENT_ACTIONS}{ESCAPE_KEY})
				{
				$self->{ACTION_VERBOSE}->("\e[33m[$self->{CURRENT_ACTIONS}{NAME}] leaving\e[m") if $self->{ACTION_VERBOSE} ; 
				$self->{CURRENT_ACTIONS} = $self->{ACTIONS} ;
				}
			else
				{
				$self->{ACTION_VERBOSE}->("\e[31m$action, [$self->{CURRENT_ACTIONS}{NAME}], $escape_key\e[m") if $self->{ACTION_VERBOSE} ; 
				}
			}
		else
			{
			$self->{ACTION_VERBOSE}->(sprintf "\e[31m%-30s\e[m", "$action") if $self->{ACTION_VERBOSE} ; 
			$self->{CURRENT_ACTIONS} = $self->{ACTIONS} ;
			}
		
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
			$self->{ACTION_VERBOSE}->(sprintf '%30s %s', '', "\e[32m$action [group]\e[0m") if $self->{ACTION_VERBOSE} ;
			$current_actions_by_name = $self->{CURRENT_ACTIONS}{$action} ;
			}
		else
			{
			$self->{ACTION_VERBOSE}->(sprintf '%30s %s', '', "\e[32m$action\e[0m") if $self->{ACTION_VERBOSE} ;
			
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
		$self->{ACTION_VERBOSE}->(sprintf '%30s %s', '', "\e[31m$action\e[0m") if $self->{ACTION_VERBOSE} ;
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
