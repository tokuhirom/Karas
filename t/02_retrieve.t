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
        }],
        row_class_map => {},
        @_,
    );
}

subtest 'run' => sub {
    my $db = create_karas();
    $db->dbh->do(q{CREATE TABLE member (id INTEGER PRIMARY KEY, name)});
    $db->load_schema_from_db(namespace => 'MyApp::DB');
    $db->insert(member => {id => 1, name => 'John'});
    $db->insert(member => {id => 2, name => 'Ben'});
    $db->insert(member => {id => 3, name => 'Dan'});
    is($db->retrieve('member' => 2)->name, 'Ben');
};

subtest 'multi pk' => sub {
    my $db = create_karas(default_row_class => 'MultiPK');
    $db->dbh->do(q{CREATE TABLE tag_entry (tag_id, entry_id, updated_at, PRIMARY KEY (tag_id, entry_id))});
    $db->load_schema_from_db(namespace => 'MyApp2::DB');
    $db->insert(tag_entry => {tag_id => 3, entry_id => 4, updated_at => 555});
    $db->insert(tag_entry => {tag_id => 4, entry_id => 5, updated_at => 556});
    $db->insert(tag_entry => {tag_id => 5, entry_id => 6, updated_at => 557});
    is($db->retrieve('tag_entry', {tag_id => 3, entry_id => 4})->updated_at, '555');
    is($db->retrieve('tag_entry', {tag_id => 4, entry_id => 5})->updated_at, '556');
    is($db->retrieve('tag_entry', {tag_id => 5, entry_id => 6})->updated_at, '557');
};

done_testing;

