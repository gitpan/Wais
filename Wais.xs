/*                               -*- Mode: C -*- 
 * Wais.xs -- 
 * ITIID           : $ITI$ $Header $__Header$
 * Author          : Ulrich Pfeifer
 * Created On      : Mon Aug  8 16:09:45 1994
 * Last Modified By: Ulrich Pfeifer
 * Last Modified On: Tue Jul 16 16:12:36 1996
 * Language        : C
 * Update Count    : 382
 * Status          : Unknown, Use with caution!
 * 
 * (C) Copyright 1995, Universität Dortmund, all rights reserved.
 * 
 * $Locker: pfeifer $
 * $Log: Wais.xs,v $
 * Revision 2.1.1.9  1996/07/16 16:38:15  pfeifer
 * patch10: Modified for building from installed freeWAIS-sf libraries
 * patch10: and include files.
 * patch10: Added support for stemming/sunodex/phonix.
 *
 * Revision 2.1.1.8  1996/04/30 07:40:51  pfeifer
 * patch9: Moved defined clash fixes to dictionary.h.
 * patch9: This is not too clean - but dictionary.h is included
 * patch9: in all C-Files.
 *
 * Revision 2.1.1.7  1996/04/09 13:06:39  pfeifer
 * patch8: Avoid some redifinition warnings.
 *
 * Revision 2.1.1.6  1996/04/09 06:55:36  pfeifer
 * patch7: Fixes by malyshki@cs.wmich.edu (Vladislav Malyshkin).
 *
 * Revision 2.1.1.5  1996/03/07 10:55:23  pfeifer
 * patch7: Made Wais::Search::diagnostics ignore
 * patch7: D_PresentRequestOutOfRange complaints.
 *
 * Revision 2.1.1.4  1996/02/27 18:42:41  pfeifer
 * patch5: Added some tabs for old xsubpp's.
 *
 * Revision 2.1.1.3  1996/02/23 15:45:38  pfeifer
 * patch4: Rewrote Wais::Docid::new. Added Wais::Docid::split.
 *
 * Revision 2.1.1.2  1996/02/05 12:42:35  pfeifer
 * patch2: Fixed some parameter declarations which confused older xsupps.
 *
 * Revision 2.1.1.1  1995/12/28 16:30:29  pfeifer
 * patch1: Support for docids.  Support for init messages. Renamed
 * patch1: database to database_name since some compilers are worried
 * patch1: about types a variables having the same name.
 *
 * Revision 2.1  1995/12/13  14:52:34  pfeifer
 * *** empty log message ***
 *
 * Revision 2.0.1.14  1995/12/13  08:41:07  pfeifer
 * patch14: Added CHARS_PER_PAGE.
 *
 * Revision 2.0.1.13  1995/12/12  11:46:25  pfeifer
 * patch13: Parallel search works.
 *
 */

#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

#include "Wais.h"
#include "dictionary.h"
#include "HTWAIS.h"
extern char *grundform _AP((char * word));
extern char *stemmer   _AP((char * word));
#ifdef VERSION
#undef VERSION
#endif
#include "patchlevel.h"
#define MAX_MESSAGE_LEN 100000
#define CHARS_PER_PAGE 4096	/* number of chars retrieved in each request */
int             WAISmaxdoc = 40;
static int      Wais_inited = 0;
static STRLEN  p_stl;

void
init_Wais()
{
  /* This is a hack to allow for embedding in freeWAIS-sf */
#ifdef DIRNAMELEN               /* freeWAIS-sf >= 2.1.1 */
  int my_perl_inited;
#else
  extern int my_perl_inited;
#endif
  char            buf[80];
  SV             *version = perl_get_sv("Wais::VERSION", TRUE);
  SV             *recsep  = perl_get_sv("Wais::recsep", TRUE);
  SV             *fldsep  = perl_get_sv("Wais::fldsep", TRUE);
  SV             *maxdoc  = perl_get_sv("Wais::maxdoc", TRUE);
  SV             *cpp     = perl_get_sv("Wais::CHARS_PER_PAGE", TRUE);

#ifdef XS_VERSION
  sv_setpv(version, XS_VERSION);
#else
  sprintf(buf, "Wais %5.3f", VERSION + PATCHLEVEL/1000); 
  sv_setpv(version, buf);
#endif
  sv_setpvn(recsep, "\000", 1);
  sv_setpvn(fldsep, "\001", 1);
  sv_setiv(maxdoc, WAISmaxdoc);
  sv_setiv(cpp, CHARS_PER_PAGE);
  Wais_inited = 1;
  my_perl_inited = 1;           /* do not start new interpreter for stemming */
}
                
