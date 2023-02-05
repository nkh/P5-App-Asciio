
use strict ;
use warnings ;

use App::Asciio::Utils::Presentation ;

[ 

new_slide_single_box_at(0, 0, <<EOT) ,
  
EOT

load_diagram(0, 0, 'tutorial/Front_page.asciio'),
load_diagram(0, 0, 'tutorial/Help.asciio'),
load_diagram(0, 0, 'tutorial/Asciio_UI.asciio'),
load_diagram(0, 0, 'tutorial/Objects.asciio'),
load_diagram(0, 0, 'tutorial/Files_manipulation.asciio'),
	#~ save file
	#~ opening files
		#~ in Asciio
		#~ on the command line
	#~ multiple formats
	#~ load
	#~ insert
load_diagram(0, 0, 'tutorial/Boxes.asciio'),
	#~ 4 types
	#~ multiple element creation
load_diagram(0, 0, 'tutorial/Arrows.asciio'),
	#~ 4 types
load_diagram(0, 0, 'tutorial/Connecting_things_together.asciio'),
	#~ auto connect
	#~ no auto connect
	#~ quick link
	#~ insert add section
	#~ remove section
load_diagram(0, 0, 'tutorial/Advanced_element_manipulation.asciio'),
	#~ grouping
	#~ front back
	#~ alt+f
load_diagram(0, 0, 'tutorial/content_from_external_commands.asciio'),
load_diagram(0, 0, 'tutorial/Personalize_Asciio.asciio'),
	#~ font size
	#~ default rulers
	#~ stencils
	#~ scripting
		#~ --script
load_diagram(0, 0, 'tutorial/Making_ASCII_slides.asciio'),
load_diagram(0, 0, 'tutorial/Scripting_Asciio.asciio'),
] ;	
