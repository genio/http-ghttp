package HTTP::GHTTP;

use strict;
use warnings;
use XSLoader ();
use base qw(Exporter);

our $VERSION = '1.080_003';
our $XS_VERSION = $VERSION;
$VERSION = eval $VERSION;

XSLoader::load('HTTP::GHTTP', $XS_VERSION);

our @EXPORT_OK = qw(
    get
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
);

our %EXPORT_TAGS = (
    methods => [
        qw(
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
            )
    ],
);

sub new {
    my $class = shift;
    my $r     = $class->_new();
    bless $r, $class;
    if (@_) {
        my $uri = shift;
        die "Blank uri not supported" unless length($uri);
        $r->set_uri($uri);
        while (@_) {
            my ($header, $value) = splice(@_, 0, 2);
            $r->set_header($header, $value);
        }
    }
    return $r;
}

sub get {
    die "get() requires a URI as a parameter" unless @_;
    my $r = __PACKAGE__->new(@_);
    $r->process_request;
    return $r->get_body();
}

sub get_socket {
    my $self = shift;
    require IO::Handle;
    my $sockno = $self->_get_socket();
    my $sock = IO::Handle->new_from_fd($sockno, "r")
        || die "Cannot open socket: $!";
    return $sock;
}

1;
__END__

=head1 NAME

HTTP::GHTTP - (DEPRECATED) Perl interface to the gnome ghttp library

=head1 SYNOPSIS

  use strict;
  use warnings;
  use HTTP::GHTTP;

  my $r = HTTP::GHTTP->new();
  $r->set_uri("http://axkit.org/");
  $r->process_request;
  print $r->get_body;

=head1 DESCRIPTION

The GNOME L<libghttp|http://ftp.gnome.org/pub/gnome/sources/libghttp> project
has been dead since 2002.  Thus, this library is deprecated.

B<Do not use this module!>

This is a fairly low level interface to L<libghttp|http://ftp.gnome.org/pub/gnome/sources/libghttp>,
which allows you to process HTTP requests to HTTP servers. There also
exists a slightly higher level interface - a simple get() function
which takes a URI as a parameter. This is not exported by default, you
have to ask for it explicitly.

=head1 FUNCTIONS

The L<HTTP::GHTTP> module makes the following standalone functions available.

=head2 get

  get($uri, [%headers])

This does everything automatically for you, retrieving the body at
the remote URI. Optionally pass in headers.

=head1 METHODS

The L<HTTP::GHTTP> module makes the following methods available.

=head2 new

  my $r = HTTP::GHTTP->new("http://axkit.com/", Connection => "close");

Constructor function - creates a new GHTTP object. If supplied a URI
it will automatically call set_uri for you. If you also supply a list
of key/value pairs it will set those as headers:

=head2 current_status

  $r->current_status()

This is only useful in async mode. It returns 3 values: The current
processing stage (0 = none, 1 = request, 2 = response headers,
3 = response), the number of bytes read, and the number of bytes total.

=head2 get_body

  my $rresponse = $r->get_body();

This gets the body of the response

=head2 get_error

  my $error = $r->get_error();

If the response failed for some reason, this returns a textual error.

=head2 get_header

  my $value = $r->get_header($header);

This gets the value of an incoming HTTP response header.

=head2 get_headers

  my @headers = $r->get_headers;
  print join("\n",
    map { "$_: " . $r->get_header($_) } @headers), "\n\n";

Returns a list of all the response header names in the order they
came back. This method is only available in L<libghttp|http://ftp.gnome.org/pub/gnome/sources/libghttp> 1.08 and later -
C<perl Makefile.PL> should have reported whether it found it or not.

=head2 get_socket

  my $sock_h = $r->get_socket();

Returns an L<IO::Handle> object that is the currently in progress socket.
Useful only when doing async downloads. There appears to be some corruption
when using the socket to retrieve file contents on more recent L<libghttp|http://ftp.gnome.org/pub/gnome/sources/libghttp>.

=head2 get_status

  $r->get_status()

This returns 2 values, a status code (numeric) and a status reason
phrase. A simple example of the return values would be (200, "OK").

=head2 prepare

  $r->prepare()

This is a low level interface useful only when doing async downloads.
See L<ASYNC OPERATION>.

=head2 process

  $r->process()

This is a low level interface useful only when doing async downloads.
See L<ASYNC OPERATION>.

process returns C<undef> for error, 1 for "in progress", and zero for
"complete".

=head2 process_request

  $r->process_request()

This sends the actual request to the server

=head2 set_async

  $r->set_async()

This turns async mode on. There is no corresponding unset function.

=head2 set_authinfo

  $r->set_authinfo($user, $password)

This sets an outgoing username and password for simple HTTP
authentication.

=head2 set_body

  $r->set_body($body);

This sets the body of a request, useful in C<POST> and some of the DAV
request types.

=head2 set_chunksize

  $r->set_chunksize($bytes)

Sets the download (and upload) chunk size in bytes for use in async
mode. This may be a useful value to set for slow modems, or perhaps
for a download progress bar, or just to allow periodic writes.

=head2 set_header

  $r->set_header($header_name, $header_value);
  $r->set_header('Connection', 'Close');

This sets an outgoing HTTP request header.

=head2 set_proxy

  $r->set_proxy("http://proxy:port")

This sets your proxy server.

=head2 set_proxy_authinfo

  $r->set_proxy_authinfo($user, $password)

If you have set a proxy and your proxy requires a username and password
you can set it with this.

=head2 set_type

  use HTTP::GHTTP qw/:methods/;
  my $r = HTTP::GHTTP->new();
  $r->set_uri('http://axkit.com/');
  $r->set_type(METHOD_HEAD);

This sets the request type. The request types themselves are constants
that are not exported by default. To export them, specify the C<:methods>
option in the import list:


The available methods are:

=over

=item *

METHOD_GET

=item *

METHOD_POST

=item *

METHOD_OPTIONS

=item *

METHOD_HEAD

=item *

METHOD_PUT

=item *

METHOD_DELETE

=item *

METHOD_TRACE

=item *

METHOD_CONNECT

=item *

METHOD_PROPFIND

=item *

METHOD_PROPPATCH

=item *

METHOD_MKCOL

=item *

METHOD_COPY

=item *

METHOD_MOVE

=item *

METHOD_LOCK

=item *

METHOD_UNLOCK

=back

=head2 set_uri

  my $boolean = $r->set_uri($some_URI_string);

This sets the URI for the request.  It returns true if the URI was
properly set and undef otherwise.

=head1 ASYNC OPERATION

It's possible to use an asynchronous mode of operation with L<HTTP::GHTTP>. Here's
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

Note also that $sock above is an L<IO::Handle>, not an L<IO::Socket>, although
you can probably get away with re-blessing it. Also note that by calling
C<< $r->get_socket() >> you load L<IO::Handle>, which probably brings a lot of
code with it, thereby obliterating a lot of the use for L<libghttp|http://ftp.gnome.org/pub/gnome/sources/libghttp>. So
use at your own risk :-)

=head1 AUTHOR

Matt Sergeant, <F<matt@sergeant.org>>.

=head1 CONTRIBUTORS

=over

=item *

Chase Whitener, <F<capoeirab@cpan.org>>.

=back

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2000 Matt Sergeant.  All rights reserved.

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
