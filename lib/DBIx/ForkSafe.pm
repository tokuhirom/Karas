package DBIx::ForkSafe;
use strict;
use warnings;
use utf8;
use DBI 1.617; # clone bug fixed.
use Carp ();
use Class::Accessor::Lite 0.05 (
    rw => [qw(owner_pid connect_info no_ping)],
);

sub new {
    my $class = shift;
    my %args = @_==1 ? %{$_[0]} : @_;
    bless {%args}, $class;
}

sub dbh {
    my $self = shift;
    $self->_verify_pid();
    return $self->{dbh};
}

sub _verify_pid {
    my $self = shift;

    if ( !$self->owner_pid || $self->owner_pid != $$ ) {
        $self->reconnect;
    }
    elsif ( my $dbh = $self->{dbh} ) {
        if ( !$dbh->FETCH('Active') ) {
            $self->reconnect;
        }
        else {
            unless ($self->no_ping) {
                if (not $dbh->ping ) {
                    $self->reconnect;
                }
            }
        }
    }
}

sub disconnect {
    my ($self) = @_;
    if (my $dbh = $self->{dbh}) {
        if ($self->owner_pid && ($self->owner_pid != $$)) {
            $dbh->{InActiveDestroy} = 1;
        }
        else {
            $dbh->disconnect;
        }
    }
    $self->owner_pid(undef);
}

sub connect {
    my ($self, @args) = @_;
    if (@args) {
        $self->connect_info(\@args);
    }
    my $connect_info = $self->connect_info();
    $self->{dbh} = eval { DBI->connect(@$connect_info) }
        or Carp::croak("Connection error: " . ($@ || $DBI::errstr));
    $self->owner_pid($$);
}

sub reconnect {
    my $self = shift;
    my $dbh = $self->{dbh};
    $self->disconnect();
    if (@_) {
        $self->connect(@_);
    } else {
        $self->{dbh} = eval { $dbh->clone({InactiveDestroy => 1}) }
            or Carp::croak("Reconnection error: " . ($@ || $DBI::errstr));
        $self->owner_pid($$);
    }
}

sub connected {
    my $self = shift;
    my $dbh  = $self->{dbh};
    return $self->owner_pid && $dbh->ping;
}

1;
