
package App::Asciio ;

$|++ ;

use strict;
use warnings;

use Data::TreeDumper ;
use Eval::Context ;
use Carp ;
use Module::Util qw(find_installed) ;
use File::Basename ;

#------------------------------------------------------------------------------------------------------

sub setup
{
my($self, $setup_ini_files) = @_ ;

for my $setup_file (@{$setup_ini_files})
	{
	print "Initializing with '$setup_file'\n" if $self->{DISPLAY_SETUP_INFORMATION};
	warn "Asciio: Warning: can't find setup data '$setup_file'\n" and next unless -e $setup_file ;
	
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
	
	warn "can't load '$setup_file': $! $@\n" if $@ ;
	}
	
	$self->setup_object_options($setup_path, $ini_files->{ASCIIO_OBJECT_SETUP} || []) ;
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
			print "loading stencil '$setup_path/$stencil'\n" if $self->{DISPLAY_SETUP_INFORMATION} ;
			$self->load_elements("$setup_path/$stencil", $stencil) ;
			}
		elsif(-d "$setup_path/$stencil")
			{
			for(glob("$setup_path/$stencil/*"))
				{
				print "batch loading stencil '$setup_path/$stencil/$_'\n" if $self->{DISPLAY_SETUP_INFORMATION} ;
				$self->load_elements($_, $stencil) ;
				}
			}
		else
			{
			print "Unknown type '$setup_path/$stencil'!\n" ;
			}
		}
	else
		{
		print "Can't find '$setup_path/$stencil'!\n" ;
		}
	}
}

#------------------------------------------------------------------------------------------------------

my Readonly $CATEGORY = 0 ;
my Readonly $SHORTCUTS = 0 ;
my Readonly $CODE = 1 ;
my Readonly $ARGUMENTS = 2 ;
my Readonly $CONTEXT_MENU_SUB = 3;
my Readonly $CONTEXT_MENU_ARGUMENTS = 4 ;
my Readonly $NAME= 5 ;
my Readonly $ORIGIN= 6 ;

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
	
	die "can't load hook file '$hook_file ': $! $@\n" if $@ ;
	
	for my $hook (@hooks)
		{
		$self->{HOOKS}{$hook->[$CATEGORY]} =  $hook->[$CODE] ;
		}
	}
}

#------------------------------------------------------------------------------------------------------

