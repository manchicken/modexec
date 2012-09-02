# ModExec.pm -- An abstraction layer providing more direct execution of Perl modules
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

package ModExec;
use strict;
use warnings;
use Error qw/:try/;
use ModExec::Exception;
use Data::Dumper;

our $VERSION = 0.1;

require Exporter;
our @ISA = qw/Exporter Object/;
our @EXPORT = qw();
our @EXPORT_OK = qw();

sub new {
  my ($class, %opts) = @_;

  my $driver = undef;
  my $driver_name = undef;

  ## Module and driver are **REQUIRED**
  if (!exists($opts{driver})) {
    throw ModExec::Exception ("ERR_INSUFFICIENT_DATA", "Driver unspecified at ModExec.pm (line " . __LINE__ . ")");
  }
  if (!exists ($opts{module})) {
    throw ModExec::Exception ("ERR_INSUFFICIENT_DATA", "Executable module unspecified at ModExec.pm (line " . __LINE__ . ")");
  }

  $driver_name = sprintf ("ModExec::Driver::%s", $opts{driver});

  # Let's load the driver.
  if ($driver_name !~ m/^[a-zA-Z0-9_-]+(::[a-zA-Z0-9_-]+)*$/si) {
    throw ModExec::Exception ("ERR_MODEXEC_SECURITY", "Sorry, the module name you specified is not valid.");
  }
  eval qq{use $driver_name;};
  if ($@) {
    throw ModExec::Exception("ERR_MODEXEC_BAD_DRIVER_LOAD", "Failed to load driver '${driver_name}': $@");
  }

  if (!defined (&driver_init)) {
    throw ModExec::Exception("ERR_MODEXEC_BAD_DRIVER", "Driver '${driver_name}' does not implement Driver.");
  }

  try {
    $driver = driver_init ($opts{module}, $opts{auth});

    if (!defined ($driver) || !($driver->isa ("ModExec::Driver"))) {
      throw ModExec::Exception("ERR_INVALID_DRIVER", "The driver returned by driver_init() was not valid.");
    }
  } catch ModExec::Exception with {
    my $err = shift (@_);
    throw $err;
  } otherwise {
    my $err = shift (@_);
    throw ModExec::Exception ("ERR_UNKNOWN", "Failed to initialize the driver (${driver_name}): " .
      $err->stringify);
  };

  return $driver;
}

1;

__END__
=pod

=head1 NAME

ModExec - An abstraction layer providing more direct execution of Perl modules

=head1 SYNOPSIS

 use ModExec;

# Non-zero auth indicates that we're logged in.
 my $meh = new ModExec (driver => "JSON", module => "Foo::Bar", auth => 1);
 my $struct_to_return = {"array" => [1,2,3], "associative_array" => {"foo"=>"bar"}};
 my %hash_to_return = (a=>1, b=>2, c=>3);
 my @array_to_return = qw/a b c/;
 my $exec_args = $driver->grab_data ();
 
# Assuming "do_something" is the function you wish to execute.
 $meh->exec ("do_something", $struct_to_pass);
# OR
 $meh->exec ("do_something", \%hash_to_pass);
# OR
 $meh->exec ("do_something", \@array_to_pass);

=head1 DESCRIPTION

This module is an interface that we can use for executing module code.  There are a couple of conventions that it is important to follow...

=head1 CALLING MODEXEC FUNCTIONS

 $meh->exec ("foo_bar", {args=>[$a,$b,$c]})

	 SAME AS

 use Module;
 foo_bar ($a, $b, $c);

 $meh->exec ("foo_bar", {a=>1,b=>2,c=>3});

    SAME AS
 
 use Module;
 foo_bar (a=>1, b=>2, c=>3);

 $meh->exec ("foo_bar", undef);

    SAME AS
 
 use Module;
 foo_bar ();

=cut
