# Perl.pm -- A modexec driver for Perl interaction
# Copyright (C) 2006-2007  Michael D. Stemle, Jr. and DW Data, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

package ModExec::Driver::Perl;
use strict;
use warnings;
use Error qw/:try/;
use ModExec::Driver;
use ModExec::Exception;
use Data::Dumper;

our $VERSION = 0.01;

require Exporter;
our @ISA = qw/Exporter ModExec::Driver/;
our @EXPORT = qw(driver_init);
our @EXPORT_OK = qw();

sub exec {
  my ($self, $func, $args) = @_;

  my $retval = undef;
  my $to_return = undef;
  my $orig_args = undef;

  # Execute the function
  try {
    $to_return = $self->func_exec ($func, $args);
  } catch ModExec::Exception with {
    # Rethrow any ModExec exceptions
    shift->throw();
  } otherwise {
    # If we're here, then the Perl driver didn't expect the output of modexec_export.
    my $err = shift;
    throw ModExec::Exception ("ERR_MODEXEC_EXCEPTION", "The return of the function called was not compatible with the Perl ModExec driver.  Please ensure that all ModExec functions return simple types (scalar, array-ref, hash-ref): " . $err->stringify);
  };

  return $to_return;
}

sub new {
  return bless({},shift);
}

1;

__END__
=pod

=head1 NAME

ModExec::Driver::Perl - A modexec driver for Perl interaction

=head1 SYNOPSIS

 use ModExec; # NEVER use the driver on its own.

# Non-zero auth indicates that we're logged in.
 my $meh = new ModExec (driver => "Perl", module => "Foo::Bar", auth => 1);
 my $struct_to_return = {"array" => [1,2,3], "associative_array" => {"foo"=>"bar"}};
 my %hash_to_return = (a=>1, b=>2, c=>3);
 my @array_to_return = qw/a b c/;
 my $exec_args = $driver->grab_data ();
 
# Assuming "do_something" is the function you wish to execute.
 $meh->exec ("do_something", $struct_to_return);
# OR
 $meh->exec ("do_something", \%hash_to_return);
# OR
 $meh->exec ("do_something", \@array_to_return);

=head1 DESCRIPTION

This is the Perl driver for ModExec.  This driver will call functions in modules and communcate entirely in Perl.

=cut
