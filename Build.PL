
use strict ;
use warnings ;

use Module::Build;

my %all_modules ;
my @split_modules ;

my @pm_files = qw(
lib/App/Asciio.pm

lib/App/Asciio/Actions.pm
lib/App/Asciio/Ascii.pm
lib/App/Asciio/Boxes.pm
lib/App/Asciio/Connections.pm
lib/App/Asciio/Markup.pm
lib/App/Asciio/Cross.pm
lib/App/Asciio/Dialogs.pm
lib/App/Asciio/Elements.pm
lib/App/Asciio/Io.pm
lib/App/Asciio/Menues.pm
lib/App/Asciio/Options.pm
lib/App/Asciio/Scripting.pm
lib/App/Asciio/Server.pm
lib/App/Asciio/Setup.pm
lib/App/Asciio/Stencil.pm
lib/App/Asciio/String.pm
lib/App/Asciio/Geometry.pm
lib/App/Asciio/Undo.pm
lib/App/Asciio/ZBuffer.pm

lib/App/Asciio/Actions/Align.pm
lib/App/Asciio/Actions/Asciio.pm
lib/App/Asciio/Actions/Arrow.pm
lib/App/Asciio/Actions/Box.pm
lib/App/Asciio/Actions/Clipboard.pm
lib/App/Asciio/Actions/Clone.pm
lib/App/Asciio/Actions/Colors.pm
lib/App/Asciio/Actions/Debug.pm
lib/App/Asciio/Actions/Elements.pm
lib/App/Asciio/Actions/ElementsManipulation.pm
lib/App/Asciio/Actions/ElementAttributes.pm
lib/App/Asciio/Actions/Eraser.pm
lib/App/Asciio/Actions/File.pm
lib/App/Asciio/Actions/Git.pm
lib/App/Asciio/Actions/Mouse.pm
lib/App/Asciio/Actions/Multiwirl.pm
lib/App/Asciio/Actions/Presentation.pm
lib/App/Asciio/Actions/Ruler.pm
lib/App/Asciio/Actions/Selection.pm
lib/App/Asciio/Actions/Shapes.pm
lib/App/Asciio/Actions/Unsorted.pm
lib/App/Asciio/Actions/ZBuffer.pm
lib/App/Asciio/Actions/Tabs.pm

lib/App/Asciio/stripes/angled_arrow.pm
lib/App/Asciio/stripes/center_connect_box.pm
lib/App/Asciio/stripes/editable_arrow2.pm
lib/App/Asciio/stripes/editable_box2.pm
lib/App/Asciio/stripes/ellipse.pm
lib/App/Asciio/stripes/exec_box.pm
lib/App/Asciio/stripes/group.pm
lib/App/Asciio/stripes/if_box.pm
lib/App/Asciio/stripes/process_box.pm
lib/App/Asciio/stripes/rhombus.pm
lib/App/Asciio/stripes/section_wirl_arrow.pm
lib/App/Asciio/stripes/single_stripe.pm
lib/App/Asciio/stripes/stripes.pm
lib/App/Asciio/stripes/triangle_down.pm
lib/App/Asciio/stripes/triangle_up.pm
lib/App/Asciio/stripes/wirl_arrow.pm
lib/App/Asciio/stripes/dot.pm

lib/App/Asciio/Utils/Presentation.pm
lib/App/Asciio/Utils/Scripting.pm

lib/App/Asciio/GTK/Asciio.pm
lib/App/Asciio/GTK/Asciio/HelpWidget.pm
lib/App/Asciio/GTK/Asciio/TabbedAsciio.pm
lib/App/Asciio/GTK/Asciio/TabManager.pm
lib/App/Asciio/GTK/Asciio/TabManager/WebApi.pm

lib/App/Asciio/GTK/Asciio/Boxfuncs.pm
lib/App/Asciio/GTK/Asciio/Dialogs.pm
lib/App/Asciio/GTK/Asciio/DnD.pm
lib/App/Asciio/GTK/Asciio/Selection.pm
lib/App/Asciio/GTK/Asciio/Pen.pm
lib/App/Asciio/GTK/Asciio/Find.pm
lib/App/Asciio/GTK/Asciio/Menues.pm

lib/App/Asciio/GTK/Asciio/stripes/angled_arrow.pm
lib/App/Asciio/GTK/Asciio/stripes/editable_arrow2.pm
lib/App/Asciio/GTK/Asciio/stripes/editable_box2.pm
lib/App/Asciio/GTK/Asciio/stripes/editable_exec_box.pm
lib/App/Asciio/GTK/Asciio/stripes/ellipse.pm
lib/App/Asciio/GTK/Asciio/stripes/rhombus.pm
lib/App/Asciio/GTK/Asciio/stripes/section_wirl_arrow.pm
lib/App/Asciio/GTK/Asciio/stripes/wirl_arrow.pm
lib/App/Asciio/GTK/Asciio/stripes/image_box.pm
lib/App/Asciio/GTK/Asciio/Actions/File.pm

lib/App/Asciio/Text/Asciio.pm
lib/App/Asciio/Text/Asciio/Dialogs.pm
lib/App/Asciio/Text/Asciio/Menues.pm
lib/App/Asciio/Text/Asciio/stripes/editable_arrow2.pm
lib/App/Asciio/Text/Asciio/stripes/editable_box2.pm
lib/App/Asciio/Text/Asciio/stripes/editable_exec_box.pm
lib/App/Asciio/Text/Asciio/stripes/section_wirl_arrow.pm
lib/App/Asciio/Text/Asciio/stripes/wirl_arrow.pm
);

