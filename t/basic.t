#!perl
#                              -*- Mode: Perl -*- 
# test.pl -- 
# ITIID           : $ITI$ $Header $__Header$
# Author          : Ulrich Pfeifer
# Created On      : Tue Jun  7 17:45:45 1994
# Last Modified By: Ulrich Pfeifer
# Last Modified On: Fri Feb 14 14:41:35 1997
# Update Count    : 151
# Status          : Unknown, Use with caution!
# 
# 
# (C) Copyright 1995, Universitšt Dortmund, all rights reserved.
# 
# $Locker:  $
# $Log: basic.t,v $
# Revision 2.4  1997/02/14 15:02:45  pfeifer
# Test do not call remote servers now. People behind firewalls will see
# all test succeed now - hopefully.
#
# Revision 2.3  1997/02/06 09:31:12  pfeifer
# Switched to CVS
#
# Revision 2.2  1996/08/19 17:15:20  pfeifer
# perl5.003
#
# Revision 2.1.1.3  1996/07/16 16:40:41  pfeifer
# patch10:
#
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
BEGIN {print "1..4\n";}
use Wais;

my $db = 'test/test';

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

$host     = 'localhost';
$port     = 4171;
$db       = 'test';
$query    = 'au=pennekamp';
($headl, $diag) = &Wais::search($db, $query, $host,$port);
@docs = split($WAISrecsep, $headl);
print (($#docs == 0)?"ok 3\n" : "not ok 3\n");

$ti = 'Incremental Processing of Vague Queries';
($score,$lines,$docid,$headline) = split(/$WAISfldsep/,pop @docs);
($text,$diag) = &Wais::retrieve($db, $docid, $host,$port);
print (($text =~ /$ti/)?"ok 4\n" : "not ok 4\n$text\n");

