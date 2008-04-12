#!/usr/bin/perl

package Moose::Meta::Method::VariantTable;
use Moose;

extends qw(Moose::Object Moose::Meta::Method);

use Moose::Util::TypeConstraints::VariantTable;

has _variant_table => (
    isa => "Moose::Util::TypeConstraints::VariantTable",
    is  => "ro",
    default => sub { Moose::Util::TypeConstraints::VariantTable->new },
    handles => qr/^[a-z]/,
);

has body => (
    isa => "CodeRef",
    is  => "ro",
    lazy => 1,
    builder => "initialize_body",
);

sub initialize_body {
    my $self = shift;

    my $variant_table = $self->_variant_table;

    return sub {
        my ( $self, $value, @args ) = @_;

        if ( my ( $result, $type ) = $variant_table->find_variant($value) ) {
            my $method = (ref($result)||'') eq 'CODE'
                ? $result
                : $self->can($result);

            goto $method;
        }

        return;
    };
}


__PACKAGE__

__END__

=pod

=head1 NAME

Moose::Meta::Method::VariantTable - 

=head1 SYNOPSIS

	use Moose::Meta::Method::VariantTable;

=head1 DESCRIPTION

=cut


