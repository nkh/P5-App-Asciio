#!/bin/env perl

use strict; use warnings;

use File::Slurp ;
use App::Asciio::Scripting ;

die "usage:\n\ttext_to_asciio output_file_name text_file_to import text_file_to import ...\n" if @ARGV < 2 ;

my $output_file_name = shift @ARGV ;

my $pos = 0 ;

for my $text_to_import_file (@ARGV)
	{
	add 'box1', new_box
			(
			TEXT_ONLY => scalar read_file($text_to_import_file),
			BOX_TYPE =>
				[
				[0, 'top',              '.', '-',  '.', 1, ],
				[0, 'title separator',  '|', '-',  '|', 1, ],
				[0, 'body separator',  '| ', '|', ' |', 1, ],
				[0, 'bottom',          '\'', '-', '\'', 1, ],
				[0, 'fill-character',  '',   ' ', '',   1, ],
				],
			),  $pos,  $pos ;

	$pos += 5 ;
	}

save_to "$output_file_name.asciio" ;

