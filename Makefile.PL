use inc::Module::Install;
use Module::Install::AuthorTests;

name       'IPC-Lock-WithTTL';
all_from   'lib/IPC/Lock/WithTTL.pm';
license    'perl';
repository 'https://github.com/hirose31/IPC-Lock-WithTTL';

if ($^O eq 'MSWin32') {
    print STDERR "OS unsupported: $^O\n";
    exit;
}

requires 'Smart::Args';
requires 'Class::Accessor::Lite';

test_requires 'Test::More' => 0.88;

tests_recursive;
author_tests 'xt';

auto_set_repository;
use_test_base;
WriteAll;

