use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    license              => 'perl',
    dynamic_config       => 0,

    build_requires       => {
        'Test::More' => '0.98',
        'Test::Requires' => 0,
    },
    configure_requires   => { 'Module::Build' => '0.38' },
    requires             => {
        perl => '5.010001',
        'Class::Accessor::Lite' => 0.05,
        'Module::Find' => 0,
        'Module::Load' => 0,
        'String::CamelCase' => 0,
        'Scalar::Util' => 0,
        'Class::Trigger' => 0,
        'DBIx::TransactionManager' => 0,
        'DBI' => '1.6.14',
        'parent'                        => '0',
        'SQL::Maker' => 0,
        'Data::Page::NoTotalEntries' => 0,
        'DBIx::Handler' => 0,
        'DBIx::Inspector' => 0,
    },

    no_index    => { 'directory' => [ 'inc' ] },
    name        => 'Karas',
    module_name => 'Karas',

    # script_files => [''],

    test_files => (-d '.git' || $ENV{RELEASE_TESTING}) ? 't/ xt/' : 't/',
    recursive_test_files => 1,
   
    create_readme  => 1,
    create_license => 1,
);
$build->create_build_script();
