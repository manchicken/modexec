# This is just for the test.
package Dummy::Module;
use strict;
use warnings;
use 5.010;

use base qw/Exporter ModExec::DriverHook/;

sub foo {
	say __PACKAGE__.' - FOO!';
    return ''.__PACKAGE__.' - FOO!';
}

sub modexec_export {
  my ($secure) = @_;
  my $funcs = {};

  return {
    foo => \&foo,
  };
}

1;
