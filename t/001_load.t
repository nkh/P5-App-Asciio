
# test module loading

use strict ;
use warnings ;

use Test::NoWarnings qw(warnings clear_warnings);
use Test::Warn ;

use Test::More qw(no_plan);

use_ok( 'App::Asciio' ) or BAIL_OUT("Can't load module"); 
	
for my $warning (warnings())
	{
	my $message = $warning->getMessage() ;
	chomp $message ;
	
	fail("No warnings. Found '$message'!") unless $message =~ /asked to lazy-load .* but that package is not registered/ ;
	}
	
clear_warnings() ;