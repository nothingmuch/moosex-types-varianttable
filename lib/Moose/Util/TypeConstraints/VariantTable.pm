#!/usr/bin/perl

package Moose::Util::TypeConstraints::VariantTable;
use Moose;

use Moose::Util::TypeConstraints;

use Carp qw(croak);

our $VERSION = "0.01";

sub BUILD {
    my ( $self, $params ) = @_;

    if ( my $variants = $params->{variants} ) {
        foreach my $variant ( @$variants ) {
            $self->add_variant( @{ $variant }{qw(type value)} );
        }
    }
}

has _variant_list => (
    isa => "ArrayRef[HashRef]",
    is  => "rw",
    default => sub { [] },
);

sub clone {
    my $self = shift;
    ( ref $self )->new( _variant_list => [@{ $self->_variant_list }] );
}

sub merge {
    my ( @selves ) = @_; # our @selves reads better =/

    my $self = $selves[0];

    return ( ref $self )->new(
        variants => [ map { @{ $_->_variant_list } } @selves ],
    );
}

sub has_type {
    my ( $self, $type_or_name ) = @_;

    my $type = Moose::Util::TypeConstraints::find_type_constraint($type_or_name);

    foreach my $existing_type ( map { $_->{type} } @{ $self->_variant_list } ) {
        return 1 if $type->equals($existing_type);
    }

    return;
}

sub has_parent {
    my ( $self, $type_or_name ) = @_;

    my $type = Moose::Util::TypeConstraints::find_type_constraint($type_or_name);

    foreach my $existing_type ( map { $_->{type} } @{ $self->_variant_list } ) {
        return 1 if $type->is_subtype_of($existing_type);
    }

    return;
}

sub add_variant {
    my ( $self, $type_or_name, $value ) = @_;

    croak "Duplicate variant entry for $type_or_name"
        if $self->has_type($type_or_name);

    my $type = Moose::Util::TypeConstraints::find_type_constraint($type_or_name);

    my $list = $self->_variant_list;

    my $entry = { type => $type, value => $value };

    for ( my $i = 0; $i < @$list; $i++ ) {
        if ( $type->is_subtype_of($list->[$i]{type}) ) {
            splice @$list, $i, 0, $entry;
            return;
        }
    }

    push @$list, $entry;
    return;
}

sub remove_variant {
    my ( $self, $type_or_name, $value ) = @_;

    my $type = Moose::Util::TypeConstraints::find_type_constraint($type_or_name);

    my $list = $self->_variant_list;

    @$list = grep { not $_->{type}->equals($type) } @$list;

    return;
}

sub find_variant {
    my ( $self, @args ) = @_;

    if ( my $entry = $self->_find_variant(@args) ) {
        if ( wantarray ) {
            return @{ $entry }{qw(value type)};
        } else {
            return $entry->{value};
        }
    }

    return;
}

sub _find_variant {
    my ( $self, $value ) = @_;

    foreach my $entry ( @{ $self->_variant_list } ) {
        if ( $entry->{type}->check($value) ) {
            return $entry;
        }
    }

    return;
}

sub dispatch {
    my $self = shift;
    my $value = $_[0];

    if ( my $result = $self->find_variant($value) ) {
        if ( (ref($result)||'') eq 'CODE' ) {
            goto &$result;
        } else {
            return $result;
        }
    }

    return;
}

__PACKAGE__

__END__

=pod

=head1 NAME

Moose::Util::TypeConstraints::VariantTable - Type constraint based variant
table

=head1 SYNOPSIS

	use Moose::Util::TypeConstraints::VariantTable;

    my $dispatch_table = Moose::Util::TypeConstraints::VariantTable->new(
        variants => [
            { type => "Foo", value => \&foo_handler },
            { type => "Bar", value => \&bar_handler },
            { type => "Item", value => \&fallback },
        ],
    );

    # a handler will be chosen based on $item and which type constraints it passes
    $dispatch_table->dispatch( $item, @args );

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item new

=item add_variant $type, $value

Registers C<$type>, such that C<$value> will be returned by C<find_variant> for
items passing $type.

Subtyping is respected in the table.

=item find_variant $value

Returns the registered value for the most specific type that C<$value> passes.

=item dispatch $value, @args

A convenience method for when the registered values are code references.

Calls C<find_variant> and if the result is a code reference, it will C<goto>
this code reference with the value and any additional arguments.

=item has_type $type

Returns true if an entry for C<$type> is registered.

=item has_parent $type

Returns true if a parent type of C<$type> is registered.

=back

=cut



=head1 VERSION CONTROL

This module is maintained using Darcs. You can get the latest version from
L<http://nothingmuch.woobling.org/code>, and use C<darcs send> to commit
changes.

=head1 AUTHOR

Yuval Kogman E<lt>nothingmuch@woobling.orgE<gt>

=head1 COPYRIGHT

	Copyright (c) 2008 Yuval Kogman. All rights reserved
	This program is free software; you can redistribute
	it and/or modify it under the same terms as Perl itself.

=cut
