use strict;
use warnings;
use utf8;
use Test::More;
use Test::Requires 'DBD::SQLite';
use Test::Time;
use Karas;

{
    package MyDB;
    use parent qw/Karas/;
    __PACKAGE__->load_plugin('Timestamp');
}

my $db = MyDB->new(connect_info => ['dbi:SQLite::memory:', '', '', {
    RaiseError => 1,
    PrintError => 0,
    AutoCommit => 1,
}]);
$db->dbh->do(q{CREATE TABLE foo (id integer PRIMARY KEY, name VARCHAR(255), created_on integer, updated_on integer)});
$db->insert(foo => {
     id => 1,
     name => 'heh',
});
my @foo = $db->search('foo');
my ($row) = @foo;
is(0+@foo, 1);
ok($row->created_on);
ok($row->updated_on);
sleep 2;
$db->update($row, {name => 'Yoshio'});
$row = $db->refetch($row);
is($row->id, 1);
is($row->name, 'Yoshio');
isnt($row->created_on, $row->updated_on);

done_testing;

