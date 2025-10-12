
package App::Asciio ;

use strict ; use warnings ;

use Encode ;
use List::Util qw(max) ;
use List::MoreUtils qw(any) ;
use Clone ;

#------------------------------------------------------------------------------------------------------

$|++ ;

#------------------------------------------------------------------------------------------------------

sub use_action_group
{
my ($self, $action) = @_ ; ;

$self->{CURRENT_ACTIONS} = $self->{ACTIONS}{$action} // $self->{ACTIONS_BY_NAME}{$action} ;
}

sub show_binding_completions
{
my ($self, $keep_visible) = @_ ;

if($self->{USE_BINDINGS_COMPLETION})
	{
	my %reserved = map { $_ => 1 } qw(IS_GROUP ENTER_GROUP ESCAPE_KEYS NAME SHORTCUTS ORIGIN CODE) ;
	my $hide_bindings_name = $self->{HIDE_GROUP_BINDING_HELP} // {} ;
	my $current_actions = Clone::clone($self->{CURRENT_ACTIONS}) ;

	while(my ($key, $value) = each %{$current_actions})
		{
		next if(exists $reserved{$key}) ;
		if((($hide_bindings_name->{$value->{GROUP_NAME}//''}//{})->{$value->{NAME}//''}//'') ne '')
			{
			delete $current_actions->{$key} ;
			}
		}

	my $binding_max_length = max map { length } grep { ! exists $reserved{$_} } keys $current_actions->%* ;
	
	my $max_length = 0 ;
	
	$self->{BINDINGS_COMPLETION} = 
			[
			map
				{
				my $completion = sprintf("%-${binding_max_length}s - %s", $_, $current_actions->{$_}{NAME}) ;
				my $length = length $completion ;
				
				$max_length = $length if $length > $max_length ;
				$completion ;
				}
				sort grep { ! exists $reserved{$_} } keys $current_actions->%*
			] ;
	
	$self->{BINDINGS_COMPLETION_LENGTH} = $max_length ;
	$self->update_display() ;
	}
else
	{
	if(exists $self->{BINDINGS_COMPLETION})
		{
		delete $self->{BINDINGS_COMPLETION} ;
		$self->update_display() ;
		}
	}

$_[0]->{KEEP_BINDINGS_COMPLETION}++ if $keep_visible ; 
}

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
	$modifiers //= '000-' ;
	
	next if $action_key eq 'Shift_R' || $action_key eq 'Shift_L' ||  $action_key eq 'Alt_R' ||  $action_key eq 'Alt_L' ;
	
	my $action = encode('utf8', $action) ;
	
	if(exists $self->{CURRENT_ACTIONS}{$action})
		{
		my $action_is_group  = $self->{CURRENT_ACTIONS}{$action}{IS_GROUP} ;
		my $action_capture   = defined $self->{CURRENT_ACTIONS}{$action}{ESCAPE_KEYS} && $self->{CURRENT_ACTIONS}{$action}{ESCAPE_KEYS}->@* ;
		my $action_group_tag = $action_is_group ? ($action_capture ? "[ge] " : "[g] ") : '' ;
		
		$self->{ACTION_VERBOSE}->
			(
			sprintf
				(
				"%-30s %-30s [%s]",
				"${modifiers}$action_key $action_group_tag",
				$self->{CURRENT_ACTIONS}{$action}{NAME},
				$self->{CURRENT_ACTIONS}{$action}{ORIGIN}
				)
			) if $self->{ACTION_VERBOSE} && $self->{CURRENT_ACTIONS}{$action}{NAME} ne 'Mouse motion' ;
		
		# Note: action sub is what changes $self->{CURRENT_ACTIONS} to a new action group
		my $start_actions = $self->{CURRENT_ACTIONS} ;
		
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
			push @results, [ $self->{CURRENT_ACTIONS}{$action}{CODE}->($self, @arguments) ] ;
			}
		
		if($start_actions != $self->{CURRENT_ACTIONS})
			{
			# entered new group
			$self->{CURRENT_ACTIONS}{ENTER_GROUP}->($self) if defined $self->{CURRENT_ACTIONS}{ENTER_GROUP} ;
			$self->show_binding_completions() ; 
			}
		else
			{
			unless ($self->{KEEP_BINDINGS_COMPLETION})
				{
				delete $self->{BINDINGS_COMPLETION} ;
				}
			
			delete $self->{KEEP_BINDINGS_COMPLETION} ;
			
			if(defined $self->{CURRENT_ACTIONS}{ESCAPE_KEYS} && any { $_ eq $action } $self->{CURRENT_ACTIONS}{ESCAPE_KEYS}->@*)
				{
				$self->{ACTION_VERBOSE}->("\e[33m[$self->{CURRENT_ACTIONS}{NAME}] leaving\e[m") if $self->{ACTION_VERBOSE} ; 
				$self->{CURRENT_ACTIONS} = $self->{ACTIONS} ;
				}
			else
				{
				my $in_capture = defined $self->{CURRENT_ACTIONS}{ESCAPE_KEYS} && $self->{CURRENT_ACTIONS}{ESCAPE_KEYS}->@* ;
				$self->{CURRENT_ACTIONS} = $self->{ACTIONS} unless $in_capture ;
				}
			}
		}
	else
		{
		if(defined $self->{CURRENT_ACTIONS}{ESCAPE_KEYS} && $self->{CURRENT_ACTIONS}{ESCAPE_KEYS}->@*)
			{
			if(any { $_ eq $action } $self->{CURRENT_ACTIONS}{ESCAPE_KEYS}->@*)
				{
				$self->{ACTION_VERBOSE}->("\e[33m[$self->{CURRENT_ACTIONS}{NAME}] leaving\e[m") if $self->{ACTION_VERBOSE} ; 
				$self->{CURRENT_ACTIONS} = $self->{ACTIONS} ;
				}
			else
				{
				my $escape_key = "escape keys: " . join (', ', $self->{CURRENT_ACTIONS}{ESCAPE_KEYS}->@*) ;
				$self->{ACTION_VERBOSE}->("\e[31m$action, [$self->{CURRENT_ACTIONS}{NAME}], $escape_key\e[m") if $self->{ACTION_VERBOSE} ; 
				}
			}
		else
			{
			$self->{ACTION_VERBOSE}->(sprintf "\e[31m%-30s\e[m", "$action") if $self->{ACTION_VERBOSE} ; 
			$self->{CURRENT_ACTIONS} = $self->{ACTIONS} ;
			}
		
		delete $self->{BINDINGS_COMPLETION} ;
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
