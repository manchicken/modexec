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

use Test::More tests => 9;
use Test::Exception;
use English q{-no_match_vars};
use Data::Dumper;

# Load the module using C<use_ok()>
sub BEGIN {
	use_ok q{ModExec::Exception};
}

# Verify that instantiation gives us a C<ModExec::Exception> instance.
my $test1 = ModExec::Exception->new();
isa_ok $test1, q{ModExec::Exception},
    'Verify we got a ModExec::Exception instance...';

# Verify we can set just the error message
$test1->errstr(q{TEST1});
is $test1->errstr(), q{TEST1}, 'Verify we can set only the error message...';

# Verify we can set just the error code
$test1->errcode(q{ERR_CODE1});
is $test1->errcode(), q{ERR_CODE1},
    'Verify we can set only the error code...';

# Verify we can set both error code and error message via errstr()...
$test1->errstr( q{TEST2}, q{ERR_CODE2} );
is $test1->errstr(),  q{TEST2},     'Verify we set the error message...';
is $test1->errcode(), q{ERR_CODE2}, 'Verify we set the error code...';

# Verify that we have a stack which includes our test name...
like $test1->stack(), qr{$0}x,
    'Verify that the stack trace includes the test script name...';

# Verify stringify
like $test1->stringify(), qr{
		\A        # The beginning of the string
		ERR_CODE2 # The error code we last set
		:\s       # A colon and a space
		TEST2     # The string TEST2 for the error message
		\n        # A literal newline
		.*?$0     # The program name
	}x, 'Verify that our stringify output looks correct...';

# Let's verify that this behaves like an exception with Error qw/:try/ sugar
my $boom = 0;
try {
    ModExec::Exception->throw( 'ERR_CODE3', 'TEST3' );
} catch {
    $boom = $ARG;
};
isa_ok $boom, q{ModExec::Exception}, 'Verify that Error\'s try/catch sugar works...';

try {
	try {
	    ModExec::Exception->throw( 'ERR_CODE3', 'TEST3' );
	}
	catch {
		$ERRNO->throw();
	};
} catch {

};

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
