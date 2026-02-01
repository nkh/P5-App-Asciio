package Layout::Engine::Client;

use strict;
use warnings;
use IPC::Open3;
use Symbol qw(gensym);
use JSON::MaybeXS;
use IO::Handle;
use Carp qw(croak);

our $VERSION = '0.01';

=head1 NAME

Layout::Engine::Client - Persistent JSON client for the layout engine

=head1 SYNOPSIS

  use Layout::Engine::Client;

  my $client = Layout::Engine::Client->new(
      cmd              => './layout',
      input_separator  => '---END---',
      output_separator => '---END---',
  );

  my $req = {
      id    => 'example',
      nodes => [
          { id => 'A', width => 60, height => 40 },
          { id => 'B', width => 60, height => 40 },
      ],
      edges => [
          { source => 'A', target => 'B' },
      ],
      constraints => {
          layout   => JSON::true,
          routing  => 'orthogonal',
      },
  };

  my $resp = $client->layout($req);

  # Do something with $resp->{nodes}, $resp->{edges}, etc.

  $client->exit_engine;

=head1 DESCRIPTION

Layout::Engine::Client manages a persistent layout engine subprocess,
sending JSON requests and reading JSON responses with configurable
input/output separators.

=cut

sub new {
    my ($class, %args) = @_;

    my $cmd              = $args{cmd}              || './layout';
    my $input_sep        = $args{input_separator}  || '---END---';
    my $output_sep       = $args{output_separator} || '---END---';
    my $json             = JSON::MaybeXS->new(utf8 => 1, canonical => 1);

    my $self = bless {
        cmd              => $cmd,
        input_separator  => $input_sep,
        output_separator => $output_sep,
        json             => $json,
        pid              => undef,
        in_fh            => undef,
        out_fh           => undef,
        err_fh           => undef,
    }, $class;

    $self->_start_engine;

    return $self;
}

sub _start_engine {
    my ($self) = @_;

    return if defined $self->{pid};

    my $cmd = $self->{cmd};

    my @cmd = (
        $cmd,
        "--input-separator=$self->{input_separator}",
        "--separator=$self->{output_separator}",
    );

    my $err_fh = gensym;
    my ($in_fh, $out_fh);

    my $pid = eval {
        open3($in_fh, $out_fh, $err_fh, @cmd);
    };
    if ($@) {
        croak "Failed to start layout engine (@cmd): $@";
    }

    $in_fh->autoflush(1);
    $out_fh->autoflush(1);

    $self->{pid}   = $pid;
    $self->{in_fh} = $in_fh;
    $self->{out_fh}= $out_fh;
    $self->{err_fh}= $err_fh;

    return;
}

sub layout {
    my ($self, $request) = @_;

    croak "Request must be a hashref" unless ref $request eq 'HASH';

    $self->_start_engine unless defined $self->{pid};

    my $json_text = $self->{json}->encode($request);

    my $in_sep  = $self->{input_separator};
    my $out_sep = $self->{output_separator};

    my $in_fh   = $self->{in_fh};
    my $out_fh  = $self->{out_fh};

    # Send request
    print {$in_fh} $json_text, "\n", $in_sep, "\n"
        or croak "Failed to write to layout engine: $!";

    # Read response until output separator
    my @lines;
    while (defined(my $line = <$out_fh>)) {
        chomp $line;
        last if $line eq $out_sep;
        push @lines, $line;
    }

    my $resp_text = join "\n", @lines;
    return {} unless length $resp_text;

    my $resp = eval { $self->{json}->decode($resp_text) };
    if ($@) {
        croak "Failed to decode JSON response: $@; raw response: $resp_text";
    }

    return $resp;
}

sub exit_engine {
    my ($self) = @_;

    return unless defined $self->{pid};

    my $in_fh  = $self->{in_fh};
    my $pid    = $self->{pid};

    my $in_sep = $self->{input_separator};

    my $exit_req = { command => 'exit' };
    my $json_text = $self->{json}->encode($exit_req);

    eval {
        print {$in_fh} $json_text, "\n", $in_sep, "\n";
        close $in_fh;
    };

    waitpid($pid, 0);

    $self->{pid}   = undef;
    $self->{in_fh} = undef;
    $self->{out_fh}= undef;
    $self->{err_fh}= undef;

    return;
}

