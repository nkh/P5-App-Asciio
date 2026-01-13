
package App::Asciio ;

use strict ; use warnings ;

use Encode ;
use List::Util qw(max) ;
use List::MoreUtils qw(any) ;
use B;

#------------------------------------------------------------------------------------------------------

$|++ ;

#------------------------------------------------------------------------------------------------------

sub use_action_group
{
my ($self, $action) = @_ ; ;

$self->{CURRENT_ACTIONS} = $self->{ACTIONS}{$action} // $self->{ACTIONS_BY_NAME}{$action} ;
}

#------------------------------------------------------------------------------------------------------

sub show_binding_completions
{
my ($self, $keep_visible) = @_ ;

if($self->{USE_BINDINGS_COMPLETION} && ! $self->{CURRENT_ACTIONS}{HIDE})
	{
	my %reserved = map { $_ => 1 } qw(HIDE IS_GROUP ENTER_GROUP ESCAPE_KEYS ESCAPE_GROUP NAME SHORTCUTS ORIGIN CODE OPTIONS) ;
	
	my $binding_max_length =
		max map { length }
			map 
				{
				'ARRAY' eq ref($self->{CURRENT_ACTIONS}{$_}{SHORTCUTS})
						?  join(', ', $self->{CURRENT_ACTIONS}{$_}{SHORTCUTS}->@*)
						: $_
				} grep { ! exists $reserved{$_} } keys $self->{CURRENT_ACTIONS}->%* ;
	
	my $max_length = 0 ;
	my @actions ;
	
	@actions = map {[ $_->{SHORTCUTS}, $_->{NAME} ]}
			grep
				{
				my $shortcut = $_->{SHORTCUTS} ;
				
				   ! exists $reserved{$shortcut} 
				&& ! ($self->{CURRENT_ACTIONS}{$shortcut}{OPTIONS}{HIDE})
				} $self->{ACTIONS_ORDERED}{$self->{CURRENT_ACTIONS}{NAME}}->@* ;
	
	$self->{BINDINGS_COMPLETION} = 
			[
			map
				{
				my ($action_shortcut, $action_name) = $_->@* ;
				
				$action_shortcut = join(', ', $action_shortcut->@*) if 'ARRAY' eq ref $action_shortcut ;
				
				my $completion = sprintf("%-${binding_max_length}s - %s", $action_shortcut, $action_name) ;
				my $length = length $completion ;
				
				$max_length = $length if $length > $max_length ;
				$completion ;
				} @actions
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
	
	($action, @arguments) = @{ $action } if 'ARRAY' eq ref $action ;
	
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
				"%-30s %-40s %s",
				"${modifiers}$action_key $action_group_tag",
				$self->{CURRENT_ACTIONS}{$action}{NAME},
				coderef2name($self->{CURRENT_ACTIONS}{$action}{CODE}) =~ s/App::Asciio:://r,
				# $self->{CURRENT_ACTIONS}{$action}{ORIGIN},
				)
			) if $self->{ACTION_VERBOSE}
				&&    $self->{CURRENT_ACTIONS}{$action}{NAME} ne 'Mouse motion'
				&& ! ($self->{CURRENT_ACTIONS}{$action}{OPTIONS}{HIDE}) ;
		
		# Note: action sub is what changes $self->{CURRENT_ACTIONS} to a new action group
		my $start_actions = $self->{CURRENT_ACTIONS} ;
		
		delete $self->{BINDINGS_COMPLETION} unless $self->{KEEP_BINDINGS_COMPLETION} ;
		
		
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
			if(defined $self->{CURRENT_ACTIONS}{ENTER_GROUP})
				{
				my ($enter_group_sub, $arguments) = 'ARRAY' eq ref $self->{CURRENT_ACTIONS}{ENTER_GROUP}
									? ($self->{CURRENT_ACTIONS}{ENTER_GROUP}->@*)
									: ($self->{CURRENT_ACTIONS}{ENTER_GROUP}) ; 
				
				$enter_group_sub->($self, $arguments) ; 
				}
			
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
				$self->{ACTION_VERBOSE}->("\e[33m[$self->{CURRENT_ACTIONS}{NAME}] leaving\e[0m") if $self->{ACTION_VERBOSE} ; 
				
				$self->{CURRENT_ACTIONS}{ESCAPE_GROUP}->($self) if defined $self->{CURRENT_ACTIONS}{ESCAPE_GROUP} ;
				
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
				$self->{ACTION_VERBOSE}->("\e[33m[$self->{CURRENT_ACTIONS}{NAME}] leaving\e[0m") if $self->{ACTION_VERBOSE} ; 
				$self->{CURRENT_ACTIONS}{ESCAPE_GROUP}->($self) if defined $self->{CURRENT_ACTIONS}{ESCAPE_GROUP} ;
				$self->{CURRENT_ACTIONS} = $self->{ACTIONS} ;
				}
			else
				{
				my $escape_key = "escape keys: " . join (', ', $self->{CURRENT_ACTIONS}{ESCAPE_KEYS}->@*) ;
				$self->{ACTION_VERBOSE}->("\e[31m$action, [$self->{CURRENT_ACTIONS}{NAME}], $escape_key\e[0m") if $self->{ACTION_VERBOSE} ; 
				}
			}
		else
			{
			$self->{ACTION_VERBOSE}->(sprintf "\e[31m%-30s\e[0m", "$action") if $self->{ACTION_VERBOSE} ; 
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
						$current_actions_by_name->{$action}{ARGUMENTS},
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

sub run_macro
{
my ($self, $commands) = @_ ; ;

for my $command ($commands->@*)
	{
	if('ARRAY' eq ref $command)
		{
		my ($action, @arguments) = @{ $command } ;
		my $action_name = (coderef2name($action) =~ s/App::Asciio:://r) ;
		
		$self->{ACTION_VERBOSE}->(sprintf '%30s %s', '', "\e[32m$action_name\e[0m") if $self->{ACTION_VERBOSE} ;
		
		$action->($self, @arguments) ;
		}
	else
		{
		$self->run_actions_by_name($command) ;
		}
	}

$self->update_display() ;
}


#------------------------------------------------------------------------------------------------------

sub exists_action
{
my ($self, $action) = @_ ;

return exists $self->{CURRENT_ACTIONS}{$action} ;
}

#------------------------------------------------------------------------------------------------------

sub coderef2name 
{
my ($coderef) = @_;

return '' unless UNIVERSAL::isa($coderef, "CODE");

my $obj = B::svref_2object($coderef);
return $obj->GV->STASH->NAME . "::" . $obj->GV->NAME;
}

#------------------------------------------------------------------------------------------------------

1 ;
