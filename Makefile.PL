use inc::Module::Install;
#use Module::Install::AuthorTests;
#use Module::Install::Repository;

name       'IPC-Lock-WithTTL';
all_from   'lib/IPC/Lock/WithTTL.pm';
license    'perl';
#homepage   'http://fixme/';
#repository 'http://github.com/hirose31/ipc-lock-withttl';
# OR auto_set_repository;

# requires '';

test_requires 'Test::More' => 0.88;

tests_recursive;
author_tests 'xt';

auto_set_repository;
use_test_base;
WriteAll;