sub setup_action_handlers
{
my($self, $setup_path, $action_files) = @_ ;

for my $action_file (@{ $action_files })
	{
	my $context = new Eval::Context() ;
	
	my %action_handlers;
	
	$context->eval
		(
		REMOVE_PACKAGE_AFTER_EVAL => 0, # VERY IMPORTANT as we return code references that will cease to exist otherwise
		INSTALL_SUBS => {register_action_handlers => sub{%action_handlers = @_}},
		PRE_CODE => "use strict;\nuse warnings;\n",
		CODE_FROM_FILE => "$setup_path/$action_file",
		) ;
	
	die "can't load setup file '$action_file': $! $@\n" if $@ ;
	
	for my $name (keys %action_handlers)
		{
		
		my $action_handler ;
		my $group_name ;
		
		my $shortcuts_definition ;
		if('HASH' eq ref $action_handlers{$name})
			{
			# print "\e[31maction_handler: '$name' is group\e[m\n" ;
			$shortcuts_definition = $action_handlers{$name}{SHORTCUTS}  ;
			$action_handlers{$name}{GROUP_NAME} = $group_name = $name ;
			$action_handlers{$name}{ORIGIN} = $action_file ;
			
			$action_handler = $self->get_group_action_handler($setup_path, $action_file, $name, \%action_handlers) ;
			}
		elsif('ARRAY' eq ref $action_handlers{$name})
			{
			$self->check_action_by_name($setup_path, $action_file, $name, \%action_handlers) ;
			
			$shortcuts_definition= $action_handlers{$name}[$SHORTCUTS]  ;
			$action_handlers{$name}[$NAME] = $name ;
			$action_handlers{$name}[$ORIGIN] = $action_file ;
			
			$action_handler = $action_handlers{$name} ;
			}
		else
			{
			# print "ignoring '$name'\n"  ;
			next ;
			}
			
		$self->{ACTIONS_BY_NAME}{$name} = $action_handler  ;
		$self->{ACTIONS_BY_NAME}{ORIGINS}{$name}{ORIGIN} = $action_file ;
		
		my $shortcuts ;
		if('ARRAY' eq ref $shortcuts_definition)
			{
			$shortcuts = $shortcuts_definition  ;
			}
		else
			{
			$shortcuts = [$shortcuts_definition]  ;
			}
		
		for my $shortcut (@$shortcuts)
			{
			if(exists $self->{ACTIONS}{$shortcut})
				{
				print "Overriding shortcut '$shortcut'\n" ;
				print "\tnew is '$name' defined in file '$setup_path/$action_file'\n" ;
				print "\told was '$self->{ACTIONS}{$shortcut}[$NAME]' defined in file '$self->{ACTIONS}{$shortcut}[$ORIGIN]'\n" ;
				}
				
			# print "\e[32maction_handler: '$name', file: '$setup_path/$action_file'\e[m\n" ;
			$self->{ACTIONS}{$shortcut} = $action_handler ;
			
			if ('ARRAY' eq ref $action_handler)
				{
				if (! defined $action_handler->[$CODE] && ! defined $action_handler->[$CONTEXT_MENU_SUB])
					{
					print "\e[32mNo action for action_handler: '$name', file: '$setup_path/$action_file'\e[m\n" ;
					delete $self->{ACTIONS}{$shortcut} ;
					}
				}
			
			if(defined $group_name)
				{
				$self->{ACTIONS}{$shortcut}{GROUP_NAME} = $group_name ;
				$self->{ACTIONS}{$shortcut}{ORIGIN} = $action_file ;
				}
			}
		}
	}

# use IO::Prompter ; $a = prompt -1, 'Finished registering actions ...' ;
}

