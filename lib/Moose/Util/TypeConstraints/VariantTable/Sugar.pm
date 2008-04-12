#!/usr/bin/perl

package Moose::Util::TypeConstraints::VariantTable::Sugar;

use strict;
use warnings;

use Carp qw(croak);

use base qw(Exporter);

our @EXPORT = qw(variant_method);

use Moose::Meta::Method::VariantTable;

sub variant_method ($$&) {
	my ( $name, $type, $body ) = @_;

	my $class = caller;

	my $meta = $class->meta;

	my $meta_method = $class->meta->get_method($name);

	unless ( $meta_method ) {
        if ( my $parent_method = ( $class->meta->find_all_methods_by_name($name) )[0] ) {
            # FIXME allow overriding of variants
            $meta_method = $parent_method->{code}->clone;
        } else {
            $meta_method = Moose::Meta::Method::VariantTable->new();
        }

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
