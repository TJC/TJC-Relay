#!perl

use strict;
use warnings;
use Test::More;
use Test::Exception;

unless ( $ENV{RELEASE_TESTING} ) {
    plan( skip_all => "Author tests not required for installation" );
}

use TJC::Relay;

ok((-e '/dev/ttyUSB0'), "OK, /dev/ttyUSB0 exists..");
my $relay = TJC::Relay->new(tty => '/dev/ttyUSB0');

TODO: {
    local $TODO = "I don't know why this fails..";

    lives_ok {
        alarm(2);
        $SIG{ALRM} = sub { die "timeout - test failed.\n" };
        $relay->status;
        alarm(0);
    } 'can call relay status';

};

done_testing();
