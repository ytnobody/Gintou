use strict;
use Test::More;
use Gintou;
use t::Util;

my $c = Gintou->new( repository => 'git://github.com/ytnobody/Upas.git' );

my @logs = $c->log( qw( -n 3 --skip 3 ) );
my $show = $c->show( $logs[0]->{commit} );

ok key_exists( $show, qw/ author commit differ date message / );
isa_ok $show->{differ}, 'ARRAY';

for my $diff ( @{$show->{differ}} ) {
    ok key_exists( $diff, qw/ code file / );
}

done_testing;
