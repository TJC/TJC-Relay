use inc::Module::Install;

name     'TJC-Relay';
perl_version '5.010001';
all_from 'lib/TJC/Relay.pm';
author   q{Toby Corkindale <tjc@cpan.org>};
license  'perl';

build_requires 'Test::More';
build_requires 'Test::Exception';

requires 'autodie';
requires 'Mouse';

# also requires Carp, IO::File and List::Util, but they're in perl core.
# autodie is in recent perl core too.

auto_install;

WriteAll;

