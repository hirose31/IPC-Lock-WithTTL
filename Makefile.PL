use inc::Module::Install;

name       'IPC-Lock-WithTTL';
all_from   'lib/IPC/Lock/WithTTL.pm';
license    'perl';
repository 'https://github.com/hirose31/IPC-Lock-WithTTL';
auto_provides;

if ($^O eq 'MSWin32') {
    print STDERR "OS unsupported: $^O\n";
    exit;
}

cpanfile;
WriteAll;
