
package App::Asciio::GTK::Asciio ;

use strict ; use warnings ;

use MIME::Base64 ;
use Clone ;

use Sereal qw(
	get_sereal_decoder
	get_sereal_encoder
	looks_like_sereal
	) ;

use Sereal::Encoder qw(SRL_SNAPPY SRL_ZLIB SRL_ZSTD) ;

use App::Asciio::Actions::Clipboard ;
use App::Asciio::String ;

#--------------------------------------------------------------------------

sub setup_dnd
{
my ($self, $window)  = @_ ; 

$window = $self->{widget} ;

my @targets=
	(
	Gtk3::TargetEntry->new( 'ASCIIO'       , 0, 0 ),
	Gtk3::TargetEntry->new( 'text/uri-list', 0, 1 ),
	Gtk3::TargetEntry->new( 'text/plain'   , 0, 2 ),
	Gtk3::TargetEntry->new( 'STRING'       , 0, 3 ),
	) ;

# $window->drag_source_set(['button1_mask', 'button3_mask'], \@targets, ['copy','move']) ;
$window->signal_connect('drag-begin' => \&drag_begin_cb, $self);

my $target_list = Gtk3::TargetList->new([ @targets ]) ;

$window->drag_dest_set('all', \@targets, ['copy', 'move']) ;
$window->drag_dest_set_target_list($target_list) ;

$window->signal_connect(drag_data_received => \&drag_data_received_cb, $self) ;

# $window->signal_connect(drag_motion => sub{ print STDERR "drag_motion\n"}, $self) ;
$window->signal_connect(drag_end => sub { $self->{IN_DRAG_DROP} = 0 ; }, $self);

$window->signal_connect(drag_data_get => \&drag_data_get_cb, $self) ;
}

#--------------------------------------------------------------------------

sub drag_data_get_cb
{
my ($widget, $context, $data, $info, $time, $self ) = @_ ;

if($info == 0)
	{
	my $serialized_elements = App::Asciio::Actions::Clipboard::serialize_selected_elements($self) ;

	my $atom2 = Gtk3::Gdk::Atom::intern('ASCIIO', Glib::FALSE) ;
	$data->set($atom2, 8, [unpack 'C*', $serialized_elements] ) ;
	}
else
	{
	$data->set_text($self->transform_elements_to_ascii_buffer($self->get_selected_elements(1)), -1) ;
	}

$self->{widget}->drag_source_unset ;
}

#--------------------------------------------------------------------------

sub drag_begin_cb
{
my ( $widget, $context, $self ) = @_ ;

# change icon
my $text = $self->transform_elements_to_ascii_buffer_aligned_left($self->get_selected_elements(1)) ;
my $lines = $text =~ tr /\n/\n/ ;

my ($character_width, $character_height) = $self->get_character_size() ;
my ($width, $height)                     = (max(map { unicode_length $_ } split('\n', $text)) * $character_width, $character_height * $lines) ;
my $surface                              = Cairo::ImageSurface->create('argb32', $width, $height) ;
my $gc                                   = Cairo::Context->create($surface) ;
my $layout                               = Pango::Cairo::create_layout($gc) ;
my $font_description                     = Pango::FontDescription->from_string($self->get_font_as_string()) ;

$gc->set_source_rgb(@{$self->get_color('drag_and_drop')}) ;

$layout->set_font_description($font_description) ;
$layout->set_text($text) ;

Pango::Cairo::show_layout($gc, $layout) ;

Gtk3::drag_set_icon_surface($context,$surface) ;
}

#--------------------------------------------------------------------------

sub drag_data_received_cb
{
my ($widget, $context, $x, $y, $data, $info, $time, $self) = @_ ;

($self->{PREVIOUS_X}, $self->{PREVIOUS_Y}) = ($self->{MOUSE_X}, $self->{MOUSE_Y}) ;

my ($character_width, $character_height) = $self->get_character_size() ;
($self->{MOUSE_X}, $self->{MOUSE_Y}) = (int($x / $character_width), int($y / $character_height)) ;
	

if($data->get_data_type == Gtk3::Gdk::Atom::intern('ASCIIO', Glib::FALSE))
	{
	my $serialized_elements = pack 'C*', @{$data->get_data} ;
	
	$self->{CLIPBOARD} = Clone::clone
				(
				get_sereal_decoder()->decode
					(
					MIME::Base64::decode_base64($serialized_elements)
					)
				) ;
	
	App::Asciio::Actions::Clipboard::insert_from_clipboard($self) ;
	
	warn "Asciio: Asciio elements\n" ;
	Gtk3::drag_finish($context, 1, 0, $time);
	}
elsif($info == 1)
	{
	my @uris = @{ $data->get_uris } ;
	warn "Asciio: uri: $uris[0]\n" ;
	
	my $box = new App::Asciio::stripes::editable_box2
			({
			TEXT_ONLY => join("\n", @uris),
			TITLE => '',
			EDITABLE => 1,
			RESIZABLE => 1,
			}) ;
	
	$self->add_element_at_no_connection($box, $self->{MOUSE_X}, $self->{MOUSE_Y}) ;
	$self->update_display() ;
	
	Gtk3::drag_finish($context, 1, 0, $time);
	}
elsif($info == 2 || $info == 3)
	{
	my $text = $data->get_text ;
	
	my $box = new App::Asciio::stripes::editable_box2
			({
			TEXT_ONLY => $text,
			TITLE => '',
			EDITABLE => 1,
			RESIZABLE => 1,
			}) ;
	
	$self->add_element_at_no_connection($box, $self->{MOUSE_X}, $self->{MOUSE_Y}) ;
	$self->update_display() ;
	
	Gtk3::drag_finish($context, 1, 0, $time);
	}
}

#--------------------------------------------------------------------------

sub start_dnd
{
my ($self, $event) = @_ ;

my $target_list = Gtk3::TargetList->new
			([
			Gtk3::TargetEntry->new( 'ASCIIO'    , 0, 0 ),
			Gtk3::TargetEntry->new( 'text/plain', 0, 1 ),
			]) ;

my @targets=
	(
	Gtk3::TargetEntry->new( 'ASCIIO'    , 0, 0 ),
	Gtk3::TargetEntry->new( 'text/plain', 0, 1 ),
	) ;

$self->{widget}->drag_source_set(['button1_mask', 'button3_mask'], \@targets, ['copy','move']) ;
$self->{widget}->drag_begin_with_coordinates
	(
	$target_list,
	'copy', # actions
	1, #$button,
	$event,
	0, #$x,
	0, #$y
	) if $event->state() >= "button1-mask" ;
}

#--------------------------------------------------------------------------

1 ;
