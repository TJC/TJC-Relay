package TJC::Relay;
use 5.10.1;
use strict;
use warnings;
use autodie;
use Carp qw(croak);
use IO::File;
use List::Util qw(sum);
use Mouse;

=head1 NAME

TJC::Relay - Control relays via usb-over-serial tty.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

has 'tty' => (
    is => 'ro',
    required => 1,
    isa => 'Str',
    documentation => 'Serial device to use. Eg /dev/ttyUSB0',
);

has 'fh' => (
    is => 'rw',
    isa => 'IO::File',
    lazy => 1,
    default => sub {
        my $self = shift;
        warn 'Opening tty: ' . $self->tty . "\n";
        my $fh = IO::File->new($self->tty, 'r+');
        $fh->binmode(1);
        return $fh;
    },
);

=head1 SYNOPSIS

Perl module for driving a serial or USB attached relay controller.

I wrote this module to control a device I bought off eBay:

    It was described as: "RS232 quad relay controller"
    I bought it from this seller: http://myworld.ebay.com.au/r32190

Example of use:

    use TJC::Relay;

    my $relay = TJC::Relay->new(tty => '/dev/ttyUSB0');
    $relay->enable(0..3);
    $relay->disable(1, 2);

=head1 METHODS

=cut

=head2 enable ($id, $id, $id, $id)

Enables (closes) a relay.

Accepts up to four relay IDs, which must be in the range 0-3, indicating which
ones to enable.

=cut

sub enable {
    my ($self, @ids) = @_;
    $self->_relay_cmd(0x55, 2, @ids);
}

=head2 disable ($id, $id, $id, $id)

Disables (opens) a relay.

Accepts up to four relay IDs, which must be in the range 0-3, indicating which
ones to disable.

=cut

sub disable {
    my ($self, @ids) = @_;
    $self->_relay_cmd(0x55, 1, @ids);
}

=head2 status

This is basically a NOOP that gets the controller to return the current
status of the relays.

=cut

sub status {
    my ($self) = @_;
    $self->_relay_cmd(0x55, 0);
    $self->check_result;
}


=head2 _relay_cmd ($cmd, $val, @ids)

Sends a command to the relay controller.

$cmd = the hex value indicating the mode. Usually 0x55.

$val = the value to assign to the positions indicating relay id actions.

  0=no change
  1=open
  2=close

=cut

sub _relay_cmd {
    my ($self, $cmd, $val, @ids) = @_;

    croak("Too many IDs") if scalar(@ids) > 4;
    croak("Invalid relay ID") if grep { $_ < 0 or $_ > 3 } @ids;

    my @set = (0, 0, 0, 0);
    $set[$_] = $val for (@ids);

    my $checksum = $cmd + 1 + 1 + sum(@set);

    my $bytes = pack('C8', $cmd, 1, 1, @set, $checksum);
    $self->fh->syswrite($bytes, 8);
}

=head2 check_result

Checks the last returned data from the relay controller.

Theoretically this always indicates the current status of the relays, but for
some reason it never works for me.

I am probably doing something wrong..

=cut

sub check_result {
    my $self = shift;
    my $buf;
    $self->fh->sysread($buf, 8);
    my @bytes = unpack('C8', $buf);
    say sprintf('%#x %x %x %x %x %x %x %x', @bytes);
}

=head1 AUTHOR

Toby Corkindale, C<< <tjc at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-tjc-relay at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=TJC-Relay>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc TJC::Relay

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=TJC-Relay>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/TJC-Relay>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/TJC-Relay>

=item * Search CPAN

L<http://search.cpan.org/dist/TJC-Relay/>

=back


=head1 DEVELOPMENT NOTES

 To open relay 1: 0x55 01 01 02 00 00 00 59
 relay 2:         0x55 01 01 00 02 00 00 59
 It should ack with:
 0x22 01 00 02 00 00 00 25
 To close relay 1:
 0x55 01 01 01 00 00 00 58
 It acks with:
 0x22 01 00 01 00 00 00 24

 Open all with: 55 01 01 02 02 02 02 5F

 Check status with: 55 01 01 00 00 00 00 57

It appears that the first byte is the command, I don't know what the next two
bytes are. Then you get four bytes, one for each relay. 01=off, 02=on.

The final byte is a checksum, just add up the first seven bytes.

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Toby Corkindale.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

__PACKAGE__->meta->make_immutable;
no Mouse;
1;

