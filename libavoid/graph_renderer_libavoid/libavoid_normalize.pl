#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long ;

sub show_help
{
print "Usage: $0 [input_file [output_file]] [-h]\n" ;
print "\n" ;
print "Converts flexible graph format to strict libavoid format.\n" ;
print "\n" ;
print "Modes:\n" ;
print "  $0                      Read from stdin, write to stdout\n" ;
print "  $0 input.txt            Read from file, write to stdout\n" ;
print "  $0 input.txt output.txt Read from file, write to file\n" ;
print "\n" ;
print "Options:\n" ;
print "  -h, --help              Show this help message\n" ;
print "\n" ;
print "Flexible format features:\n" ;
print "  - Case-insensitive commands\n" ;
print "  - Comments (lines starting with #)\n" ;
print "  - Blank lines\n" ;
print "  - Multiple spaces/tabs between arguments\n" ;
print "  - Leading/trailing whitespace\n" ;
print "\n" ;
print "Strict format output:\n" ;
print "  - Uppercase commands\n" ;
print "  - No comments\n" ;
print "  - No blank lines\n" ;
print "  - Single space between arguments\n" ;
print "  - No leading/trailing whitespace\n" ;
exit 0 ;
}

my $help = 0 ;
GetOptions('h|help' => \$help) or die "Error in command line arguments\n" ;
show_help() if $help ;

my $input_fh ;
my $output_fh ;

if (@ARGV == 2)
	{
	open $input_fh, '<', $ARGV[0] or die "Cannot read $ARGV[0]: $!" ;
	open $output_fh, '>', $ARGV[1] or die "Cannot write to $ARGV[1]: $!" ;
	}
elsif (@ARGV == 1)
	{
	open $input_fh, '<', $ARGV[0] or die "Cannot read $ARGV[0]: $!" ;
	$output_fh = \*STDOUT ;
	}
elsif (@ARGV == 0)
	{
	$input_fh  = \*STDIN ;
	$output_fh = \*STDOUT ;
	}
else
	{
	print STDERR "Error: Too many arguments\n\n" ;
	show_help() ;
	}

while (my $line = <$input_fh>)
	{
	chomp $line ;
	
	$line =~ s/^\s+|\s+$//g ;
	
	next if $line eq '' ;
	next if $line =~ /^#/ ;
	
	$line =~ s/#.*$// ;
	$line =~ s/^\s+|\s+$//g ;
	
	my @parts = split /\s+/, $line ;
	next unless @parts ;
	
	$parts[0] = uc($parts[0]) ;
	
	if ($parts[0] =~ /^(GRAPH|GRAPHEND|LAYOUT|DONE)$/)
		{
		print $output_fh "$parts[0]\n" ;
		}
	elsif ($parts[0] eq 'NODE' && @parts == 8)
		{
		print $output_fh "NODE $parts[1] $parts[2] $parts[3] $parts[4] $parts[5] $parts[6] $parts[7]\n" ;
		}
	elsif ($parts[0] eq 'PORT' && @parts == 6)
		{
		my $side = uc($parts[3]) ;
		print $output_fh "PORT $parts[1] $parts[2] $side $parts[4] $parts[5]\n" ;
		}
	elsif ($parts[0] =~ /^(EDGE|EDGEP|PEDGE|PEDGEP)$/ && @parts == 7)
		{
		print $output_fh "$parts[0] $parts[1] $parts[2] $parts[3] $parts[4] $parts[5] $parts[6]\n" ;
		}
	elsif ($parts[0] eq 'CLUSTER' && @parts == 6)
		{
		print $output_fh "CLUSTER $parts[1] $parts[2] $parts[3] $parts[4] $parts[5]\n" ;
		}
	elsif ($parts[0] eq 'OPTION' && @parts >= 3)
		{
		my $option_name  = $parts[1] ;
		my $option_value = join(' ', @parts[2..$#parts]) ;
		print $output_fh "OPTION $option_name $option_value\n" ;
		}
	elsif ($parts[0] eq 'PENALTY' && @parts == 3)
		{
		print $output_fh "PENALTY $parts[1] $parts[2]\n" ;
		}
	elsif ($parts[0] eq 'ROUTINGOPTION' && @parts >= 3)
		{
		my $option_name  = $parts[1] ;
		my $option_value = join(' ', @parts[2..$#parts]) ;
		print $output_fh "ROUTINGOPTION $option_name $option_value\n" ;
		}
	else
		{
		print $output_fh join(' ', @parts) . "\n" ;
		}
	}

close $input_fh if $input_fh != \*STDIN ;
close $output_fh if $output_fh != \*STDOUT ;
