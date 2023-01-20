
package App::Asciio ;

$|++ ;

use strict;
use warnings;

use Data::TreeDumper ;
#~ use Compress::LZF ':compress';
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

sub undo
{
my ($self, $number_of_steps) = @_;

(my $new_stack_pointer = $self->{DO_STACK_POINTER}) -= $number_of_steps ;

$new_stack_pointer = 0 if($new_stack_pointer < 0) ;

$self->{DO_STACK} ||= [] ;

if($self->{DO_STACK_POINTER} == @{$self->{DO_STACK}})
	{
	$self->create_undo_snapshot() ;
	}
	
$self->{DO_STACK_POINTER} = $new_stack_pointer ;

$self->do($new_stack_pointer) ;
}

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
#TODO: delta, serialize and compress, use the same huffman table for extra compression
my $serialized_self ;

{
	local $self->{DO_STACK} = undef ;
	$serialized_self = $self->serialize_self()  ;
}

my $compressed_self = compress $serialized_self ;

splice(@{$self->{DO_STACK}}, min($self->{DO_STACK_POINTER}, scalar(@{$self->{DO_STACK}}))) ; # new do branch

push @{$self->{DO_STACK}}, $compressed_self ;
$self->{DO_STACK_POINTER} = @{$self->{DO_STACK}} ;

#~ print 'stack: ' . scalar(@{$self->{DO_STACK}}) . ' size: ' . length($serialized_self) . ' compressed: ' . length($compressed_self) . "\n" ;
}

#-----------------------------------------------------------------------------

use Algorithm::Diff qw(diff LCS traverse_sequences) ;

sub test_diff
{
# This example produces traditional 'diff' output:
my @seq1 = ("line 1",      "line 2",                   "line3", "line 4", "line 5", 'line 6') ;
my @seq2 = ("line mod1", "line 2", "line 2B", "line3",                 "line 5") ;

my @diff_lines = get_diff_lines(\@seq1, \@seq2) ;

for my $diff_line (@diff_lines)
	{
	# print DumpTree $diff_line ;
	
	my (
		$number_of_errors
		, $number_of_match
		, $synchronized_a
		, $synchronized_b
		, $error_string
		) = CompareStrings($diff_line->{REFERENCE}, $diff_line->{NEW}) ;
		
	my $undefined_line = '' ;
	
	$undefined_line = '** reference line did not exist! **' unless defined $diff_line->{REFERENCE} ;
	$undefined_line = '** new line did not exist! **' unless defined $diff_line->{NEW} ;

	print <<ERRORS ;
line = $diff_line->{LINE}
number_of_match  = $number_of_match
number_of_errors = $number_of_errors
$undefined_line
$synchronized_a
$synchronized_b
$error_string

ERRORS
	}
}

sub get_diff_lines
{
my ($seq1, $seq2) = @_ ;

my $diff = Algorithm::Diff->new($seq1, $seq2 );
my @diff_lines ;

$diff->Base(1);
my $line = 1 ;

while($diff->Next()) 
	{
	unless($diff->Same())
		{
		my ($reference_line) = $diff->Items(1) ;
		my ($new_line) = $diff->Items(2) ;

		push @diff_lines, {LINE => $line, REFERENCE => $reference_line , NEW => $new_line} ;
		}
		
	$line++ ;
	}

return @diff_lines ;
}

sub CompareStrings($$)
{

=head2 CompareStrings

Returns the following list:

=over 2

=item 1	number_of_errors

=item 2 number_of_match

=item 3	synchronized_a

=item 4	synchronized_b

=item 5	error_string

=back

=cut


my ($a_string, $b_string) = @_ ;
my ($a, $b) ;

# handle cases were one or both strings are not defined
if(!defined $a_string && ! defined  $b_string)
	{
	return (0, 0, '', '', '') ;
	}
elsif(!defined $a_string)
	{
	return (length($b_string), 0, '', $b_string, '^' x length($b_string)) ;
	}
elsif(!defined $b_string)
	{
	return (length($a_string), 0, $a_string, '', '^' x length($a_string)) ;
	}

my @a = split //, $a_string ;
my @b = split //, $b_string ;

my @match_indexes = Algorithm::Diff::_longestCommonSubsequence( \@a, \@b) ;
#print Dumper(\@match_indexes), "\n" ;

#my @LCS = LCS( \@a, \@b ) ;
#print Dumper(\@LCS), "\n" ;

my $previous = -1 ;
my $last_match_in_B = -1 ;

# build $a a character at a time. Synchronize strings before adding current character
for(0 .. $#match_indexes) 
	{
	if(defined $previous)
		{
		if(defined $match_indexes[$_])
			{
			if($match_indexes[$_] == $previous + 1)
				{
				# match
				$b .= $b[$match_indexes[$_]] ;
				$last_match_in_B = $match_indexes[$_] ;
				}
			else
				{
				# match but extra letters in B, synchronize A
				$a .= ' ' x ($match_indexes[$_] - ($previous + 1)) ;
				$b .= join '', @b[$previous + 1 .. $match_indexes[$_]] ;
				
				$last_match_in_B = $match_indexes[$_] ;
				}
			}
		#else
			# letter in A doesn't match in B
		}
	else
		{
		if(defined $match_indexes[$_])
			{
			# match
			# synchronize B
			my $number_of_skipped_characters_in_B = ($match_indexes[$_] - 1) - ($last_match_in_B) ;
			$b .= ' ' x (length($a) - (length($b) + $number_of_skipped_characters_in_B)) ;
			
			$b .= join '', @b[$last_match_in_B + 1 .. $match_indexes[$_]] ;
			$last_match_in_B = $match_indexes[$_] ;
			
			# synchronize A if needed
			$a .= ' ' x (length($b) - (length($a) + 1)) ; # +1 as current character will be appended to $a
			}
		#else
			# letter in A doesn't match in B
		}
		
	$a .= $a[$_] ;
	$previous = $match_indexes[$_] ;
	}

my $trailers_in_A = scalar(@a) - scalar(@match_indexes) ;
$a .= join '', @a[-$trailers_in_A .. -1] ;

my $trailers_in_B = scalar(@b) - ($last_match_in_B + 1) ;
$b .= join '', @b[-$trailers_in_B .. -1] ;

my $error_string = $a ^ $b ;

my $number_of_matches = $error_string =~ tr[\0][\0] ;
my $number_of_errors = length($error_string) - $number_of_matches ;

# show were the strings are different
$error_string =~ tr[\0][^]c ;
$error_string =~ tr[\0][ ] ;

return ($number_of_errors, $number_of_matches, $a, $b, $error_string) ;
}

#-----------------------------------------------------------------------------

1 ;

