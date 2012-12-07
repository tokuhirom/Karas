package Karas::QueryBuilder;
use strict;
use warnings;
use utf8;

use parent qw/SQL::Maker/;

__PACKAGE__->load_plugin('InsertMulti');

sub insert_on_duplicate {
    my ($self, $table_name, $insert_values, $update_values) = @_;
    my ($sql, @binds) = $self->insert($table_name, $insert_values);
    my ($update_cols, $update_vals) = $self->make_set_clause($update_values);
    $sql .= " ON DUPLICATE KEY UPDATE " . join(', ', @$update_cols);
    return ($sql, @binds, @$update_vals);
}

1;

