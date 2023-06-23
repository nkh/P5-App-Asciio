
package App::Asciio ;

$|++ ;

use strict;
use warnings;

use Data::TreeDumper ;
use File::Slurp ;
use Readonly ;
use Compress::Bzip2 qw(:all :utilities :gzip);

use Sereal qw(
    get_sereal_decoder
    get_sereal_encoder
    clear_sereal_object_cache
 
    encode_sereal
    decode_sereal
) ;
use Sereal::Encoder qw(SRL_SNAPPY SRL_ZLIB SRL_ZSTD) ;

#-----------------------------------------------------------------------------

sub load_file
{
my ($self, $file_name)  = @_;

return unless defined $file_name ;

my ($base_name, $path, $extension) = File::Basename::fileparse($file_name, ('\..*')) ;
$extension =~ s/^\.// ;

my $type = $extension ne q{} ? $extension : 'internal_asciio_format';

my $title ;

if
	(
	exists $self->{IMPORT_EXPORT_HANDLERS}{$type}{IMPORT} 
	&& defined $self->{IMPORT_EXPORT_HANDLERS}{$type}{IMPORT}
	)
	{
	my ($saved_self, $handler_data) ;
	
	($saved_self, $title, $handler_data) =
		$self->{IMPORT_EXPORT_HANDLERS}{$type}{IMPORT}->
			(
			$self,
			$file_name,
			) ;
	
	$self->load_self($saved_self) ; # resurrect from mummified
	$self->{IMPORT_EXPORT_HANDLERS}{HANDLER_DATA} = $handler_data ;
	}
else
	{
	if(-e $file_name && -s $file_name)
		{
		my $serialized_self = decompress(read_file($file_name)) ;
		my $decoder = get_sereal_decoder() ;
		my $saved_self = $serialized_self = $decoder->decode($serialized_self) ;
		
		if($@)
			{
			write_file("failed_resurection_source.pl", {binmode => ':utf8'}, $serialized_self) ;
			die "load_file: can't load file '$file_name': $! $@\n" ;
			}
		
		$self->load_self($saved_self) ; # resurrect
		delete $self->{IMPORT_EXPORT_HANDLERS}{HANDLER_DATA} ;
		delete $self->{CACHE} ;
		
		$title = $file_name ;
		}
	else
		{
		my $element = $self->add_new_element_named('Asciio/box', 0, 0) ;
		my $box_type = $element->get_box_type() ;
		$box_type->[1][0] = 1 ; # title separator
		$element->set_box_type($box_type) ;
		
		$element->set_text('Warning!', "'$file_name' has no content.");
		
		$self->select_elements(1, $element) ;
		$self->update_display() ;
		
		$title = $file_name ;
		}
	}

return $title ;
}

#-----------------------------------------------------------------------------

Readonly my  @ELEMENTS_TO_KEEP_AWAY_FROM_CURRENT_OBJECT => 
	qw
		(
		widget
		root_window
		sc_window
		ACTIONS CURRENT_ACTIONS ACTIONS_BY_NAME
		HOOKS IMPORT_EXPORT_HANDLERS
		TITLE
		ELEMENT_TYPES_BY_NAME
		ELEMENT_TYPES
		MIDDLE_BUTTON_SELECTION_FILTER
		CACHE
		COLORS
		ACTION_VERBOSE
		DO_STACK_POINTER DO_STACK
		) ;

sub load_self
{
my ($self, $new_self)  = @_;

return unless defined $new_self ;

delete @{$new_self}{@ELEMENTS_TO_KEEP_AWAY_FROM_CURRENT_OBJECT} ;

my @keys = keys %{$new_self} ;
@{$self}{@keys} = @{$new_self}{@keys} ;
}

#-----------------------------------------------------------------------------

sub load_elements
{
my ($self, $file_name, $path)  = @_;

return unless defined $file_name ;

my $elements = do $file_name or die "can't load file '$file_name': $! $@\n" ;
$path = '' unless defined $path ;

for my $new_element (@{$elements})
	{
	my $new_element_type = ref $new_element or die "element without type in file '$file_name'!" ;
	
	unless(exists $self->{LOADED_TYPES}{$new_element_type})
		{
		eval "use $new_element_type" ;
		die "Error loading type '$new_element_type' :$@" if $@ ;
		
		$self->{LOADED_TYPES}{$new_element_type}++ ;
		}
	
	my $next_element_type_index = @{$self->{ELEMENT_TYPES}} ;
	
	$new_element->{NAME} = "$path/$new_element->{NAME}" ;
	$new_element->{NAME} =~ s~/+~/~g ;
	$new_element->{NAME} =~ s~^/~~g ;
	
	if(exists $new_element->{NAME})
		{
		if(exists $self->{ELEMENT_TYPES_BY_NAME}{$new_element->{NAME}})
			{
			print "Overriding element type '$new_element->{NAME}'!\n" ;
			$self->{ELEMENT_TYPES}[$self->{ELEMENT_TYPES_BY_NAME}{$new_element->{NAME}}]
				= $new_element ;
			}
		else
			{
			$self->{ELEMENT_TYPES_BY_NAME}{$new_element->{NAME}} = $next_element_type_index ;
			push @{$self->{ELEMENT_TYPES}}, $new_element ;
			
			$next_element_type_index++ ;
			}
		}
		
	if(exists $new_element->{X})
		{
		push @{$self->{ELEMENTS}}, $new_element ;
		}
	}
}

