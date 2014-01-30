package Dummy::Driver;
use strict;
use warnings;
use 5.010;

use base qw/ModExec::Driver ModExec::DriverHook/;

sub new {
  return bless({},shift);
}

1;