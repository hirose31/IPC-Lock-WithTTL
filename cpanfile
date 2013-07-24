# -*- mode: cperl -*-

requires 'Smart::Args';
requires 'Class::Accessor::Lite';

on 'test' => sub {
    requires 'Test::More';
    requires 'Devel::Cover';
};
