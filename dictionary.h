/*                               -*- Mode: C -*- 
 * dictionary.h -- 
 * ITIID           : $ITI$ $Header $__Header$
 * Author          : Ulrich Pfeifer
 * Created On      : Fri Nov 10 15:35:13 1995
 * Last Modified By: Ulrich Pfeifer
 * Last Modified On: Tue Apr 30 08:57:17 1996
 * Language        : C
 * Update Count    : 9
 * Status          : Unknown, Use with caution!
 * 
 * (C) Copyright 1995, Universitšt Dortmund, all rights reserved.
 * 
 * $Locker: pfeifer $
 * $Log: dictionary.h,v $
 * Revision 2.1.1.2  1996/04/30 07:40:55  pfeifer
 * patch9: Moved defined clash fixes to dictionary.h.
 * patch9: This is not too clean - but dictionary.h is included
 * patch9: in all C-Files.
 *
 * Revision 2.1.1.1  1995/12/28 16:31:50  pfeifer
 * patch1:
 *
 * Revision 2.1  1995/12/13  14:56:31  pfeifer
 * *** empty log message ***
 *
 * Revision 2.0.1.2  1995/11/16  12:23:55  pfeifer
 * patch11: Added document.
 *
 * Revision 2.0.1.1  1995/11/10  14:52:51  pfeifer
 * patch9: Extern definitions.
 *
 */

#ifndef DICTIONARY_H
#define DICTIONARY_H

#ifdef WORD
#undef WORD			/* defined in the perl parser */
#endif
#ifdef _config_h_
#undef _config_h_		/* load the freeWAIS-sf config.h also */
#endif
#ifdef warn
#undef warn
#endif
#ifdef Strerror
#undef Strerror
#endif

#include "cutil.h"
#include "irfiles.h"
#include "irtfiles.h"		/* for map_over_words */
#include "irext.h"
#include "irsearch.h"
#include "weight.h"

extern int find_partialword _AP((database *db, char *field_name, char *word, 
                               long offset, long *matches));
extern int find_word _AP((char *database_name, char *field_name, char *word, 
                               long offset, long *matches));
extern int postings _AP((char *database_name, char *field_name, char *word, 
                       long *number_of_postings));
extern char *headline _AP((char *database_name, long docid));
extern char *document _AP((char *database_name, long docid));
#endif
