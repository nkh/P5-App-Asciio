
package App::Asciio ;

$|++ ;

use strict;
use warnings;
use utf8 ;

use Data::TreeDumper ;
use Eval::Context ;
use Carp ;
use Module::Util qw(find_installed) ;
use File::Basename ;

#------------------------------------------------------------------------------------------------------

sub setup
{
my($self, $setup_ini_files, $object_overrides) = @_ ;

if (defined $object_overrides)
	{
	while( my ($k, $v) = each $object_overrides->%* )
		{
		$self->{$k} = $v ;
		}
	}

for my $setup_file (@{$setup_ini_files})
	{
	$self->{WARN}("Initializing with '$setup_file'\n") ;
	$self->{WARN}("Asciio: Warning: can't find setup data '$setup_file'\n") and next unless -e $setup_file ;
	
	push @{$self->{SETUP_PATHS}}, $setup_file ;
	
	my ($setup_name, $setup_path, $setup_ext) = File::Basename::fileparse($setup_file, ('\..*')) ;
	
	my $ini_files ;
	
	{
	my $context = new Eval::Context() ;
	$ini_files = $context->eval
				(
				PRE_CODE => "use strict;\nuse warnings;\n",
				INSTALL_VARIABLES =>[[ '$ASCIIO_UI'  => $self->{UI}]] ,
				CODE_FROM_FILE => $setup_file,
				) ;
	
	$self->{WARN}("can't load '$setup_file': $! $@\n") if $@ ;
	}
	
	$self->setup_object_options($setup_path, $ini_files->{ASCIIO_OBJECT_SETUP} || []) ;
	if (defined $object_overrides)
		{
		while( my ($k, $v) = each $object_overrides->%* )
			{
			$self->{$k} = $v ;
			}
		}
	
	$self->setup_stencils($setup_path, $ini_files->{STENCILS} || []) ;
	$self->setup_hooks($setup_path, $ini_files->{HOOK_FILES} || []) ;
	$self->setup_action_handlers($setup_path, $ini_files->{ACTION_FILES} || []) ;
	$self->setup_import_export_handlers($setup_path, $ini_files->{IMPORT_EXPORT} || []) ;
	}
}

#------------------------------------------------------------------------------------------------------

sub setup_stencils
{
my($self, $setup_path, $stencils) = @_ ;

for my $stencil (@{$stencils})
	{
	if(-e "$setup_path/$stencil")
		{
		if(-f "$setup_path/$stencil")
			{
			$self->{WARN}("loading stencil '$setup_path/$stencil'\n") if $self->{DISPLAY_SETUP_INFORMATION} ;
			$self->load_elements("$setup_path/$stencil", $stencil) ;
			}
		elsif(-d "$setup_path/$stencil")
			{
			for(glob("$setup_path/$stencil/*"))
				{
				$self->{WARN}("batch loading stencil '$setup_path/$stencil/$_'\n") if $self->{DISPLAY_SETUP_INFORMATION} ;
				$self->load_elements($_, $stencil) ;
				}
			}
		else
			{
			$self->{WARN}("Unknown type '$setup_path/$stencil'!\n") ;
			}
		}
	else
		{
		$self->{WARN}("Can't find '$setup_path/$stencil'!\n") ;
		}
	}
}

#------------------------------------------------------------------------------------------------------

sub setup_hooks
{
my($self, $setup_path, $hook_files) = @_ ;

for my $hook_file (@{ $hook_files })
	{
	my $context = new Eval::Context() ;
	
	my @hooks ;
	
	$context->eval
		(
		REMOVE_PACKAGE_AFTER_EVAL => 0, # VERY IMPORTANT as we return code references that will cease to exist otherwise
		INSTALL_SUBS => {register_hooks => sub{@hooks = @_}},
		PRE_CODE => "use strict;\nuse warnings;\n",
		CODE_FROM_FILE => "$setup_path/$hook_file" ,
		) ;
	
	die "Asciio: can't load hook file '$hook_file ': $! $@\n" if $@ ;
	
	for my $hook (@hooks)
		{
		while (my ($name, $hook_sub) = each %$hook)
			{
			$self->{HOOKS}{$name} = $hook_sub ;
			}
		}
	}
}