sub check_action_by_name
{
my ($self, $setup_path, $action_file, $name, $action_handlers) = @_ ;

if(exists $self->{ACTIONS_BY_NAME}{$name})
	{
	print "\e[33mOverriding action: '$name', file: '$action_file', old_file: '" . ($self->{ACTIONS_BY_NAME}{ORIGINS}{$name}{ORIGIN} // 'unknown') ;
	
	my $new_handler = $action_handlers->{$name} ;
	my $old_handler = $self->{ACTIONS_BY_NAME}{$name} ;
	
	if(! defined $new_handler->[$SHORTCUTS]) 
		{
		die "\tno shortcuts in definition\n" ;
		}
	
	my $reused = '' ;
	if(! defined $new_handler->[$CODE] && defined $old_handler->[$CODE]) 
		{
		$reused .= ", reused code" ;
		$new_handler->[$CODE] = $old_handler->[$CODE]  ;
		}
	
	if(! defined $new_handler->[$ARGUMENTS] && defined $old_handler->[$ARGUMENTS]) 
		{
		$reused .= ", reused arguments" ;
		$new_handler->[$ARGUMENTS] = $old_handler->[$ARGUMENTS]  ;
		}
	
	if(! defined $new_handler->[$CONTEXT_MENU_SUB] && defined $old_handler->[$CONTEXT_MENU_SUB]) 
		{
		$reused .= "reused context menu" ;
		$new_handler->[$CONTEXT_MENU_SUB] = $old_handler->[$CONTEXT_MENU_SUB]  ;
		}
		
	if(! defined $new_handler->[$CONTEXT_MENU_ARGUMENTS] && defined $old_handler->[$CONTEXT_MENU_ARGUMENTS]) 
		{
		$reused .= "reused contet menu arguments" ;
		$new_handler->[$CONTEXT_MENU_ARGUMENTS] = $old_handler->[$CONTEXT_MENU_ARGUMENTS]  ;
		}
	
	print "$reused\e[m\n" ;
	}
}

sub get_group_action_handler
{
my ($self, $setup_path, $action_file, $name, $action_handlers) = @_ ;

my $action_handler_definition = $action_handlers->{$name} ;
my %handler ;

for my $name (keys %{$action_handler_definition})
	{
	my $action_handler ;
	my $group_name ;
	
	my $shortcuts_definition ;
	if('SHORTCUTS' eq $name)
		{
		# print "Found shortcuts definition.\n" ;
		next ;
		}
	elsif('HASH' eq ref $action_handler_definition->{$name})
		{
		$shortcuts_definition= $action_handler_definition->{$name}{SHORTCUTS}  ;
		$action_handler_definition->{$name}{GROUP_NAME} = $group_name = $name ;
		$action_handler_definition->{$name}{ORIGIN} = $action_file  ;
		
		$action_handler = $self->get_group_action_handler($setup_path, $action_file, $name, $action_handler_definition) ;
		}
	elsif('ARRAY' eq ref $action_handler_definition->{$name})
		{
		$self->check_action_by_name($setup_path, $action_file, $name, $action_handler_definition) ;
		
		$shortcuts_definition = $action_handler_definition->{$name}[$SHORTCUTS]  ;
		$action_handler_definition->{$name}[$NAME] = $name ;
		$action_handler_definition->{$name}[$ORIGIN] = $action_file  ;
		
		$action_handler = $action_handler_definition->{$name} ;
		}
	else
		{
		# print "ignoring '$name'\n"  ;
		next ;
		}
	
	$self->{ACTIONS_BY_NAME}{$name} = $action_handler  ;
	$self->{ACTIONS_BY_NAME}{ORIGINS}{$name}{ORIGIN} = "$action_file" ;
	
	my $shortcuts ;
	if('ARRAY' eq ref $shortcuts_definition)
		{
		$shortcuts = $shortcuts_definition  ;
		}
	else
		{
		$shortcuts = [$shortcuts_definition]  ;
		}
	
	for my $shortcut (@$shortcuts)
		{
		if(exists $handler{$shortcut})
			{
			print "Overriding action group '$shortcut' with definition from file '$setup_path/$action_file'!\n" ;
			}
		
		# print "\e[32maction_handler: '$name', file: '$setup_path/$action_file'\e[m\n" ;
		$handler{$shortcut} =  $action_handler ;
		
		if(defined $group_name)
			{
			$handler{$shortcut}{GROUP_NAME} = $group_name ;
			}
		}
	}

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
			
	die "can't load import/export handler defintion file '$import_export_file': $! $@\n" if $@ ;
	
	for my $extension (keys %import_export_handlers)
		{
		if(exists $self->{IMPORT_EXPORT_HANDLERS}{$extension})
			{
			print "Overriding import/export handler for extension '$extension' in file '$setup_path/$import_export_file'\n" ;
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
	
	for my $option_name (keys %options)
		{
		$self->{$option_name} = $options{$option_name} ;
		}
	
	$self->{COLORS} = $options{COLOR_SCHEMES}{system} ;
	
	die "can't load setup file '$options_file': $! $@\n" if $@ ;
	}

$self->event_options_changed() ;
}

#------------------------------------------------------------------------------------------------------

sub run_script
{
my($self, $script) = @_ ;

if(defined $script)
	{
	my $context = new Eval::Context() ;
	
	$context->eval
		(
		PRE_CODE => "use strict;\nuse warnings;\n",
		CODE_FROM_FILE => $script,
		INSTALL_VARIABLES =>
			[ 
			[ '$self' => $self => $Eval::Context::SHARED ],
			] ,
		) ;
	
	die "can't load setup file '$script': $! $@\n" if $@ ;
	}
}

#------------------------------------------------------------------------------------------------------

1 ;

