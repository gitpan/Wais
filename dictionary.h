/*                               -*- Mode: C -*- 
 * dictionary.h -- 
 * ITIID           : $ITI$ $Header $__Header$
 * Author          : Ulrich Pfeifer
 * Created On      : Fri Nov 10 15:35:13 1995
 * Last Modified By: Ulrich Pfeifer
 * Last Modified On: Fri Nov 10 15:40:19 1995
 * Language        : C
 * Update Count    : 4
 * Status          : Unknown, Use with caution!
 * 
 * (C) Copyright 1995, Universität Dortmund, all rights reserved.
 * 
 * $Locker: pfeifer $
 * $Log: dictionary.h,v $
 * Revision 2.0.1.1  1995/11/10  14:52:51  pfeifer
 * patch9: Extern definitions.
 *
 */

#ifndef DICTIONARY_H
#define DICTIONARY_H

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
#endif
