use strict;
use warnings;

use Test::More;

BEGIN { use_ok('HTTP::GHTTP') or BAIL_OUT("Can't use module"); }

can_ok(
    'HTTP::GHTTP',
    qw(_get_socket clean new get get_socket set_uri set_proxy set_header),
    qw(process_request prepare process get_header),
    qw(close get_body get_error set_authinfo set_proxy_authinfo),
    qw(set_type set_body get_status current_status set_async set_chunksize),
    qw(METHOD_GET METHOD_OPTIONS METHOD_HEAD METHOD_POST METHOD_PUT),
    qw(METHOD_DELETE METHOD_TRACE METHOD_CONNECT METHOD_PROPFIND),
    qw(METHOD_PROPPATCH METHOD_MKCOL METHOD_COPY METHOD_MOVE METHOD_LOCK),
    qw(METHOD_UNLOCK),
);

done_testing();
