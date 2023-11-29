package App::Asciio::Server ;

use strict ; use warnings ;

use Data::TreeDumper ;

use Socket ;
use Gtk3::Helper;

use HTTP::Daemon ;
use HTTP::Request::Params ;
use HTTP::Status ;
use HTTP::Tiny;

use App::Asciio::Scripting ;
use JSON ;

# -------------------------------------------------- 

{
my $response_connection ;
sub RESPONSE_REGISTER { ($response_connection) = @_ }

sub RESPONSE_RAW
{
my ($response) = @_ ;

my $r = HTTP::Response->new(RC_ACCEPTED) ;
$r->content($response) ;

$response_connection->send_response($r) ;
}

sub RESPONSE
{
my ($response) = @_ ;

my $r = HTTP::Response->new(RC_ACCEPTED) ;
$r->content( join '&',  map { $_ . '=' . ($response->{$_} // 'undef') } keys %$response ) ;

$response_connection->send_response($r) ;
}
}

# -------------------------------------------------- 

sub start_web_server
{
my ($self, $port) = @_ ;

my ($to_child, $to_parent) ;
socketpair($to_child, $to_parent, AF_UNIX, SOCK_STREAM, PF_UNSPEC) or die "socketpair: $!" ;

my $pid = fork() ;
if($pid)
	{
	close($to_parent) ;
	
	$to_child->autoflush(1);
	
	my $tag ;
	$tag = Gtk3::Helper->add_watch ($to_child->fileno, 'in', sub { web_server_callback($to_child, [$self, $tag] ) }) ;
	
	$self->{GTK3_TAG} = {TAG => $tag, PID => $pid} ;
	$self->{ON_EXIT} = 
		sub
		{
		Gtk3::Helper->remove_watch($self->{GTK3_TAG}{TAG}) or die "GTK3::Helper: couldn't remove watcher" ;
		kill 15, $self->{GTK3_TAG}{PID} ;
		} ;
	
	return($to_child, $pid) ;
	}
else
	{
	# new process
	unless(defined $pid)
		{
		# couldn't fork
		close($to_child) ;
		close($to_parent) ;
		return ;
		}
		
	close($to_child) ;
	
	$to_parent->autoflush(1) ;
	
	my $daemon = HTTP::Daemon->new(ReusePort => 1, LocalAddr => 'localhost', LocalPort => $port) or die "Server: Error: can't start server\n" ;
	print  "Asciio: running HTTP server on port $port\n" ;
	
	$SIG{INT} = sub {
			# print "Asciio: Server received SIGINT\n" ;
			undef $daemon ;
			} ;
	
	$SIG{TERM} = sub 
			{
			# print "Asciio: Server received SIGTERM\n" ;
			undef $daemon ;
			} ;
	
	my $counter = 0 ;
	my $stop = 0 ;
	
	while (my $c = $daemon->accept) 
		{
		RESPONSE_REGISTER $c ;
		
		$counter++ ;
		
		while (my $rq = $c->get_request)
			{
			my $path = $rq->uri->path ;
			
			# print "Asciio: Http: " . $rq->method . ' ' . $daemon->url . "$path, count: $counter - $$\n" ;
			
			if ($rq->method eq 'GET')
				{
				'/' eq $path && RESPONSE { TEXT => "counter: $counter" }  ;
				}
			elsif ($rq->method eq 'POST')
				{
				local @ARGV = () ; # weird, otherwise it ends up in the parsed parameters
				
				my $parser = HTTP::Request::Params->new({req => $rq}) ;
				my $parameters = $parser->params() ;
				
				# '/' eq $path && print "Asciio:: Web server: POST\n" . DumpTree($parameters) ; 
				
				my $request_json = JSON->new->allow_nonref->canonical(1)->pretty->encode({ PATH => $path, PARAMETERS => $parameters}) ;
				print $to_parent $request_json . "\n" ; 
				
				$c->send_status_line ;
				$c->send_crlf ;
				}
			elsif ($rq->method eq 'PUT')
				{
				local @ARGV = () ; # otherwise it ends up in the parsed parameters
				
				my $parser = HTTP::Request::Params->new({req => $rq}) ;
				my $parameters = $parser->params() ;
				
				'/stop' eq $path && $stop++ ; 
				
				# '/' eq $path && print "Asciio:: Web server: PUT\n" . DumpTree($parameters) ; 
				
				my $request_json = JSON->new->allow_nonref->canonical(1)->pretty->encode({ PATH => $path, PARAMETERS => $parameters}) ;
				print $to_parent $request_json . "\n" ; 
				
				$c->send_status_line ;
				$c->send_crlf ;
				}
			
			$c->force_last_request ;
			}
		
		$c->close ;
		
		last if $stop ;
		}
	}
}

# -------------------------------------------------- 

sub web_server_callback
{
my ($fh, $asciio_tag) = @_ ;

my ($asciio, $tag) = $asciio_tag->@* ;

my $buffer ;
unless(sysread($fh, $buffer, 256 * 1024))
	{
	Gtk3::Helper->remove_watch($tag) or die "GTK3::Helper: couldn't remove watcher" ;
	close($fh) ;
	
	delete $asciio->{ON_EXIT} ;
	
	return 1 ;
	}

my $request    = JSON->new->decode($buffer) ;
my $path       = $request->{PATH} ;
my $parameters = $request->{PARAMETERS} ;

'/script_file' eq $path && App::Asciio::Scripting::run_external_script($asciio, $parameters->{script} // '') ;
'/script'      eq $path && App::Asciio::Scripting::run_external_script_text($asciio, $parameters->{script} // '', $parameters->{show_script}) ;

return 1 ;
}

# -------------------------------------------------- 

1 ;
