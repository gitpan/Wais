/*                               -*- Mode: C -*- 
 * HTWAIS.h -- 
 * ITIID           : $ITI$ $Header $__Header$
 * Author          : Ulrich Pfeifer
 * Created On      : Fri Nov 10 15:41:36 1995
 * Last Modified By: Ulrich Pfeifer
 * Last Modified On: Fri Nov 10 15:45:08 1995
 * Language        : C
 * Update Count    : 2
 * Status          : Unknown, Use with caution!
 * 
 * (C) Copyright 1995, Universität Dortmund, all rights reserved.
 * 
 * $Locker: pfeifer $
 * $Log: HTWAIS.h,v $
 * Revision 2.0.1.1  1995/11/10  14:52:19  pfeifer
 * patch9: Extern definitions.
 *
 */

#ifndef HTWAIS_H
#define HTWAIS_H
#include <ui.h>
extern int WAISsearch _AP((char *host, int port, char *database, char *keywords,
                              SV *diag, SV *headl, SV *text));

extern int WAISretrieve _AP((char *host, int port, char *database, char *docid,
                              SV *diag, SV *headl, SV *text));
#endif