MODULE = Wais PACKAGE = Wais
BOOT:
init_Wais();

int
maxdoc(num=0)
	int	num
CODE:   
{
  SV             *maxdoc = perl_get_sv("Wais::maxdoc", FALSE);

  if (num)
    sv_setiv(maxdoc, (IV) num);
  ST(0) = sv_mortalcopy(maxdoc);
}


char *
recsep(sep=NULL)
	char *	sep
CODE:   
{
  SV             *recsep = perl_get_sv("Wais::recsep", FALSE);

  if (sep)
    sv_setsv(recsep, ST(0));

  ST(0) = sv_mortalcopy(recsep);
}

char *
fldsep(sep=NULL)
	char *	sep
CODE:   
{
  SV             *fldsep = perl_get_sv("Wais::fldsep", FALSE);

  if (sep)
    sv_setsv(fldsep, ST(0));
  ST(0) = sv_mortalcopy(fldsep);
}

void
search(database_name, keywords, host=NULL,port=210)
	char *	host
	int	port
	char *	database_name
	char *	keywords
PPCODE:
{
  SV             *headl = newSV(1000);
  SV             *diag = newSV(100);
  SV             *text = newSV(0);
  int             retval;

  sv_setpv(headl, "");
  sv_setpv(diag, "");
  sv_setpv(text, "");
  retval = WAISsearch(host, port, database_name, keywords,
		      diag, headl, text);
  EXTEND(sp, 3);
  PUSHs(sv_2mortal(headl));
  PUSHs(sv_2mortal(diag));
  PUSHs(sv_2mortal(text));
}

void
retrieve(database_name, docid, host=NULL,port=210)
	char *	host
	int	port
	char *	database_name
	char *	docid
PPCODE:
{
  SV             *headl = newSV(1000);
  SV             *diag = newSV(100);
  SV             *text = newSV(0);
  int             retval;

  sv_setpv(headl, "");
  sv_setpv(diag, "");
  sv_setpv(text, "");
  retval = WAISretrieve(host, port, database_name, docid,
			diag, headl, text);

  EXTEND(sp, 3);
  PUSHs(sv_2mortal(text));
  PUSHs(sv_2mortal(headl));
  PUSHs(sv_2mortal(diag));
}

void
dictionary(database_name, ...)
	char *	database_name
PPCODE:
{
  char           *field = NULL;
  char           *word = NULL;
  long            matches = 0;
  long            offset = 0;

  if (items == 1) {
    /* NOP */
  } else if (items == 2) {
    word = (char *) SvPV(ST(1), na);
    if (word[strlen(word) - 1] != '*') {
      field = word;
      word = NULL;
    }
  } else if (items == 3) {
    field = (char *) SvPV(ST(1), na);
    word = (char *) SvPV(ST(2), na);
  } else {
    EXTEND(sp, 1);
    PUSHs(&sv_undef);
    PUTBACK;
    return;
  }
  stack_sp -= items;		/* find_partialword modifies stack :-( */
  if (!find_word(database_name, field, word, offset, &matches)) {
    EXTEND(sp, 1);
    PUSHs(&sv_undef);
  } else if (!(GIMME == G_ARRAY)) {
    EXTEND(sp, 1);
    PUSHs(sv_2mortal(newSViv(matches)));
    if (TRACE)
      fprintf(stderr, "matches: %d\n", matches);
  } else {
    sp = stack_sp;
  }
}

void
list_offset(database_name, ...)
	char *	database_name
