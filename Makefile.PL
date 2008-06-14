#!/usr/bin/perl -w

use strict;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'MooseX::Types::VariantTable',
    VERSION_FROM => 'lib/MooseX/Types/VariantTable.pm',
    INSTALLDIRS  => 'site',
    SIGN         => 1,
    PL_FILES     => { },
    PREREQ_PM    => {
        'Test::use::ok' => 0,
        'Test::Exception' => 0,
        'Sub::Exporter' => 0,
        'Moose' => '0.41', # for Class tc to sort properly it needs a fixed is_subtype_of
    },
);

