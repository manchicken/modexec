
=head1 NAME

ModExec - An abstraction layer providing more direct execution of Perl modules

=cut

package ModExec;
use strict;
use warnings;
use 5.010;

=head1 VERSION

ModExec 1.0

=cut

our $VERSION = 1.0;

=head1 DEPENDENCIES

=over 4

=item Module::Load (to load the drivers and such)

=back

=cut

use ModExec::Exception;
use English qw/-no_match_vars/;
use Readonly;
use Module::Load qw/none/;

=head1 SYNOPSIS

 use ModExec;

 # Non-zero secure indicates that we're logged in.
 my $meh = ModExec->prepare(
    driver => q|ModExec::Driver::JSON|,
    module => q|Foo::Bar|,
    secure => 1,
 );

 my $struct_to_return = { 'array' => [ 1, 2, 3 ], 'associative_array' => { 'foo'=>'bar' } };
 my %hash_to_return = ( a=>1, b=>2, c=>3 );
 my @array_to_return = qw/a b c/;
 my $exec_args = $driver->grab_data ();
 
 # Assuming "do_something" is the function you wish to execute.
 $meh->exec( 'do_something', $struct_to_pass );
 # OR
 $meh->exec( 'do_something', \%hash_to_pass );
 # OR
 $meh->exec( 'do_something', \@array_to_pass );

=head1 DESCRIPTION

This module is an interface that we can use for executing module code.  There are a couple of conventions that it is important to follow...

=head1 CALLING MODEXEC FUNCTIONS

 $meh->exec( 'foo_bar', { args => [ $a, $b, $c ] } )

   SAME AS

 use Module;
 foo_bar( $a, $b, $c );

 $meh->exec( 'foo_bar', { a =>1, b => 2, c => 3 } );

    SAME AS
 
 use Module;
 foo_bar( a => 1, b => 2, c => 3 );

 $meh->exec( 'foo_bar', undef );

    SAME AS
 
 use Module;
 foo_bar();

=cut

# This regex should help prevent nasties from getting through.
Readonly our $PACKAGE_SECURITY_PATTERN => qr?
    \A
    ([a-z0-9_-]+::)*
    ([a-z0-9_-]+)
    \Z
  ?six;

sub prepare {
    my ( $class, %opts ) = @_;

    my $driver_class = delete $opts{'driver'}
        || ModExec::Exception->throw( 'ERR_INSUFFICIENT_DATA',
        'Driver unspecified',
        );
    my $module_name = delete $opts{'module'}
        || ModExec::Exception->throw( 'ERR_INSUFFICIENT_DATA',
        'Executable module unspecified',
        );
    my $secure = delete $opts{'secure'} // 0;

    my $driver_handle = undef;

    # Verify that the driver matches security requirements.
    if ( $driver_class !~ $PACKAGE_SECURITY_PATTERN ) {
        ModExec::Exception->throw( 'ERR_MODEXEC_SECURITY',
            'Unable to load specified driver, unknown driver provided.' );
    }

    # Load the driver
    try {
        Module::Load::load($driver_class);

        if ( !$driver_class->can(q{init_driver}) ) {
            ModExec::Exception->throw( 'ERR_MODEXEC_BAD_DRIVER',
                "Driver >${driver_class}< does not implement Driver." );
        }

        $driver_handle = $driver_class->init_driver(
            module => $module_name,
            secure => $secure
        );
    }
    catch {
        if ( ref $ARG && $ARG->isa(q{ModExec::Exception}) ) {
            $ARG->throw();
        } else {
            ModExec::Exception->throw( 'ERR_MODEXEC_BAD_DRIVER_LOAD',
                "Failed to load driver >${driver_class}<: $ARG/$ERRNO" );
        }
    };

    return $driver_handle;
}

1;

=head1 DIAGNOSTICS

Most of the diagnostics involve throwing exceptions. You should use try/catch blocks
around all ModExec calls.

=head1 AUTHOR

Michael D. Stemle, Jr. <manchicken@notsosoft.net>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2005-2016  Michael D. Stemle, Jr. <manchicken@notsosoft.net>

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
