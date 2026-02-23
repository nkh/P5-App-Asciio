
use strict ;
use warnings ;

use File::Slurper qw(read_text write_text) ;

# ------------------------------------------------------------------------------ 

use App::Asciio::Utils::Scripting ;

# ------------------------------------------------------------------------------ 

register_import_export_handlers 
	(
	apl => 
		{
		IMPORT => \&import_apl ,
		EXPORT => \&export_apl,
		},
	) ;

# ------------------------------------------------------------------------------ 

sub import_apl
{
my ($self, $file)  = @_ ;

$self->select_all_elements() ;
$self->delete_selected_elements() ;

Glib::Timeout->add (50, sub { App::Asciio::Utils::Scripting::run_external_script($self, $file) ; return 0 ; }) ;

return (undef, $file, undef) ;
}

# ------------------------------------------------------------------------------ 

sub export_apl
{
my ($self, $elements_to_save, $file)  = @_ ;

if($self->{CREATE_BACKUP} && -e $file)
	{
	use File::Copy;
	copy($file,"$file.bak") or die "export_pod: Copy failed while making backup copy: $!" ;
	}

my $to_apl = '' ;
my $ascii_buffer = $self->transform_elements_to_ascii_buffer() ;

my $element_index = 0 ;
for my $element ( grep { ref $_ eq 'App::Asciio::stripes::editable_box2' } $self->{ELEMENTS}->@*)
	{
	$to_apl .= serialize_box($element) ; 
	$element_index++ ;
	}
$to_apl .= "\n" ;

$element_index = 0 ;
for my $element ( grep { ref $_ eq 'App::Asciio::stripes::section_wirl_arrow' } $self->{ELEMENTS}->@*)
	{
	$to_apl .= serialize_section_wirl_arrow($element) ; 
	$element_index++ ;
	}
$to_apl .= "\n" ;

$to_apl .= serialize_connections($self->{CONNECTIONS}) ;

my $saved = write_text($file, $to_apl) ;

return $file ;
}

# ------------------------------------------------------------------------------ 

sub serialize_box
{
my ($element) =  @_ ;

my @fields =
	qw(
	AUTO_SHRINK
	COLORS
	CONNECTORS
	EDITABLE
	EXTENTS
	HEIGHT
	ID
	RESIZABLE
	SELECTED
	STRIPES
	TEXT
	TEXT_BEGIN
	TEXT_ONLY
	TITLE
	TITLE_SEPARATOR_EXISTS
	WIDTH
	X
	Y
	) ;

my $to_apl = "add '" . ($element->{ID} // '?') . "', new_box(TEXT_ONLY =>'$element->{TEXT_ONLY}'),  $element->{X},  $element->{Y} ;\n" ;
}

# ------------------------------------------------------------------------------ 

sub serialize_section_wirl_arrow
{
my ($element) =  @_ ;

my @fields =
	qw(
	ALLOW_DIAGONAL_LINES
	COLORS
	DIRECTION
	EDITABLE
	EXTENTS
	HEIGHT
	NAME
	NOT_CONNECTABLE_END
	NOT_CONNECTABLE_START
	POINTS_OFFSETS
	SELECTED
	WIDTH
	X
	Y
	) ;

=pod
# use Data::TreeDumper ;
# print DumpTree $element, 'arrow:', MAX_DEPTH => 3 ;


arrow: blessed in 'App::Asciio::stripes::section_wirl_arrow'
|- ALLOW_DIAGONAL_LINES = 0  [S1]
|- ARROW_TYPE  [A2]
|- ARROWS  [A139]
|  `- 0 =  blessed in 'App::Asciio::stripes::wirl_arrow'  [OH140]
|     |- ALLOW_DIAGONAL_LINES = 0  [S141]
|     |- ARROW_TYPE  [A142 -> A2]
|     |- CACHE (no elements)  [H143]
|     |- DIRECTION = left-up  [S144]
|     |- END_X = -27  [S145]
|     |- END_Y = -8  [S146]
|     |- EXTENTS  [A147]
|     |- HEIGHT = 9  [S148]
|     |- STRIPES  [A149]
|     `- WIDTH = 28  [S150]
|- DIRECTION = down  [S156]
|- EXTENTS  [A158]
|  |- 0 = -27  [S159]
|  |- 1 = -8  [S160]
|  |- 2 = 1  [S161]
|  `- 3 = 1  [S162]
|- HEIGHT = 9  [S163]
|- POINTS_OFFSETS  [A166]
|  `- 0  [A167]
|     |- 0 = 0  [S168]
|     `- 1 = 0  [S169]
|- WIDTH = 28  [S170]
|- X = 49  [S171]
`- Y = 21  [S172]

=cut

return "add '" . ($element->{ID} // '?') . "', new_wirl_arrow([$element->{ARROWS}[0]{END_X}, $element->{ARROWS}[0]{END_Y}, '$element->{ARROWS}[0]{DIRECTION}']), $element->{X}, $element->{Y} ;\n" ;
}

# ------------------------------------------------------------------------------ 

sub serialize_wirl_arrow
{
my ($element) =  @_ ;

my @fields =
	qw(
	ALLOW_DIAGONAL_LINES
	DIRECTION
	END_X
	END_Y
	STRIPES
	WIDTH
	) ;

}

# ------------------------------------------------------------------------------ 

sub serialize_connections
{
my ($connections) = @_ ;

my $to_apl  = '' ;

return "# connection serialization missing" ;

# use Data::TreeDumper ;
# print DumpTree $connections, 'connections' ;

# scripting connect connects both ends, some arrow have just one connection

my $connection_index = 0 ;
for my $connection ($connections->@*)
	{
	$to_apl .= "connect_elements '" . $connection->{CONNECTEE}{ID} . "', '" . $connection->{CONNECTEE}{ID} . "', 'down' ;\n" ;
	
	$connection_index++ ;
	}

return $to_apl ;
}



