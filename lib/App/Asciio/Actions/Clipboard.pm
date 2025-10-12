package App::Asciio::Actions::Clipboard ;
use strict ;
use warnings ;

#----------------------------------------------------------------------------------------------

use utf8;
use Encode;
use List::Util qw(min max) ;
use List::MoreUtils qw(first_value) ;
use MIME::Base64 ;
use Clone ;

use Sereal qw(
	get_sereal_decoder
	get_sereal_encoder
	looks_like_sereal
	) ;

use Sereal::Encoder qw(SRL_SNAPPY SRL_ZLIB SRL_ZSTD) ;

use App::Asciio::stripes::image_box ;

sub copy_to_clipboard
{
my ($self) = @_ ;

my $cache = $self->{CACHE} ;
$self->invalidate_rendering_cache() ;

my @selected_elements = $self->get_selected_elements(1) ;

unless(@selected_elements)
	{
	delete $self->{CLIPBOARD} ;
	return ;
	}

my %selected_elements = map { $_ => 1 } @selected_elements ;

my @connections =
	grep 
		{
		exists $selected_elements{$_->{CONNECTED}} && exists $selected_elements{$_->{CONNECTEE}}
		} 
		$self->get_connections_containing(@selected_elements)  ;

my $elements_and_connections =
	{
	ELEMENTS =>  \@selected_elements,
	CONNECTIONS => \@connections ,
	};

$self->{CLIPBOARD} = Clone::clone($elements_and_connections) ;
$self->{CACHE} = $cache ;
}

#----------------------------------------------------------------------------------------------

