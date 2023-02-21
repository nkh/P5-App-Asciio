
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
	
	$self->{CACHE}{DECODER} = my $decoder = $self->{CACHE}{DECODER} // get_sereal_decoder() ;
	
	my $saved_self = $decoder->decode($new_self) ;
	
	if($@)
		{
		use File::Slurp ;
		write_file_utf8('undo_error.pl', $saved_self ) ;
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
my $serialized_self ;

{
	local $self->{DO_STACK} = undef ;
	$serialized_self = $self->serialize_self()  ;
}

splice(@{$self->{DO_STACK}}, min($self->{DO_STACK_POINTER}, scalar(@{$self->{DO_STACK}}))) ; # new do branch

push @{$self->{DO_STACK}}, $serialized_self ;
$self->{DO_STACK_POINTER} = @{$self->{DO_STACK}} ;
}

#-----------------------------------------------------------------------------

1 ;

