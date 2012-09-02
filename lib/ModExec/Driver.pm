# Driver.pm -- Driver interface for ModExec
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

package ModExec::Driver;
use strict;
use warnings;
use Error qw/:try/;
use ModExec::Exception;
use Data::Dumper;

our $VERSION = 0.1;

require Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw();
our @EXPORT_OK = qw();

sub module_name {
  my ($self, $mod_name) = @_;

  $self->{_module_name} = $mod_name if defined($mod_name);
  return $self->{_module_name};
}

sub auth {
  my ($self, $auth) = @_;

  $self->{_auth} = $auth if defined($auth);
  return $self->{_auth};
}

sub init {
  my ($self, $auth, $modname) = @_;

  if (!defined ($modname)) {
    throw ModExec::Exception ("ERR_INSUFFICIENT_DATA", "Undefined module name");
  }

  $self->auth ($auth || 0);
  $self->module_name ($modname);

  return 1;
}

sub init_module {
  my ($self) = @_;
  my $use_module = undef;

  $use_module = $self->module_name;
  if ($use_module !~ m/^([a-zA-Z0-9_-]+(::[a-zA-Z0-9_-]+)*)$/si) {
    throw ModExec::Exception ("ERR_MODEXEC_SECURITY", "Sorry, the module name you specified is not valid.");
  }
  $use_module = $1;
  eval qq{use $use_module qw{modexec_export};};
  if ($@) {
    throw ModExec::Exception ("ERR_MODEXEC_BAD_LOAD", "Failed to load module '${use_module}': $@");
  }
  if (!defined (&modexec_export)) {
    throw ModExec::Exception ("ERR_MODEXEC_DRIVERHOOK", "Module ${use_module} does not implement DriverHook");
  }
  $self->{modexec_funcs} = modexec_export ($self->auth);
  if ((grep { m/\w+\s*\(.*?\)/ } keys (%{$self->{modexec_funcs}})) <
      keys (%{$self->{modexec_funcs}})) {
    throw ModExec::Exception ("ERR_INVALID_MODEXEC_MODULE", $self->module_name . ": modexec_export() returned functions without prototypes.  Please specify prototypes.");
  }

  if (!defined ($self->{modexec_funcs}) ||
      ref($self->{modexec_funcs}) ne "HASH" ||
      scalar (keys (%{$self->{modexec_funcs}})) == 0) {
    throw ModExec::Exception ("ERR_INVALID_MODEXEC_MODULE", $self->module_name . ": modexec_export() return no functions or an invalid value.");
  }

  return 1;
}

sub get_func_by_proto {
  my ($self, $func, $prototype) = @_;

  my $qfunc = undef;
  my $qproto = undef;
  my @matches = ();
  my $proto_name = undef;
  my $proto_re = undef;
  my @symbol_table = ();

  $qfunc = quotemeta ($func);
  $qproto = quotemeta ($prototype);
  $proto_name = "${func}${prototype}";
  $proto_re = qr!$qfunc\s*$qproto!;
  @symbol_table = keys (%{$self->{modexec_funcs}});
  @matches = grep { m/$proto_re/ } @symbol_table;
  if (!scalar (@matches)) {
    throw ModExec::Exception ("ERR_INVALID_MODEXEC_FUNCTION", "Failed to modexec function ${proto_name}: No such function.");
  }
  if (scalar (@matches) > 1) {
    throw ModExec::Exception ("ERR_INVALID_MODEXEC_FUNCTION", "Multiple matches for prototype '${proto_name}'.");
  }

  return $self->{modexec_funcs}->{$matches[-1]};
}

sub func_exec {
  my ($self, $func, $args) = @_;

  # Execute the function
  if (!defined ($args)) {
    return $self->get_func_by_proto ($func, "()")->();
  } elsif (ref ($args) eq "ARRAY") {
    return $self->get_func_by_proto ($func, "(@)")->(@{$args});
  } elsif (ref ($args) eq "HASH") {
    return $self->get_func_by_proto ($func, "(%)")->(%$args);
  } else {
    return $self->get_func_by_proto ($func, '($)')->($args);
  }

  throw ModExec::Exception ("ERR_INVALID_FUNCTION", "No appropriate function prototype was found.");
}

sub exec {
  throw ModExec::Exception ("ERR_ABSTRACT_FUNCTION", "ModExec::Driver->exec() should have been over-ridden by the specific driver module.");
}

1;

__END__
=pod

=head1 NAME

ModExec::Driver - A driver abstraction for DigitalWork ModExec.

=head1 SYNOPSIS

 use ModExec::Driver;

 my $driver = new ModExec::Driver (-engine => "JSON");
 my $struct_to_return = {"array" => [1,2,3], "associative_array" => {"foo"=>"bar"}};
 my %hash_to_return = (a=>1, b=>2, c=>3);
 my @array_to_return = qw/a b c/;
 my $exec_args = $driver->grab_data ();
 
# Assuming "do_something" is the function you wish to execute
 $driver->exec ("do_something", $struct_to_return);
# OR
 $driver->exec ("do_something", \%hash_to_return);
# OR
 $driver->exec ("do_something", \@array_to_return);

=head1 DESCRIPTION

This module is intended to be a layer that allows DigitalWork ModExec to communicate with multiple callers.  Only scalars, and refs to hashes and arrays are permitted.  Blessed references are not transmitted.

=head2 init(int auth, string module_name)

=cut
