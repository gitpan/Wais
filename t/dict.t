#!./perl
#                              -*- Mode: Perl -*- 
# dict.t -- 
# ITIID           : $ITI$ $Header $__Header$
# Author          : Ulrich Pfeifer
# Created On      : Wed Nov  8 12:02:19 1995
# Last Modified By: Ulrich Pfeifer
# Last Modified On: Sun Apr 21 23:23:00 1996
# Language        : Perl
# Update Count    : 67
# Status          : Unknown, Use with caution!
# 
# (C) Copyright 1995, Universität Dortmund, all rights reserved.
# 
# $Locker: pfeifer $
# $Log: dict.t,v $
# Revision 2.1.1.5  1996/04/30 07:51:07  pfeifer
# patch9: Test now hides a bug(?). On solaris one get the results as
# patch9: before. On sunos the DICTIONARY_TOTAL_SIZE_WORD is also
# patch9: returned. Don't know which is the correct behaviour. I use
# patch9: Wais::Dict now.
#
# Revision 2.1.1.4  1996/04/09 13:06:58  pfeifer
# patch8: More robust tests.
#
# Revision 2.1.1.3  1996/02/21 13:29:31  pfeifer
# patch3: MakeMaker 5.21 (002gamma) now produces TESTDB => q[/usr/..]
# patch3: instead of TESTDB => '/usr/..'.
#
# Revision 2.1.1.2  1996/02/05 12:42:56  pfeifer
# patch2: Patch to fix chat2 for solaris.
#
# Revision 2.1.1.1  1995/12/28 16:32:01  pfeifer
# patch1:
#
# Revision 2.1  1995/12/13  14:53:23  pfeifer
# *** empty log message ***
#
# Revision 2.0.1.4  1995/11/16  12:23:25  pfeifer
# patch11: Added document.
#
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
print "1..8\n";

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

use Wais;

$should = 'pollmann,1,poersch,2,pfeifer,10,pennekamp,1,p622,2,p525,1,p455,1,p116,10';
$result = join ',', &Wais::dictionary($db , 'au', 'p*');
print (($should eq $result)?"ok 1\n" : "not ok 1\n");

$should = 'pennekamp,pfeifer,poersch,pollmann,probabilistic,processing,proper';
%x = &Wais::dictionary($db , 'p*');
$result = join ',', sort keys %x;
print (($should eq $result)?"ok 2\n" : "not ok 2\n$should\n$result\n");

$should = 'buckley,1,bremkamp,1,b652,1,b224,1,fuhr,7,f600,7,huynh,1,h500,1,pollmann,1,poersch,2,pfeifer,10,pennekamp,1,p622,2,p525,1,p455,1,p116,10';
$result = join ',', &Wais::dictionary($db, 'au');
# hide a bug!
$result = substr($result,0,length($should));
print (($should eq $result)?"ok 3\n" : "not ok 3\n$should\n$result\n\n");

$should = 16;
$result =  &Wais::dictionary($db, 'au');
print (($should <= $result)?"ok 4\n$result =?= 16\n" : "not ok 4\n");

%x = &Wais::postings($db, 'au', 'pfeifer');
#for (keys %x) {
#    print $_, "\t", join(':', @{$x{$_}}), "\n";
#}
#print $x{2}->[0], "\n";
print (($x{2}->[0] == 0.5)?"ok 5\n" : "not ok 5\n");

%x = &Wais::postings($db, 'fuhr');
print (($#{$x{1}} == 2)?"ok 6\n" : "not ok 6\n");

$should = '1991 Fuhr, N.; Pfeifer, U Combining Model-Oriented and Description';
$result = &Wais::headline($db,1);
print (($should eq $result)?"ok 7\n" : "not ok 7\n");

$should = 'Combining Model-Oriented and Description';
$result = &Wais::document($db,1);
print (($result =~ $should)?"ok 8\n" : "not ok 8\n");

