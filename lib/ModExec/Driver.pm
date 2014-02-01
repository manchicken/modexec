use strict;
use warnings;
use 5.010;

=head1 NAME

Driver.pm -- Driver interface for ModExec

=cut

package ModExec::Driver;

=head1 VERSION

ModExec 1.0

=cut

our $VERSION = '1.0';

=head1 DEPENDENCIES

=over 4

=item Module::Load (for loading driver engine modules)

=item Scalar::Util (for inspecting scalars in a more uniform manner)

=back

=cut

use English qw/-no_match_vars/;
use Module::Load;
use Scalar::Util qw/blessed reftype looks_like_number/;
use ModExec;
use ModExec::Exception;

=head1 SYNOPSIS

 use ModExec::Driver;

 my $driver = ModExec::Driver->load( engine => 'JSON' );
 my $struct_to_return = {"array" => [1,2,3], "associative_array" => {"foo"=>"bar"}};
 my %hash_to_return = (a=>1, b=>2, c=>3);
 my @array_to_return = qw/a b c/;
 my $exec_args = $driver->grab_data();
 
 # Assuming "do_something" is the function you wish to execute
 $driver->exec ("do_something", $struct_to_return);
 # OR
 $driver->exec ("do_something", \%hash_to_return);
 # OR
 $driver->exec ("do_something", \@array_to_return);

=head1 DESCRIPTION

This module is intended to be a layer that allows DigitalWork ModExec to communicate with multiple callers.  Only scalars, and refs to hashes and arrays are permitted.  Blessed references are not transmitted.

=head1 CLASS METHODS

=head2 init_driver()

This factory method loads the desired driver module and returns an instance to it.

=head3 Arguments

=over 4

=item engine

This is the name of the driver engine.

=item options

This is a hashref that you want to send to the engine when it initializes.

=back

=head3 Default Engines

Currently there are two engines supported by default:

=over 4

=item JSON

This engine takes JSON in and returns JSON out.

=item Perl

This engine is for pure Perl interfaces wanting to integrate with modules used in the ModExec framework. Items calling the Perl engine should observe all of the same security precautions and such that you would if you were calling it from an external dispenser.

=back

=cut

sub init_driver {
    my ( $pkg, %args ) = @_;

    my $module = delete $args{module}
        // ModExec::Exception->throw( 'ERR_INSUFFICIENT_DATA',
        'No module provided.' );
    my $secure = delete $args{secure} // 0;

    my $self = $pkg->new();

    $self->secure($secure);
    $self->module_name($module);

    # Load the module...
    $self->init_module();

    return $self;
}

=head1 INSTANCE METHODS

=head2 module_name([$module_name])

This method optionally sets the module name.

Arguments:

 $module_name - (optional) The name of the module to set.

Returns the current/new name of the module being run.

=cut

sub module_name {
    my ( $self, $module_name ) = @_;

    $self->{_module_name} = $module_name if defined($module_name);
    return $self->{_module_name};
}

=head2 secure([$secure])

This method optionally sets the secure flag on the driver.

Arguments:

 $secure - (optional) The secure flag to use.

Return the current/new secure flag for the module.

=cut

sub secure {
    my ( $self, $secure ) = @_;

    if ( defined $secure && !looks_like_number $secure) {
        ModExec::Exception->throw( 'ERR_MODEXEC_SECURITY', 'Invalid call.' );
    }

    $self->{_secure} = $secure if defined($secure);
    return $self->{_secure};
}

=head2 init_module()

Initialize the module being run.

This method doesn't take any arguments or return any values. It gets and validates the exported methods from the module and stores them in an internal structure for future use.

=cut

