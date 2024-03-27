package App::Asciio::GTK::Asciio ;

use strict ; use warnings ;

use App::Asciio::String ;
use App::Asciio::ZBuffer ;
use App::Asciio::Actions::Unsorted ;

my $search_words ;
my ($x_index, $y_index, $length_index) = (0, 1, 2) ;
my $is_hunk_search = 0 ;

#----------------------------------------------------------------------------------------------
sub hunk_search_toggle
{
my ($self) = @_ ;

$is_hunk_search ^= 1 ;
}

#----------------------------------------------------------------------------------------------
sub find_enter
{
my ($self) = @_ ;

$self->change_custom_cursor('find') ;

if($is_hunk_search)
	{
	hunk_search_text($self) ;
	}
else
	{
	normal_search_text($self) ;
	}
}

#----------------------------------------------------------------------------------------------
sub normal_search_text
{
my ($self) = @_ ;

$self->{CACHE}{FIND_COORDINATES} = undef ;

$search_words = $self->display_edit_dialog("input search words", '', $self, undef, undef, undef, undef, 300, 100);
return unless($search_words) ;

if (search_text($self))
	{
	jump_to_first_highlight($self) ;
	}
}

#----------------------------------------------------------------------------------------------
sub hunk_search_text
{
my ($self) = @_ ;

$self->{CACHE}{FIND_COORDINATES} = undef ;

my @selected_elements = $self->get_selected_elements(1) ;

if((@selected_elements == 1) 
	&& exists $selected_elements[0]->{TEXT_ONLY} 
	&& $selected_elements[0]->{TEXT_ONLY})
	{
	$search_words = $selected_elements[0]->{TEXT_ONLY} ;
	if(search_text($self))
		{
		jump_to_first_highlight($self) ;
		}
	}
}

#----------------------------------------------------------------------------------------------
sub search_text
{
my ($self) = @_ ;

return unless($search_words) ;
$self->{CACHE}{FIND_COORDINATES} = undef ;

my $zbuffer = App::Asciio::ZBuffer->new(0, @{$self->{ELEMENTS}}) ;

my ($text, $min_x, $min_y, $width, $height) = $self->get_text_rectangle($zbuffer->{coordinates}) ;

my $row_cnt = -1 ;
my $is_text_found = 0;

for my $row (split "\n", $text)
	{
	$row_cnt++ ;
	my $ori_x = 0;
	while($row =~ m/$search_words/gi)
		{
		$is_text_found++ ;
		my $fit_str = $&;
		my $sub_str = substr($row, 0, pos($row)-length($fit_str)) ;
		$ori_x = $min_x + unicode_length($sub_str) ;
		my $fit_length = unicode_length($fit_str) ;
		push @{$self->{CACHE}{FIND_COORDINATES}}, [$ori_x, $min_y+$row_cnt, $fit_length] ;
		}
	}
return $is_text_found ;
}

#----------------------------------------------------------------------------------------------
sub draw_find_keywords_highlight
{
my ($self, $gc, $character_width, $character_height) = @_ ;

if(@{$self->{CACHE}{FIND_COORDINATES}//[]} > 0)
	{
	my $index = 0 ;
	$gc->set_source_rgba(@{$self->get_color('find_current_highlight')}) ;

	for my $highlight (@{$self->{CACHE}{FIND_COORDINATES}})
		{
		if($index == 1)
			{
			$gc->set_source_rgba(@{$self->get_color('find_other_highlight')}) ;
			}
		my $start_x = $highlight->[$x_index] * $character_width ;
		my $start_y = $highlight->[$y_index] * $character_height ;
		$gc->rectangle($start_x, $start_y, $character_width * $highlight->[$length_index], $character_height) ;
		$gc->fill() ;
		$gc->stroke() ;
		$index++ ;
		}
	}
}

#----------------------------------------------------------------------------------------------
sub jump_to_first_highlight
{
my ($self) = @_ ;

my ($character_width, $character_height) = $self->get_character_size() ;
my ($window_width, $window_height) = $self->{root_window}->get_size() ;
my ($window_x_start, $window_y_start)  = ($self->{sc_window}->get_hadjustment()->get_value(), $self->{sc_window}->get_vadjustment()->get_value()) ;
my ($window_x_end, $window_y_end) = ($window_width + $window_x_start, $window_height + $window_y_start) ;

my $first_highlight_x = $self->{CACHE}{FIND_COORDINATES}->[0][$x_index] * $character_width ;
my $first_highlight_y = $self->{CACHE}{FIND_COORDINATES}->[0][$y_index] * $character_height ;

my $is_need_update = 0 ;

unless($window_x_start < $first_highlight_x < $window_x_end)
	{
	$self->{sc_window}->get_hadjustment()->set_value($first_highlight_x) ;
	$is_need_update++ ;
	}

unless($window_y_start < $first_highlight_y < $window_y_end)
	{
	$self->{sc_window}->get_vadjustment()->set_value($first_highlight_y) ;
	$is_need_update++ ;
	}

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------
sub find_zoom
{
my ($self, $direction) = @_ ;

App::Asciio::Actions::Unsorted::zoom($self, $direction) ;
search_text($self) ;
}

#----------------------------------------------------------------------------------------------
sub find_next
{
my ($self) = @_ ;

if(@{$self->{CACHE}{FIND_COORDINATES}//[]} > 0)
	{
	push @{$self->{CACHE}{FIND_COORDINATES}}, shift @{$self->{CACHE}{FIND_COORDINATES}} ;
	jump_to_first_highlight($self) ;
	}
}

#----------------------------------------------------------------------------------------------
sub find_previous
{
my ($self) = @_ ;

if(@{$self->{CACHE}{FIND_COORDINATES}//[]} > 0)
	{
	unshift @{$self->{CACHE}{FIND_COORDINATES}}, pop @{$self->{CACHE}{FIND_COORDINATES}};
	jump_to_first_highlight($self) ;
	}
}

#----------------------------------------------------------------------------------------------
sub find_escape
{
my ($self) = @_ ;

$self->{CACHE}{FIND_COORDINATES} = undef ;
$self->change_cursor('left_ptr') ;
}

#----------------------------------------------------------------------------------------------

1 ;

