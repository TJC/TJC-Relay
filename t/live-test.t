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

lives_ok {
    $relay->enable;
} 'can enable zero relays';

dies_ok {
    $relay->enable(1,2,3,2,1);
} "can't enable five relays";

for my $i (0..3) {
    lives_ok {
        $relay->enable($i);
    } "can enable relays id $i";
    subsleep(0.250);
}

subsleep(0.5);

for my $i (0..3) {
    lives_ok {
        $relay->disable($i);
    } "can disable relays id $i";
    subsleep(0.25);
}

subsleep(0.5);

lives_ok {
    for (1..9) {
        marching_ants();
        subsleep(0.25);
    }
} "run a whole bunch of commands";

done_testing();

sub marching_ants {
    $relay->enable(0,2);
    subsleep(0.25);
    $relay->disable(0,2);
    subsleep(0.25);
    $relay->enable(1,3);
    subsleep(0.25);
    $relay->disable(1,3);
}

sub subsleep {
    # poor man's sub-second sleep
    # (When did Time::HiRes enter core?)
    select(undef,undef,undef,shift);
}
