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
        @_,
    );
}

{
    package MultiPK;
    use parent qw/Karas::Row/;
    sub primary_key { qw/tag_id entry_id/ }
}

subtest 'run' => sub {
    my $db = create_karas();
    $db->dbh->do(q{CREATE TABLE member (id, name)});
    $db->insert(member => {id => 1, name => 'John'});
    $db->insert(member => {id => 2, name => 'Ben'});
    $db->insert(member => {id => 3, name => 'Dan'});
    is($db->retrieve('member' => 2)->name, 'Ben');
};

subtest 'multi pk' => sub {
    my $db = create_karas(default_row_class => 'MultiPK');
    $db->dbh->do(q{CREATE TABLE tag_entry (tag_id, entry_id, updated_at)});
    $db->insert(tag_entry => {tag_id => 3, entry_id => 4, updated_at => 555});
    $db->insert(tag_entry => {tag_id => 4, entry_id => 5, updated_at => 556});
    $db->insert(tag_entry => {tag_id => 5, entry_id => 6, updated_at => 557});
    is($db->retrieve('tag_entry', {tag_id => 3, entry_id => 4})->updated_at, '555');
    is($db->retrieve('tag_entry', {tag_id => 4, entry_id => 5})->updated_at, '556');
    is($db->retrieve('tag_entry', {tag_id => 5, entry_id => 6})->updated_at, '557');
};

done_testing;

