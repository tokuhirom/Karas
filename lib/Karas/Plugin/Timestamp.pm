package Karas::Plugin::Timestamp;
use strict;
use warnings;
use utf8;
use DBIx::Inspector;

sub new {
    my $self = shift;
    my %args = @_==1 ? %{$_[0]} : @_;
    bless {%args}, $self;
}

sub init {
    my ($plugin, $db) = @_;
    Carp::croak("Do not use this plugin to instance") if ref $db;
    Carp::croak("Do not load this plugin to Karas itself. Please make your own child class from Karas.") if $db eq 'Karas';

    $db->add_trigger('BEFORE_INSERT' => sub {
        my ($db, $table_name, $values) = @_;
        if ($plugin->_has_created_on($db->dbh, $table_name)) {
            unless (exists $values->{created_on}) {
                $values->{'created_on'} = time();
            }
        }
        if ($plugin->_has_updated_on($db->dbh, $table_name)) {
            unless (exists $values->{updated_on}) {
                $values->{'updated_on'} = time();
            }
        }
    });
    $db->add_trigger('BEFORE_BULK_INSERT' => sub {
        my ($db, $table_name, $cols, $values) = @_;
        if ($plugin->_has_created_on($db->dbh, $table_name)) {
            unless (grep { 'created_on' eq $_ } @$cols) {
                push @$cols, 'created_on';
                for my $row (@$values) {
                    push @$row, time();
                }
            }
        }
        if ($plugin->_has_updated_on($db->dbh, $table_name)) {
            unless (grep { 'updated_on' eq $_ } @$cols) {
                push @$cols, 'updated_on';
                for my $row (@$values) {
                    push @$row, time();
                }
            }
        }
    });
    $db->add_trigger('BEFORE_UPDATE_ROW' => sub {
        my ($db, $row, $set) = @_;
        if ($plugin->_has_updated_on($db->dbh, $row->table_name)) {
            unless (exists $set->{updated_on}) {
                $set->{'updated_on'} = time();
            }
        }
    });
    $db->add_trigger('BEFORE_UPDATE_DIRECT' => sub {
        my ($db, $table_name, $set, $where) = @_;
        if ($plugin->_has_updated_on($db->dbh, $table_name)) {
            unless (exists $set->{updated_on}) {
                $set->{'updated_on'} = time();
            }
        }
    });
}

sub _has_created_on {
    my ($self, $dbh, $table_name) = @_;
    return !!$self->_load_schema($dbh)->{created_on}->{$table_name};
}

sub _has_updated_on {
    my ($self, $dbh, $table_name) = @_;
    return !!$self->_load_schema($dbh)->{updated_on}->{$table_name};
}

sub _load_schema {
    my ($self, $dbh) = @_;
    $self->{schema} ||= do {
        my %schema;
        my $inspector = DBIx::Inspector->new(dbh => $dbh);
        my @tables = $inspector->tables;
        for my $table (@tables) {
            my @columns = $table->columns;
            for my $key (qw/created_on updated_on/) {
                LOOP: for my $col (@columns) {
                    if ($col->name eq $key) {
                        $schema{$key}->{$table->name}++;
                        last LOOP;
                    }
                }
            }
        }
        \%schema;
    };
}

1;
__END__

=head1 NAME

Karas::Plugin::Timestamp - Timestamp plugin

=head1 DESCRIPTION

This is a timestamp plugin for Karas.

If your tables has created_on or updated_on columns.

Note: This plugin detects created_on/updated_on using DBIx::Inspector.

I don't recommend to use this plugin.

=head1 AFTER MYSQL 5.6

MySQL 5.6 supports more flexible timestamp management.

You can use following style.

    CREATE TABLE t1 (
        created_on DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_on DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    );

See this URL for more details:
https://dev.mysql.com/doc/refman/5.6/en/timestamp-initialization.html
http://optimize-this.blogspot.co.uk/2012/04/datetime-default-now-finally-available.html

