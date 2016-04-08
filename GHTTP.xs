#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#include "ghttp.h"

typedef struct {
    ghttp_request *ghttp;
    SV *set_body_sv;
} http_ghttp_class;

MODULE = HTTP::GHTTP         PACKAGE = HTTP::GHTTP

PROTOTYPES: DISABLE

http_ghttp_class *
_new(CLASS)
        char * CLASS
    PREINIT:
        http_ghttp_class *self;
    CODE:
        self = malloc( sizeof(http_ghttp_class) );
        if ( !self ) {
            warn("Unable to allocate http_ghttp_class");
            XSRETURN_UNDEF;
        }
        self->ghttp = ghttp_request_new();
        if ( !self->ghttp ) {
            warn("Unable to allocate ghttp_request");
            XSRETURN_UNDEF;
        }
        self->set_body_sv = NULL;
        RETVAL = self;
        /* sv_bless(RETVAL, gv_stash_pv(CLASS, 1)); */
    OUTPUT:
        RETVAL

void
DESTROY(self)
        http_ghttp_class *self
    CODE:
        ghttp_request_destroy(self->ghttp);
        if ( self->set_body_sv )
            SvREFCNT_dec( self->set_body_sv );
        free( self );

int
set_uri(self, uri)
        http_ghttp_class *self
        char *uri
    CODE:
        if(ghttp_set_uri(self->ghttp, uri) == ghttp_error) {
            XSRETURN_UNDEF;
        }
        RETVAL = 1;
    OUTPUT:
        RETVAL

int
set_proxy(self, proxy)
        http_ghttp_class *self
        char *proxy
    CODE:
        RETVAL = ghttp_set_proxy(self->ghttp, proxy);
    OUTPUT:
        RETVAL

void
set_header(self, hdr, val)
        http_ghttp_class *self
        const char *hdr
        const char *val
    CODE:
        ghttp_set_header(self->ghttp, hdr, val);

void
process_request(self)
        http_ghttp_class *self
    CODE:
        ghttp_prepare(self->ghttp);
        ghttp_process(self->ghttp);

void
clean(self)
       http_ghttp_class *self
    CODE:
       ghttp_clean(self->ghttp);

int
prepare(self)
        http_ghttp_class *self
    CODE:
        RETVAL = ghttp_prepare(self->ghttp);
    OUTPUT:
        RETVAL

int
process(self)
        http_ghttp_class *self
    PREINIT:
        ghttp_status process_status;
    CODE:
        process_status = ghttp_process(self->ghttp);
        if (process_status == ghttp_error) {
            XSRETURN_UNDEF;
        }
        RETVAL = !process_status;
    OUTPUT:
        RETVAL

const char*
get_header(self, hdr)
        http_ghttp_class *self
        const char *hdr
    CODE:
        RETVAL = ghttp_get_header(self->ghttp, hdr);
    OUTPUT:
        RETVAL

#ifdef HAVE_GHTTP_GET_HEADER_NAMES

void
get_headers(self)
        http_ghttp_class *self
    PREINIT:
        char **hdrs;
        int num_hdrs;
        int i;
    PPCODE:
        if (ghttp_get_header_names(self->ghttp, &hdrs, &num_hdrs) == -1) {
            XSRETURN_UNDEF;
        }

        EXTEND(SP, num_hdrs);

        for (i = 0; i < num_hdrs; i++) {
            PUSHs(sv_2mortal(newSVpv(hdrs[i], 0)));
            free(hdrs[i]);
        }

#endif

int
close(self)
        http_ghttp_class *self
    CODE:
        RETVAL = ghttp_close(self->ghttp);
    OUTPUT:
        RETVAL

SV *
get_body(self)
        http_ghttp_class *self
    PREINIT:
        SV* buffer;
    CODE:
        buffer = newSVpvn("",0);
        sv_catpvn(buffer, ghttp_get_body(self->ghttp), ghttp_get_body_len(self->ghttp));
        RETVAL = buffer;
    OUTPUT:
        RETVAL

const char *
get_error(self)
        http_ghttp_class *self
    CODE:
        RETVAL = ghttp_get_error(self->ghttp);
    OUTPUT:
        RETVAL

int
set_authinfo(self, user, pass)
        http_ghttp_class *self
        const char *user
        const char *pass
    CODE:
        RETVAL = ghttp_set_authinfo(self->ghttp, user, pass);
    OUTPUT:
        RETVAL

