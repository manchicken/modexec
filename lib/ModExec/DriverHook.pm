
=pod

=head1 NAME

ModExec::DriverHook - A driver hook abstraction for ModExec.

=cut

package ModExec::DriverHook;
use strict;
use warnings;
use ModExec::Exception;

=head1 VERSION

ModExec 1.0

=cut

our $VERSION = 1.0;

=head1 SYNOPSIS

 use base qw/Exporter ModExec::DriverHook/;

 sub foo {
  say __PACKAGE__.' - FOO!';
 }

 sub modexec_export {
   my ($secure) = @_;
   my $funcs = {};

   $funcs = {
     "foo"=>\&foo,
   };
 }

=head1 DESCRIPTION

This module gives the modexec framework something to tie into for modexec-compatible PMs.

=head1 MODEXEC EXPORTING

For security purposes, and function-providing purposes, it is important to determine whether or not you are authenticated, and evaluate how your code needs to behave differently in each instance. NEVER allow your code to expose any ModExec functions directly. EVER. NEVER EVER EVER.

Requiring a separate modexec_export function allows us to keep people from using something like File.pm and then unlinking files.

Here's how I suggest we play this game....

 sub foo_authed {
   return do_something();
 }
 
 sub foo_unauthed {
   return do_something_else();
 }
 
 sub modexec_export {
   my $auth = (@_);
 
   # Should be zero or non-zero
   if ($auth) {
      return {"foo"=>\&foo_authed};
   } else {
      return {"foo"=>\&foo_unauthed};
   }
 }

This, obviously, also means that both the authed version and the unauthed version must take the same number of arguments. Also, for consistency's sake, try to make your functions and their exported names be somewhat consistent.

=head2 Exported Function Guidelines

It is required that you specify a prototype in the modexec_export returns. If you fail to do so, loading the module will throw an exception. This is just another way we can ensure that the right data is making it to the right code, and that the functions don't have to use any special means of abstracting the arguments. We want all of the abstraction to be done at the driver level. The only change to a host module would be the addition of the modexec_export function.

All functions in a host function must return a scalar value. If you want your function that returns an array or a hash to use modexec, please add a wantarray call in there to handle this, or write a wrapper around it, something like this...

 sub modexec_export {
   my ($auth) = @_;

   my $funcs = {
     "foo" => sub {
       my @foo = the_real_foo (@_);
       return \@foo;
     },
   };
 }

All you have to do is change it to a reference to the hash or array, and it's all good.

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

=cut

1;