for(@pm_files)
	{
	$all_modules{$_} = $_ ;
	push @split_modules, $_ ;
	}

my @setup_lib=
qw(
setup/setup.ini

setup/actions/default_bindings.pl

setup/asciio_object/basic.pl
setup/hooks/canonize_connections.pl

setup/import_export/ascii.pl
setup/import_export/json.pl
setup/import_export/perl.pl
setup/import_export/svg.pl

setup/Asciio
setup/Stencils/Computer
setup/Stencils/Divers
setup/Stencils/People

setup/GTK/setup.ini
setup/GTK/import_export/png.pl

setup/Text/setup.ini
setup/Text/actions/vim_bindings.pl
setup/Text/asciio_object/basic.pl
) ;

for(@setup_lib)
	{
	$all_modules{$_} = "lib/App/Asciio/$_" ;
	}

sub GetVersionAndRevisionFrom
{
my ($file) = @_ ;

my $version_from = File::Spec->catfile( split '/', $file );
my $version      = Module::Build->version_from_file($version_from);

if($ENV{'App_Asciio_USE_GIT_VERSION_FOR_DIST'})
	{
	my $number_of_commits = `git log | grep -E 'commit [0-9a-f]{40}' | wc -l` ;
	chomp $number_of_commits ;
	
	if($number_of_commits)
		{
		#print "number of git revision: $number_of_commits.\n" ;
		return("${version}.${number_of_commits}") ;
		}
	else
		{
		print "Couldn't get git revision, using version from '$file'!\n" ;
		return($version) ;
		}
	}
else
	{
	return($version) ;
	}
}

my $code = <<'EOC';
use strict ;
use warnings ;

sub GetVersionAndRevisionFrom
{
my ($file) = @_ ;

my $version_from = File::Spec->catfile( split '/', $file );
my $version      = Module::Build->version_from_file($version_from);

if($ENV{'App_Asciio_USE_GIT_VERSION_FOR_DIST'})
	{
	my $number_of_commits = `git log | grep -E 'commit [0-9a-f]{40}' | wc -l` ;
	chomp $number_of_commits ;
	
	if($number_of_commits)
		{
		#print "number of git revision: $number_of_commits.\n" ;
		return("${version}.${number_of_commits}") ;
		}
	else
		{
		print "Couldn't get git revision, using version from '$file'!\n" ;
		return($version) ;
		}
	}
else
	{
	return($version) ;
	}
}

