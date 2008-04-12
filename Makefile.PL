#!/usr/bin/perl -w

use strict;

use ExtUtils::MakeMaker;

WriteMakefile(
	NAME         => 'Moose::Util::TypeConstraints::VariantTable',
	VERSION_FROM => 'lib/Moose/Util/TypeConstraints/VariantTable.pm',
	INSTALLDIRS  => 'site',
	SIGN         => 1,
	PL_FILES     => { },
	PREREQ_PM    => {
		'Test::use::ok' => 0,
        'Moose' => '0.41', # for Class tc to sort properly it needs a fixed is_subtype_of
	},
);

