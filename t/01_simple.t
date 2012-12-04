use strict;
use warnings;
use utf8;
use Test::More;
use Test::Requires 'DBD::SQLite';
use Karas;

sub create_karas {
    return Karas->new(
        connect_info => [
            'dbi:SQLite::memory:', '', '', {
            RaiseError => 1,
            PrintError => 0,
        }]
    );
}

subtest 'update from row object.' => sub {
    my $db = create_karas();
    $db->dbh->do(q{CREATE TABLE foo (id integer not null, name varchar(255))});
    my $row = $db->insert(foo => {id => 1, name => 'John'});
    is($row->name(), 'John');
    $row->name('Ben');
    is($row->name(), 'Ben');
    $db->update($row);
    my $new = $db->refetch($row);
    is($new->name(), 'Ben');
};

subtest 'count' => sub {
    my $db = create_karas();
    $db->dbh->do(q{CREATE TABLE foo (id integer not null, name varchar(255))});
    $db->insert(foo => {id => 1, name => 'John'});
    $db->insert(foo => {id => 2, name => 'John'});
    $db->insert(foo => {id => 3, name => 'John'});
    $db->insert(foo => {id => 4, name => 'Ben'});
    is($db->count('foo'), 4);
    is($db->count('foo' => {name => 'John'}), 3);
    is($db->count('foo' => {name => 'Ben'}), 1);
};

done_testing;

