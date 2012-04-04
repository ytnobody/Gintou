use inc::Module::Install;
name 'Gintou';
all_from 'lib/Gintou.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
