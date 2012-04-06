use strict;
use Test::More;
use Gintou;

my $c = Gintou->new( repository => 'git://github.com/ytnobody/Upas.git' );

my @logs = $c->log( qw( -n 3 --skip 3 ) );
diag explain $c->show( $logs[0]->{commit} );

ok 1;

done_testing;
