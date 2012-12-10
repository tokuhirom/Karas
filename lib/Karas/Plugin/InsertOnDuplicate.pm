package Karas::Plugin::InsertOnDuplicate;
use strict;
use warnings;
use utf8;
use Carp ();

sub new {
    my $self = shift;
    my %args = @_==1 ? %{$_[0]} : @_;
    bless {%args}, $self;
}

sub init {
    my ($plugin, $db) = @_;
    $db = ref $db if ref $db;

    no strict 'refs';
    *{"$db\::insert_on_duplicate"} = \&_insert_on_duplicate;
}

sub _insert_on_duplicate {
    my ($self, $table_name, $insert_values, $update_values) = @_;
    $self->call_trigger(BEFORE_INSERT_ON_DUPLICATE => $table_name, $insert_values, $update_values);
    my ($sql, @binds) = $self->query_builder->insert_on_duplicate($table_name, $insert_values, $update_values);
    my $sth = $self->dbh->prepare($sql);
    $sth->execute(@binds);
    return undef;
}

1;