#------------------------------------------------------------------------------------------------------

sub setup_action_handlers
{
my($self, $setup_path, $action_files) = @_ ;

use Module::Util qw(find_installed) ;
use File::Basename ;

my $installed = find_installed('App::Asciio') ;
my ($basename, $path, $ext) = File::Basename::fileparse($installed, ('\..*')) ;
my $asciio_setup_path = $path . $basename . '/setup/' ;

my %first_level_group ;

for my $action_file (@{ $action_files })
	{
	my $context = new Eval::Context() ;
	
	my (%action_handlers, $remove_old_shortcuts) ;
	
	if($action_file =~ /^$asciio_setup_path/)
		{
		$setup_path = $asciio_setup_path ;
		substr($action_file, 0, length("$asciio_setup_path/")) = '' 
		}
	
	my $location = $action_file =~ /^\// ? $action_file : "$setup_path/$action_file" ;
	
	$context->eval
		(
		REMOVE_PACKAGE_AFTER_EVAL => 0, # VERY IMPORTANT as we return code references that will cease to exist otherwise
		INSTALL_SUBS => {
				register_action_handlers                      => sub { %action_handlers = @_ ; },
				register_action_handlers_remove_old_shortcuts => sub { %action_handlers = @_ ; $remove_old_shortcuts++ ; },
				register_first_level_group                    => sub { %first_level_group = (%first_level_group, @_) ; },
				},
		PRE_CODE => "use strict;\nuse warnings;\n",
		CODE_FROM_FILE => $location,
		) ;
	
	die "Asciio: can't load setup file '$action_file': $! $@\n" if $@ ;
	
	for my $name (grep { $_ ne 'SHORTCUTS' && $_ ne 'ESCAPE_KEYS' } keys %action_handlers)
		{
		my $action_handler_definition = $action_handlers{$name} ;
		my $action_handler ;
		my $group_name ;
		
		my $shortcuts_definition ;
		
		if('HASH' eq ref $action_handler_definition)
			{
			$shortcuts_definition = $action_handler_definition->{SHORTCUTS}  ;
			# $self->{ACTION_VERBOSE}("\e[31maction_handler: '$name' is group $shortcuts_definition\e[m\n") ;
			
			$action_handler = $self->get_group_action_handler($setup_path, $action_file, $name, $action_handler_definition) ;
			}
		elsif('ARRAY' eq ref $action_handler_definition)
			{
			my %action_handler_hash ; # transform the definition from array into hash
			@action_handler_hash{'SHORTCUTS', 'CODE', 'ARGUMENTS', 'CONTEXT_MENU_SUB', 'CONTEXT_MENU_ARGUMENTS', 'NAME', 'ORIGIN'}
				 = @$action_handler_definition ;
			
			$shortcuts_definition = $action_handler_hash{SHORTCUTS}  ;
			$action_handler_hash{NAME} = $name ;
			$action_handler_hash{ORIGIN} = $action_file ;
			
			$self->check_action_by_name($setup_path, $action_file, \%action_handler_hash, \%action_handlers) ;
			
			$action_handler = \%action_handler_hash ;
			}
		else
			{
			# $self->{ACTION_VERBOSE}("ignoring '$name'\n") ;
			next ;
			}
			
		$self->{ACTIONS_BY_NAME}{$name} = $action_handler  ;
		$self->{ACTIONS_BY_NAME}{ORIGINS}{$name}{ORIGIN} = $action_file ;
		
		if($remove_old_shortcuts)
			{
			for my $shortcut (keys %{$self->{ACTIONS}})
				{
				my $action = $self->{ACTIONS}{$shortcut} ;
				
				if($action->{IS_GROUP})
					{
					for my $group_shortcut (grep {'HASH' eq ref $action->{$_} } keys %$action)
						{
						if($action_handler->{IS_GROUP})
							{
							for my $group_action (grep {'HASH' eq ref $action_handler->{$_} } keys %$action_handler )
								{
								delete $action->{$group_shortcut} 
									if exists $action->{$group_shortcut} &&
										$action->{$group_shortcut}{NAME} eq $action_handler->{$group_action}{NAME} ;
								}
							}
						else
							{
							delete $action->{$group_shortcut} 
								if exists $action->{$group_shortcut} &&
									 $action->{$group_shortcut}{NAME} eq $action_handler->{NAME} ;
							}
						}
					}
				else
					{
					if($action_handler->{IS_GROUP})
						{
						for my $group_action (grep {'HASH' eq ref $action_handler->{$_} } keys %$action_handler )
							{
							delete $self->{ACTIONS}{$shortcut} 
								if exists $self->{ACTIONS}{$shortcut} &&
									$self->{ACTIONS}{$shortcut}{NAME} eq $action_handler->{$group_action}{NAME} ;
							}
						}
					else
						{
						delete $self->{ACTIONS}{$shortcut} 
							if $action->{NAME} eq $action_handler->{NAME} ;
						}
					}
				}
			}
		
		for my $shortcut ('ARRAY' eq ref $shortcuts_definition ? @$shortcuts_definition : ($shortcuts_definition))
			{
			if(exists $self->{ACTIONS}{$shortcut})
				{
				$self->{ACTION_VERBOSE}("Overriding shortcut '$shortcut'\n") ;
				$self->{ACTION_VERBOSE}("\tnew is '$name' defined in file '$setup_path/$action_file'\n") ;
				$self->{ACTION_VERBOSE}( "\told was '$self->{ACTIONS}{$shortcut}{NAME}' defined in file '$self->{ACTIONS}{$shortcut}{ORIGIN}'\n") ;
				}
				
			$self->{ACTIONS}{$shortcut} = $action_handler ;
			
			if (! defined $action_handler->{CODE} && ! defined $action_handler->{CONTEXT_MENU_SUB})
				{
				$self->{ACTION_VERBOSE}("\e[33mNo action for action_handler: '$name', file: '$setup_path/$action_file'\e[m\n") ;
				delete $self->{ACTIONS}{$shortcut} ;
				}
			
			$self->{ACTIONS}{$shortcut}{GROUP_NAME} = $group_name if defined $group_name ;
			}
		}
	}

$self->register_first_level_group(\%first_level_group) ;
}

