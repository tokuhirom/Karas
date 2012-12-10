package Karas::Row;
use strict;
use warnings;
use utf8;
use Carp ();
use String::CamelCase ();

sub new {
    my ($class, $table_name, $values) = @_;
    bless {
        __private_table_name   => $table_name,
        __private_dirty_column => +{},
        %$values,
    }, $class;
}

# Abstract methods.
sub table_name   { Carp::croak("Abstract method"); }
sub primary_key  { Carp::croak("Abstract method"); }
sub column_names { Carp::croak("Abstract method"); }
sub has_column   {
    my ($self, $column) = @_;
    return (grep { $_ eq $column } $self->column_names) > 0;
}

sub get_dirty_columns { $_[0]->{__private_dirty_column} }

sub mk_accessors {
    my ($class, @cols) = @_;
    $class = ref $class if ref $class;
    for my $col (@cols) {
        Carp::croak("Column is undefined") unless defined $col;
        Carp::croak("Invalid column name: $col") if $col =~ /^__private/;
        no strict 'refs';
        *{"${class}::${col}"} = sub {
            if (@_==1) {
                # my ($self) = @_;
                Carp::croak("You don't selected $col in SQL.") unless exists $_[0]->{$col};
                return $_[0]->{$col};
            } elsif (@_==2) {
                # my ($self, $val) = @_;
                Carp::croak("You can't set non scalar value as column data: $col") if ref $_[1];
                $_[0]->{$col} = ($_[0]->{__private_dirty_column}->{$col} = $_[1]);
            } else {
                Carp::croak("Too many arguments for ${class}::${col}");
            }
        };
    }
}

sub make_where_condition {
    my $self = shift;
    my %cond;
    for my $key ($self->primary_key) {
        $cond{$key} = $self->get_column($key);
    }
    return \%cond;
}

sub get_column {
    my ($self, $col) = @_;
    Carp::croak("Usage: Karas::Row#get_column(\$col)") unless @_==2;
    Carp::croak("Column is undefined") unless defined $col;
    Carp::croak("You don't selected $col") unless exists $self->{$col};
    Carp::croak("Invalid column name: $col") if $col =~ /^__private/;
    return $self->{$col};
}

sub set_column {
    my ($self, $col, $val) = @_;
    Carp::croak("Usage: Karas::Row#set_column(\$col, \$val)") unless @_==3;
    $_[0]->{__private_dirty_column}->{$_[1]} = $_[2];
}

our $AUTOLOAD;
sub AUTOLOAD {
    my $class = shift;
    my $meth = $AUTOLOAD;
    $meth =~ s/.*:://;
    $class->mk_accessors($meth);
    $class->$meth(@_);
}

# hide from AUTOLOAD
sub DESTROY { }

1;
__END__

=head1 NAME

Karas::Row - row class for Karas

=head1 DESCRIPTION

Row class for Karas

=head1 METHODS

=over 4

=item my @pk = $row->primary_key()

This method returns list of strings. It's primary keys.

Default method returns 'id'. You can override this method to use another primary key.

=item my $table_name = $row->table_name()

Returns table name. It's set at constructor.

=item my $val = $row->get_column($column_name)

Get a column value from row object. This method throws exception if column is not selected by SQL.

=item AUTOLOAD

This class provides AUTOLOAD method to generate accessor automatically.

Accessor returns a column value.

=back
