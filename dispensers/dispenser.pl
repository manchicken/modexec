#!/usr/bin/perl
# index.cgi - A CGI ModExec dispenser
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
use warnings;

use lib qw(./);
use Error qw/:try/;
use CGI;
use URI::Escape;
use ModExec;

use constant MODEXEC_DRIVER => "JSON";

sub is_authenticated {
  # Put your authentication logic here.

  return 0;
}

sub print_exception {
  my ($query, $e) = @_;

  my $output = undef;
  my $json_obj = {};

  print STDERR "Received exception: (".$e->errcode().") ".$e->errstr()."\n";
  $json_obj = {errcode => $e->errcode(),
    errmsg => $e->errstr()};

  $output = objToJson ($json_obj);

  print $query->header('/text/plain')."${output}";

  return;
}

sub print_results {
  my ($query, $return) = @_;

  print $query->header('text/plain')."${return}";

  return;
}

sub main () {
  my $query = CGI->new;
  my $return = "";
  my $use_module = uri_unescape($query->param("use_module")) || undef;
  my $call_function = uri_unescape($query->param("call_function")) || undef;
  my $args = $query->param("args") || undef;
  my $meh = undef;

  # Let's execute the module.
  try {
    if (!defined ($use_module) || !length ($use_module)) {
      throw Exception ("ERR_INVALID_MODEXEC_CALL", "No module specified.");
    } elsif (!defined ($call_function) || !length ($call_function)) {
      throw Exception ("ERR_INVALID_MODEXEC_CALL", "No function call specified.");
    }

    $meh = new ModExec (driver => MODEXEC_DRIVER,
      module => $use_module,
      auth => is_authenticated());

    print_results ($query, $meh->exec($call_function, $args));
  } catch ModExec::Exception with {
    my $err = shift;
    print_exception($query, $err);
  } otherwise {
    my $err = shift;
    print_exception ($query, ModExec::Exception->("ERR_UNKNOWN", $err->stringify()));
  };

  return 0;
}
&main;
