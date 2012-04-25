use strict;
use Test::More;
use Gintou;
use t::Util;

my $c = Gintou->new( repository => 'git://github.com/ytnobody/Upas.git' );

my @logs = $c->log( qw( -n 3 --skip 3 ) );

is scalar @logs, 3;
for my $log ( @logs ) {
    ok key_exists( $log, qw/ author commit date message / );
}

done_testing;