PPCODE:
{
  char           *field = NULL;
  char           *word = NULL;
  long            matches = 0;
  long            offset = 1;

  if (items == 1) {
    /* NOP */
  } else if (items == 2) {
    word = (char *) SvPV(ST(1), na);
    if (word[strlen(word) - 1] != '*') {
      field = word;
      word = NULL;
    }
  } else if (items == 3) {
    field = (char *) SvPV(ST(1), na);
    word = (char *) SvPV(ST(2), na);
  } else {
    EXTEND(sp, 1);
    PUSHs(&sv_undef);
    PUTBACK;
    return;
  }
  stack_sp -= items;		/* find_partialword modifies stack :-( */
  if (!find_word(database_name, field, word, offset, &matches)) {
    EXTEND(sp, 1);
    PUSHs(&sv_undef);
  } else if (!(GIMME == G_ARRAY)) {
    EXTEND(sp, 1);
    PUSHs(sv_2mortal(newSViv(matches)));
    if (TRACE)
      fprintf(stderr, "matches: %d\n", matches);
  } else {
    sp = stack_sp;
  }
}

void
postings(database_name, ...)
	char *	database_name
PPCODE:
{
  char           *field = NULL;
  char           *word = NULL;
  long            number_of_postings = 0;

  if (items == 2) {
    word = (char *) SvPV(ST(1), na);
  } else if (items == 3) {
    field = (char *) SvPV(ST(1), na);
    word = (char *) SvPV(ST(2), na);
  } else {
    EXTEND(sp, 1);
    PUSHs(&sv_undef);
    PUTBACK;
    return;
  }
  stack_sp -= items;		/* postings() modifies stack :-( */
  if (!postings(database_name, field, word, &number_of_postings)) {
    EXTEND(sp, 1);
    PUSHs(&sv_undef);
  } else if (!(GIMME == G_ARRAY)) {
    EXTEND(sp, 1);
    PUSHs(sv_2mortal(newSViv(number_of_postings)));
    if (TRACE)
      fprintf(stderr, "number_of_postings: %d\n", number_of_postings);
  } else {
    sp = stack_sp;
  }
}

char *
headline(database_name, docid)
	char *	database_name
	long	docid

char *
document(database_name,docid)
	char *	database_name
	long	docid
CODE:
{
  RETVAL = document(database_name, docid);
  ST(0) = sv_newmortal();
  sv_setpv((SV *) ST(0), RETVAL);
  s_free(RETVAL);
}

char *
generate_init_apdu()
CODE:
{
  long            request_buffer_length = MAX_MESSAGE_LEN;
  char           *request_message =
  (char *) s_malloc((size_t) MAX_MESSAGE_LEN * sizeof(char));
  InitAPDU       *init = NULL;
  long            result;
  char           *userInfo = "perl";
  init = makeInitAPDU(true, false, false, false, false, request_buffer_length, 
                      request_buffer_length, userInfo, 
                      defaultImplementationID(),
		      defaultImplementationName(),
		      defaultImplementationVersion(), NULL, userInfo);

  /* write it to the buffer */
  result = writeInitAPDU(init, request_message + HEADER_LENGTH,
			 &request_buffer_length) - request_message;

  ST(0) = sv_newmortal();
  if (result < 0) {
    SV             *error = perl_get_sv("Wais::errmsg", TRUE);

    sv_setpv(error, "Could not generate request_message");
  } else {
    writeWAISPacketHeader(request_message,
			  MAX_MESSAGE_LEN - request_buffer_length,
			  (long) 'z',	/* Z39.50 */
			  "wais      ",		/* server name */
			  (long) NO_COMPRESSION,	/* no compression */
			  (long) NO_ENCODING, (long) HEADER_VERSION);
    sv_setpvn(ST(0), request_message, HEADER_LENGTH +
	      MAX_MESSAGE_LEN - request_buffer_length);
  }
  freeInitAPDU(init);
}

char *
generate_search_apdu(keywords, database_name, ...)
	char *	keywords
	char *	database_name
