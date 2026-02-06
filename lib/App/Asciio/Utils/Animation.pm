
package App::Asciio::Utils::Animation ;

use Exporter qw/import/ ;
@EXPORT = 
	qw(
	flash_selected
	) ;

use strict;
use warnings;

# ------------------------------------------------------------------------------

use File::Slurper qw(read_lines) ;
use Time::HiRes qw(sleep) ;
use Tree::Trie ;

# ------------------------------------------------------------------------------

sub move_elements_to
{
# to object
# to object center
# object lower right
}

# ------------------------------------------------------------------------------

sub flash_selected
{
my ($time, $time2, $times) = @_ ;

$time  //= 100 ;
$time2 //= 200 ;
$times //= 3 ;

my @selected_elements = $App::Asciio::Scripting::script_asciio->get_selected_elements(1) ;

flash_by_selecting
	(
	$App::Asciio::Scripting::script_asciio,
	$time,
	$time2,
	$times,
	@selected_elements,
	) ;
}

# ------------------------------------------------------------------------------

sub flash_by_selecting
{
my ($self, $time, $time2, $times, @elements) = @_ ;

$time  /= 1000 ;
$time2 /= 1000 ;

$self //= $App::Asciio::Scripting::script_asciio ;

my %start_colors ;

for (0 .. $times)
	{
	$self->select_elements_flip(@elements) ;
	$self->update_display(1) ;
	$self->update_display(1) ;
	
	sleep($time) ;
	
	$self->select_elements_flip(@elements) ;
	$self->update_display(1) ;
	$self->update_display(1) ;
	sleep($time2) ;
	}
}

# ------------------------------------------------------------------------------

sub flash_elements
{
my ($self, $time, $time2, $times, @elements_colors) = @_ ;

$time  /= 1000 ;
$time2 /= 1000 ;

$self //= $App::Asciio::Scripting::script_asciio ;

my %start_colors ;

for (0 .. $times)
	{
	for my $element_color (@elements_colors)
		{
		my ($element, $bg_color, $fg_color) = $element_color->@* ;
		
		$start_colors{$element} = [$element->get_colors()] ;
		
		$element->set_background_color($bg_color) ;
		$element->set_foreground_color($fg_color) ;
		}
	
	$self->update_display(1) ;
	$self->update_display(1) ;
	
	sleep($time) ;
	
	for my $element_color (@elements_colors)
		{
		my ($element) = $element_color->@* ;
		
		$element->set_colors($start_colors{$element}->@*) ;
		}
	
	$self->update_display(1) ;
	$self->update_display(1) ;
	sleep($time2) ;
	}
}

# ------------------------------------------------------------------------------

sub flash_rectangle
{
}

# ------------------------------------------------------------------------------

sub flash_bouding_rectangle
{
}

# ------------------------------------------------------------------------------

sub get_line_points
{
my ($xs, $ys, $xe, $ye) = @_ ;

my $dx  = abs($xe - $xs) ;
my $dy  = -abs($ye - $ys) ;
my $sx  = $xs < $xe ? 1 : -1 ;
my $sy  = $ys < $ye ? 1 : -1 ;
my $err = $dx + $dy ;
my @points ;

while (1)
	{
	push(@points, [$xs, $ys]) ;
	last if ($xs == $xe && $ys == $ye) ;
	
	my $e2 = 2 * $err ;
	
	if ($e2 >= $dy)
		{
		$err += $dy ;
		$xs  += $sx ;
		}
	
	if ($e2 <= $dx)
		{
		$err += $dx ;
		$ys  += $sy ;
		}
	}

return @points ;
}

# ------------------------------------------------------------------------------

sub get_circle_points
{
my ($cx, $cy, $sx, $sy) = @_ ;
	
my $r = sqrt(($sx - $cx) ** 2 + ($sy - $cy) ** 2) ;

return () if $r <= 0 ;

my @base ;
my %seen_base ;

my $max_step = 1.0 / $r ;

my $steps = int(6.283185307179586 / $max_step) ;

for(my $i = 0 ; $i < $steps ; $i++)
	{
	my $a = ($i / $steps) * 6.283185307179586 ;
	
	my $x = int($cx + $r * cos($a) + 0.5) ;
	my $y = int($cy + $r * sin($a) + 0.5) ;
	
	my $k = "$x,$y" ;
	
	next if $seen_base{$k}++ ;
	
	push @base, [$x, $y] ;
	}

@base = sort
	{
	my ($ax, $ay) = @$a ;
	my ($bx, $by) = @$b ;
	
	atan2($ay - $cy, $ax - $cx) <=> atan2($by - $cy, $bx - $cx)
	} @base ;

my @pts ;
my %seen ;
my $n = @base ;

for(my $i = 0 ; $i < $n ; $i++)
	{
	my ($x1, $y1) = @{$base[$i]} ;
	my ($x2, $y2) = @{$base[($i + 1) % $n]} ;
	
	my $dx = $x2 - $x1 ;
	my $dy = $y2 - $y1 ;

	my $steps_line = abs($dx) > abs($dy) ? abs($dx) : abs($dy) ;
	
	for(my $s = 0 ; $s <= $steps_line ; $s++)
		{
		my $t = $steps_line ? $s / $steps_line : 0.0 ;
		
		my $x = int($x1 + $dx * $t + 0.5) ;
		my $y = int($y1 + $dy * $t + 0.5) ;
		
		my $k = "$x,$y" ;
		
		next if $seen{$k}++ ;
		
		push @pts, [$x, $y] ;
		}
	}

return @pts ;
}

