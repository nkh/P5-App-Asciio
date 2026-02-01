
./gen.pl --nodes=20 --json | ./cli-layout.pl

#!/usr/bin/env perl
use strict;
use warnings;
use JSON::MaybeXS;
use Layout::Engine::Client;

# Read Perl data structure from STDIN
my $input = do { local $/; <STDIN> };
my $req = eval $input;
die "Invalid Perl structure on STDIN\n" if $@ or ref $req ne 'HASH';

# Start client
my $client = Layout::Engine::Client->new(
    cmd              => './layout',
    input_separator  => '---END---',
    output_separator => '---END---',
);

# Send request
my $resp = $client->layout($req);

# Print JSON response
my $json = JSON::MaybeXS->new(utf8 => 1, canonical => 1, pretty => 1);
print $json->encode($resp);

exit 0;