CODE:
{
  long            maxDocsRetrieved = SvIV(perl_get_sv("Wais::maxdoc", FALSE));
  long            request_buffer_length = MAX_MESSAGE_LEN;
  char           *request_message =
  (char *) s_malloc((size_t) MAX_MESSAGE_LEN * sizeof(char));
  DocObj        **docobjs = NULL;
  long            i;

  if (items > 3)
    croak("Usage: Wais::generate_search_apdu(words,database_name, ...)");
  if (items == 3) {
    if (SvROK(ST(2)) && (SvTYPE(SvRV(ST(2))) == SVt_PVAV)) {
      AV             *darr = (AV *) SvRV(ST(2));
      long            length = (av_len(darr) + 1) / 2;

      docobjs = (DocObj **)
	malloc((length + 1) * sizeof(DocObj *));
      if (docobjs == NULL)
	croak("Out of memory");
      for (i = 0; i < length; i++) {
	any             docid;
	char           *itype;

	SV            **this = av_fetch(darr, 2 * i, 0);
	SV            **type = av_fetch(darr, 2 * i + 1, 0);

	itype = SvPV(*type, na);
	if (sv_isa(*this, "Wais::Docid")) {
	  docid.bytes = SvPV(SvRV(*this), p_stl);
          docid.size=p_stl;
	} else {
	  croak("Wais::generate_search_apdu: Invalid docid in request");
	}
	docobjs[i] = makeDocObjUsingWholeDocument(&docid, itype);
      }
      docobjs[length] = NULL;
    } else {
      croak("docobjs is no array reference");
    }
  }
  if (!request_message)
    croak("Out of memory");
  ST(0) = sv_newmortal();
  /* reserve room for the header so that we will not have to reallocate in 
     interprete_message */
  RETVAL = generate_search_apdu(request_message + HEADER_LENGTH,
				&request_buffer_length,
				keywords, database_name, docobjs,
				maxDocsRetrieved);
  if (TRACE)
    fprintf(stderr, "generate_search_apdu-> %ld\n",
	    HEADER_LENGTH + MAX_MESSAGE_LEN - request_buffer_length);
  if (RETVAL != NULL) {
    writeWAISPacketHeader(request_message,
			  MAX_MESSAGE_LEN - request_buffer_length,
			  (long) 'z',	/* Z39.50 */
			  "wais      ",		/* server name */
			  (long) NO_COMPRESSION,	/* no compression */
			  (long) NO_ENCODING, (long) HEADER_VERSION);
    sv_setpvn(ST(0), request_message, HEADER_LENGTH +
	      MAX_MESSAGE_LEN - request_buffer_length);
  } else {
    SV             *error = perl_get_sv("Wais::errmsg", TRUE);

    sv_setpv(error, "Could not generate request_message");
  }
  if (docobjs) {
    i = 0;
    while (docobjs[i]) {
      free(docobjs[i]);
      i++;
    }
    free(docobjs);
  }
  if (request_message)
    free(request_message);
}


char *
generate_retrieval_apdu(database_name, docid, type, ...)
	char *	database_name
	char *	docid
	char *	type
