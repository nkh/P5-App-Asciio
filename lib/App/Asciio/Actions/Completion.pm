
package App::Asciio::Actions::Completion ;

use strict ; use warnings ;

#----------------------------------------------------------------------------------------------

use List::Util qw(max) ;
use Data::TreeDumper ;

#----------------------------------------------------------------------------------------------

sub enter
{
my ($self, $subs)                   = @_ ;
my ($get_entries, $completion_done) = $subs->@* ;

# my $completions = $get_entries->($self) ;

$self->{COMPLETION}{KEYS}              = '' ;
$self->{COMPLETION}{COMPLETION_SUB}      = $get_entries ;
$self->{COMPLETION}{COMPLETION_DONE_SUB} = $completion_done ;
}

#----------------------------------------------------------------------------------------------

sub escape
{
my ($self) = @_ ;

delete $self->{COMPLETION} ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub key
{
my ($self, $key) = @_ ;

my $execute_script ;

my @texts ;
my $text_line        = 0 ;
my @text_color       = ([0.50, 0.50, 0.50], [0, 0, 0]) ;
my @completion_color = ([0.70, 0.70, 0.70], [0, 0, 0]) ;
my @error_color      = ([0.50, 0.10, 0.10], [0, 0, 0]) ;
my @match_color      = ([0.10, 0.50, 0.10], [0, 0, 0]) ;

if('erase' eq $key)
	{
	$self->{COMPLETION}{KEYS} = '' ;
	$self->update_display() ;
	return ;
	}
if('backspace' eq $key)
	{
	if($self->{COMPLETION}{KEYS} ne '')
		{
		substr($self->{COMPLETION}{KEYS}, -1) = '' ;
		
		my @found = $self->{COMPLETION}{COMPLETION_SUB}->($self, $self->{COMPLETION}{KEYS}) ;
		
		if (0 == @found)
			{
			push @texts, [0, $text_line++, @error_color, $self->{COMPLETION}{KEYS}] ;
			}
		elsif (1 == @found)
			{
			if($self->{COMPLETION}{KEYS} eq $found[0])
				{
				push @texts, [0, $text_line++, @match_color, $self->{COMPLETION}{KEYS}] ;
				}
			else
				{
				push @texts, [0, $text_line++, @text_color, $self->{COMPLETION}{KEYS}] ;
				}
			}
		else
			{
			push @texts, [0, $text_line++, @text_color, $self->{COMPLETION}{KEYS}] ;
			}
		
		$self->set_text_overlay(\@texts) ;
		$self->update_display() ;
		}
	else
		{
		print "completion keys: $self->{COMPLETION}{KEYS}\n" ;
		}
	
	return ;
	}
elsif('tab' eq $key || 'taball' eq $key)
	{
	my @found = $self->{COMPLETION}{COMPLETION_SUB}->($self, $self->{COMPLETION}{KEYS}) ;
	my $max_length = max(map { length} @found) // 0 ;
	
	my @found_all ;
	
	if('taball' eq $key)
		{
		@found_all = $self->{COMPLETION}{COMPLETION_SUB}->($self, '') ;
		$max_length = max(map { length} @found_all) // 0 ;
		}
	
	# print DumpTree \@found, 'found:' ;
	
	if(@found == 0)
		{
		push @texts, [0, $text_line++, @error_color, sprintf("%-${max_length}s", $self->{COMPLETION}{KEYS})] ;
		}
	elsif(@found == 1)
		{
		$self->{COMPLETION}{KEYS} = lcp(@found) ;
		push @texts, [0, $text_line++, @match_color, sprintf("%-${max_length}s", $self->{COMPLETION}{KEYS})] ;
		}
	else
		{
		push @texts, [0, $text_line++, @text_color, sprintf("%-${max_length}s", $self->{COMPLETION}{KEYS} // '')] ;
		}
	
	if('taball' eq $key)
		{
		@found = @found_all ;
		}
	
	if(@found != 1)
		{
		for my $found (sort @found)
			{
			push @texts, [0, $text_line++, @completion_color, sprintf("%-${max_length}s", $found)] ;
			}
		}
	
	$self->set_text_overlay(\@texts) ;
	$self->update_display() ;
	
	return ;
	}
elsif('return' eq $key)
	{
	$execute_script++ ;
	}
else
	{
	$self->{COMPLETION}{KEYS} .= $key ;
	}

my @found = $self->{COMPLETION}{COMPLETION_SUB}->($self, $self->{COMPLETION}{KEYS}) ;

if (0 == @found)
	{
	push @texts, [0, $text_line++, @error_color, "$self->{COMPLETION}{KEYS}"] ;
	
	$self->set_text_overlay(\@texts) ;
	$self->update_display(1) ;
	}
elsif (1 == @found)
	{
	$self->{COMPLETION}{KEYS} = lcp(@found) ;
	
	push @texts, [0, $text_line++, @match_color, "$self->{COMPLETION}{KEYS}"] ;
	
	$self->set_text_overlay(\@texts) ;
	$self->update_display(1) ;
	
	if($execute_script)
		{
		$self->{COMPLETION}{COMPLETION_DONE_SUB}->($self, $self->{COMPLETION}{KEYS}) ;
		
		$self->run_actions(['000-Escape']) ;
		}
	}
else
	{
	$self->{COMPLETION}{KEYS} = lcp(@found) ;
	
	my $max_length = max(map { length} @found) ;
	
	push @texts, [0, $text_line++, @text_color, sprintf("%-${max_length}s", $self->{COMPLETION}{KEYS})] ;
	
	for my $found (sort @found)
		{
		push @texts, [0, $text_line++, @completion_color, sprintf("%-${max_length}s", $found)] ;
		}
	
	$self->set_text_overlay(\@texts) ;
	$self->update_display(1) ;
	}
}

#----------------------------------------------------------------------------------------------

sub lcp { (join("\0", @_) =~ /^ ([^\0]*) [^\0]* (?:\0 \1 [^\0]*)* $/sx)[0] ; }

#----------------------------------------------------------------------------------------------
1 ;