# ------------------------------------------------------------------------------

sub scan_directories 
{
my ($dirs_ref, $scan_subdirectories) = @_ ;

my %dir_tries ;
my %file_paths ;
my %scanned ;

my %seen ;
my @to_scan = grep { !$seen{$_}++ } @$dirs_ref ;

for my $dir (@to_scan)
	{
	my @ignore_patterns ;
	
	if (-e "$dir/.scriptignore")
		{
		@ignore_patterns = read_lines("$dir/.scriptignore") ;
		}
	
	scan_directory
		(
		$dir,
		$scan_subdirectories,
		\%dir_tries,
		\%file_paths,
		\%scanned,
		\@ignore_patterns,
		) ;
	}

my $global_trie_paths = Tree::Trie->new() ;
my $global_trie_files = Tree::Trie->new() ;

for my $filename (keys %file_paths)
	{
	for my $path ($file_paths{$filename}->@*)
		{
		$global_trie_paths->add_data("$path/$filename", $file_paths{$filename}) ;
		}

	$global_trie_files->add_data($filename, $file_paths{$filename}) ;
	}

return 
	{
	tries_per_directories => \%dir_tries,
	tries_per_path        => $global_trie_paths,
	tries_per_file        => $global_trie_files,
	file_paths            => \%file_paths,
	};
}

sub scan_directory
{
my ($dir, $scan_subdirectories, $dir_tries, $file_paths, $scanned, $ignore_patterns) = @_ ;

return unless -e $dir ;
return if $scanned->{$dir}++ ;

my $dir_trie = Tree::Trie->new() ;
$dir_tries->{$dir} = $dir_trie ;

opendir(my $dh, $dir) or return ;

my @entries = grep { $_ ne '.' && $_ ne '..' } readdir($dh) ;

my %ignores ;

for my $ignore_pattern ($ignore_patterns->@*)
	{
	for (<$dir/$ignore_pattern>)
		{
		$_ =~ s/$dir\/// ;
		$ignores{$_}++ ; #todo: remove dir
		}
	}

closedir($dh) ;

for my $entry (grep { ! exists $ignores{$_} } @entries)
	{
	my $entry_path = "$dir/$entry" ;
	
	if (-d $entry_path)
		{
		if ($scan_subdirectories)
			{
			scan_directory
				(
				$entry_path,
				$scan_subdirectories,
				$dir_tries,
				$file_paths,
				$scanned,
				$ignore_patterns,
				) ;
			}
		}
	else
		{
		$dir_trie->add($entry) ;
		push @{$file_paths->{$entry}}, $dir ;
		}
	}
}
#------------------------------------------------------------------------------------------------------

sub load_diagram
{
my ($x_offset, $y_offset, $file) = @_ ;

clear_all(),
insert_diagram($x_offset, $y_offset, $file),
}

#------------------------------------------------------------------------------------------------------

sub insert_diagram
{
my ($x_offset, $y_offset, $file) = @_ ;

my ($self) = @_ ;
$self->run_actions_by_name(['Insert', $x_offset, $y_offset, $file]) ;
}

#------------------------------------------------------------------------------------------------------

sub box
{
my ($x, $y, $title, $text, $select) = @_ ;

my ($self) = @_ ;

my $element = $self->add_new_element_named('Asciio/box', $x, $y) ;
$element->set_text($title, $text) ;

$self->select_elements($select, $element) ;

return $element ;
}

#------------------------------------------------------------------------------------------------------

sub clear_all
{
my ($self) = @_ ;

$self->select_all_elements() ;
$self->delete_elements($self->get_selected_elements(1)) ;
}

#------------------------------------------------------------------------------------------------------

1 ;
