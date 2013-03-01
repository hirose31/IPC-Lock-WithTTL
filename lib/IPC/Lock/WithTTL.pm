package IPC::Lock::WithTTL;

use strict;
use warnings;

use Carp;
use Log::Minimal;
use Smart::Args;
use Class::Accessor::Lite (
    rw => [qw(ttl)],
    ro => [qw(file kill_old_proc)],
   );
use Fcntl qw(:DEFAULT :flock :seek);

sub new {
    args(my $class,
         my $file          => { isa => 'Str' },
         my $ttl           => { isa => 'Int',  default => 0 },
         my $kill_old_proc => { isa => 'Bool', default => 0 },
        );

    my $self = bless {
        file          => $file,
        ttl           => $ttl,
        kill_old_proc => $kill_old_proc,
        #
        _fh           => undef,
    }, $class;

    return $self;
}

sub _fh {
    args(my $self);

    unless ($self->{_fh}) {
        open $self->{_fh}, '+>>', $self->file or croak $!;
    }

    return $self->{_fh};
}

sub acquire {
    args(my $self,
         my $ttl => { isa => 'Int', optional => 1 },
        );
    $self->ttl($ttl) if $ttl;

    my $fh = $self->_fh;
    flock $fh, LOCK_EX or return;

    seek $fh, 0, SEEK_SET;
    my($heartbeat) = <$fh>;
    $heartbeat ||= "0 0";
    debugf("heartbeat: %s", $heartbeat);
    my($pid, $expiration) = split /\s+/, $heartbeat;
    $pid += 0; $expiration += 0;

    my $now = time();
    my $new_expiration;
    my $acquired = 0;
    if ($pid == 0) {
        # Previous task finished successfully
        if ($now >= $expiration) {
            # expired
            $new_expiration = $self->update_heartbeat;
            $acquired = 1;
        } else {
            # not expired
            $acquired = 0;
        }
    } elsif ($pid != $$) {
        # Other task is in process?
        if ($now >= $expiration) {
            # expired (Last task may have terminated abnormally)
            $new_expiration = $self->update_heartbeat;

            if ($self->kill_old_proc && $pid > 0) {
                debugf("kill %d", $pid);
                kill 'KILL', $pid;
            }
            $acquired = 1;
        } else {
            # not expired (Still running)
            $acquired = 0;
        }
    } else {
        # Previous task done by this process
        if ($now >= $expiration) {
            # expired (Last task may have terminated abnormally)
            $new_expiration = $self->update_heartbeat;
            $acquired = 1;
        } else {
            # not expired (Last task may have terminated abnormally)
            $new_expiration = $self->update_heartbeat;
            $acquired = 1;
        }
    }

    flock $fh, LOCK_UN;
    if ($acquired) {
        return wantarray ? (1, { pid => $$,   expiration => $new_expiration })
                         : 1;
    } else {
        return wantarray ? (0, { pid => $pid, expiration => $expiration })
                         : 0;
    }
}

sub release {
    args(my $self);

    $self->update_heartbeat(pid => 0);
    undef $self->{_fh};

    return 1;
}

sub update_heartbeat {
    args(my $self,
         my $pid => { isa => 'Int', default => $$ },
       );

    my $fh = $self->_fh;

    my $expiration = time() + $self->ttl;
    debugf("update heartbeat to: %d %d", $pid, $expiration);

    seek $fh, 0, SEEK_SET;
    truncate $fh, 0;
    print {$fh} join(' ', $pid, $expiration)."\n";

    return $expiration;
}

1;

__END__

=encoding utf-8

=head1 NAME

IPC::Lock::WithTTL - fixme

=head1 SYNOPSIS

    use IPC::Lock::WithTTL;
    fixme

=head1 DESCRIPTION

IPC::Lock::WithTTL is fixme

=head1 METHODS

=over 4

=item B<method_name>($message:Str)

fixme

=back

=head1 ENVIRONMENT

=over 4

=item HOME

Used to determine the user's home directory.

=back

=head1 FILES

=over 4

=item F</path/to/config.ph>

設定ファイル。

=back

=head1 AUTHOR

HIROSE Masaaki E<lt>hirose31 _at_ gmail.comE<gt>

=head1 REPOSITORY

L<https://github.com/hirose31/ipc-lock-withttl>

  git clone git://github.com/hirose31/ipc-lock-withttl.git

patches and collaborators are welcome.

=head1 SEE ALSO

L<Module::Hoge|Module::Hoge>,
ls(1), cd(1)

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# for Emacsen
# Local Variables:
# mode: cperl
# cperl-indent-level: 4
# indent-tabs-mode: nil
# coding: utf-8
# End:

# vi: set ts=4 sw=4 sts=0 :
