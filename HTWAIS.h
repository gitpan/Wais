/*                               -*- Mode: C -*- 
 * HTWAIS.h -- 
 * ITIID           : $ITI$ $Header $__Header$
 * Author          : Ulrich Pfeifer
 * Created On      : Fri Nov 10 15:41:36 1995
 * Last Modified By: Ulrich Pfeifer
 * Last Modified On: Tue Apr  9 14:01:54 1996
 * Language        : C
 * Update Count    : 3
 * Status          : Unknown, Use with caution!
 * 
 * (C) Copyright 1995, Universität Dortmund, all rights reserved.
 * 
 * $Locker: pfeifer $
 * $Log: HTWAIS.h,v $
 * Revision 2.1.1.1  1996/04/09 13:05:43  pfeifer
 * patch8: Avoid some redifinition warnings.
 *
 * Revision 2.1  1995/12/13  14:53:14  pfeifer
 * *** empty log message ***
 *
 * Revision 2.0.1.1  1995/11/10  14:52:19  pfeifer
 * patch9: Extern definitions.
 *
 */

#ifndef HTWAIS_H
#define HTWAIS_H
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
#include <ui.h>
extern int WAISsearch _AP((char *host, int port, char *database, char *keywords,
                              SV *diag, SV *headl, SV *text));

extern int WAISretrieve _AP((char *host, int port, char *database, char *docid,
                              SV *diag, SV *headl, SV *text));
#endif
