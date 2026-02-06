
package App::Asciio ;

$|++ ;
binmode( STDOUT, ":encoding(UTF-8)" ) ; 
binmode( STDERR, ":encoding(UTF-8)" ) ; 

use strict;
use warnings;
use utf8 ;

use Carp ;
use Data::TreeDumper ;
use Eval::Context ;
use File::Basename ;
use File::Slurper qw(read_text write_text) ;
use File::Temp qw(tempfile) ;
use Module::Util qw(find_installed) ;
use Sub::Util qw(set_subname ) ;
use List::MoreUtils qw(none) ;

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

my @bindings ;

for my $setup_file (@{$setup_ini_files})
	{
	$self->{WARN}("Initializing with '$setup_file'\n") if $self->{DISPLAY_SETUP_INFORMATION} ;
	$self->{WARN}("Asciio: Warning: can't find setup data '$setup_file'\n") and next unless -e $setup_file ;
	
	push @{$self->{SETUP_PATHS}}, $setup_file ;
	
	my ($setup_name, $setup_path, $setup_ext) = File::Basename::fileparse($setup_file, ('\..*')) ;
	
	my $ini_files ;
	
	{
	my $context = new Eval::Context() ;
	$ini_files = $context->eval
				(
				PRE_CODE          => "use strict;\nuse warnings;\nuse utf8 ;\n",
				INSTALL_VARIABLES => [[ '$ASCIIO_UI'  => $self->{UI}]] ,
				CODE_FROM_FILE    => $setup_file,
				) ;
	
	$self->{WARN}("can't load '$setup_file': $! $@\n") if $@ ;
	}
	
	$self->setup_object_options($setup_path, $ini_files->{ASCIIO_OBJECT_SETUP} || []) ;
	if (defined $object_overrides)
		{
		while( my ($k, $v) = each $object_overrides->%* )
			{
			$self->{$k} = $v ;
			print "object_override $k => $v\n" if $self->{DISPLAY_SETUP_INFORMATION} ;
			}
		}
	
	$self->setup_stencils($setup_path, $ini_files->{STENCILS} || []) ;
	$self->setup_hooks($setup_path, $ini_files->{HOOK_FILES} || []) ;
	push @bindings, $self->setup_action_handlers($setup_path, $ini_files->{ACTION_FILES} || []) ;
	$self->setup_import_export_handlers($setup_path, $ini_files->{IMPORT_EXPORT} || []) ;
	}


$self->{ANIMATION}{TOP_DIRECTORY}     = "animations" if -e "animations" and -d "animations" ;
$self->{ANIMATION}{TOP_DIRECTORY}     = $self->{SCRIPTS_PATHS} if defined $self->{SCRIPTS_PATHS} ;
$self->{SCRIPTS_PATHS}              //= '.' ;
$self->{ANIMATION}{TOP_DIRECTORY}   //= $self->{SCRIPTS_PATHS} ;

