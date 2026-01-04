
#package App::Asciio::GTK::Asciio::FindAndReplace ;
package App::Asciio ;

use warnings ; use strict ;
use utf8;

our $FIND_IN_TITLE = 1 ;
our $FIND_IN_TEXT  = 2 ;

#----------------------------------------------------------------------------------------------

sub get_elements_matching
{
my ($self, $fields, $regexp, @elements) = @_ ;
my %matching_elements ;

for my $element (@elements)
	{
	if($fields & $FIND_IN_TITLE)
		{
		for my $line (split /\n/, $element->{TITLE})
			{
			$matching_elements{$element} = $element if $line =~ $regexp ;
			}
		}
	
	if($fields & $FIND_IN_TEXT)
		{
		for my $line (split /\n/, $element->{TEXT_ONLY})
			{
			$matching_elements{$element} = $element if $line =~ $regexp ;
			}
		}
	}

return (values %matching_elements) ;
}

#----------------------------------------------------------------------------------------------

sub replace_in_title_and_text
{
my $self = shift @_ ;

return $self->replace_in_title(@_) + $self->replace_in_text(@_) ;
}

#----------------------------------------------------------------------------------------------

sub replace_in_title
{
my $self = shift @_ ;
return $self->replace_in_elements($FIND_IN_TITLE, @_) ;
}

sub replace_in_text
{
my $self = shift @_ ;
return $self->replace_in_elements($FIND_IN_TEXT, @_) ;
}

#----------------------------------------------------------------------------------------------

sub replace_in_elements
{
my ($self, $where, $regexp, $replacement, @elements) = @_ ;

my $modified = 0 ;

for my $element (@elements)
	{
	my $element_modified = 0 ;
	
	my $new_text = '' ;
	for my $line (split /\n/, $where == $FIND_IN_TITLE ? $element->{TITLE} : $element->{TEXT_ONLY})
		{
		$element_modified++ if $line =~ s/$regexp/$replacement/ ;
		$new_text .= "$line\n" ;
		}
	
	if($element_modified)
		{
		$element->setup
			(
			($where == $FIND_IN_TITLE ? $element->{TEXT_ONLY} : $new_text        ),
			($where == $FIND_IN_TITLE ? $new_text             : $element->{TITLE}),
			$element->{BOX_TYPE},
			$element->{WIDTH},
			$element->{HEIGHT},
			$element->{RESIZABLE},
			$element->{EDITABLE},
			$element->{AUTO_SHRINK},
			) ;
		
		delete $element->{CACHE} ;
		
		$modified++ ;
		}
	}

return $modified ;
}

#----------------------------------------------------------------------------------------------
1 ;

