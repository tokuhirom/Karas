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

done_testing;

