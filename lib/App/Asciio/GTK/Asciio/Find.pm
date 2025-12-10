package App::Asciio::GTK::Asciio::Find ;

use strict ; use warnings ;

use App::Asciio::String ;
use App::Asciio::ZBuffer ;
use App::Asciio::Actions::Unsorted ;

my $search_words ;

#----------------------------------------------------------------------------------------------

sub find_enter
{
my ($asciio) = @_ ;
$asciio->change_cursor('spider') ;

search_text($asciio) ;
}

#----------------------------------------------------------------------------------------------

sub find_new_search
{
my ($asciio) = @_ ;

find_clear_all_highlight($asciio) ;

$search_words = $asciio->display_edit_dialog("input search words", '', $asciio) ;

return unless(defined $search_words && $search_words ne '') ;

if(search_text($asciio))
	{
	jump_to_first_highlight($asciio) ;
	}
}

#----------------------------------------------------------------------------------------------

sub search_text
{
my ($asciio) = @_ ;

return unless($search_words) ;

my $zbuffer = App::Asciio::ZBuffer->new(0, @{$asciio->{ELEMENTS}}) ;

my ($text, $min_x, $min_y, $width, $height) = $asciio->get_text_rectangle($zbuffer->{coordinates}) ;

my $row_cnt = -1 ;
my $is_text_found = 0 ;

for my $row (split "\n", $text)
	{
	$row_cnt++ ;
	my $ori_x = 0 ;
	eval
		{
		while($row =~ m/$search_words/gi)
			{
			$is_text_found++ ;
			my $fit_str = $& ;
			my $sub_str = substr($row, 0, pos($row)-length($fit_str)) ;
			$ori_x = $min_x + unicode_length($sub_str) ;
			my $fit_length = unicode_length($fit_str) ;
			push @{$asciio->{CACHE}{FIND_COORDINATES}},
				{
				x      => $ori_x,
				y      => $min_y+$row_cnt,
				length => $fit_length,
				} ;
			}
		}
	}
	if ($@)
		{
		print STDERR "wrong search characters or wrong regular expression, please check\n" ;
		}
return $is_text_found ;
}

#----------------------------------------------------------------------------------------------

sub draw_find_keywords_highlight
{
my ($asciio, $gc, $character_width, $character_height) = @_ ;

if(@{$asciio->{CACHE}{FIND_COORDINATES}//[]} > 0)
	{
	my $index = 0 ;
	$gc->set_source_rgba(@{$asciio->get_color('find_current_highlight')}) ;

	for my $highlight (@{$asciio->{CACHE}{FIND_COORDINATES}})
		{
		if($index == 1)
			{
			$gc->set_source_rgba(@{$asciio->get_color('find_other_highlight')}) ;
			}
		my $start_x = $highlight->{x} * $character_width ;
		my $start_y = $highlight->{y} * $character_height ;
		$gc->rectangle($start_x, $start_y, $character_width * $highlight->{length}, $character_height) ;
		$gc->fill() ;
		$gc->stroke() ;
		$index++ ;
		}
	}
}

#----------------------------------------------------------------------------------------------

sub jump_to_first_highlight
{
my ($asciio) = @_ ;

my ($window_width, $window_height) = $asciio->{ROOT_WINDOW}->get_size() ;
my ($window_x_start, $window_y_start)  = ($asciio->{SC_WINDOW}->get_hadjustment()->get_value(), $asciio->{SC_WINDOW}->get_vadjustment()->get_value()) ;
my ($window_x_end, $window_y_end) = ($window_width + $window_x_start, $window_height + $window_y_start) ;

my ($character_width, $character_height) = $asciio->get_character_size() ;
my $first_highlight_x = $asciio->{CACHE}{FIND_COORDINATES}->[0]->{x} * $character_width ;
my $first_highlight_y = $asciio->{CACHE}{FIND_COORDINATES}->[0]->{y} * $character_height ;

unless ($window_x_start < $first_highlight_x && $first_highlight_x < $window_x_end)
	{
	$asciio->{SC_WINDOW}->get_hadjustment()->set_value($first_highlight_x) ;
	}

unless ($window_y_start < $first_highlight_y && $first_highlight_y < $window_y_end)
	{
	$asciio->{SC_WINDOW}->get_vadjustment()->set_value($first_highlight_y) ;
	}

$asciio->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub find_zoom
{
my ($asciio, $direction) = @_ ;

App::Asciio::Actions::Unsorted::zoom($asciio, $direction) ;
search_text($asciio) ;
}

#----------------------------------------------------------------------------------------------

sub find_next
{
my ($asciio) = @_ ;

if(@{$asciio->{CACHE}{FIND_COORDINATES}//[]} > 0)
	{
	push @{$asciio->{CACHE}{FIND_COORDINATES}}, shift @{$asciio->{CACHE}{FIND_COORDINATES}} ;
	jump_to_first_highlight($asciio) ;
	}
}

#----------------------------------------------------------------------------------------------

sub find_previous
{
my ($asciio) = @_ ;

if(@{$asciio->{CACHE}{FIND_COORDINATES}//[]} > 0)
	{
	unshift @{$asciio->{CACHE}{FIND_COORDINATES}}, pop @{$asciio->{CACHE}{FIND_COORDINATES}} ;
	jump_to_first_highlight($asciio) ;
	}
}

#----------------------------------------------------------------------------------------------

sub find_escape
{
my ($asciio) = @_ ;

$asciio->change_cursor('left_ptr') ;
find_clear_all_highlight($asciio) ;
}

#----------------------------------------------------------------------------------------------

sub find_clear_all_highlight
{
my ($asciio) = @_ ;

$asciio->{CACHE}{FIND_COORDINATES} = undef ;
$asciio->update_display() ;
}

#----------------------------------------------------------------------------------------------

1 ;

