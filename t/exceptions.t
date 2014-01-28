#!/usr/bin/env perl

=head1 NAME

exception.t - A test for exceptions in the ModExec system.

=head1 SYNOPSIS

 prove exception.t

=head1 DESCRIPTION

 This program tests C<ModExec::Exception>.

=cut

use strict;
use warnings;
use 5.010;

use Test::More tests => 7;
use Test::Exception;

# Load the module using C<use_ok()>
use_ok q{ModExec::Exception};

# Verify that instantiation gives us both a C<ModExec::Exception> and C<Error::Simple>
my $test1 = ModExec::Exception->new();
isa_ok $test1, q{ModExec::Exception}, 'Verify we got a ModExec::Exception instance...';
isa_ok $test1, q{Error::Simple}, 'Verify we got an Error::Simple instance...';

# Verify we can set just the error message
$test1->errstr( q{TEST1} );
is $test1->errstr(), q{TEST1}, 'Verify we can set only the error message...';

# Verify we can set just the error code
$test1->errcode( q{ERR_CODE1} );
is $test1->errcode(), q{ERR_CODE1}, 'Verify we can set only the error code...';

# Verify we can set both error code and error message via errstr()...
$test1->errstr( q{TEST2}, q{ERR_CODE2} );
is $test1->errstr(), q{TEST2}, 'Verify we set the error message...';
is $test1->errcode(), q{ERR_CODE2}, 'Verify we set the error code...';


=head1 SEE ALSO

 L<Test::More>, L<Test::Exception>

=head1 AUTHOR

 $AUTHOR$

=cut

=head1 DIAGNOSTICS

USEFUL STUFF

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