my $slide_directory = "$self->{ANIMATION}{TOP_DIRECTORY}/" . ($self->{TITLE} // '') ;

$self->{ANIMATION}{SLIDE_DIRECTORY}   = $slide_directory if -e $slide_directory and -d $slide_directory ;
$self->{ANIMATION}{SLIDE_DIRECTORY} //= $self->{ANIMATION}{TOP_DIRECTORY} ;

return \@bindings ;
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
		INSTALL_SUBS              => {register_hooks => sub{@hooks = @_}},
		PRE_CODE                  => "use strict;\nuse warnings;\nuse utf8;\n",
		CODE_FROM_FILE            => "$setup_path/$hook_file" ,
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
my($self, $setup_path, $action_files, $from_code) = @_ ;

my $installed = find_installed('App::Asciio') ;
my ($basename, $path, $ext) = File::Basename::fileparse($installed, ('\..*')) ;
my $asciio_setup_path = $path . $basename . '/setup/' ;

my %bindings_by_file ;

for my $action_file (@{ $action_files })
	{
	my $context = new Eval::Context() ;
	
	my (%action_handlers, @context_menues, $remove_old_shortcuts) ;
	my (@root_groups, @proxy_groups, @groups) ;
	
	if($action_file =~ /^\Q$asciio_setup_path\E/)
		{
		$setup_path = $asciio_setup_path ;
		substr($action_file, 0, length("$asciio_setup_path/")) = '' 
		}
	
	my $location = $action_file =~ /^\// ? $action_file : "$setup_path/$action_file" ;
	
	my $use_group_sub = 
		sub 
		{ 
		my $group = shift ;
		my $sub = sub { $_[0]->use_action_group("group_$group") ; } ;
		bless $sub, "use_group_$group" ;
		set_subname( "App::Asciio::Actions::Group::$group", $sub ) ;
		return $sub ;
		} ;
	
	my $group_sub = sub { my $group = [@_] ; push @groups, $group ; return bless $group, 'action_group' ; } ;
	
	my $set_macro = 
		sub 
		{ 
		my $macro_commands = \@_ ;
		my $sub  = sub { $_[0]->run_macro($macro_commands) ; } ;
		set_subname("App::Asciio::Actions::Macro", $sub ) ;
		return $sub ;
		} ;
	
	$context->eval
		(
		REMOVE_PACKAGE_AFTER_EVAL => 0, # VERY IMPORTANT as we return code references that will cease to exist otherwise
		INSTALL_SUBS => {
				register_action_handlers               => sub { %action_handlers = @_ ; },
				register_action_handlers_with_override => sub { %action_handlers = @_ ; $remove_old_shortcuts++ ; },
				PROXY_GROUP                            => sub { push @proxy_groups, [@_] ; return () ; },
				ROOT_GROUP                             => sub { push @root_groups, [@_]  ; return () ; },
				GROUP                                  => $group_sub, 
				USE_GROUP                              => $use_group_sub,
				CONTEXT_MENU                           => sub { push @context_menues, [@_] ; return () ; },
				CAPTURE_KEYS                           => sub { return sub {} ; },
				MACRO                                  => $set_macro,
				},
		PRE_CODE => "use strict;\nuse warnings;\nuse utf8;\n",
		(defined $from_code ? (CODE => $from_code) : (CODE_FROM_FILE => $location)) ,
		) ;
	
	die "Asciio: can't load setup file '$action_file': $! $@\n" if $@ ;
	
	$bindings_by_file{$action_file} =
		{
		root_groups  => \@root_groups,
		proxy_groups => \@proxy_groups,
		groups       => \@groups,
		} ;
	
	my %reserved = map {$_ => 1} qw(SHORTCUTS HIDE ENTER_GROUP ESCAPE_KEYS ESCAPE_GROUP DESCRIPTION) ;
	
	for my $name (grep { ! exists $reserved{$_}} keys %action_handlers)
		{
		if('action_group' eq ref $action_handlers{$name})
			{
			unshift $action_handlers{$name}->@*, 'NAME' => $name ;
			}
		
		# print DumpTree $action_handlers{$name} ;
		$self->register_action($setup_path, $action_file, $remove_old_shortcuts, $name, $action_handlers{$name}) ;
		}
	
	$self->register_separator_group() ;
	
	for my $root_group ( @root_groups )
		{
		$self->register_root_group($setup_path, $action_file, $remove_old_shortcuts, $root_group->@*) ;
		}
	
	for my $proxy_group ( @proxy_groups )
		{
		$self->register_proxy_group($setup_path, $action_file, $proxy_group->@*) ;
		}
	
	for my $context_menu ( @context_menues )
		{
		$self->register_context_menu($context_menu) ;
		}
	}

return \%bindings_by_file ;
}

#------------------------------------------------------------------------------------------------------

sub register_root_group
{
my ($self, $setup_path, $action_file, $remove_old_shortcuts, $options, @group_definition) = @_ ;

my ($name, $description) = 'HASH' eq ref $options ? @{$options}{'NAME', 'DESCRIPTION'} : ($options, '') ;

my $i = 0 ;
while( ( my($name, $definition) = @group_definition[$i++,$i++] ), $i <= @group_definition)
	{
	$self->register_action($setup_path, $action_file, $remove_old_shortcuts, $name, $definition) ;
	}
}

#------------------------------------------------------------------------------------------------------

