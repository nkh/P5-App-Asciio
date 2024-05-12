
package App::Asciio ;

$|++ ;

use strict;
use warnings;

my $ASCIIO_MIME_TYPE = "application/x-asciio" ;

use Data::TreeDumper ;
use File::Slurp ;
use Readonly ;
use Clone ;
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

my $asciio = $self ;

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
		my $header_diagram  = read_file($file_name) ;
		
		my $magic           = substr($header_diagram, 0, length($ASCIIO_MIME_TYPE)) ;
		my $diagram         = $magic eq $ASCIIO_MIME_TYPE ? substr($header_diagram, length($ASCIIO_MIME_TYPE)) : $header_diagram ;
		
		my $serialized_self = decompress($diagram) ;
		my $decoder         = get_sereal_decoder() ;
		my $saved_self      = $serialized_self = $decoder->decode($serialized_self) ;
		
		if($@)
			{
			write_file("failed_resurection_source.pl", {binmode => ':utf8'}, $serialized_self) ;
			die "load_file: can't load file '$file_name': $! $@\n" ;
			}
		
		$asciio = $self->load_all_self($saved_self) ; # resurrect
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

return ($title, $asciio) ;
}

#-----------------------------------------------------------------------------

Readonly my  @ELEMENTS_TO_KEEP_AWAY_FROM_CURRENT_OBJECT => 
	qw
		(
		widget
		root_window
		sc_window
		notebook
		label
		asciios
		asciio_argv
		event_handlers
		is_need_focus_in
		seen_elements
		format_painter
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
		GIT_MODE_CONNECTOR_CHAR_LIST
		PEN_MODE_CHARS_SETS
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
sub load_all_self
{
my ($self, $new_self)  = @_;

my @asciios = (ref($new_self) eq 'ARRAY') ? @{$new_self} : ($new_self);

my $decoder = get_sereal_decoder() ;
my $new_asciio = $self ;
my $is_not_first_self = 0 ;

for my $asciio (@asciios)
	{
	if($is_not_first_self++)
		{
		$new_asciio = new App::Asciio() ;
		$new_asciio->setup(Clone::clone($self->{SETUP_PATHS})) ;
		}
	
	my $deserialization_self = (ref($new_self) eq 'ARRAY') ? $decoder->decode($asciio) : $asciio ;
	$new_asciio->load_self($deserialization_self);
	push @{$self->{asciios}}, $new_asciio ;
	}
return $self ;
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
			print STDERR "Overriding element type '$new_element->{NAME}'!\n" ;
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
sub serialize_all_self
{
my ($self) = @_ ;

my $all_serialize_str ;
my $asciios ;

foreach my $asciio (@{$self->{asciios}})
	{
	push @{$asciios}, $asciio->serialize_self() ;
	}

$self->{CACHE}{ENCODER} = my $encoder = $self->{CACHE}{ENCODER} // get_sereal_encoder({compress => SRL_ZLIB}) ;
my $serialized = $encoder->encode($asciios) ;

return $serialized ;
}


#-----------------------------------------------------------------------------

sub serialize_self
{
my ($self, $indent) = @_ ;

local $self->{widget} = undef ;
local $self->{root_window} = undef ;
local $self->{sc_window} = undef ;
local $self->{notebook} = undef ;
local $self->{asciios} = undef ;
local $self->{label} = undef ;
local $self->{event_handlers} = undef ;
local $self->{asciio_argv} = undef ;
local $self->{is_need_focus_in} = undef ;
local $self->{seen_elements} = undef ;
local $self->{format_painter} = undef ;
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
local $self->{COLORS} = undef ;
local $self->{ELEMENT_TYPES} = undef ;
local $self->{ELEMENT_TYPES_BY_NAME} = undef ;
local $self->{ACTION_VERBOSE} = undef ;
local $self->{WARN} = undef ;
local $self->{GIT_MODE_CONNECTOR_CHAR_LIST} = undef ;
local $self->{PEN_MODE_CHARS_SETS} = undef ;

my @elements_cache ;
for my $element (@{$self->{ELEMENTS}}) 
	{
	push @elements_cache, [$element, $element->{CACHE}] ;
	$element->{CACHE} = undef ;
	}

my $encoder ;
# although compression adds a little time, it greatly reduces memory consumption.
$self->{CACHE}{ENCODER} = $encoder = $self->{CACHE}{ENCODER} // get_sereal_encoder({compress => SRL_ZLIB}) ;
local $self->{CACHE} = undef ;

my $on_exit = $self->{ON_EXIT} ;
delete $self->{ON_EXIT} ;

my $serialized = $encoder->encode($self) ;

$self->{ON_EXIT} = $on_exit ;
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
	# :TOCHECK: by qinqing
	# write_file($file_name, $ASCIIO_MIME_TYPE . compress($self->serialize_self() .'$VAR1 ;')) or $title = undef ;
	write_file($file_name, compress($self->serialize_all_self() .'$VAR1 ;')) or $title = undef ;
	}
	
return $title ;
}

#-----------------------------------------------------------------------------

1 ;