sub insert_from_clipboard
{
my ($self, @args) = @_ ;

my ($x_offset, $y_offset) ;

if(@args)
	{
	($x_offset, $y_offset) = 'ARRAY' eq $args[0] ? $args[0]->@* : @args ;
	}

if(defined $self->{CLIPBOARD}{ELEMENTS} && @{$self->{CLIPBOARD}{ELEMENTS}})
	{
	$self->create_undo_snapshot() ;
	
	$self->deselect_all_elements() ;
	
	unless(defined $x_offset)
		{
		my $min_x = min(map {$_->{X}} @{$self->{CLIPBOARD}{ELEMENTS}}) ;
		$x_offset = $min_x - $self->{MOUSE_X} ;
		}
	
	unless(defined $y_offset)
		{
		my $min_y = min(map {$_->{Y}} @{$self->{CLIPBOARD}{ELEMENTS}}) ;
		$y_offset = $min_y  - $self->{MOUSE_Y} ;
		}
	
	my %new_group ;
	
	for my $element (@{$self->{CLIPBOARD}{ELEMENTS}})
		{
		@$element{'X', 'Y'}= ($element->{X} - $x_offset, $element->{Y} - $y_offset) ;
		
		if(exists $element->{GROUP} && scalar(@{$element->{GROUP}}) > 0)
			{
			my $group = $element->{GROUP}[-1] ;
			
			unless(exists $new_group{$group})
				{
				$new_group{$group} = {'GROUP_COLOR' => $self->get_group_color()} ;
				}
				
			pop @{$element->{GROUP}} ;
			push @{$element->{GROUP}}, $new_group{$group} ;
			}
		else
			{
			delete $element->{GROUP} ;
			}
		}
	
	my $clipboard = Clone::clone($self->{CLIPBOARD}) ;
	
	$self->add_elements_no_connection(@{$clipboard->{ELEMENTS}}) ;
	$self->add_connections(@{$clipboard->{CONNECTIONS}}) ;
	
	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

sub import_elements_from_system_clipboard
{
my ($self, @args) = @_ ;

my @clipboard_out_options=("-b", "-p") ;
my $invalid_flag = 1 ;
my $elements_serail ;

for my $option (@clipboard_out_options)
	{
		my $elements_base64 = qx~xsel $option -o~ ;
		
		# print STDERR "get data:==>" . $elements_base64 . "\n" ;
		
		$elements_serail = MIME::Base64::decode_base64($elements_base64) ;
		
		if(looks_like_sereal($elements_serail))
			{
			$invalid_flag = 0 ;
			last;
			}
		else
			{
			print STDERR "data from $option is invalid!\n" ;
			}
	}

return if $invalid_flag ;

$self->{CLIPBOARD} = Clone::clone(get_sereal_decoder()->decode($elements_serail)) ;

insert_from_clipboard($self, @args) ;
}

#----------------------------------------------------------------------------------------------

sub serialize_selected_elements
{
my ($self) = @_ ;

copy_to_clipboard($self) ;

my $export_elements = Clone::clone($self->{CLIPBOARD}) ;
my $encoder         = get_sereal_encoder({compress => SRL_ZLIB}) ;
my $serialized      = $encoder->encode($export_elements) ;
my $base64          = MIME::Base64::encode_base64($serialized, '') ;
}

sub export_elements_to_system_clipboard
{
my ($self) = @_ ;

my $serialized_elements = serialize_selected_elements($self) ;

use open qw( :std :encoding(UTF-8) ) ;
open CLIPBOARD, "| xsel -i -b -p"  or die "can't copy to clipboard: $!" ;
local $SIG{PIPE} = sub { die "xsel pipe broke" } ;

print CLIPBOARD $serialized_elements ;
close CLIPBOARD ;
}

#----------------------------------------------------------------------------------------------

sub export_to_clipboard_as_ascii
{
my ($self) = @_ ;

use open qw( :std :encoding(UTF-8) ) ;
open CLIPBOARD, "| xsel -i -b -p"  or die "can't copy to clipboard: $!" ;
local $SIG{PIPE} = sub { die "xsel pipe broke" } ;

print CLIPBOARD $self->transform_elements_to_ascii_buffer($self->get_selected_elements(1)) ;
close CLIPBOARD ;
}

#----------------------------------------------------------------------------------------------

sub export_to_clipboard_as_markup
{
my ($self) = @_ ;

use open qw( :std :encoding(UTF-8) ) ;
open CLIPBOARD, "| xsel -i -b -p"  or die "can't copy to clipboard: $!" ;
local $SIG{PIPE} = sub { die "xsel pipe broke" } ;

print CLIPBOARD $self->transform_elements_to_markup_buffer($self->get_selected_elements(1)) ;
close CLIPBOARD ;
}

#----------------------------------------------------------------------------------------------

sub import_from_primary_to_box
{
my ($self) = @_ ;

my $ascii = qx~xsel -p -o~ ;

my $element = $self->add_new_element_named('Asciio/box', $self->{MOUSE_X}, $self->{MOUSE_Y}) ;
$element->set_text('', $ascii) ;
$self->select_elements(1, $element) ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub import_from_primary_to_text
{
my ($self) = @_ ;

my $ascii = qx~xsel -p -o~ ;

my $element = $self->add_new_element_named('Asciio/text', $self->{MOUSE_X}, $self->{MOUSE_Y}) ;
$element->set_text('', $ascii) ;
$self->select_elements(1, $element) ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub import_from_system_clipboard_to_image_box
{
my ($self) = @_ ;

$self->create_undo_snapshot();

$self->deselect_all_elements() ;

# libjpeg8-dev libjpeg9-dev
my %commands = (
	'png'  => [ 'xclip -selection clipboard -t image/png -o',  'xclip -selection primary -t image/png -o'  ],
	'jpeg' => [ 'xclip -selection clipboard -t image/jpeg -o', 'xclip -selection primary -t image/jpeg -o' ],
);

my $type = `xclip -selection clipboard -t TARGETS -o` ;
$type = `xclip -selection primary -t TARGETS -o` if $type !~ /image/ ;

my $image_type = first_value { $type =~ /$_/ } keys %commands;
my $use_commands = $commands{$image_type} if $image_type;

my $image ;
for (@{$use_commands // []})
	{
	$image = qx~$_~ ;
	last if($image ne '') ;
	}

if (!defined $image || $image eq '') {
	print STDERR "no image found!\n\e[m" ;
    return;
}

my ($character_width, $character_height) = $self->get_character_size() ;

my $image_box = new App::Asciio::stripes::image_box
		({
		NAME => 'image_box',
		TEXT_ONLY => ' ',
		TITLE => '',
		EDITABLE => 0,
		RESIZABLE => 1,
		AUTO_SHRINK => 0,
		CHARACTER_WIDTH => $character_width,
		CHARACTER_HEIGHT => $character_height,
		IMAGE => $image,
		IMAGE_TYPE => $image_type,
		});

$self->add_element_at($image_box, $self->{MOUSE_X}, $self->{MOUSE_Y});

$self->select_elements(1, $image_box);

$self->update_display();
}

#----------------------------------------------------------------------------------------------
sub import_from_clipboard
{
my ($self, $obj) = @_ ;

my $ascii = qx~xsel -b -o~ ;
$ascii = decode("utf-8", $ascii);
$ascii =~ s/\r//g;
$ascii =~ s/\t/$self->{TAB_AS_SPACES}/g;

my $element = $self->add_new_element_named('Asciio/' . $obj, $self->{MOUSE_X}, $self->{MOUSE_Y}) ;
$element->set_text('', $ascii) ;
$self->select_elements(1, $element) ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub import_from_clipboard_to_box
{
my ($self) = @_ ;
import_from_clipboard($self, 'box');
}

#----------------------------------------------------------------------------------------------

sub import_from_clipboard_to_text
{
my ($self) = @_ ;
import_from_clipboard($self, 'text');
}

#----------------------------------------------------------------------------------------------


1 ;

