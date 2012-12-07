use strict;
use warnings;
use utf8;
use Test::More;
use Test::Requires 'DBD::SQLite', 'Test::Time';
use Test::Time;
use Karas;

{
    package MyDB;
    use parent qw/Karas/;
    __PACKAGE__->load_plugin('Timestamp');
}

sub create_db {
    my $db = MyDB->new(connect_info => ['dbi:SQLite::memory:', '', '', {
        RaiseError => 1,
        PrintError => 0,
        AutoCommit => 1,
    }]);
    $db->dbh->do(q{CREATE TABLE foo (id integer PRIMARY KEY, name VARCHAR(255), created_on integer, updated_on integer)});
    $db;
};

subtest 'insert' => sub {
    my $db = create_db();
    $db->insert(foo => {
        id => 1,
        name => 'heh',
    });
    my $row = $db->retrieve(foo => 1);
    ok($row->created_on);
    ok($row->updated_on);
};

subtest 'bulk_insert' => sub {
    my $db = create_db();
    $db->bulk_insert(foo => ['id', 'name'], [
         [1, 'heh'],
         [2, 'bar'],
    ]);
    my $row = $db->retrieve(foo => 1);
    ok($row);
    ok($row->created_on);
    ok($row->updated_on);
};

subtest 'update_row' => sub {
    my $db = create_db();
    $db->insert(foo => {
        id => 1,
        name => 'heh',
    });
    my $row = $db->retrieve(foo => 1);
    sleep 2;
    $db->update($row, {name => 'Yoshio'});
    $row = $db->refetch($row);
    isnt($row->created_on, $row->updated_on);
};

subtest 'update_direct' => sub {
    my $db = create_db();
    $db->insert(foo => {
        id => 1,
        name => 'heh',
    });
    my $row = $db->retrieve(foo => 1);
    sleep 2;
    $db->update('foo' => {name => 'Yoshio'}, {id => 1});
    $row = $db->refetch($row);
    isnt($row->created_on, $row->updated_on);
};

done_testing;

