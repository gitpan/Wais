/*                               -*- Mode: C -*- 
 * Wais.xs -- 
 * ITIID           : $ITI$ $Header $__Header$
 * Author          : Ulrich Pfeifer
 * Created On      : Mon Aug  8 16:09:45 1994
 * Last Modified By: Ulrich Pfeifer
 * Last Modified On: Fri Nov 10 17:11:40 1995
 * Update Count    : 143
 * Status          : Unknown, Use with caution!
 */


#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef WORD
#undef WORD			/* defined in the perl parser */
#endif
#ifdef _config_h_
#undef _config_h_		/* load the freeWAIS-sf config.h also */
#endif
#include "dictionary.h"
#include "HTWAIS.h"
#include "patchlevel.h"

int  WAISmaxdoc = 40;
static  int Wais_inited = 0;

void
init_Wais ()
{
  char            buf[80];
  SV             *version = perl_get_sv ("Wais::version", TRUE);
  SV             *recsep  = perl_get_sv ("Wais::recsep", TRUE);
  SV             *fldsep  = perl_get_sv ("Wais::fldsep", TRUE);
  SV             *maxdoc  = perl_get_sv ("Wais::maxdoc", TRUE);
  sv_setpv  (version, sprintf (buf, "Wais %3.1f%d", VERSION, PATCHLEVEL));
  sv_setpvn (recsep,  "\000", 1);
  sv_setpvn (fldsep,  "\001", 1);
  sv_setiv  (maxdoc,  WAISmaxdoc);
  Wais_inited = 1;
}
                
MODULE = Wais PACKAGE = Wais
BOOT:
init_Wais();

int
maxdoc(num=0)
	int	num
CODE:   
{
        SV *maxdoc = perl_get_sv ("Wais::maxdoc", FALSE);
        if (num)
           sv_setiv  (maxdoc, (IV) num);
     	ST(0) = sv_mortalcopy(maxdoc);
}

char *
recsep(sep=NULL)
	char *	sep
CODE:   
{
        SV             *recsep  = perl_get_sv ("Wais::recsep", FALSE);
        if (sep) 
           sv_setsv(recsep,ST(0));

	ST(0) = sv_mortalcopy(recsep);
}

char *
fldsep(sep=NULL)
	char *	sep
CODE:   
{
	SV             *fldsep  = perl_get_sv ("Wais::fldsep", FALSE);
        if (sep) sv_setsv(fldsep,ST(0));
        ST(0) = sv_mortalcopy(fldsep);
}

void
search(database, keywords, host=NULL,port=210)
	char *	host
	int	port
	char *	database
	char *	keywords
PPCODE:
{
  SV *headl = newSV(1000);
  SV *diag  = newSV(100);
  SV *text  = newSV(0);
  int retval;

  sv_setpv(headl,"");
  sv_setpv(diag,"");
  sv_setpv(text,"");
  retval = WAISsearch(host, port, database, keywords,
                              diag, headl, text);
  EXTEND(sp, 3);
  PUSHs(sv_2mortal(headl));
  PUSHs(sv_2mortal(diag));
  PUSHs(sv_2mortal(text));
}

void
retrieve(database, docid, host=NULL,port=210)
	char *	host
	int	port
	char *	database
	char *	docid
PPCODE:
{
  SV *headl = newSV(1000);
  SV *diag  = newSV(100);
  SV *text  = newSV(0);
  int retval;

  sv_setpv(headl,"");
  sv_setpv(diag,"");
  sv_setpv(text,"");
  retval = WAISretrieve(host, port, database, docid,
                              diag, headl, text);

  EXTEND(sp, 3);
  PUSHs(sv_2mortal(text));
  PUSHs(sv_2mortal(headl));
  PUSHs(sv_2mortal(diag));
}

void
dictionary(database, ...)
	char *database
PPCODE:
{
    char     *field  = NULL;
    char     *word   = NULL;
    long      matches = 0;
    long      offset  = 0;

    if (items == 1) {
        /* NOP */
    } else if (items == 2) {
        word = (char *)SvPV(ST(1), na);
        if (word[strlen(word)-1] != '*') {
            field = word;
            word  = NULL;
        }
    } else if (items == 3) {
        field = (char *)SvPV(ST(1), na);
        word  = (char *)SvPV(ST(2), na);
    } else {
        EXTEND (sp, 1);
        PUSHs (&sv_undef);
        PUTBACK;
        return;
    }
    stack_sp  -= items;         /* find_partialword modifies stack :-( */
    if (!find_word(database,field,word,offset,&matches)) {
        EXTEND (sp, 1);
        PUSHs  (&sv_undef);
    } else if (!(GIMME == G_ARRAY)) {
      EXTEND (sp, 1);
      PUSHs (sv_2mortal (newSViv (matches)));
      if (TRACE) fprintf(stderr, "matches: %d\n", matches);
    } else {
        sp = stack_sp;
    }
}

void
list_offset(database, ...)
	char *database
PPCODE:
{
    char     *field  = NULL;
    char     *word   = NULL;
    long      matches = 0;
    long      offset  = 1;

    if (items == 1) {
        /* NOP */
    } else if (items == 2) {
        word = (char *)SvPV(ST(1), na);
        if (word[strlen(word)-1] != '*') {
            field = word;
            word  = NULL;
        }
    } else if (items == 3) {
        field = (char *)SvPV(ST(1), na);
        word  = (char *)SvPV(ST(2), na);
    } else {
        EXTEND (sp, 1);
        PUSHs (&sv_undef);
        PUTBACK;
        return;
    }
    stack_sp  -= items;         /* find_partialword modifies stack :-( */
    if (!find_word(database,field,word,offset,&matches)) {
        EXTEND (sp, 1);
        PUSHs  (&sv_undef);
    } else if (!(GIMME == G_ARRAY)) {
      EXTEND (sp, 1);
      PUSHs (sv_2mortal (newSViv (matches)));
      if (TRACE) fprintf(stderr, "matches: %d\n", matches);
    } else {
        sp = stack_sp;
    }
}

void
postings(database, ...)
	char *database
PPCODE:
{
    char     *field  = NULL;
    char     *word   = NULL;
    long     number_of_postings = 0;

    if (items == 2) {
        word = (char *)SvPV(ST(1), na);
    } else if (items == 3) {
        field = (char *)SvPV(ST(1), na);
        word  = (char *)SvPV(ST(2), na);
    } else {
        EXTEND (sp, 1);
        PUSHs (&sv_undef);
        PUTBACK;
        return;
    }
    stack_sp  -= items;         /* postings() modifies stack :-( */
    if (!postings(database,field,word,&number_of_postings)) {
        EXTEND (sp, 1);
        PUSHs  (&sv_undef);
    } else if (!(GIMME == G_ARRAY)) {
      EXTEND (sp, 1);
      PUSHs (sv_2mortal (newSViv (number_of_postings)));
      if (TRACE) 
          fprintf(stderr, "number_of_postings: %d\n", number_of_postings);
    } else {
        sp = stack_sp;
    }
}

char *
headline(database,docid)
	char *	database;
	long	docid;

	