int
set_proxy_authinfo(self, user, pass)
        http_ghttp_class *self
        const char *user
        const char *pass
    CODE:
        RETVAL = ghttp_set_proxy_authinfo(self->ghttp, user, pass);
    OUTPUT:
        RETVAL

int
set_type(self, type)
        http_ghttp_class *self
        int type
    CODE:
        RETVAL = ghttp_set_type(self->ghttp, type);
    OUTPUT:
        RETVAL

int
set_body(self, body)
        http_ghttp_class *self
        SV *body
    PREINIT:
        STRLEN len;
        char * str;
    CODE:
        if ( self->set_body_sv )
            SvREFCNT_dec( self->set_body_sv );
        self->set_body_sv = body;
        SvREFCNT_inc( body );
        str = SvPV(body, len);
        RETVAL = ghttp_set_body(self->ghttp, str, len);
    OUTPUT:
        RETVAL

int
_get_socket(self)
        http_ghttp_class *self
    CODE:
        RETVAL = ghttp_get_socket(self->ghttp);
    OUTPUT:
        RETVAL

void
get_status(self)
        http_ghttp_class *self
    PREINIT:
        int code;
        const char *reason;
    PPCODE:
        code = ghttp_status_code(self->ghttp);
        reason = ghttp_reason_phrase(self->ghttp);
        EXTEND(SP, 2);
        PUSHs(sv_2mortal(newSViv(code)));
       if (reason == NULL)
               reason="NULL";
               PUSHs(sv_2mortal(newSVpv((char*)reason, 0)));

void
current_status(self)
        http_ghttp_class *self
    PREINIT:
        ghttp_current_status status;
    PPCODE:
        status = ghttp_get_status(self->ghttp);
        EXTEND(SP, 3);
        PUSHs(sv_2mortal(newSViv(status.proc)));
        PUSHs(sv_2mortal(newSViv(status.bytes_read)));
        PUSHs(sv_2mortal(newSViv(status.bytes_total)));

int
set_async(self)
        http_ghttp_class *self
    CODE:
        RETVAL = ghttp_set_sync(self->ghttp, ghttp_async);
    OUTPUT:
        RETVAL

void
set_chunksize(self, size)
        http_ghttp_class *self
        int size
    CODE:
        ghttp_set_chunksize(self->ghttp, size);

 #
 # CONSTANTS
 #

int
METHOD_GET()
    CODE:
        RETVAL = ghttp_type_get;
    OUTPUT:
        RETVAL

int
METHOD_OPTIONS()
    CODE:
        RETVAL = ghttp_type_options;
    OUTPUT:
        RETVAL

int
METHOD_HEAD()
    CODE:
        RETVAL = ghttp_type_head;
    OUTPUT:
        RETVAL

int
METHOD_POST()
    CODE:
        RETVAL = ghttp_type_post;
    OUTPUT:
        RETVAL

int
METHOD_PUT()
    CODE:
        RETVAL = ghttp_type_put;
    OUTPUT:
        RETVAL

int
METHOD_DELETE()
    CODE:
        RETVAL = ghttp_type_delete;
    OUTPUT:
        RETVAL

int
METHOD_TRACE()
    CODE:
        RETVAL = ghttp_type_trace;
    OUTPUT:
        RETVAL

int
METHOD_CONNECT()
    CODE:
        RETVAL = ghttp_type_connect;
    OUTPUT:
        RETVAL

int
METHOD_PROPFIND()
    CODE:
        RETVAL = ghttp_type_propfind;
    OUTPUT:
        RETVAL

int
METHOD_PROPPATCH()
    CODE:
        RETVAL = ghttp_type_proppatch;
    OUTPUT:
        RETVAL

int
METHOD_MKCOL()
    CODE:
        RETVAL = ghttp_type_mkcol;
    OUTPUT:
        RETVAL

int
METHOD_COPY()
    CODE:
        RETVAL = ghttp_type_copy;
    OUTPUT:
        RETVAL

int
METHOD_MOVE()
    CODE:
        RETVAL = ghttp_type_move;
    OUTPUT:
        RETVAL

int
METHOD_LOCK()
    CODE:
        RETVAL = ghttp_type_lock;
    OUTPUT:
        RETVAL

int
METHOD_UNLOCK()
    CODE:
        RETVAL = ghttp_type_unlock;
    OUTPUT:
        RETVAL