CODE:
{
  long            request_buffer_length = MAX_MESSAGE_LEN;
  char           *request_message =
  (char *) s_malloc((size_t) MAX_MESSAGE_LEN * sizeof(char));
  long            i;
  long            chunk = 0;
  any             docid;
  SV             *cpp = perl_get_sv("Wais::CHARS_PER_PAGE", TRUE);

  if (sv_isa(ST(1), "Wais::Docid")) {
    docid.bytes = SvPV(SvRV(ST(1)), p_stl);
    docid.size=p_stl;
  } else {
    croak("Wais::generate_retrieval_apdu: Invalid docid in request");
  }
  if (!request_message)
    croak("Out of memory");
  if (items == 4) {
    chunk = SvIV(ST(3));
  }
  if (items > 4) {
    croak("Usage: Wais::generate_retrieval_apdu(database_name, docid, type, [chunk])");
  }
  ST(0) = sv_newmortal();

  RETVAL = generate_retrieval_apdu(request_message + HEADER_LENGTH,
				   &request_buffer_length,
				   &docid,
				   CT_byte,
				   chunk * SvIV(cpp),
				   (chunk + 1) * SvIV(cpp),
				   type,
				   database_name);

  if (TRACE)
    fprintf(stderr, "generate_retrieval_apdu-> %ld\n",
	    HEADER_LENGTH + MAX_MESSAGE_LEN - request_buffer_length);
  if (RETVAL != NULL) {
    writeWAISPacketHeader(request_message,
			  MAX_MESSAGE_LEN - request_buffer_length,
			  (long) 'z',	/* Z39.50 */
			  "wais      ",		/* server name */
			  (long) NO_COMPRESSION,	/* no compression */
			  (long) NO_ENCODING, (long) HEADER_VERSION);
    sv_setpvn(ST(0), request_message, HEADER_LENGTH +
	      MAX_MESSAGE_LEN - request_buffer_length);
  } else {
    SV             *error = perl_get_sv("Wais::errmsg", TRUE);

    sv_setpv(error, "Could not generate request_message");
  }
  if (request_message)
    free(request_message);
}


char *
local_answer(request_message)
	char *	request_message
CODE:
{
  long            request_length = na /* - HEADER_LENGTH */ ;	/* not used anyway */
  long            response_length;
  char           *response_message =
  (char *) s_malloc((size_t) MAX_MESSAGE_LEN * sizeof(char));
  long            response_buffer_length = MAX_MESSAGE_LEN;
  unsigned long   verbose = 0;

  if (response_message == NULL)
    croak("Out of memory");

  ST(0) = sv_newmortal();
  response_length =
    locally_answer_message(request_message, request_length,
			   response_message,
			   response_buffer_length);
  if (response_length == 0) {
    SV             *error = perl_get_sv("Wais::errmsg", TRUE);

    sv_setpv(error, "locally_answer_message failed");
  } else {
    sv_setpvn(ST(0), response_message + HEADER_LENGTH, response_length);
  }
  if (response_message)
    free(response_message);
}

MODULE = Wais PACKAGE = Wais::Init

InitResponseAPDU *
new(result_message)
	char *	result_message
CODE:
{
  RETVAL = NULL;

  if (readInitResponseAPDU(&RETVAL,result_message) == NULL){
    freeWAISInitResponse((WAISInitResponse*)RETVAL->UserInformationField);
    freeInitResponseAPDU(RETVAL);
    ST(0) = &sv_undef;
    XSRETURN(1);
  }
  if (RETVAL->Result == false)
    {				/* the server declined service */
      freeWAISInitResponse((WAISInitResponse*)RETVAL->UserInformationField);
      freeInitResponseAPDU(RETVAL);
      ST(0) = &sv_undef;
      XSRETURN(1);
    }
  else				/* we got a response back */
    { /* result = RETVAL->MaximumRecordSize;
      freeWAISInitResponse((WAISInitResponse*)RETVAL->UserInformationField);
      freeInitResponseAPDU(RETVAL); */
    }
}
OUTPUT:
	RETVAL

void
DESTROY(init_response)
	InitResponseAPDU *	init_response
CODE:
{
  if (TRACE)
    fprintf(stderr, "DESTROY: %lx\n", init_response);
  if (init_response && init_response != (InitResponseAPDU *) 0xDeadBeef) {
    freeWAISInitResponse((WAISInitResponse *) init_response->
			 UserInformationField);
    freeInitResponseAPDU(init_response);
  }
  init_response = (InitResponseAPDU *) 0xDeadBeef;
}
OUTPUT:
	init_response

char *
ImplementationID(init_response)
	InitResponseAPDU *	init_response
CODE:
{
  RETVAL = init_response->ImplementationID;
}
OUTPUT:
	RETVAL

char *
ImplementationName(init_response)
	InitResponseAPDU *	init_response
CODE:
{
  RETVAL = init_response->ImplementationName;
}
OUTPUT:
	RETVAL

