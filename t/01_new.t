use strict;
use Test::More;

require IPC::Lock::WithTTL;
note("new");
my $obj = new_ok("IPC::Lock::WithTTL");

# diag explain $obj

done_testing;
