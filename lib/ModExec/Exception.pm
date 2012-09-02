# Exception.pm -- A simple exception class definition
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

use strict;
package ModExec::Exception;
use base 'Error::Simple';
use vars qw($VERSION);
use Carp;
use Error qw/:try/;

$VERSION = 0.1;

sub new {
  my ($class, $code, $msg) = @_;
  my $this = {};

  bless ($this, $class);

  $this->errstr ($msg, $code);
  if (defined (&Carp::longmess)) {
    $this->stack (&Carp::longmess);
  }

  return $this;
}

sub errstr ($;$$)
{
  my ($this, $msg, $code) = @_;

  $this->{"_code"} = $code unless (!defined ($code));
  $this->{"_msg"} = $msg unless (!defined ($msg));

  return $this->{"_msg"};
}

sub errcode {
  my ($this, $code) = @_;

  $this->{"_code"} = $code unless (!defined ($code));

  return $this->{"_code"};
}

sub stack {
  my ($this, $stack) = @_;

  $this->{"_stack"} = $stack unless (!defined ($stack));

  return $this->{"_stack"};
}

sub stringify {
  my ($this) = @_;
  my $str = undef;

  $str = $this->errcode () . ": " . $this->errstr () . "\n" . $this->stack ();

  return $str;
}

1;

__END__
=pod

=head1 NAME

ModExec::Exception - A simple exception class definition.

=head1 SYNOPSIS

 use ModExec::Exception;

 try {
    do_something() ||
    throw ModExec::Exception (
       "ERR_SOME_ERROR", "Some error occurred");
 } catch ModExec::Exception with {
   die ($@->errstr ());
 }

=head1 DESCRIPTION

This is a simple exception class.

=cut
