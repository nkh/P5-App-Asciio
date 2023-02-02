
package App::Asciio ;

$|++ ;

use strict;
use warnings;

use Compress::Bzip2 qw(:all :utilities :gzip);
use Sereal qw(
    get_sereal_decoder
    get_sereal_encoder
    clear_sereal_object_cache
 
    encode_sereal
    decode_sereal
) ;

#-----------------------------------------------------------------------------

sub pop_undo_buffer
{
my ($self, $number_of_steps) = @_;

pop @{$self->{DO_STACK}} for(1 .. $number_of_steps) ;
}

#-----------------------------------------------------------------------------

sub redo
{
my ($self, $number_of_steps) = @_;

$self->{DO_STACK_POINTER} += $number_of_steps ;

if($self->{DO_STACK_POINTER} >= @{$self->{DO_STACK}})
	{
	$self->{DO_STACK_POINTER} = @{$self->{DO_STACK}} - 1 ;
	}
	
$self->do($self->{DO_STACK_POINTER}) ;
}

#-----------------------------------------------------------------------------

sub undo
{
my ($self, $number_of_steps) = @_;

(my $new_stack_pointer = $self->{DO_STACK_POINTER}) -= $number_of_steps ;

$new_stack_pointer = 0 if $new_stack_pointer < 0 ;

$self->{DO_STACK} //= [] ;

if($self->{DO_STACK_POINTER} == @{$self->{DO_STACK}})
	{
	$self->create_undo_snapshot() ;
	}
	
$self->{DO_STACK_POINTER} = $new_stack_pointer ;

$self->do($new_stack_pointer) ;
}

#-----------------------------------------------------------------------------

sub do
{
my ($self, $stack_pointer) = @_;

my $new_self = $self->{DO_STACK}[$stack_pointer] ;

if(defined $new_self)
	{
	my ($do_stack_pointer, $do_stack) = ($self->{DO_STACK_POINTER}, $self->{DO_STACK}) ;
	
	my $decoder = get_sereal_decoder() ;
	my $decompressed_new_self = decompress $new_self ;
	my $saved_self = $decoder->decode($decompressed_new_self) ;
	
	if($@)
		{
		use File::Slurp ;
		write_file('undo_error.pl', $decompressed_new_self ) ;
		die "Can't undo! $@\n" ;
		}
	else
		{
		$self->load_self($saved_self) ;
		($self->{DO_STACK_POINTER}, $self->{DO_STACK}) = ($do_stack_pointer, $do_stack) ;
		$self->set_modified_state(1) ;
		$self->update_display() ;
		}
	}
else
	{
	$self->set_modified_state(0) ;
	}
}

#-----------------------------------------------------------------------------

sub create_undo_snapshot
{
my ($self) = @_;
#TODO: use the same huffman table for all the frames in the undo buffer for extra compression
my $serialized_self ;

{
	local $self->{DO_STACK} = undef ;
	$serialized_self = $self->serialize_self()  ;
}

my $compressed_self = compress $serialized_self ;

splice(@{$self->{DO_STACK}}, min($self->{DO_STACK_POINTER}, scalar(@{$self->{DO_STACK}}))) ; # new do branch

push @{$self->{DO_STACK}}, $compressed_self ;
$self->{DO_STACK_POINTER} = @{$self->{DO_STACK}} ;
}

#-----------------------------------------------------------------------------

1 ;

