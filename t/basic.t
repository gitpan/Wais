#!perl
#                              -*- Mode: Perl -*- 
# test.pl -- 
# ITIID           : $ITI$ $Header $__Header$
# Author          : Ulrich Pfeifer
# Created On      : Tue Jun  7 17:45:45 1994
# Last Modified By: Ulrich Pfeifer
# Last Modified On: Sun Apr 21 12:23:00 1996
# Update Count    : 146
# Status          : Unknown, Use with caution!
# 
# 
# (C) Copyright 1995, Universität Dortmund, all rights reserved.
# 
# $Locker: pfeifer $
# $Log: basic.t,v $
# Revision 2.1.1.2  1996/04/09 13:06:56  pfeifer
# patch8: More robust tests.
#
# Revision 2.1.1.1  1996/02/21 13:29:28  pfeifer
# patch3: MakeMaker 5.21 (002gamma) now produces TESTDB => q[/usr/..]
# patch3: instead of TESTDB => '/usr/..'.
#
# Revision 2.1  1995/12/13  14:53:19  pfeifer
# *** empty log message ***
#
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
    if (/TESTDB => (\'|q\[)(.*)(\'|\])/) {
        $db = $2;
        last;
    } elsif (m/^TESTDB\s*=\s*(\S+)\s*$/) {
        $db = $1;
        last;
    }
}
close(MF);
die "Which db?" unless $db;
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
@docs = split(/$WAISrecsep/, $headl);
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