sub ACTION_author_test
{
my $self = shift;
local $self->{properties}{test_files} = 'xt/author/*.t' ;
$self->SUPER::ACTION_test();
}

sub ACTION_build 
{
my $self = shift;

if($ENV{'App_Asciio_USE_GIT_VERSION_FOR_DIST'})
	{
	my ($version) = GetVersionAndRevisionFrom('lib/App/Asciio.pm') ;
	
	#~ print "Generating version module ($version)\n" ;
	
	open VERSION, '>', 'Version.pm' or die "can't generate Version module: $!\n" ;
	
	print VERSION <<EOV ;
	
	# version module automatically generated by the build system
	
	package Config::Version ;
	
	sub GetVersion {return '$version'} ;
	
	1 ;
	
	# end of generated version module
EOV
	
	close VERSION ;
	}
	
$self->SUPER::ACTION_build(@_);
}

sub ACTION_dist
{
my $self = shift;

$self->SUPER::ACTION_test() ;

$self->SUPER::ACTION_dist();
};


EOC

my $class = Module::Build->subclass(class => 'App::Asciio', code => $code) ;

my $build = $class->new
	(
	module_name => 'App::Asciio',
	
	dist_version => GetVersionAndRevisionFrom('lib/App/Asciio.pm'),
	
	license => 'perl',
	build_requires => 
		{
		'Directory::Scratch::Structured' => 0,
		'Hash::Slice'                    => 0,
		'Module::Build'                  => 0,
		'Module::Install'                => 0,
		'Test::Exception'                => 0,
		'Test::NoWarnings'               => 0,
		'Test::Warn'                     => 0,
		'Text::Diff'                     => 0,
		},
	
	requires => 
		{
		'Archive::Tar'                    => 0,
		'Clone'                           => 0,
		'Compress::Bzip2'                 => 0,
		'Cwd'                             => 0,
		'Data::Compare'                   => 0,
		'Data::TreeDumper'                => 0.41,
		'Digest::MD5'                     => 0,
		'Eval::Context'                   => 0,
		'ExtUtils::PkgConfig'             => 0,
		'Image::ExifTool'                 => 0,
		'File::Basename'                  => 0,
		'File::Copy'                      => 0,
		'File::HomeDir'                   => 0,
		'File::Slurper'                   => 0,
		'File::Spec'                      => 0,
		'Glib'                            => 0,
		'Gtk3'                            => 0,
		'Data::TreeDumper::Renderer::GTK' => 0,
		'IO::Prompter'                    => 0,
		'List::MoreUtils'                 => 0,
		'List::Util'                      => 0,
		'MIME::Base64'                    => 0,
		'Module::Build::Compat'           => 0,
		'Module::Util'                    => 0,
		'Number::Compare'                 => 0,
		'Readonly'                        => 0,
		'Sereal'                          => 5.004,
		'Sub::Exporter'                   => 0,
		'Sub::Util'                       => 0,
		'Term::ReadKey'                   => 0,
		'Term::Size::Any'                 => 0,
		'Term::TermKey'                   => 0,
		'Test::Block'                     => 0,
		'Gtk3::Helper'                    => 0,
		'HTTP::Request::Params'           => 0,
		'Module::Install'                 => 0,
		'Hash::Slice'                     => 0,
		'Gtk3::Helper'                    => 0,
		'HTTP::Daemon'                    => 0,
		'HTTP::Request::Params'           => 0,
		'JSON'                            => 0,
		'version'                         => 0.50,
		},
		
	pm_files     => \%all_modules,
	
	script_files => [qw(
			script/asciio
			script/tasciio
			script/asciio_to_text
			script/text_to_asciio
			script/A
			script/TA
			script/AV
			script/T
			script/stdin_to_asciio
			script/json_dtd_to_asciio_script)
			],
	dist_author  => 'Khemir Nadim ibn Hamouda. <nadim@gmail.com>',
	dist_abstract => 'App::Asciio - ASCII diagramming',
	);
	
$build->create_build_script;
  

