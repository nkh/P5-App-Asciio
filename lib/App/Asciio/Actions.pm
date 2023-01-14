
package App::Asciio ;

#------------------------------------------------------------------------------------------------------

$|++ ;

#------------------------------------------------------------------------------------------------------

my Readonly $SHORTCUTS = 0 ;
my Readonly $CODE = 1 ;
my Readonly $ARGUMENTS = 2 ;
my Readonly $CONTEXT_MENU_SUB = 3 ;
my Readonly $CONTEXT_MENU_ARGUMENTS = 4 ;
my Readonly $NAME= 5 ;
my Readonly $ORIGIN= 6 ;

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
		
	my ($modifiers, $action_key) = $action =~ /(...)-(.*)/ ;
	
	if(exists $self->{CURRENT_ACTIONS}{$action})
		{
		if('HASH' eq ref $self->{CURRENT_ACTIONS}{$action})
			{
			my $action_group_name = $self->{CURRENT_ACTIONS}{$action}{GROUP_NAME}  || 'unnamed action group' ;
			
			printf "%-20s %-40s [%s]\n", "$modifiers-$action_key", $action_group_name, $self->{CURRENT_ACTIONS}{$action}{ORIGIN} ;
			
			$self->{CURRENT_ACTIONS} = $self->{CURRENT_ACTIONS}{$action} ;
			}
		else
			{
			printf "%-20s %-40s [%s]\n", "$modifiers-$action_key", $self->{CURRENT_ACTIONS}{$action}[$NAME], $self->{CURRENT_ACTIONS}{$action}[$ORIGIN] ;
			
			if(defined $self->{CURRENT_ACTIONS}{$action}[$ARGUMENTS])
				{
				push @results,
					[
					$self->{CURRENT_ACTIONS}{$action}[$CODE]->
							(
							$self,
							$self->{CURRENT_ACTIONS}{$action}[$ARGUMENTS],
							@arguments
							) 
					] ;
				}
			else
				{
				push @results,
					[
					$self->{CURRENT_ACTIONS}{$action}[$CODE]->($self, @arguments)
					] ;
				}
			}
		}
	else
		{
		print "$modifiers-$action_key\n" ;
		$self->{CURRENT_ACTIONS} = $self->{ACTIONS} ;
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
			printf '%20s %s', '', "\e[32m$action [group]\e[0m\n" ;
			$current_actions_by_name = $self->{CURRENT_ACTIONS}{$action} ;
			}
		else
			{
			printf '%20s %s', '', "\e[32m$action\e[0m\n" ;
			
			if(defined $current_actions_by_name->{$action}[$ARGUMENTS])
				{
				push @results,
					[
					$current_actions_by_name->{$action}[$CODE]->
							(
							$self,
							$self->{CURRENT_ACTIONS}{$action}[$ARGUMENTS],
							@arguments
							)
					] ;
				}
			else
				{
				push @results,
					[
					$current_actions_by_name->{$action}[$CODE]->($self, @arguments)
					] ;
				}
			}
		}
	else
		{
		printf '%20s %s', '', "\e[31m$action\e[0m\n" ;
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