sub register_action
{
my ($self, $setup_path, $action_file, $remove_old_shortcuts, $name, $action_handler_definition) = @_ ;

my $action_handler ;

my $shortcuts_definition ;

if('action_group' eq ref $action_handler_definition || 'HASH' eq ref $action_handler_definition)
	{
	($shortcuts_definition, $action_handler) = $self->get_group_action_handler($setup_path, $action_file, $name, $action_handler_definition) ;
	}
elsif('ARRAY' eq ref $action_handler_definition)
	{
	my %action_handler_hash ; # transform the definition from array into hash
	@action_handler_hash{'SHORTCUTS', 'CODE', 'ARGUMENTS', 'OPTIONS', 'NAME', 'ORIGIN'}
		 = @$action_handler_definition ;
	$action_handler_hash{OPTIONS} //= {} ;
	
	$shortcuts_definition = $action_handler_hash{SHORTCUTS}  ;
	$action_handler_hash{NAME} = $name ;
	$action_handler_hash{ORIGIN} = $action_file ;
	
	$self->check_action_by_name($setup_path, $action_file, \%action_handler_hash) ;
	
	$action_handler = \%action_handler_hash ;
	}
else
	{
	$self->{ACTION_VERBOSE}("register_action: ignoring '$name'\n") ;
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
		$self->{ACTION_VERBOSE}("\e[33mNo action for action_handler: '$name', file: '$setup_path/$action_file'\e[0m\n") ;
		delete $self->{ACTIONS}{$shortcut} ;
		}
	}
}

#------------------------------------------------------------------------------------------------------

sub register_proxy_group
{
my ($self, $setup_path, $action_file, $options, @group_definition) = @_ ;

my ($shortcuts, $hide) = 'HASH' eq ref $options ? @{$options}{'SHORTCUTS', 'HIDE'} : ($options, 0) ;

my %group_handler ;

for my $name ( @group_definition )
	{
	my $action_shortcuts ;
	
	if('ARRAY' eq ref $name)
		{
		$action_shortcuts = $name->[1] ;
		$name             = $name->[0] ;
		}
	
	die "Asciio: Top level group entry '$name' not defined\n" unless exists $self->{ACTIONS_BY_NAME}{$name} ;
	
	my $handler = $self->{ACTIONS_BY_NAME}{$name} ;
	
	push $self->{ACTIONS_ORDERED}{"proxy_$shortcuts"}->@*, $handler ;
	
	$action_shortcuts //= $handler->{SHORTCUTS} ;
	
	for my $shortcut ('ARRAY' eq ref $action_shortcuts ? $action_shortcuts->@* : $action_shortcuts) 
		{
		$group_handler{$shortcut} = $handler ;
		}
	}

my $group_handler = sub { $_[0]->{CURRENT_ACTIONS} = \%group_handler ; } ;
set_subname( "App::Asciio::Actions::Group::top_level", $group_handler ) ;

@group_handler{'HIDE', 'IS_GROUP', 'ENTER_GROUP', 'ESCAPE_KEYS', 'SHORTCUTS', 'CODE', 'NAME', 'ORIGIN'} = 
	(
	$hide,
	1,
	undef,
	undef,
	('ARRAY' eq ref $shortcuts  ? $shortcuts  : [$shortcuts]),
	$group_handler,
	"proxy_$shortcuts",
	$action_file,
	) ;

$self->{ACTIONS}{$_} = \%group_handler for $group_handler{SHORTCUTS}->@* ;
}

#------------------------------------------------------------------------------------------------------

