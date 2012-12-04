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
    $db->add_trigger('BEFORE_INSERT' => sub {
        my ($db, $table_name, $values) = @_;
        if ($plugin->_has_created_on($db->dbh, $table_name)) {
            $values->{'created_on'} = time();
        }
        if ($plugin->_has_updated_on($db->dbh, $table_name)) {
            $values->{'updated_on'} = time();
        }
    });
    $db->add_trigger('BEFORE_UPDATE_ROW' => sub {
        my ($db, $row, $set) = @_;
        if ($plugin->_has_updated_on($db->dbh, $row->table_name)) {
            $set->{'updated_on'} = time();
        }
    });
    $db->add_trigger('BEFORE_UPDATE_DIRECT' => sub {
        my ($db, $table_name, $set, $where) = @_;
        if ($plugin->_has_updated_on($db->dbh, $table_name)) {
            $set->{'updated_on'} = time();
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

