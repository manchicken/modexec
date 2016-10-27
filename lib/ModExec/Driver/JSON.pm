# JSON.pm -- A modexec driver for JSON interaction
# Copyright (C) 2006-2016  Michael D. Stemle, Jr.
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

package ModExec::Driver::JSON;
use strict;
use warnings;
use ModExec::Driver;
use ModExec::Exception;
use JSON;
use Scalar::Util qw/blessed reftype looks_like_number/;
use English qw/-no_match_vars/;

our $VERSION = 0.1;

require Exporter;
our @ISA = qw/Exporter ModExec::Driver/;
our @EXPORT = qw(driver_init);
our @EXPORT_OK = qw();

sub exec {
  my ($self, $func, $args) = @_;

  my $json_args = undef;
  my @aargs = ();
  my %hargs = ();
  my $retval = undef;
  my $to_return = undef;
  my $orig_args = undef;

  # Parse JSON if necessary.
  if (defined ($args) && !ref($args) && $args =~ m/^(\{|\[)/) {
    try {
      $orig_args = $args;
      $json_args = jsonToObj ($args);
      $args = $json_args;
    } catch ModExec::Exception with {
      my $err = shift;
      $err->throw();
    } catch {
      # Bad arguments...
      ModExec::Exception->throw("ERR_INVALID_ARGUMENTS", "Arguments '${orig_args}' are not JSON compatible.");
    };
  } elsif ($args =~ m/^\"(.*)\"$/) {
    $args = $1;
  }

  # Execute the function
  return try {
    $retval = $self->func_exec( function => $func, arguments => $args );
    $to_return = objToJson ({'value'=>$retval});
    if ($retval && !$to_return) {
      ModExec::Exception->throw("ERR_MODEXEC_EXECEPTION", "Got a return value, but JSON returned nothing.\n");
    }
    
    return $to_return;
  }
  catch {
    blessed( $ARG ) && $ARG->throw(); # Rethrow

    ModExec::Exception->throw("ERR_MODEXEC_EXCEPTION", "The return of the function called was not compatible with JSON.  Please ensure that all ModExec functions return simple types (scalar, array-ref, hash-ref): " . $ARG);
  };
}

sub new {
  return bless({},shift);
}

1;

__END__
=pod

=head1 NAME

ModExec::Driver::JSON - A modexec driver for JSON interaction.

=head1 SYNOPSIS

 use ModExec; # NEVER use the driver on its own.

# Non-zero auth indicates that we're logged in.
 my $meh = new ModExec (driver => "JSON", module => "Foo::Bar", auth => 1);
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

This is the JSON driver for ModExec.  This driver will call functions in modules and communcate entirely in JSON.

=cut
