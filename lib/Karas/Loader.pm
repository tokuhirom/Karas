package Karas::Loader;
use strict;
use warnings;
use utf8;
use Carp ();
use Karas::Dumper;
use DBIx::Inspector;

sub load {
    my $class = shift;
    my %args = @_ == 1 ? %{$_[0]} : @_;
    my $dbh = $args{dbh} // Carp::croak "Missing mandatory parameter: dbh";
    my $namespace = $args{namespace} // Carp::croak "Missing mandatory parameter: namespace";
    my $name_map = $args{name_map} || +{};

    my $inspector = DBIx::Inspector->new(dbh => $dbh);
    require Karas::Row;
    my %class_map;
    for my $table ($inspector->tables) {
        no strict 'refs';
        my $klass = sprintf("%s::Row::%s", $namespace, $name_map->{$table->name} || String::CamelCase::camelize($table->name));
        $class_map{$table->name} = $klass;
        # setup inheritance
        unshift @{"${klass}::ISA"}, 'Karas::Row';
        # make accessors
        my @column_names = map { $_->name } $table->columns();
        $klass->mk_accessors(@column_names);
        # define 'table_name' method
        {
            my $table_name = $table->name;
            *{"${klass}::table_name"} = sub { $table_name };
        }
        # define 'primary_key' method
        {
            my @pk = map { $_->name } $table->primary_key();
            *{"${klass}::primary_key"} = sub { @pk };
        }
        # define 'column_names' method
        {
            *{"${klass}::column_names"} = sub { @column_names };
        }
    }
    return \%class_map;
}

1;

