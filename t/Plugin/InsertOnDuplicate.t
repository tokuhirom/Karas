use strict;
use warnings;
use utf8;
use Test::More;
use Test::Requires 'Test::mysqld';
use Karas;

my $mysqld = Test::mysqld->new(
    my_cnf => {
        'skip-networking' => '',    # no TCP socket
    }
) or plan skip_all => $Test::mysqld::errstr;

my $db = Karas->new(connect_info => [
    $mysqld->dsn(dbname => 'test'),
]);
Karas->load_plugin('InsertOnDuplicate');
$db->dbh->do(q{CREATE TABLE counter (date date primary key, n int unsigned not null)});
$db->insert_on_duplicate(counter => { date => '2012-11-11', n => 1 }, { n => \"n + 1"});
$db->insert_on_duplicate(counter => { date => '2012-11-11', n => 1 }, { n => \"n + 1"});
$db->insert_on_duplicate(counter => { date => '2012-11-11', n => 1 }, { n => \"n + 1"});
$db->insert_on_duplicate(counter => { date => '2012-11-11', n => 1 }, { n => \"n + 1"});
my $row = ($db->search('counter', { date => '2012-11-11' }))[0];
is($row->n, 4);

done_testing;

