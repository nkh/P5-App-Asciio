
use File::Slurp ;
use JSON ;

register_import_export_handlers 
	(
	json => 
		{
		IMPORT => undef ,
		EXPORT => \&export_json,
		},
	) ;

sub export_json
{
my ($self, $elements_to_save, $file)  = @_ ;

if($self->{CREATE_BACKUP} && -e $file)
	{
	use File::Copy;
	copy($file,"$file.bak") or die "export_pod: Copy failed while making backup copy: $!";		
	}

# use Data::TreeDumper ;
# write_file($file.'.ddt', {binmode => ':utf8'}, DumpTree($self)) ;

my $to_json = {} ;
my %element_to_index ;

$to_json->{ASCII_BUFFER} = $self->transform_elements_to_ascii_buffer() ;

my $element_index = 0 ;
for my $element ($self->{ELEMENTS}->@*)
	{
	$element_to_index{$element} = $element_index ;
	
	my $type = ref $element ;
	$to_json->{ELEMENTS}[$element_index]{type} = $type ;
	
	serialize_box($element, $to_json->{ELEMENTS}[$element_index])
		if $type eq "App::Asciio::stripes::editable_box2" ; 
	
	serialize_section_wirl_arrow($element, $to_json->{ELEMENTS}[$element_index])
		if $type eq 'App::Asciio::stripes::section_wirl_arrow' ;
	
	$element_index++ ;
	}

serialize_connections($self->{CONNECTIONS}, $to_json->{CONNECTIONS} = [], \%element_to_index) ;

my $saved = write_file
		(
		$file,
		{binmode => ':utf8'},
		JSON::XS->new->pretty(1)->canonical(1)->utf8->encode($to_json)
		) ;

return $file ;
}

# ------------------------------------------------------------------------------ 

sub serialize_connections
{
my ($connections, $to_json, $element_to_index) = @_ ;

my $connection_index = 0 ;
for my $connection ($connections->@*)
	{
	$to_json->[$connection_index] = 
		{
		CONNECTED  => $element_to_index->{$connection->{CONNECTED}},
		CONNECTEE  => $element_to_index->{$connection->{CONNECTEE}},
		CONNECTION => $connection->{CONNECTION},
		CONNECTOR  => $connection->{CONNECTOR},
		} ;
	
	$connection_index++ ;
	}
}


# ------------------------------------------------------------------------------ 

sub serialize_box
{
my ($element, $to_json) =  @_ ;

my @fields =
	qw(
	AUTO_SHRINK
	COLORS
	CONNECTORS
	EDITABLE
	EXTENTS
	HEIGHT
	NAME
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

@{$to_json}{@fields} = @{$element}{@fields} ;
}

# ------------------------------------------------------------------------------ 

sub serialize_section_wirl_arrow
{
my ($element, $to_json) =  @_ ;

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

@{$to_json}{@fields} = @{$element}{@fields} ;

my $element_index = 0 ;
for my $arrow ($element->{ARROWS}->@*)
	{
	serialize_wirl_arrow($arrow, $to_json->{ARROWS}{$element_index} = {}) ;
	$element_index++ ;
	}
}

# ------------------------------------------------------------------------------ 

sub serialize_wirl_arrow
{
my ($element, $to_json) =  @_ ;

my @fields =
	qw(
	ALLOW_DIAGONAL_LINES
	DIRECTION
	END_X
	END_Y
	STRIPES
	WIDTH
	) ;

# other fields:
# ARROW_TYPE

@{$to_json}{@fields} = @{$element}{@fields} ;
}

