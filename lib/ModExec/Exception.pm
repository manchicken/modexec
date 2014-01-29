
=head1 NAME

ModExec::Exception - A simple exception class definition. Extends L<Error::Simple>.

=cut

package ModExec::Exception;
use strict;
use warnings;
use 5.010;
use base qw/Exporter/;

=head1 VERSION

ModExec 1.0

=cut

our $VERSION = '1.0';

=head1 DEPENDENCIES

=over 4

=item Try::Tiny (for syntax sugar)

=item Carp (stack traces, uses longmess)

=back

=cut

use Carp;
use Try::Tiny;

# No Critic DGR: Makes life easier for our users
our @EXPORT = qw/try catch finally/; ## no critic (ProhibitAutomaticExportation)

=head1 SYNOPSIS

 use ModExec::Exception;

 try {
    do_something() ||
    throw ModExec::Exception (
       'ERR_SOME_ERROR', 'Some error occurred'
    );
 } catch ModExec::Exception with {
   die ($@->errstr ());
 }

=head1 DESCRIPTION

This is a simple exception class.

=head1 SUBROUTINES/METHODS

=head2 new(error_code, error_message)

Construct an instance of the object, inheriting from C<Error::Simple> and return it.

Arguments:
  $error_code ..... The error code to use
  $error_message .. The error message to use

Returns an instance of the exception.

=cut

sub new {
    my ( $pkg, $error_code, $error_message ) = @_;
    my $self = {};

    bless $self, $pkg;

    $self->errstr( $error_message, $error_code );

    # Once upon a time, Carp couldn't longmess.
    if ( Carp->can('longmess') ) {
        $self->stack( Carp::longmess() );
    }

    return $self;
}

=head2 errstr([error_message, error_code])

Fetch and optionally set the error code and error message.

Arguments:
  $error_code ..... The error code to use (optional)
  $error_message .. The error message to use (optional)

Returns the current error message.

=cut

sub errstr {
    my ( $self, $error_message, $error_code ) = @_;

    $self->{'_code'} = $error_code
        if defined $error_code;
    $self->{'_message'} = $error_message
        if defined $error_message;

    return $self->{'_message'} // undef;
}

=head2 errcode([error_code])

Fetch and optionally set the error code.

Arguments:
  $error_code .. The error code to use (optional)

Returns the current error code.

=cut

sub errcode {
    my ( $self, $code ) = @_;

    $self->{'_code'} = $code
        if defined $code;

    return $self->{'_code'} // undef;
}

=head2 stack([stack_dump])

Fetch and optionally set the stack dump.

Arguments:
  $stack_dump .. The stack dump to use (optional)

Returns the current stack dump.

=cut

sub stack {
    my ( $self, $stack ) = @_;

    $self->{'_stack'} = $stack
        if defined $stack;

    return $self->{'_stack'} // undef;
}

=head2 stringify()

Return a string containing the data contained in the instance.

=cut

sub stringify {
    my ($self) = @_;

    return $self->errcode() . ": " . $self->errstr() . "\n" . $self->stack();
}

=head2 throw()

Die with an instance of this class.

Usage: throw ModExec::Exception->new( $code, $message )

=cut

sub throw {
    my ($pkg, @args) = @_;

    # No Critic DGR: Carp::croak screws up the object being thrown.
    die $pkg->new( @args ); ## no critic (RequireCarping)
}


1;

=head1 DIAGNOSTICS

This class is intended to be the reporter of errors, and as such it doesn't really have any errors of its own.

=head1 AUTHOR

Michael D. Stemle, Jr. <manchicken@notsosoft.net>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2005-2014  Michael D. Stemle, Jr. <manchicken@notsosoft.net>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