#------------------------------------------------------------------------------------------------------

sub register_first_level_group
{
my ($self, $group_definition) = @_ ;

my %handler ;

for my $name ( grep { $_ ne 'SHORTCUTS' } keys %{$group_definition} )
	{
	die "Asciio: Group 'first_level' entry '$name' not defined\n" unless exists $self->{ACTIONS_BY_NAME}{$name} ;
	my $handler = $self->{ACTIONS_BY_NAME}{$name} ;

	for my $shortcut ('ARRAY' eq ref $handler->{SHORTCUTS} ? $handler->{SHORTCUTS}->@* : $handler->{SHORTCUTS}) 
		{
		$handler{$shortcut} = $handler
		}
	}

my $escape_keys = 'ARRAY' eq ref $group_definition->{ESCAPE_KEYS} ? $group_definition->{ESCAPE_KEYS} : [$group_definition->{ESCAPE_KEYS}//()] ;
my $shortcuts   = 'ARRAY' eq ref $group_definition->{SHORTCUTS}   ? $group_definition->{SHORTCUTS}   : [$group_definition->{SHORTCUTS}] ;

@handler{'IS_GROUP', 'ENTER_GROUP', 'ESCAPE_KEYS', 'SHORTCUTS', 'CODE', 'NAME', 'ORIGIN'} = 
	(
	1,
	$group_definition->{ENTER_GROUP},
	$escape_keys,
	$shortcuts,
	sub { $_[0]->{CURRENT_ACTIONS} = \%handler },
	'first_level_group',
	'action_file'
	) ;

my $name = $handler{SHORTCUTS}[0] ;

if (defined $name)
	{
	$self->{ACTIONS}{$name} = \%handler ;
	}
}

#------------------------------------------------------------------------------------------------------

sub check_action_by_name
{
my ($self, $setup_path, $action_file, $action_handler, $action_handlers) = @_ ;
my $name = $action_handler->{NAME} ;

if(exists $self->{ACTIONS_BY_NAME}{$name})
	{
	my $reused = '' ;
	$self->{ACTION_VERBOSE}("\e[33mOverriding action: '$name', file: '$action_file', old_file: '" . ($self->{ACTIONS_BY_NAME}{ORIGINS}{$name}{ORIGIN} // 'unknown'))
		if $self->{DISPLAY_SETUP_INFORMATION_ACTION} ;

	my $old_handler = $self->{ACTIONS_BY_NAME}{$name} ;
	
	if(! defined $action_handler->{SHORTCUTS}) 
		{
		die "\tno shortcuts in definition\n" ;
		}
	
	if(! defined $action_handler->{CODE} && defined $old_handler->{CODE}) 
		{
		$reused .= ", reused code" ;
		$action_handler->{CODE} = $old_handler->{CODE}  ;
		}
	
	if(! defined $action_handler->{ARGUMENTS} && defined $old_handler->{ARGUMENTS})
		{
		$reused .= ", reused arguments" ;
		$action_handler->{ARGUMENTS} = $old_handler->{ARGUMENTS}  ;
		}
	
	if(! defined $action_handler->{CONTEXT_MENU_SUB} && defined $old_handler->{CONTEXT_MENU_SUB})
		{
		$reused .= "reused context menu" ;
		$action_handler->{CONTEXT_MENU_SUB} = $old_handler->{CONTEXT_MENU_SUB}  ;
		}
		
	if(! defined $action_handler->{CONTEXT_MENU_ARGUMENTS} && defined $old_handler->{CONTEXT_MENU_ARGUMENTS}) 
		{
		$reused .= "reused contet menu arguments" ;
		$action_handler->{CONTEXT_MENU_ARGUMENTS} = $old_handler->{CONTEXT_MENU_ARGUMENTS}  ;
		}
	
	$self->{ACTION_VERBOSE}("$reused\e[m\n") ;
	}
}

#------------------------------------------------------------------------------------------------------

sub get_group_action_handler
{
my ($self, $setup_path, $action_file, $group_name, $group_definition) = @_ ;

die "Asciio: group '$group_name' is without shortcuts in '$action_file'.\n"
	unless exists $group_definition->{SHORTCUTS} ;

my %handler ;

my $escape_keys = 'ARRAY' eq ref $group_definition->{ESCAPE_KEYS} ? $group_definition->{ESCAPE_KEYS} : [ ($group_definition->{ESCAPE_KEYS} // ()) ] ;

for my $name (grep { $_ ne 'SHORTCUTS' && $_ ne 'ESCAPE_KEYS' } keys %{$group_definition})
	{
	my $action_handler ;
	
	my $shortcuts_definition ;
	if('HASH' eq ref $group_definition->{$name})
		{
		$shortcuts_definition = $group_definition->{$name}{SHORTCUTS}  ;
		$group_definition->{$name}{GROUP_NAME} = $name ;
		$group_definition->{$name}{ORIGIN} = $action_file  ;
		
		$action_handler = $self->get_group_action_handler($setup_path, $action_file, $name, $group_definition->{$name}) ;
		}
	elsif('ARRAY' eq ref $group_definition->{$name})
		{
		my %action_handler_hash ; # transform the definition from array into hash
		
		@action_handler_hash{'SHORTCUTS', 'CODE', 'ARGUMENTS', 'CONTEXT_MENU_SUB', 'CONTEXT_MENU_ARGUMENTS', 'NAME', 'ORIGIN'}
			 = @{$group_definition->{$name}} ;
		
		$shortcuts_definition = $action_handler_hash{SHORTCUTS}  ;
		$action_handler_hash{NAME} = $name ;
		$action_handler_hash{GROUP_NAME} = $group_name ;
		$action_handler_hash{ORIGIN} = $action_file ;
		
		$self->check_action_by_name($setup_path, $action_file, \%action_handler_hash, $group_definition) ;
		
		$action_handler = \%action_handler_hash ;
		}
	else
		{
		# print "ignoring '$name'\n"  ;
		next ;
		}
	
	$self->{ACTIONS_BY_NAME}{$name} = $action_handler  ;
	$self->{ACTIONS_BY_NAME}{ORIGINS}{$name}{ORIGIN} = "$action_file" ;
	
	for my $shortcut ('ARRAY' eq ref $shortcuts_definition ? @$shortcuts_definition : ($shortcuts_definition))
		{
		$self->{ACTION_VERBOSE}("Overriding action group '$shortcut' with definition from file '$setup_path/$action_file'!\n")
			if exists $handler{$shortcut} && $self->{DISPLAY_SETUP_INFORMATION_ACTION} ;
		
		# $self->{ACTION_VERBOSE}("\e[32maction_handler: '$name' shortcut: $shortcut\e[m\n") ;
		$handler{$shortcut} = $action_handler ;
		
		$handler{$shortcut}{GROUP_NAME} = $group_name if defined $group_name ;
		}
	}

@handler{'IS_GROUP', 'ENTER_GROUP', 'ESCAPE_KEYS', 'SHORTCUTS', 'CODE', 'NAME', 'ORIGIN'} = 
	(
	1,
	$group_definition->{ENTER_GROUP},
	$escape_keys,
	$group_definition->{SHORTCUTS},
	sub { $_[0]->{CURRENT_ACTIONS} = \%handler },
	$group_name,
	$action_file
	) ;

return \%handler ;
}

#------------------------------------------------------------------------------------------------------

sub setup_import_export_handlers
{
my($self, $setup_path, $import_export_files) = @_ ;

for my $import_export_file (@{ $import_export_files })
	{
	my $context = new Eval::Context() ;
	
	my %import_export_handlers ;
	$context->eval
		(
		REMOVE_PACKAGE_AFTER_EVAL => 0, # VERY IMPORTANT as we return code references that will cease to exist otherwise
		INSTALL_SUBS => {register_import_export_handlers => sub{%import_export_handlers = @_}},
		PRE_CODE => <<EOC ,
			use strict;
			use warnings;
		
EOC
		CODE_FROM_FILE => "$setup_path/$import_export_file",
		) ;
			
	die "Asciio: can't load import/export handler defintion file '$import_export_file': $! $@\n" if $@ ;
	
	for my $extension (keys %import_export_handlers)
		{
		if(exists $self->{IMPORT_EXPORT_HANDLERS}{$extension})
			{
			$self->{WARN}("Overriding import/export handler for extension '$extension' in file '$setup_path/$import_export_file'\n") ;
			}
			
		$self->{IMPORT_EXPORT_HANDLERS}{$extension} = $import_export_handlers{$extension}  ;
		}
	}
}

#------------------------------------------------------------------------------------------------------

sub setup_object_options
{
my($self, $setup_path, $options_files) = @_ ;

for my $options_file (@{ $options_files })
	{
	my $context = new Eval::Context() ;
	
	my %options = 
		$context->eval
			(
			PRE_CODE => "use strict;\nuse warnings;\n",
			CODE_FROM_FILE => "$setup_path/$options_file",
			) ;
	
	for my $option_name (sort keys %options)
		{
		$self->{$option_name} = $options{$option_name} ;
		}
	
	$self->{COLORS} = $options{COLOR_SCHEMES}{system} if exists $options{COLOR_SCHEMES}{system} ;
	
	die "Asciio: can't load setup file '$options_file': $! $@\n" if $@ ;
	}

$self->event_options_changed() ;
}

#------------------------------------------------------------------------------------------------------

1 ;