char *
ImplementationVersion(init_response)
	InitResponseAPDU *	init_response
CODE:
{
  RETVAL = init_response->ImplementationVersion;
}
OUTPUT:
	RETVAL

MODULE = Wais PACKAGE = Wais::Docid

SV *
new(server, database_name, localid, ...)
	char *	server
	char *	database_name
	char *	localid
CODE:
{
  DocID           docID;
  any             Server;
  any             Database;
  any             LocalID;
  any            *Result;
  SV             *svdocid = sv_newmortal();
  HV             *stash = gv_stashpv("Wais::Docid", TRUE);

  Server.bytes = SvPV(ST(1), p_stl);
  Server.size=p_stl;
  Database.bytes = SvPV(ST(2), p_stl);
  Database.size=p_stl;
  LocalID.bytes = SvPV(ST(3), p_stl);
  LocalID.size=p_stl;

  docID.originalServer = &Server;
  docID.distributorServer = &Server;
  docID.originalDatabase = &Database;
  docID.distributorDatabase = &Database;
  docID.originalLocalID = &LocalID;
  docID.distributorLocalID = &LocalID;
  docID.copyrightDisposition = COPY_WITHOUT_RESTRICTION;
  if (items > 3) {
    docID.copyrightDisposition =  SvIV(ST(4));
  }
  if (items > 4) {
    Server.bytes = SvPV(ST(5), p_stl);
    Server.size=p_stl;
    docID.originalServer = &Server;
  }
  if (items > 5) {
    Database.bytes = SvPV(ST(6), p_stl);
    Database.size=p_stl;
    docID.originalDatabase = &Database;
  }
  if  (items > 6) {
    LocalID.bytes = SvPV(ST(7), p_stl);
    LocalID.size=p_stl;
    docID.originalLocalID = &LocalID;
  }
  Result = anyFromDocID(&docID);
  sv_setpvn(svdocid, Result->bytes, Result->size);
  freeAny(Result);
  RETVAL = newRV(svdocid);
  (void) sv_bless(RETVAL, stash);
}
OUTPUT:
	RETVAL

void
split(docid)
	char *	docid
PPCODE:
{
  any raw;
  DocID* new;

  raw.bytes = SvPV(SvRV(ST(0)), p_stl);
  raw.size=p_stl;
  
  if ((new = docIDFromAny(&raw)) != NULL) {
    EXTEND(sp, 3);
    PUSHs(sv_2mortal(newSVpv(new->distributorServer->bytes, 
                             new->distributorServer->size)));
    PUSHs(sv_2mortal(newSVpv(new->distributorDatabase->bytes,
                             new->distributorDatabase->size)));
    PUSHs(sv_2mortal(newSVpv(new->distributorLocalID->bytes,
                             new->distributorLocalID->size)));
    PUSHs(sv_2mortal(newSViv(new->copyrightDisposition)));
    PUSHs(sv_2mortal(newSVpv(new->originalServer->bytes, 
                             new->originalServer->size)));
    PUSHs(sv_2mortal(newSVpv(new->originalDatabase->bytes,
                             new->originalDatabase->size)));
    PUSHs(sv_2mortal(newSVpv(new->originalLocalID->bytes,
                             new->originalLocalID->size)));
    freeDocID(new);
  } else {
    ST(0) = &sv_undef;
  }
}

MODULE = Wais PACKAGE = Wais::Search

SearchResponseAPDU *
new(result_message)
        char *	result_message
CODE:
{
  RETVAL = NULL;

  readSearchResponseAPDU (&RETVAL, result_message);
}
OUTPUT:
	RETVAL

void
DESTROY(query_response)
	SearchResponseAPDU *	query_response
CODE:
{
  if (TRACE)
    fprintf(stderr, "DESTROY: %lx\n", query_response);
  if (query_response && query_response != (SearchResponseAPDU *) 0xDeadBeef) {
    if (query_response->DatabaseDiagnosticRecords)
      freeWAISSearchResponse(query_response->DatabaseDiagnosticRecords);
    freeSearchResponseAPDU(query_response);
  }
  query_response = (SearchResponseAPDU *) 0xDeadBeef;
}
OUTPUT:
	query_response

