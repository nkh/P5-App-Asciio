package App::Asciio::Actions::Clipboard ;
use strict ;
use warnings ;

#----------------------------------------------------------------------------------------------

use utf8;
use Encode qw(decode FB_CROAK) ;
use List::Util qw(min max) ;
use MIME::Base64 ;
use Clone ;

use Sereal qw(
	get_sereal_decoder
	get_sereal_encoder
	looks_like_sereal
	) ;

use Sereal::Encoder qw(SRL_SNAPPY SRL_ZLIB SRL_ZSTD) ;
use App::Asciio::GTK::Asciio::stripes::image_box ;

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

my @connections = grep 
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

my $serialized_import_success = import_serialized_elements_from_system_clipboard($self, @args) ;

unless($serialized_import_success)
	{
	import_image_from_system_clipboard($self) ;
	}
}

#----------------------------------------------------------------------------------------------

sub import_image_from_system_clipboard
{
my ($self) = @_ ;

my ($image_data, $image_type) = read_clipboard_image() ;

if ($image_data)
	{
	my ($character_width, $character_height) = $self->get_character_size() ;
	
	my $image_box = new App::Asciio::GTK::Asciio::stripes::image_box
		({
		NAME => 'image_box',
		TEXT_ONLY => ' ',
		TITLE => '',
		EDITABLE => 0,
		RESIZABLE => 1,
		AUTO_SHRINK => 0,
		CHARACTER_WIDTH => $character_width,
		CHARACTER_HEIGHT => $character_height,
		IMAGE => $image_data,
		IMAGE_TYPE => $image_type,
		});
	
	$self->add_element_at($image_box, $self->{MOUSE_X}, $self->{MOUSE_Y}) ;
	$self->select_elements(1, $image_box) ;
	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

sub import_serialized_elements_from_system_clipboard
{
my ($self, @args) = @_ ;

my @clipboard_out_options=("-b", "-p") ;
my $serialized_data ;

for my $option (@clipboard_out_options)
	{
	my $elements_base64 = read_clipboard_raw_text($option) ;
	
	my $decoded = MIME::Base64::decode_base64($elements_base64) ;
	
	if(looks_like_sereal($decoded))
		{
		$serialized_data = $decoded ;
		last;
		}
	else
		{
		$self->{WARN}->("data from $option is invalid!\n") ;
		}
	}

if (defined $serialized_data)
	{
	$self->{CLIPBOARD} = Clone::clone(get_sereal_decoder()->decode($serialized_data)) ;
	insert_from_clipboard($self, @args) ;
	return 1 ;
	}
else
	{
	return 0 ;
	}
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

#----------------------------------------------------------------------------------------------

sub export_elements_to_system_clipboard
{
my ($self) = @_ ;

write_clipboard_raw_text(serialize_selected_elements($self)) ;
}

#----------------------------------------------------------------------------------------------

sub export_to_clipboard_as_ascii
{
my ($self) = @_ ;

write_clipboard_raw_text(
	$self->transform_elements_to_ascii_buffer($self->get_selected_elements(1))
	) ;
}

#----------------------------------------------------------------------------------------------

sub export_to_clipboard_as_markup
{
my ($self) = @_ ;

write_clipboard_raw_text(
	$self->transform_elements_to_markup_buffer($self->get_selected_elements(1))
	) ;
}

#----------------------------------------------------------------------------------------------

sub import_from_primary_to_box { my ($self) = @_ ; import_from_clipboard($self, '-p', 'box'); }

#----------------------------------------------------------------------------------------------

sub import_from_primary_to_text { my ($self) = @_ ; import_from_clipboard($self, '-p', 'text'); }

#----------------------------------------------------------------------------------------------

sub import_from_clipboard_to_box { my ($self) = @_ ; import_from_clipboard($self, '-b', 'box'); }

#----------------------------------------------------------------------------------------------

sub import_from_clipboard_to_text { my ($self) = @_ ; import_from_clipboard($self, '-b', 'text'); }

#----------------------------------------------------------------------------------------------

sub import_from_clipboard
{
my ($self, $source, $obj) = @_ ;

my $ascii = read_clipboard_raw_text($source) ;

$ascii = eval { decode("UTF-8", $ascii, FB_CROAK) } || decode("GBK", $ascii) ;

$ascii =~ s/\r//g;
$ascii =~ s/\t/$self->{TAB_AS_SPACES}/g;

my $element = $self->add_new_element_named('Asciio/' . $obj, $self->{MOUSE_X}, $self->{MOUSE_Y}) ;
$element->set_text('', $ascii) ;
$self->select_elements(1, $element) ;

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub write_clipboard_raw_text
{
my ($text) = @_ ;

if ($^O eq 'MSWin32')
	{
	my $ok = eval
			{
			require Win32::Clipboard ;
			Win32::Clipboard()->Set(Encode::decode('UTF-8', $text)) ;
			1 ;
			} ;
	
	if (!$ok)
		# fallback to PowerShell
		{
		open my $POWERSHELL, "|-", "powershell", "-Command",
			"[Console]::InputEncoding = [System.Text.Encoding]::UTF8; \$input | Set-Clipboard"
			or die "Can't open PowerShell" ;
		
		binmode($POWERSHELL, ":encoding(UTF-8)") ;
		print $POWERSHELL $text ;
		close $POWERSHELL ;
		}
	}
else
	{
	for my $opt ('-b', '-p')
		{
		local $SIG{PIPE} = sub { die "xsel pipe broke for $opt" } ;
		open my $CLIP, "| xsel -i $opt" or die "Can't write to clipboard $opt" ;
		binmode($CLIP, ":encoding(UTF-8)") ;
		print $CLIP $text ;
		close $CLIP ;
		}
	}
}

#----------------------------------------------------------------------------------------------

sub read_clipboard_raw_text
{
my ($option) = @_ ;

if ($^O eq 'MSWin32')
	{
	my $clip = eval
			{
			require Win32::Clipboard ;
			Win32::Clipboard()->Get() ;
			} ;
	
	# fallback to PowerShell
	return defined $clip ? $clip : qx{powershell -Command "Get-Clipboard"} ;
	}
else
	{
	return qx{xsel $option -o} ;
	}
}

#----------------------------------------------------------------------------------------------

sub read_clipboard_image
{
return $^O eq 'MSWin32' ? read_clipboard_image_win() : read_clipboard_image_x11() ;
}

#----------------------------------------------------------------------------------------------

sub read_clipboard_image_win
{
my $ps_command = <<'END_PS' ;
$img = Get-Clipboard -Format Image ;
if ($img) {
	$ms = New-Object System.IO.MemoryStream;
	$img.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png);
	$ms.Position = 0;
	$bytes = $ms.ToArray();
	[Convert]::ToBase64String($bytes)
}
END_PS

my $base64 = `powershell -Command "$ps_command"` ;
$base64 =~ s/\s+//g ;

return (undef, undef) unless $base64 ;

my $image = decode_base64($base64) ;

return ($image, 'png') ;
}

#----------------------------------------------------------------------------------------------

sub read_clipboard_image_x11
{
my $targets = qx{xclip -selection clipboard -t TARGETS -o} ;

my %mime_map = ('image/jpeg' => 'jpeg', 'image/png'  => 'png',) ;

for my $mime (keys %mime_map)
	{
	if ($targets =~ /\Q$mime\E/)
		{
		return (qx{xclip -selection clipboard -t $mime -o}, $mime_map{$mime}) ;
		}
	}

return (undef, undef) ;
}

#----------------------------------------------------------------------------------------------

1 ;

