use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;
use Karas::Dumper;

subtest 'dumper' => sub {
    my $db = create_karas();
    $db->dbh->do(q{CREATE TABLE member (id int unsigned not null primary key, name varchar(255))});
    $db->dbh->do(q{CREATE TABLE entry (id int unsigned not null primary key, member_id int unsigned not null, title varchar(255))});
    $db->dbh->do(q{CREATE TABLE tag_entry (tag_id int unsigned not null, entry_id int unsigned not null, primary key (tag_id, entry_id))});
    my $src = Karas::Dumper->dump(
        dbh => $db->dbh,
        namespace => 'MyApp::DB',
    );
    note $src;
    eval $src;
    ok(!$@) or diag $@;
    is_deeply([MyApp::DB::Row::Member->primary_key], ['id']);
    is_deeply([MyApp::DB::Row::TagEntry->primary_key], ['tag_id', 'entry_id']);
};

done_testing;

