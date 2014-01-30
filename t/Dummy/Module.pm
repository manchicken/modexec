# This is just for the test.
package Dummy::Module;
use strict;
use warnings;
use 5.010;

require Exporter;
our @ISA = qw/Exporter ModExec::DriverHook/;
our @EXPORT = qw/modexec_export/;

sub foo {
	say __PACKAGE__.' - FOO!';
}

sub modexec_export {
  my ($secure) = @_;
  my $funcs = {};

  $funcs = {
    "foo()"=>\&foo,
  };
}

1;