sub init_module {
    my ($self) = @_;

    my $module_to_use = $self->module_name();

    # Make sure the module meets the package security pattern for ModExec.
    if ( $module_to_use !~ $ModExec::PACKAGE_SECURITY_PATTERN ) {
        throw ModExec::Exception( 'ERR_MODEXEC_SECURITY',
            'Sorry, the module name you specified is not valid.' );
    }

    # Load the module...
    try {
        # Load the file
        Module::Load::load($module_to_use);

        if ( !$module_to_use->isa(q{ModExec::DriverHook}) ) {
            ModExec::Exception->throw( 'ERR_MODEXEC_DRIVERHOOK',
                "Module ${module_to_use} does not implement DriverHook" );
        }

        # Make sure the module implements modexec_export()
        if ( !$module_to_use->can('modexec_export') ) {
            ModExec::Exception->throw( "ERR_INVALID_MODEXEC_MODULE",
                "Module >${module_to_use}< does not implement modexec_export()."
            );
        }

        # Load the publicly exported functions
        my $modexec_export_ref = undef;
        say "\$modexec_export_ref = \\&${module_to_use}::modexec_export";
        eval "\$modexec_export_ref = \\&${module_to_use}::modexec_export";
        $self->{modexec_funcs} = $modexec_export_ref->( $self->secure );

        # Verify we actually got a hash back...
        if ( reftype $self->{modexec_funcs} ne 'HASH' ) {
            ModExec::Exception->throw( "ERR_INVALID_MODEXEC_MODULE",
                "$module_to_use is unavailable for use." );
        }

        # Let's verify that the functions exported are valid...
        my $valid_function_pattern = qr{
          \A             # Start of string
          [a-z][a-z0-9]* # The name of the function, must start with a letter.
          \Z             # End of the string
        }xsi;
        foreach my $exported_function ( keys %{ $self->{modexec_funcs} } ) {

            # Verify that the function names are valid...
            if ( $exported_function !~ $valid_function_pattern ) {
                ModExec::Exception->throw( "ERR_INVALID_MODEXEC_MODULE",
                    "$module_to_use: modexec_export() attempted to export invalid formats or functions."
                );
            }

            # Verify that the functions are actually functions.
            elsif ( reftype $self->{modexec_funcs}->{$exported_function} ne
                'CODE' )
            {
                ModExec::Exception->throw( "ERR_INVALID_MODEXEC_MODULE",
                    "$module_to_use: modexec_export() attempted to export invalid functions."
                );
            }
        }

    }
    catch {
        if ( blessed $ARG ) {
            $ARG->throw();    # Rethrow
        } else {
            ModExec::Exception->throw( 'ERR_UNKNOWN',
                "Caught unexpected exception: $ARG" );
        }
    };

    return;
}

sub get_func_by_proto {
    my ( $self, $func, $prototype ) = @_;

    my $qfunc        = undef;
    my $qproto       = undef;
    my @matches      = ();
    my $proto_name   = undef;
    my $proto_re     = undef;
    my @symbol_table = ();

    $qfunc        = quotemeta($func);
    $qproto       = quotemeta($prototype);
    $proto_name   = "${func}${prototype}";
    $proto_re     = qr!$qfunc\s*$qproto!;
    @symbol_table = keys( %{ $self->{modexec_funcs} } );
    @matches      = grep {m/$proto_re/} @symbol_table;
    if ( !scalar(@matches) ) {
        throw ModExec::Exception( "ERR_INVALID_MODEXEC_FUNCTION",
            "Failed to modexec function ${proto_name}: No such function." );
    }
    if ( scalar(@matches) > 1 ) {
        throw ModExec::Exception( "ERR_INVALID_MODEXEC_FUNCTION",
            "Multiple matches for prototype '${proto_name}'." );
    }

    return $self->{modexec_funcs}->{ $matches[-1] };
}

sub func_exec {
    my ( $self, $func, $args ) = @_;

    # Execute the function
    if ( !defined($args) ) {
        return $self->get_func_by_proto( $func, "()" )->();
    } elsif ( ref($args) eq "ARRAY" ) {
        return $self->get_func_by_proto( $func, "(@)" )->( @{$args} );
    } elsif ( ref($args) eq "HASH" ) {
        return $self->get_func_by_proto( $func, "(%)" )->(%$args);
    } else {
        return $self->get_func_by_proto( $func, '($)' )->($args);
    }

    throw ModExec::Exception( "ERR_INVALID_FUNCTION",
        "No appropriate function prototype was found." );
}

sub exec {
    throw ModExec::Exception( "ERR_ABSTRACT_FUNCTION",
        "ModExec::Driver->exec() should have been over-ridden by the specific driver module."
    );
}

1;

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
