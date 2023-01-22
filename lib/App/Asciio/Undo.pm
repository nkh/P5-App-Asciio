
package App::Asciio ;

$|++ ;

use strict;
use warnings;

use Compress::Bzip2 qw(:all :utilities :gzip);

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
	
	my $decompressed_new_self = decompress $new_self ;
	$decompressed_new_self .= "\n\n" ; # important line or eval would complain about syntax errors !!!
	
	my $VAR1 ;
	eval $decompressed_new_self  ;
	
	if($@)
		{
		use File::Slurp ;
		write_file('undo_error.pl', $decompressed_new_self ) ;
		die "Can't undo! $@\n" ;
		}
	else
		{
		$self->load_self($VAR1) ;
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
#TODO: use the same huffman table for extra compression
my $serialized_self ;

{
	local $self->{DO_STACK} = undef ;
	
	# my $cache = $self->{CACHE} ;
	# $self->invalidate_rendering_cache() ;
	
	$serialized_self = $self->serialize_self()  ;
	
	# $self->{CACHE} = $cache ;
}

my $compressed_self = compress $serialized_self ;

splice(@{$self->{DO_STACK}}, min($self->{DO_STACK_POINTER}, scalar(@{$self->{DO_STACK}}))) ; # new do branch

push @{$self->{DO_STACK}}, $compressed_self ;
$self->{DO_STACK_POINTER} = @{$self->{DO_STACK}} ;
}

#-----------------------------------------------------------------------------

1 ;

