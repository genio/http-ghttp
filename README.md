# NAME

HTTP::GHTTP - (DEPRECATED) Perl interface to the gnome ghttp library

# SYNOPSIS

    use strict;
    use warnings;
    use HTTP::GHTTP;

    my $r = HTTP::GHTTP->new();
    $r->set_uri("http://axkit.org/");
    $r->process_request;
    print $r->get_body;

# DESCRIPTION

The GNOME [libghttp](http://ftp.gnome.org/pub/gnome/sources/libghttp) project
has been dead since 2009.  This, this library is deprecated.

**Do not use this module!**

This is a fairly low level interface to [libghttp](http://ftp.gnome.org/pub/gnome/sources/libghttp),
which allows you to process HTTP requests to HTTP servers. There also
exists a slightly higher level interface - a simple get() function
which takes a URI as a parameter. This is not exported by default, you
have to ask for it explicitly.

# FUNCTIONS

The [HTTP::GHTTP](https://metacpan.org/pod/HTTP::GHTTP) module makes the following standalone functions available.

## get

    get($uri, [%headers])

This does everything automatically for you, retrieving the body at
the remote URI. Optionally pass in headers.

# METHODS

The [HTTP::GHTTP](https://metacpan.org/pod/HTTP::GHTTP) module makes the following methods available.

## new

    my $r = HTTP::GHTTP->new("http://axkit.com/", Connection => "close");

Constructor function - creates a new GHTTP object. If supplied a URI
it will automatically call set\_uri for you. If you also supply a list
of key/value pairs it will set those as headers:

## current\_status

    $r->current_status()

This is only useful in async mode. It returns 3 values: The current
processing stage (0 = none, 1 = request, 2 = response headers,
3 = response), the number of bytes read, and the number of bytes total.

## get\_body

    my $rresponse = $r->get_body();

This gets the body of the response

## get\_error

    my $error = $r->get_error();

If the response failed for some reason, this returns a textual error.

## get\_header

    my $value = $r->get_header($header);

This gets the value of an incoming HTTP response header.

## get\_headers

    my @headers = $r->get_headers;
    print join("\n",
      map { "$_: " . $r->get_header($_) } @headers), "\n\n";

Returns a list of all the response header names in the order they
came back. This method is only available in [libghttp](http://ftp.gnome.org/pub/gnome/sources/libghttp) 1.08 and later -
`perl Makefile.PL` should have reported whether it found it or not.

## get\_socket

    my $sock_h = $r->get_socket();

Returns an [IO::Handle](https://metacpan.org/pod/IO::Handle) object that is the currently in progress socket.
Useful only when doing async downloads. There appears to be some corruption
when using the socket to retrieve file contents on more recent [libghttp](http://ftp.gnome.org/pub/gnome/sources/libghttp).

## get\_status

    $r->get_status()

This returns 2 values, a status code (numeric) and a status reason
phrase. A simple example of the return values would be (200, "OK").

## prepare

    $r->prepare()

This is a low level interface useful only when doing async downloads.
See ["ASYNC OPERATION"](#async-operation).

## process

    $r->process()

This is a low level interface useful only when doing async downloads.
See ["ASYNC OPERATION"](#async-operation).

process returns `undef` for error, 1 for "in progress", and zero for
"complete".

## process\_request

    $r->process_request()

This sends the actual request to the server

## set\_async

    $r->set_async()

This turns async mode on. There is no corresponding unset function.

## set\_authinfo

    $r->set_authinfo($user, $password)

This sets an outgoing username and password for simple HTTP
authentication.

## set\_body

    $r->set_body($body);

This sets the body of a request, useful in `POST` and some of the DAV
request types.

## set\_chunksize

    $r->set_chunksize($bytes)

Sets the download (and upload) chunk size in bytes for use in async
mode. This may be a useful value to set for slow modems, or perhaps
for a download progress bar, or just to allow periodic writes.

## set\_header

    $r->set_header($header_name, $header_value);
    $r->set_header('Connection', 'Close');

This sets an outgoing HTTP request header.

## set\_proxy

    $r->set_proxy("http://proxy:port")

This sets your proxy server.

## set\_proxy\_authinfo

    $r->set_proxy_authinfo($user, $password)

If you have set a proxy and your proxy requires a username and password
you can set it with this.

## set\_type

    use HTTP::GHTTP qw/:methods/;
    my $r = HTTP::GHTTP->new();
    $r->set_uri('http://axkit.com/');
    $r->set_type(METHOD_HEAD);

This sets the request type. The request types themselves are constants
that are not exported by default. To export them, specify the `:methods`
option in the import list:

The available methods are:

- METHOD\_GET
- METHOD\_POST
- METHOD\_OPTIONS
- METHOD\_HEAD
- METHOD\_PUT
- METHOD\_DELETE
- METHOD\_TRACE
- METHOD\_CONNECT
- METHOD\_PROPFIND
- METHOD\_PROPPATCH
- METHOD\_MKCOL
- METHOD\_COPY
- METHOD\_MOVE
- METHOD\_LOCK
- METHOD\_UNLOCK

## set\_uri

    my $boolean = $r->set_uri($some_URI_string);

This sets the URI for the request.  It returns true if the URI was
properly set and undef otherwise.

# ASYNC OPERATION

It's possible to use an asynchronous mode of operation with [HTTP::GHTTP](https://metacpan.org/pod/HTTP::GHTTP). Here's
a brief example of how:

    my $r = HTTP::GHTTP->new("http://axkit.org/");
    $r->set_async;
    $r->set_chunksize(1);
    $r->prepare;

    my $status;
    while ($status = $r->process) {
        # do something
        # you can do $r->get_body in here if you want to
        # but it always returns the entire body.
    }

    die "An error occured" unless defined $status;

    print $r->get_body;

Doing timeouts is an exercise for the reader (hint: lookup select() in
perlfunc).

Note also that $sock above is an [IO::Handle](https://metacpan.org/pod/IO::Handle), not an [IO::Socket](https://metacpan.org/pod/IO::Socket), although
you can probably get away with re-blessing it. Also note that by calling
`$r-`get\_socket()> you load [IO::Handle](https://metacpan.org/pod/IO::Handle), which probably brings a lot of
code with it, thereby obliterating a lot of the use for [libghttp](http://ftp.gnome.org/pub/gnome/sources/libghttp). So
use at your own risk :-)

# AUTHOR

Matt Sergeant, <`matt@sergeant.org`>.

# CONTRIBUTORS

- Chase Whitener, <`capoeirab@cpan.org`>.

# COPYRIGHT AND LICENSE

Copyright (c) 2000 Matt Sergeant.  All rights reserved.

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
