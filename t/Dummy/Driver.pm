package Dummy::Driver;
use strict;
use warnings;
use 5.010;

use base qw/ModExec::Driver ModExec::DriverHook/;

sub new {
  return bless({},shift);
}

sub exec {
  my ($self, $function, @args) = @_;
  return $self->func_exec( function => $function, arguments => @args );
}

1;
