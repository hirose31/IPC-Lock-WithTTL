<div>
    <a href="https://travis-ci.org/hirose31/IPC-Lock-WithTTL"><img src="https://travis-ci.org/hirose31/IPC-Lock-WithTTL.png?branch=master" alt="Build Status" /></a>
    <a href="https://coveralls.io/r/hirose31/IPC-Lock-WithTTL?branch=master"><img src="https://coveralls.io/repos/hirose31/IPC-Lock-WithTTL/badge.png?branch=master" alt="Coverage Status" /></a>
</div>

# NAME

IPC::Lock::WithTTL - run only one process up to given timeout

# SYNOPSIS

    use IPC::Lock::WithTTL;
    
    my $lock = IPC::Lock::WithTTL->new(
        file          => '/tmp/lockme',
        ttl           => 5,
        kill_old_proc => 0,
       );
    
    my($r, $hb) = $lock->acquire;
    
    if ($r) {
        infof("Got lock! yay!!");
    } else {
        critf("Cannot get lock. Try after at %d", $hb->{expiration});
        exit 1;
    }
    
    $lock->release;

# DESCRIPTION

IPC::Lock::WithTTL provides inter process locking feature.
This locking has timeout feature, so we can use following cases:

    * Once send an alert email, don't send same kind of alert email within 10 minutes.
    * We want to prevent the situation that script for failover some system is invoked more than one processes at same time and invoked many times in short time.

# DETAIL

## SEQUENCE

    1. flock a heartbeat file (specified by file param in new) with LOCK_EX
       return if failed to flock.
    2. read a heartbeat file and examine PID and expiration (describe later)
       return if I should not go ahead.
    3. update a heartbeat file with my PID and new expiration.
    4. ACQUIRED LOCK
    5. unlock a lock file.
    6. process main logic.
    7. RELEASE LOCK with calling $lock->release method.
       In that method update a heartbeat file with PID=0 and new expiration.

## DETAIL OF EXAMINATION OF PID AND EXPIRATION

Format of a heartbeat file (lock file) is:

    PID EXPIRATION

Next action table by PID and expiration

    PID       expired?  Next action      Description
    =========================================================================
    not mine  yes       acquired lock*1  Another process is running or
    - - - - - - - - - - - - - - - - - -  exited abnormally (without leseasing
    not mine  no        return           lock).
    -------------------------------------------------------------------------
    mine      yes       acquired lock    Previously myself acquired lock but
    - - - - - - - - - - - - - - - - - -  does not release lock.
    mine      no        acquired lock
    -------------------------------------------------------------------------
    0         yes       acquired lock    Previously someone acquired and
    - - - - - - - - - - - - - - - - - -  released lock successfully.
    0         no        return
    -------------------------------------------------------------------------
    
    *1 try to kill another process if you enable kill_old_proc option in new().

# METHODS

- **new**($args:Hash)

        file => Str (required)
          File path of heartbeat file. IPC::Lock::WithTTL also flock this file.
        
        ttl  => Int (default is 0)
          TTL to exipire. expiration time set to now + TTL.
        
        kill_old_proc => Boolean (default is 0)
          Try to kill old process which might exit abnormally.

- **acquire**(ttl => $TTL:Int)

    Try to acquire lock. ttl option set TTL to expire (override ttl in new())

    This method returns scalar or list by context.

        Scalar context
        =========================================================================
          Acquired lock successfully
            1
          -----------------------------------------------------------------------
          Failed to acquire lock
            0
        
        List context
        =========================================================================
          Acquired lock successfully
            (1, { pid => PID, expiration => time_to_expire })
            PID is mine. expiration is setted by me.
          -----------------------------------------------------------------------
          Failed to acquire lock
            (0, { pid => PID, expiration => time_to_expire })
            PID is another process. expiration is setted by another process.

- **release**()

    Update a heartbeat file (PID=0 and new expiration) and release lock.

# AUTHOR

HIROSE Masaaki <hirose31 \_at\_ gmail.com>

# REPOSITORY

[https://github.com/hirose31/IPC-Lock-WithTTL](https://github.com/hirose31/IPC-Lock-WithTTL)

    git clone git://github.com/hirose31/IPC-Lock-WithTTL.git

patches and collaborators are welcome.

# SEE ALSO

[IPC::Lock](https://metacpan.org/pod/IPC::Lock)

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
