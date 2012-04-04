use strict;
use Test::More;
use Gintou;

my $c = Gintou->new( repository => 'git://github.com/ytnobody/Upas.git' );

diag explain $c->logs;

ok 1;

done_testing;