sub check_action_by_name
{
my ($self, $setup_path, $action_file, $action_handler) = @_ ;
my $name = $action_handler->{NAME} ;

if(exists $self->{ACTIONS_BY_NAME}{$name})
	{
	if(! defined $action_handler->{SHORTCUTS}) 
		{
		die "\tno shortcuts in definition\n" ;
		}
	
	$self->{ACTION_VERBOSE}("\e[33mOverriding action: '$name', file: '$action_file', old_file: '" . ($self->{ACTIONS_BY_NAME}{ORIGINS}{$name}{ORIGIN} // 'unknown') . "\e[0m" )
		if $self->{DISPLAY_SETUP_INFORMATION_ACTION} ;
	
	my $shortcuts = '' eq ref $action_handler->{SHORTCUTS} ? [$action_handler->{SHORTCUTS}] : $action_handler->{SHORTCUTS} ;
	
	$self->{ACTION_VERBOSE}("\e[33m" . DumpTree($shortcuts, 'shortcuts:', DISPLAY_CALLER_LOCATION => 0) . "\e[0m")
		if $self->{DISPLAY_SETUP_INFORMATION_ACTION} ;
	
	my $reused = '' ;
	my $old_handler = $self->{ACTIONS_BY_NAME}{$name} ;
	
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
	
	$self->{ACTION_VERBOSE}("$reused\e[0m\n") if $reused ne '' ;
	}
}

#------------------------------------------------------------------------------------------------------

sub get_group_action_handler
{
my ($self, $setup_path, $action_file, $group_name, $group_definition) = @_ ;

my %handler ;

my ($shortcuts, $enter_group, $escape_keys, $escape_group, $hide, $description) ;

if('action_group' eq ref $group_definition)
	{
	die "Asciio: group '$group_name': odd number of elements \n" if $group_definition->@* % 1 ;
	
	my %group_definition = $group_definition->@* ;
	
	die "Asciio: group '$group_name' is without shortcuts in '$action_file'.\n"
		unless exists $group_definition{SHORTCUTS} ;
	
	$escape_keys  = 'ARRAY' eq ref $group_definition{ESCAPE_KEYS} ? $group_definition{ESCAPE_KEYS} : [ ($group_definition{ESCAPE_KEYS} // ()) ] ;
	$enter_group  = $group_definition{ENTER_GROUP} ;
	$escape_group = $group_definition{ESCAPE_GROUP} ;
	$shortcuts    = $group_definition{SHORTCUTS} ;
	$hide         = $group_definition{HIDE} ;
	$description  = $group_definition{DESCRIPTION} ;
	
	$self->{ACTIONS_ORDERED}{$group_name} = [] ; # reset if overridden 
	
	my %reserved = map {$_ => 1} qw(NAME SHORTCUTS HIDE ENTER_GROUP ESCAPE_KEYS ESCAPE_GROUP DESCRIPTION) ;
	
	my $i = 0 ;
	while( ( my($name, $setup) = ($group_definition->[$i++], $group_definition->[$i++])), $i <= $group_definition->@*)
		{
		next if exists $reserved{$name} ;
		
		my $shortcuts_definition ;
		my $action_handler ;
		
		if('action_group' eq ref $setup)
			{
			($shortcuts_definition, $action_handler) = $self->get_group_action_handler($setup_path, $action_file, $name, $setup) ;
			}
		elsif('ARRAY' eq ref $setup)
			{
			my %action_handler_hash ; # transform the definition from array into hash
			
			@action_handler_hash{'SHORTCUTS', 'CODE', 'ARGUMENTS', 'OPTIONS', 'NAME', 'ORIGIN'}
				 = @$setup ;
			
			$action_handler_hash{OPTIONS} //= {} ;
			
			if($hide)
				{
				$action_handler_hash{OPTIONS}{HIDE} = $hide unless exists $action_handler_hash{OPTIONS}{HIDE} ;
				}
			
			$shortcuts_definition = $action_handler_hash{SHORTCUTS}  ;
			$action_handler_hash{NAME} = $name ;
			$action_handler_hash{ORIGIN} = $action_file ;
			
			$self->check_action_by_name($setup_path, $action_file, \%action_handler_hash) ;
			
			$action_handler = \%action_handler_hash ;
			}
		else
			{
			$self->{ACTION_VERBOSE}("get_group_action_handler: ignoring '$name'\n") ;
			next ;
			}
		
		$self->{ACTIONS_BY_NAME}{$name} = $action_handler  ;
		$self->{ACTIONS_BY_NAME}{ORIGINS}{$name}{ORIGIN} = $action_file ;
		
		for my $shortcut ('ARRAY' eq ref $shortcuts_definition ? @$shortcuts_definition : ($shortcuts_definition))
			{
			$self->{ACTION_VERBOSE}("1 Overriding action group '$shortcut' with definition from file '$setup_path/$action_file'!\n")
				if exists $handler{$shortcut} && $self->{DISPLAY_SETUP_INFORMATION_ACTION} ;
			
			# $self->{ACTION_VERBOSE}("\e[32maction_handler: '$name' shortcut: $shortcut\e[0m\n") ;
			$handler{$shortcut} = $action_handler ;
			
			$handler{$shortcut}{GROUP_NAME} = $group_name if defined $group_name ;
			
			push $self->{ACTIONS_ORDERED}{$group_name}->@*, $action_handler ;
			
			$handler{$shortcut}{GROUP_NAME} = $group_name ;
			}
		}
	}

my $group_handler = sub { $_[0]->{CURRENT_ACTIONS} = \%handler ; } ;
set_subname( "App::Asciio::Actions::Group::$group_name", $group_handler ) ;

@handler{'IS_GROUP', 'DESCRIPTION', 'HIDE', 'ENTER_GROUP', 'ESCAPE_KEYS', 'ESCAPE_GROUP', 'SHORTCUTS', 'CODE', 'NAME', 'ORIGIN'} = 
	(
	1,
	$description,
	$hide,
	$enter_group,
	$escape_keys,
	$escape_group,
	$shortcuts,
	$group_handler,
	$group_name,
	$action_file
	) ;

return $shortcuts, \%handler ;
}

#------------------------------------------------------------------------------------------------------

sub register_context_menu
{
my ($self, $context_menu)  = @_ ;

$self->{ACTIONS}{$context_menu->[0]} =
	{
	IS_GROUP              => 0,
	ENTER_GROUP           => undef,
	ESCAPE_KEYS           => undef,
	ESCAPE_GROUP          => undef,
	SHORTCUTS             => $context_menu->[1],
	CODE                  => undef,
	NAME                  => $context_menu->[0],
	ORIGIN                => 'internal',
	CONTEXT_MENU_SUB      => $context_menu->[2],
	CONTEXT_MENU_ARGUMENT => $context_menu->[3],
	}
}

#------------------------------------------------------------------------------------------------------

sub register_separator_group
{
$_[0]->register_action
	(
	'',
	'',
	0,
	' ', 
	[
	NAME  => 'separator',
	SHORTCUTS  => '',
	DESCRIPTION  => 'group separator',
	]) ;

$_[0]->{ACTIONS_BY_NAME}{' '} = 
	{
	IS_GROUP     => 1,
	DESCRIPTION  => '',
	ENTER_GROUP  => undef,
	ESCAPE_KEYS  => undef,
	ESCAPE_GROUP => undef,
	SHORTCUTS    => [''],
	CODE         => sub {},
	NAME         => ' ',
	ORIGIN       => 'internal',
	} ;
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
		INSTALL_SUBS              => {register_import_export_handlers => sub{%import_export_handlers = @_}},
		PRE_CODE                  => <<EOC ,
						use strict;
						use warnings;
						use utf8 ;
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
	
	my %options = $context->eval
				(
				PRE_CODE       => "use strict;\nuse warnings;\nuse utf8;\n",
				CODE_FROM_FILE => "$setup_path/$options_file",
				) ;
	
	for my $option_name (sort keys %options)
		{
		$self->{$option_name} = $options{$option_name} ;
		print "$option_name => $options{$option_name}\n" if $self->{DISPLAY_SETUP_INFORMATION} ;
		}
	
	$self->{COLORS} = $options{COLOR_SCHEMES}{system} if exists $options{COLOR_SCHEMES}{system} ;
	
	die "Asciio: can't load setup file '$options_file': $! $@\n" if $@ ;
	}

$self->event_options_changed() ;
}

#------------------------------------------------------------------------------------------------------

sub setup_embedded_bindings
{
my ($asciio, $asciio_config) = @_ ;

for my $file ($asciio_config->{BINDING_FILES}->@*)
	{
	print STDERR "Asciio: adding binding '$file' to document\n" ;
	
	my $code = read_text($file) ;
	
	$asciio->setup_action_handlers
		(
		'file',
		["EMBEDDED_$file"], # can only pass one "file" at a time when evaluating perl code
		$code
		) ;
	
	push $asciio->{EMBEDDED_BINDINGS}->@*,
			{
			NAME => "EMBEDDED_$file",
			CODE => $code,
			DATE => scalar localtime(),
			} ;
	}

if(defined $asciio_config->{RESET_BINDINGS})
	{
	delete $asciio->{EMBEDDED_BINDINGS} ;
	$asciio->run_actions_by_name(['Save']) ;
	print STDERR "Asciio: reset embedded bindings\n" ;
	exit ;
	}

if(defined $asciio_config->{DUMP_BINDING_NAMES})
	{
	for my $binding ($asciio->{EMBEDDED_BINDINGS}->@*)
		{
		print STDERR "Asciio: using binding '$binding->{NAME}' from $binding->{DATE}\n" ;
		}
	}

if(defined $asciio_config->{DUMP_BINDINGS})
	{
	for my $binding ($asciio->{EMBEDDED_BINDINGS}->@*)
		{
		my $binding_dump_file = (tempfile())[1] ;
		
		print STDERR "Asciio: writing binding '$binding->{NAME}' from $binding->{DATE} to '$binding_dump_file'\n" ;
		write_text($binding_dump_file, $binding->{CODE}) ;
		}
	}
}

#------------------------------------------------------------------------------------------------------

1 ;

