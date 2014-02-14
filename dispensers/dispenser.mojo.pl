#!/usr/bin/env perl

=head1 NAME

dispenser.mojo.pl - A ModExec dispenser using the Mojolicious::Lite framework.

=head1 DESCRIPTION

This is a dispenser using Mojolicious::Lite. For this dispenser we will only implement
non-secure calls

=cut

use strict;
use warnings;

use 5.010;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use English qw/-no_match_vars/;
use Readonly;
use Scalar::Util qw/blessed/;

# We use mojo for this dispenser
use Mojolicious::Lite;
use Mojo::JSON;

# Our libs
use ModExec;
use ModExec::Exception;

# Calling this dispenser looks like
any [qw/GET POST/] => '/:module_name/:method_name' => sub {
    my ($self) = @_;

    my $module_name = $self->param('module_name');
    my $method_name = $self->param('method_name');
    my $arguments   = $self->param('arguments');

    my $json = Mojo::JSON->new();

    try {
    	my $decoded_arguments = $json->decode( $arguments );
	} catch {
		my $e = $ARG;

		if ( blessed $e && $e->isa)

		$self->render( json => )
	};
};