#-----------------------------------------------------------------------------

sub save_stencil
{
my ($self) = @_ ;

my $name = $self->display_edit_dialog('stencil name', '', $self) ;

if(defined $name && $name ne q[])
	{
	my $file_name = $self->get_file_name('save') ;
	
	if(defined $file_name && $file_name ne q[])
		{
		if(-e $file_name)
			{
			my $override = $self->display_yes_no_cancel_dialog
						(
						"Override file!",
						"File '$file_name' exists!\nOverride file?"
						) ;
						
			$file_name = undef unless $override eq 'yes' ;
			}
		}
	
	if(defined $file_name && $file_name ne q[])
		{
		use Data::Dumper ;
		my ($element) = $self->get_selected_elements(1) ;
		
		my $cache = $element->{CACHE} ;
		delete $element->{CACHE} ;
		
		my $stencil = Clone::clone($element) ;
		
		$element->{CACHE} = $cache ;
		
		delete $stencil->{X} ;
		delete $stencil->{Y} ;
		$stencil->{NAME} = $name;
		
		write_file($file_name, {binmode => ':utf8'}, Dumper [$stencil]) ;
		}
	}
}

#-----------------------------------------------------------------------------

sub serialize_self
{
my ($self, $indent) = @_ ;

local $self->{widget} = undef ;
local $self->{ACTIONS} = [] ;
local $self->{HOOKS} = [] ;
local $self->{CURRENT_ACTIONS} = [] ;
local $self->{ACTIONS_BY_NAME} = [] ;
local $self->{DO_STACK} = undef ;
local $self->{DO_STACK_POINTER} = undef ;
local $self->{IMPORT_EXPORT_HANDLERS} = undef ;
local $self->{MODIFIED} => 0 ;
local $self->{TITLE} = '' ;
local $self->{CREATE_BACKUP} = undef ;
local $self->{MIDDLE_BUTTON_SELECTION_FILTER} = undef ;
local $self->{ELEMENT_TYPES} = undef ;
local $self->{ELEMENT_TYPES_BY_NAME} = undef ;
local $self->{ACTION_VERBOSE} = undef ;

my @elements_cache ;
for my $element (@{$self->{ELEMENTS}}) 
	{
	push @elements_cache, [$element, $element->{CACHE}] ;
	$element->{CACHE} = undef ;
	}

$self->{CACHE}{ENCODER} = my $encoder = $self->{CACHE}{ENCODER} // get_sereal_encoder({compress => SRL_ZLIB}) ;
local $self->{CACHE} = undef ;

my $serialized = $encoder->encode($self) ;

$_->[0]{CACHE} = $_->[1] for @elements_cache ;

return $serialized ;
}

#-----------------------------------------------------------------------------

sub save_with_type
{
my ($self, $elements_to_save, $type, $file_name) = @_ ;

my $title ;

if
	(
	exists $self->{IMPORT_EXPORT_HANDLERS}{$type}{EXPORT} 
	&& defined $self->{IMPORT_EXPORT_HANDLERS}{$type}{EXPORT}
	)
	{
	$title = $self->{IMPORT_EXPORT_HANDLERS}{$type}{EXPORT}->
			(
			$self,
			$elements_to_save,
			$file_name,
			$self->{IMPORT_EXPORT_HANDLERS}{HANDLER_DATA},
			) ;
	}
else
	{
	if($self->{CREATE_BACKUP} && -e $file_name)
		{
		use File::Copy;
		copy($file_name,"$file_name.bak") or die "save_with_type: Copy failed while making backup copy: $!" ;
		}
		
	$title = $file_name ;
	write_file($file_name, compress($self->serialize_self() .'$VAR1 ;')) or $title = undef ;
	}
	
return $title ;
}

#-----------------------------------------------------------------------------

1 ;
