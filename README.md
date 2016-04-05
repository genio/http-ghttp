# NAME

HTTP::GHTTP - Perl interface to the gnome ghttp library

# SYNOPSIS

    use HTTP::GHTTP;

    my $r = HTTP::GHTTP->new();
    $r->set_uri("http://axkit.org/");
    $r->process_request;
    print $r->get_body;

# DESCRIPTION

This is a fairly low level interface to the Gnome project's libghttp,
which allows you to process HTTP requests to HTTP servers. There also
exists a slightly higher level interface - a simple get() function
which takes a URI as a parameter. This is not exported by default, you
have to ask for it explicitly.

# API

## HTTP::GHTTP->new(\[$uri, \[%headers\]\])

Constructor function - creates a new GHTTP object. If supplied a URI
it will automatically call set\_uri for you. If you also supply a list
of key/value pairs it will set those as headers:

    my $r = HTTP::GHTTP->new(
        "http://axkit.com/",
        Connection => "close");

## $r->set\_uri($uri)

This sets the URI for the request

## $r->set\_header($header, $value)

This sets an outgoing HTTP request header

## $r->set\_type($type)

This sets the request type. The request types themselves are constants
that are not exported by default. To export them, specify the :methods
option in the import list:

    use HTTP::GHTTP qw/:methods/;
    my $r = HTTP::GHTTP->new();
    $r->set_uri('http://axkit.com/');
    $r->set_type(METHOD_HEAD);
    ...

The available methods are:

    METHOD_GET
    METHOD_POST
    METHOD_OPTIONS
    METHOD_HEAD
    METHOD_PUT
    METHOD_DELETE
    METHOD_TRACE
    METHOD_CONNECT
    METHOD_PROPFIND
    METHOD_PROPPATCH
    METHOD_MKCOL
    METHOD_COPY
    METHOD_MOVE
    METHOD_LOCK
    METHOD_UNLOCK

Some of these are for DAV.

## $r->set\_body($body)

This sets the body of a request, useful in POST and some of the DAV
request types.

## $r->process\_request()

This sends the actual request to the server

## $r->get\_status()

This returns 2 values, a status code (numeric) and a status reason
phrase. A simple example of the return values would be (200, "OK").

## $r->get\_header($header)

This gets the value of an incoming HTTP response header

## $r->get\_headers()

Returns a list of all the response header names in the order they
came back. This method is only available in libghttp 1.08 and later -
perl Makefile.PL should have reported whether it found it or not.

    my @headers = $r->get_headers;
    print join("\n",
          map { "$_: " . $r->get_header($_) } @headers), "\n\n";

## $r->get\_body()

This gets the body of the response

## $r->get\_error()

If the response failed for some reason, this returns a textual error

## $r->set\_authinfo($user, $password)

This sets an outgoing username and password for simple HTTP
authentication

## $r->set\_proxy($proxy)

This sets your proxy server, use the form "http://proxy:port"

## $r->set\_proxy\_authinfo($user, $password)

If you have set a proxy and your proxy requires a username and password
you can set it with this.

## $r->prepare()

This is a low level interface useful only when doing async downloads.
See ["ASYNC OPERATION"](#async-operation).

## $r->process()

This is a low level interface useful only when doing async downloads.
See ["ASYNC OPERATION"](#async-operation).

process returns undef for error, 1 for "in progress", and zero for
"complete".

## $r->get\_socket()

Returns an IO::Handle object that is the currently in progress socket.
Useful only when doing async downloads. There appears to be some corruption
when using the socket to retrieve file contents on more recent libghttp's.

## $r->current\_status()

This is only useful in async mode. It returns 3 values: The current
processing stage (0 = none, 1 = request, 2 = response headers,
3 = response), the number of bytes read, and the number of bytes total.

## $r->set\_async()

This turns async mode on. There is no corresponding unset function.

## $r->set\_chunksize($bytes)

Sets the download (and upload) chunk size in bytes for use in async
mode. This may be a useful value to set for slow modems, or perhaps
for a download progress bar, or just to allow periodic writes.

## get($uri, \[%headers\])

This does everything automatically for you, retrieving the body at
the remote URI. Optionally pass in headers.

# ASYNC OPERATION

Its possible to use an asynchronous mode of operation with ghttp. Here's
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

Note also that $sock above is an IO::Handle, not an IO::Socket, although
you can probably get away with re-blessing it. Also note that by calling
$r->get\_socket() you load IO::Handle, which probably brings a lot of
code with it, thereby obliterating a lot of the use for libghttp. So
use at your own risk :-)

# AUTHOR

Matt Sergeant, <`matt@sergeant.org`>.

# CONTRIBUTORS

- Chase Whitener, <`capoeirab@cpan.org`>.

# COPYRIGHT AND LICENSE

Copyright (c) 2000 Matt Sergeant.  All rights reserved.

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
