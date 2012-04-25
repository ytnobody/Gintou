package t::Util;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT = qw/ key_exists /;

sub key_exists {
    my ( $hash, @keys ) = @_;
    my $result = 1;
    for my $key ( @keys ) {
        unless ( defined $hash->{$key} ) {
            $result = undef;
            last;
        }
    }
    return $result;
}

1;
