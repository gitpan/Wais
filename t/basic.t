#!perl
#                              -*- Mode: Perl -*- 
# test.pl -- 
# ITIID           : $ITI$ $Header $__Header$
# Author          : Ulrich Pfeifer
# Created On      : Tue Jun  7 17:45:45 1994
# Last Modified By: Ulrich Pfeifer
# Last Modified On: Wed Nov  8 19:27:08 1995
# Update Count    : 135
# Status          : Unknown, Use with caution!
# 

#!./perl
#                              -*- Mode: Perl -*- 
# dict.t -- 
# ITIID           : $ITI$ $Header $__Header$
# Author          : Ulrich Pfeifer
# Created On      : Wed Nov  8 12:02:19 1995
# Last Modified By: Ulrich Pfeifer
# Last Modified On: Wed Nov  8 15:39:44 1995
# Language        : Perl
# Update Count    : 26
# Status          : Unknown, Use with caution!
# 
# (C) Copyright 1995, Universität Dortmund, all rights reserved.
# 
# $Locker: pfeifer $
# $Log: basic.t,v $
# Revision 2.0.1.2  1995/11/08  18:31:05  pfeifer
# patch7: Test remote database also.
#
# Revision 2.0.1.1  1995/11/08  15:14:15  pfeifer
# patch6: Test the local database in the freeWAIS-sf soyrce directories.
#
# 

use Wais;

open(MF, "Makefile") || die "could not open Makefile: $!";
while (<MF>) {
    if (/TESTDB => \'(.*)\'/) {
        $db = $1;
        last;
    }
}
close(MF);

print "1..4\n";
$query    = 'au=(fuhr and pfeifer)';
$ti       = 'Probabilistic  Learning Approaches for Indexing and Retrieval';
$lines    = 0;
$score    = 0;
$headline = '';
$diag     = '';
$headl    = '';
$text     = '';

$WAISrecsep = &Wais::recsep("\000");
$WAISfldsep = &Wais::fldsep("\001");

($headl, $diag) = &Wais::search($db, $query);
@docs = split($WAISrecsep, $headl);
print (($#docs == 6)?"ok 1\n" : "not ok 1\n");

($score,$lines,$docid,$headline) = split(/$WAISfldsep/,pop @docs);
($text,$diag) = &Wais::retrieve($db, $docid);
print (($text =~ /$ti/)?"ok 2\n" : "not ok 2\n");

$host     = 'ls6-www.informatik.uni-dortmund.de';
$port     = 210;
$db       = 'demo';
$query    = 'general au=white';
($headl, $diag) = &Wais::search($db, $query, $host,$port);
@docs = split($WAISrecsep, $headl);
print (($#docs == 1)?"ok 3\n" : "not ok 3\n");

$ti = 'Technology growth has produced';
($score,$lines,$docid,$headline) = split(/$WAISfldsep/,pop @docs);
($text,$diag) = &Wais::retrieve($db, $docid, $host,$port);
print (($text =~ /$ti/)?"ok 4\n" : "not ok 4\n");

