#!/usr/bin/env perl

=head1 NAME

modexec.t - A test for the ModExec factory class.

=head1 SYNOPSIS

prove modexec.t

=head1 DESCRIPTION

This program tests C<ModExec>.

=cut

use strict;
use warnings;
use 5.010;
use FindBin qw/$Bin/;
use lib $Bin;
use Test::More tests => 5;
use Test::Exception;
use English q{-no_match_vars};
use Data::Dumper;
use ModExec::Exception;

# Load the module using C<use_ok()>
sub BEGIN {
  use_ok q{ModExec};
}

my $meh = undef;
try {
  say 'Trying!';
  # Test preparing the module
  $meh = ModExec->prepare(
    driver => 'Dummy::Driver',
    module => 'Dummy::Module',
  );
  
} catch {
  
  say 'Caught!';
  say $ARG->stringify() if ref $ARG;
  say $ERRNO->stringify() if ref $ERRNO;
  
};

# Verify that the driver isa Dummy::Driver
isa_ok $meh, q|Dummy::Driver|, 'Verify we got a driver...';
# Verify that the module name matches what we want it to.
is $meh->module_name(), q|Dummy::Module|, 'Verify it thinks it loaded the module...';
# Verify we can call the method we wanted...
ok $meh->module_can('foo'), 'Verify that we can call the function we defined, foo()...';
say '>'.$meh->exec('foo', {}).'<';
is $meh->exec('foo', {}), q|Dummy::Module - FOO|, 'Verify that the execution passes!';

=head1 SEE ALSO

L<Test::More>, L<Test::Exception>

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
