use strict;
use warnings;

use HTTP::GHTTP;
use Test::More;

my $r = HTTP::GHTTP->new();
isa_ok($r, 'HTTP::GHTTP', 'new object instance');
ok($r->set_uri("http://axkit.org/"), 'set_uri: truthy response');

done_testing();
