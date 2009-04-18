use strict;
use warnings;
use Test::More;
use Test::Exception;
use MooseX::Types::VariantTable;
use Moose::Util::TypeConstraints;

BEGIN {
    eval q[
        use MooseX::Types::Structured;
        use MooseX::Types::Moose;
        1;
    ] or plan skip_all => 'requires MooseX::Types and MooseX::Types::Structured';
}

use MooseX::Types::Structured qw/Tuple Dict/;
use MooseX::Types::Moose qw/Num Int Str Any/;

plan tests => 9;

{
    my $t = MooseX::Types::VariantTable->new;
    $t->add_variant( Tuple[Tuple[Num], Dict[]] => 'Num' );
    $t->add_variant( Tuple[Tuple[Str], Dict[]] => 'Str' );

    is($t->find_variant([[21], {}]), 'Num');
    is($t->find_variant([['hey'], {}]), 'Str');
}

{
    package Paper;
    use Moose;

    package Scissors;
    use Moose;

    package Stone;
    use Moose;
}

{
    my $t = MooseX::Types::VariantTable->new;
    $t->add_variant( Tuple[Tuple[ class_type('Paper'),    class_type('Stone')    ], Dict[]] => 1 );
    $t->add_variant( Tuple[Tuple[ class_type('Scissors'), class_type('Paper')    ], Dict[]] => 1 );
    $t->add_variant( Tuple[Tuple[ class_type('Stone'),    class_type('Scissors') ], Dict[]] => 1 );
    $t->add_variant( Tuple[Tuple[ Any, Any ], Dict[]] => 0);

    ok(!$t->find_variant([[ Paper->new, Scissors->new ], {}]));
    ok(!$t->find_variant([[ Stone->new, Stone->new    ], {}]));
    ok( $t->find_variant([[ Paper->new, Stone->new    ], {}]));
}

{
    my $t = MooseX::Types::VariantTable->new;
    $t->add_variant( Tuple[Tuple[ Int, Num ], Dict[]] => 'first' );
    $t->add_variant( Tuple[Tuple[ Num, Int ], Dict[]] => 'second' );

    dies_ok { $t->find_variant([[ 42, 23 ], {}]) };

    is($t->find_variant([[ 42, 23.3 ], {}]), 'first');
    is($t->find_variant([[ 42.2, 23 ], {}]), 'second');
}

{
    my $t = MooseX::Types::VariantTable->new;
    $t->add_variant( Tuple[Tuple[ Int ], Dict[foo => Int]] => 'first'  );
    $t->add_variant( Tuple[Tuple[ Int ], Dict[          ]] => 'second' );

    is($t->find_variant([[ 23 ], { foo => 42 }]), 'first');
    is($t->find_variant([[ 42 ], { }]), 'second');
    ok(!$t->find_variant([[ 23 ], { foo => 'bar' }]));
}
