# -*- mode: cperl; -*-
use Test::Dependencies
    exclude => [qw(Test::Dependencies Test::Base Test::Perl::Critic
                   IPC::Lock::WithTTL
                 )],
    style   => 'light';
ok_dependencies();
