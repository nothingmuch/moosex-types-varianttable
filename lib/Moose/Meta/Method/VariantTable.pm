#!/usr/bin/perl

package Moose::Meta::Method::VariantTable;
use Moose;

extends qw(Moose::Object Moose::Meta::Method);

use Moose::Util::TypeConstraints::VariantTable;

has _variant_table => (
    isa => "Moose::Util::TypeConstraints::VariantTable",
    is  => "ro",
    default => sub { Moose::Util::TypeConstraints::VariantTable->new },
    handles => qr/^(?: \w+_variant$ | has_ )/x,
);

has body => (
    isa => "CodeRef",
    is  => "ro",
    lazy => 1,
    builder => "initialize_body",
);

sub merge {
    my ( $self, @others ) = @_; # our @selves reads better =/

    return ( ref $self )->new(
        _variant_table => $self->_variant_table->merge(map { $_->_variant_table } @others),
    );
}

sub clone {
    my $self = shift;
    ( ref $self )->new( _variant_table => $self->_variant_table->clone );
}
    
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


