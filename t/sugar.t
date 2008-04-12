#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

{
    package Gorch;
    use Moose;

    package Bar;
    use Moose;
    
    extends qw(Gorch);

    package Foo;
    use Moose;
    use Moose::Util::TypeConstraints::VariantTable::Sugar;

    variant_method foo => "Gorch" => sub { "gorch" };
    variant_method foo => "Bar" => sub { "bar" };
    variant_method foo => "Item" => sub { "any" };
}

my $bar = Bar->new;
my $gorch = Gorch->new;

my $foo = Foo->new;

can_ok( $foo, "foo" );

is( $foo->foo($gorch), "gorch", "variant table method on $gorch" );
is( $foo->foo($bar), "bar", "... on $bar" );
is( $foo->foo([]), "any", "... on array ref" );

$foo->meta->get_method("foo")->remove_variant("Bar");

is( $foo->foo($gorch), "gorch", "$gorch" );
is( $foo->foo($bar), "gorch", "$bar is now gorch because it's variant was removed" );
