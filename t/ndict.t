#!./perl
#                              -*- Mode: Perl -*- 
# ndict.t -- 
# ITIID           : $ITI$ $Header $__Header$
# Author          : Ulrich Pfeifer
# Created On      : Wed Nov  8 12:02:19 1995
# Last Modified By: Ulrich Pfeifer
# Last Modified On: Thu Sep 19 16:15:06 1996
# Language        : Perl
# Update Count    : 97
# Status          : Unknown, Use with caution!
# 
# (C) Copyright 1995, Universität Dortmund, all rights reserved.
# 
# $Locker:  $
# $Log: ndict.t,v $
# Revision 2.3  1997/02/06 09:31:13  pfeifer
# Switched to CVS
#
# Revision 2.2  1996/08/19 17:15:20  pfeifer
# perl5.003
#
# Revision 2.1.1.1  1996/08/01 18:12:51  pfeifer
# patch14: Need harder tests here for binsearch().
#
# 
BEGIN {
  print "1..15\n";
  require Wais;
  print "ok 1\n";
  require Wais::Dict;
  print "ok 2\n";
}

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

$au = tie %au, Wais::Dict, "${db}_field_au";

print "ok 3\n";

$test = 4;
$should = 'b224,1,b652,1,bremkamp,1,buckley,1,f600,7,fuhr,7,h500,1,huynh,1,p116,10,p455,1,p525,1,p622,2,pennekamp,1,pfeifer,10,poersch,2,pollmann,1';
$result = join ',', %au;
print ((substr($result,0,length($should)))?"ok $test\n" : "not ok $test\n");

$test++;
$result = $au->FETCH('pfeifer');
$should = 10;
print (($should == $result)?"ok $test\n" : "not ok $test\n");

$test++;
$result = $au->FETCH('wall');
print ((!defined $result)?"ok $test\n" : "not ok $test\n");

$test++;
$result = $au->FIRSTKEY;
print (('b224' eq $result)?"ok $test\n" : "not ok $test\n");

$test++;
$au->NEXTKEY;
$au->PREVKEY;
$result = $au->PREVKEY;
print (('b224' eq $result)?"ok $test\n" : "not ok $test\n");

$test++;
$result = $au->SET('pfeifer');
print ($result?"ok $test\n" : "not ok $test\n");

$test++;
$result = $au->NEXTKEY;
print (($result eq 'pfeifer')?"ok $test\n" : "not ok $test\n");

$test++;
$au->SET('pfei');
$result = $au->NEXTKEY;
print (($result eq 'pfeifer')?"ok $test\n" : "not ok $test\n");

$test++;
$au->SET('pfeifer1');
$result = $au->NEXTKEY;
print (($result ge 'pfeifer')?"ok $test\n" : "not ok $test\n");

$test++;
$result = $au->POSTINGS('wall');
print ((!defined $result)?"ok $test\n" : "not ok $test\n");

$test++;
$result = $au->POSTINGS('pfeifer');
print (($result == 20)?"ok $test\n" : "not ok $test\n");

$test++;
%po = $au->POSTINGS('pfeifer');
$result = join ',', sort {$a <=> $b} keys %po;
$should = join ',', 1..10;
print (($result eq $should)?"ok $test\n" : "not ok $test\n");