void
diagnostics(response)
	SearchResponseAPDU *	response
PPCODE:
{
  WAISSearchResponse *info;
  int             i;

  if (response->DatabaseDiagnosticRecords != 0) {
    info = (WAISSearchResponse *) response->DatabaseDiagnosticRecords;
    if (info->Diagnostics != NULL) {
      for (i = 0; info->Diagnostics[i] != NULL; i++) {
        char *tmp = D_PresentRequestOutOfRange;
        /* Ignore 'request out of range' diags */
        if ((info->Diagnostics[i]->DIAG[1] != tmp[1])
            || (info->Diagnostics[i]->DIAG[0] != tmp[0])) {
          EXTEND(sp, 2);
          PUSHs(sv_2mortal(newSVpv(info->Diagnostics[i]->DIAG,
                                   DIAGNOSTIC_CODE_SIZE)));
          PUSHs(sv_2mortal(newSVpv(info->Diagnostics[i]->ADDINFO, 0)));
        }
      }
    }
  }
}

void
header(response)
	SearchResponseAPDU *	response
PPCODE:
{
  WAISSearchResponse *info;
  int             i;

  if (response->DatabaseDiagnosticRecords != 0) {
    info = (WAISSearchResponse *) response->DatabaseDiagnosticRecords;
    if (info->DocHeaders != NULL) {
      for (i = 0; info->DocHeaders[i] != NULL; i++) {
	AV             *docarr = (AV *) sv_2mortal((SV *) newAV());
	AV             *types = (AV *) /*sv_2mortal */ ((SV *) newAV());
	SV             *refdocid;
	SV             *docid;
	HV             *stash = gv_stashpv("Wais::Docid", TRUE);

	char          **type;

	EXTEND(sp, 1);
	av_push(docarr, (newSViv(info->DocHeaders[i]->Score)));
	av_push(docarr, (newSViv(info->DocHeaders[i]->Lines)));
	av_push(docarr, (newSViv(info->DocHeaders[i]->DocumentLength)));
	av_push(docarr, (newSVpv(info->DocHeaders[i]->Headline, 0)));
	type = info->DocHeaders[i]->Types;
	while (*type) {
	  av_push(types, (newSVpv(*type, 0)));
	  type++;
	}
	av_push(docarr, (newRV((SV *) types)));
	docid = newSVpv(info->DocHeaders[i]->DocumentID->bytes,
			info->DocHeaders[i]->DocumentID->size);
	refdocid = newRV(docid);
	(void) sv_bless(refdocid, stash);
	av_push(docarr, refdocid);
	PUSHs(sv_2mortal(newRV((SV *) docarr)));
      }
    }
  }
}

void
text(response)
	SearchResponseAPDU *	response
PPCODE:
{
  WAISSearchResponse *info;
  int             i;

  if (response->DatabaseDiagnosticRecords != 0) {
    WAISDocumentText **texts;

    info = (WAISSearchResponse *) response->DatabaseDiagnosticRecords;
    texts = info->Text;
    if (texts == 0) {
        ST(0) = &sv_undef;
        XSRETURN(1);
    }
    while (*texts != NULL) {
      EXTEND(sp, 1);
      PUSHs(sv_2mortal(newSVpv((*texts)->DocumentText->bytes,
			       (*texts)->DocumentText->size)));
      texts++;
    }
  }
}

MODULE = Wais PACKAGE = Wais::Type

char *
stemmer(word)
	char * word

char *
grundform(word)
	char * word

char *
phonix(word)
	char * word
CODE:
{
    char 	RETVAL[80];

    PhonixCode(word,RETVAL);
    ST(0) = sv_newmortal();
    sv_setpv((SV*)ST(0), RETVAL);
}

char *
soundex(word)
	char * word
CODE:
{
    char 	RETVAL[80];

    SoundexCode(word,RETVAL);
    ST(0) = sv_newmortal();
    sv_setpv((SV*)ST(0), RETVAL);
}
       