sub DESTROY {
    my ($self) = @_;
    $self->exit_engine;
}

1;

__END__

=head1 AUTHOR

You.

=head1 LICENSE

Same as your project.

=head1 NAME

Layout::Engine::Client - Persistent JSON client for the layout engine

=head1 SYNOPSIS

  use Layout::Engine::Client;

  my $client = Layout::Engine::Client->new(
      cmd              => './layout',
      input_separator  => '---END---',
      output_separator => '---END---',
  );

  my $req = {
      id    => 'example',
      nodes => [
          { id => 'A', width => 60, height => 40 },
          { id => 'B', width => 60, height => 40 },
      ],
      edges => [
          { source => 'A', target => 'B' },
      ],
      constraints => {
          layout   => JSON::true,
          routing  => 'orthogonal',
      },
  };

  my $resp = $client->layout($req);

  # Do something with $resp->{nodes}, $resp->{edges}, etc.

  $client->exit_engine;

=head1 DESCRIPTION

Layout::Engine::Client provides a high-level, persistent interface to the
external layout engine. It manages a long-running subprocess, sends JSON
requests, reads JSON responses, and handles input/output separators.

This wrapper is designed for automation pipelines, rendering systems, and
diagramming tools that need to send many layout requests efficiently.

The module:

=over 4

=item *
Starts the layout engine as a persistent subprocess

=item *
Encodes Perl data structures to JSON

=item *
Sends requests terminated by an input separator

=item *
Reads responses until an output separator

=item *
Decodes JSON responses back into Perl structures

=item *
Provides a clean C<layout()> method

=item *
Provides an explicit C<exit_engine()> method

=back

=head1 CONSTRUCTOR

=head2 new

  my $client = Layout::Engine::Client->new(%args);

Creates a new client and starts the layout engine.

Supported arguments:

=over 4

=item C<cmd>

Path to the layout engine executable.

Default: C<./layout>

=item C<input_separator>

String marking the end of each request.

Default: C<---END--->

=item C<output_separator>

String marking the end of each response.

Default: C<---END--->

=back

=head1 METHODS

=head2 layout

  my $resp = $client->layout($request_hashref);

Sends a request to the layout engine and returns the decoded JSON response.

The request must be a hash reference containing:

=over 4

=item *
C<nodes> array

=item *
Optional C<edges> array

=item *
Optional C<constraints> hash

=item *
Optional C<id> field (echoed back in the response)

=back

The method:

=over 4

=item *
Encodes the request as JSON

=item *
Writes it to the engine followed by the input separator

=item *
Reads lines until the output separator

=item *
Decodes the JSON response

=back

Returns a Perl hash reference representing the engine's response.

=head2 exit_engine

  $client->exit_engine;

Sends:

  { "command": "exit" }

to the engine, followed by the input separator, then waits for the process
to terminate.

This is the only supported way to shut down the persistent engine.

=head1 PROCESS MANAGEMENT

The engine is started using C<IPC::Open3>. The wrapper maintains:

=over 4

=item *
A write handle to the engine's STDIN

=item *
A read handle to the engine's STDOUT

=item *
A read handle to the engine's STDERR

=back

The engine is restarted automatically if C<layout()> is called after it has
exited.

=head1 ERROR HANDLING

The wrapper throws exceptions (via C<croak>) on:

=over 4

=item *
Failure to start the engine

=item *
Failure to write to the engine

=item *
Failure to read a complete response

=item *
Invalid JSON in the response

=back

=head1 JSON ENCODING

JSON encoding/decoding is performed using L<JSON::MaybeXS> with:

=over 4

=item *
UTF‑8 enabled

=item *
Canonical key ordering

=back

=head1 DESTRUCTOR

When the object is destroyed, C<exit_engine()> is automatically called if
the engine is still running.

=head1 SEE ALSO

=over 4

=item *
The layout engine protocol documentation

=item *
L<JSON::MaybeXS>

=item *
L<IPC::Open3>

=back

=head1 AUTHOR

You.

=head1 LICENSE

Same as your project.

=cut
