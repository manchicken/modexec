# ModExecTest.pm -- Just a test module for testing ModExec
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
package ModExecTest;
use strict;
use warnings;

use ModExec::DriverHook;

require Exporter;
our @ISA = qw/Exporter ModExec::DriverHook/;
our @EXPORT = qw/modexec_export/;

sub foo {
  return ["cat","dog","goat"];
}

sub secure_ary_test {
  my @inputs = @_;
  push (@inputs, "SECURE_ARY_TEST");

  return \@inputs;
}

sub insecure_ary_test {
  my @inputs = @_;
  push (@inputs, "INSECURE_ARY_TEST");

  return \@inputs;
}

sub modexec_export {
  my ($secure) = @_;
  my $funcs = {};

  $funcs = {
    "foo()"=>\&foo,
    "ary_test(@)" => ($secure) ? \&secure_ary_test : \&insecure_ary_test,
  };
}
