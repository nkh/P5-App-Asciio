
package App::Asciio::GTK::Asciio::TabManager ;

use strict ; use warnings ;

sub web_callback
{
my ($tab_manager, $request, $path, $parameters, $to_child) = @_ ;

my $current_page = $tab_manager->{notebook}->get_current_page() ;
my $asciio       = $tab_manager->{asciios}[$current_page] ;

if(defined $parameters->{tab_id})
	{
	for my $i (0 .. $#{$tab_manager->{asciios}})
		{
		if ("$tab_manager->{asciios}[$i]" eq $parameters->{tab_id})
			{
			$asciio = $tab_manager->{asciios}[$i] ;
			last ;
			}
		}
	}

'/script_file'        eq $path && App::Asciio::Scripting::run_external_script($asciio, $parameters->{script} // '') ;
'/script'             eq $path && App::Asciio::Scripting::run_external_script_text($asciio, $parameters->{script} // '', $parameters->{show_script}) ;
'/get_current_tab_id' eq $path && print $to_child "$asciio\n" ;
'/new_tab'            eq $path && $tab_manager->create_tab() ;
'/set_title'          eq $path && $tab_manager->rename_tab($parameters->{new_title} // 'new title not set in script') ;
'/copy_tab'           eq $path && $tab_manager->create_tab({ serialized => $asciio->serialize_self() }) ;

return 1 ;
}

# ---------------------------------------------------------------------------- 

1 ;
