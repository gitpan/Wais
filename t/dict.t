#!./perl
#                              -*- Mode: Perl -*- 
# dict.t -- 
# ITIID           : $ITI$ $Header $__Header$
# Author          : Ulrich Pfeifer
# Created On      : Wed Nov  8 12:02:19 1995
# Last Modified By: Ulrich Pfeifer
# Last Modified On: Fri Nov 10 15:50:04 1995
# Language        : Perl
# Update Count    : 36
# Status          : Unknown, Use with caution!
# 
# (C) Copyright 1995, Universität Dortmund, all rights reserved.
# 
# $Locker: pfeifer $
# $Log: dict.t,v $
# Revision 2.0.1.3  1995/11/10  14:52:29  pfeifer
# patch9: Added test for headline().
#
# Revision 2.0.1.2  1995/11/09  20:30:51  pfeifer
# patch8: Added postings().
#
# Revision 2.0.1.1  1995/11/08  15:14:30  pfeifer
# patch6: Test the dictionary functiions.
#
# 

open(MF, "Makefile") || die "could not open Makefile: $!";
while (<MF>) {
    if (/TESTDB => \'(.*)\'/) {
        $db = $1;
        last;
    }
}
close(MF);

use Wais;

print "1..7\n";

$should = 'pollmann,1,poersch,2,pfeifer,10,pennekamp,1,p622,2,p525,1,p455,1,p116,10';
$result = join ',', &Wais::dictionary($db , 'au', 'p*');
print (($should eq $result)?"ok 1\n" : "not ok 1\n");

$should = 'pfeifer,19,pennekamp,1,poersch,3,pollmann,1,probabilistic,4,processing,2,proper,1';
$result = join ',', &Wais::dictionary($db , 'p*');
print (($should eq $result)?"ok 2\n" : "not ok 2\n");

$should = 'buckley,1,bremkamp,1,b652,1,b224,1,fuhr,7,f600,7,huynh,1,h500,1,pollmann,1,poersch,2,pfeifer,10,pennekamp,1,p622,2,p525,1,p455,1,p116,10';
$result = join ',', &Wais::dictionary($db, 'au');
print (($should eq $result)?"ok 3\n" : "not ok 3\n");

$should = 16;
$result =  &Wais::dictionary($db, 'au');
print (($should == $result)?"ok 4\n" : "not ok 4\n");

%x = &Wais::postings($db, 'au', 'pfeifer');
print (($x{2}->[0] == 0.5)?"ok 5\n" : "not ok 5\n");

%x = &Wais::postings($db, 'fuhr');
print (($#{$x{1}} == 2)?"ok 6\n" : "not ok 6\n");

$should = '1991 Fuhr, N.; Pfeifer, U Combining Model-Oriented and Description';
$result = &Wais::headline($db,1);
print (($should eq $result)?"ok 7\n" : "not ok 7\n");
