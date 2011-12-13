#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'TJC::Relay' ) || print "Bail out!\n";
}

diag( "Testing TJC::Relay $TJC::Relay::VERSION, Perl $], $^X" );
