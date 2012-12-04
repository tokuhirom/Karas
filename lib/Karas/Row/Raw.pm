package Karas::Row::Raw;
use strict;
use warnings;
use utf8;

sub new {
    my ($class, $vars) = @_;
    return $vars;
}

1;
__END__

=head1 NAME

Karas::Row::Raw - raw row class.

=head1 DESCRIPTION

This class is a dummy row class. This method does not create any object.
Just return hashref.

It makes less memory, fast speed.

