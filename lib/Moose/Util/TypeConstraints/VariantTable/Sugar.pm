#!/usr/bin/perl

use strict;
use warnings;

use Carp qw(croak);

use Sub::Exporter -setup => {
	exports => [ "variant_method" ],
};

use Moose::Meta::Method::VariantTable;

sub variant_method ($$&) {
	my ( $name, $type, $body ) = @_;

	my $class = caller;

	my $meta = $class->meta;

	my $meta_method = $class->meta->get_method($name);

	unless ( $meta_method ) {
		$meta_method = Moose::Meta::Method::VariantTable->new();
		$meta->add_method( $name => $meta_method );
	}

	if ( $meta_method->isa("Moose::Meta::Method::VariantTable") ) {
		$meta_method->add_variant( $type, $body );
	} else {
		croak "Method $name is already defined";
	}

	return $meta_method->body;
}

__PACKAGE__

__END__
