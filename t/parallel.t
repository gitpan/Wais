#!/usr/local/ls6/perl/bin/perl
#                              -*- Mode: Perl -*- 
# parallel.t -- 
# ITIID           : $ITI$ $Header $__Header$
# Author          : Ulrich Pfeifer
# Created On      : Tue Dec 12 16:55:05 1995
# Last Modified By: Ulrich Pfeifer
# Last Modified On: Mon Jul 22 17:55:30 1996
# Language        : Perl
# Update Count    : 79
# Status          : Unknown, Use with caution!
# 
# (C) Copyright 1995, Universität Dortmund, all rights reserved.
# 
# $Locker: pfeifer $
# $Log: parallel.t,v $
# Revision 2.2  1996/08/19 17:15:20  pfeifer
# perl5.003
#
# Revision 2.1.1.7  1996/08/01 18:13:31  pfeifer
# patch14: Added use lib '.' to make it find chat2.pl in current
# patch14: directory.
#
# Revision 2.1.1.6  1996/07/16 16:41:10  pfeifer
# patch10: Made test al little sloppier ;-)
#
# Revision 2.1.1.5  1996/04/30 07:51:27  pfeifer
# patch9: Database change.
#
# Revision 2.1.1.4  1996/04/09 13:07:00  pfeifer
# patch8: More robust tests.
#
# Revision 2.1.1.3  1996/02/27 18:43:16  pfeifer
# patch5: Now searchestwo databases in parallel ;-)
#
# Revision 2.1.1.2  1996/02/23 15:45:49  pfeifer
# patch4: Added test for Wais::Docid::split.
#
# Revision 2.1.1.1  1996/02/21 13:29:33  pfeifer
# patch3: MakeMaker 5.21 (002gamma) now produces TESTDB => q[/usr/..]
# patch3: instead of TESTDB => '/usr/..'.
#
# Revision 2.1  1995/12/13  14:53:27  pfeifer
# *** empty log message ***
#
# Revision 2.0  1995/12/12  17:08:58  pfeifer
# Does not test parallel search yet. (Should be no problem anyway :-)
#
# 

use lib '.';
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

print "1..6\n";

$host = 'ls6-www.informatik.uni-dortmund.de';
$db2   = 'wais-docs';

print "Testing local searches\n";
$result = Wais::Search({
    'query'    => 'pfeifer', 
    'database' => $db,
    'database' => $db.'g',
    });

&headlines($result);
$id     = ($result->header)[9]->[6];
$length = ($result->header)[9]->[3];
@header = $result->header;
print (($#header >= 14)?"ok 1\n" : "not ok 1\n$#header\n");

print "Testing local retrieve\n";
$result = Wais::Retrieve(
                         'database' => $db,
                         'docid'    => $id, 
                         'type'     => 'TEXT',
                         );
print $result->text;
print length($result->text), "***\n";
print ((length($result->text) == $length)?"ok 2\n" : "not ok 2\n");

print "Testing remote searches\n";
$result = Wais::Search({
    'query'    => 'wais',
    'host'     => $host,
    'database' => $db2,
    });
&headlines($result);
@header = $result->header;
#print $#header, "===\n";
print (($#header == 20)?"ok 3\n" : "not ok 3\n");
$long  = ($result->header)[7]->[6];
$short = ($result->header)[0]->[6];
print "Testing remote retrieve\n";

$result = Wais::Retrieve(
                         'host'     => $host,
                         'database' => $db2,
                         'docid'    => $short,
                         'type'     => 'TEXT',
                         );

print $result->text;
#print length($result->text), "===\n";
print ((length($result->text) == 1347)?"ok 4\n" : "not ok 4\n");

print "Testing long documents\n";

$result = Wais::Retrieve(
                         'host'     => $host,
                         'database' => $db2,
                         'docid'    => $long, 
                         'type'     => 'TEXT',
                         );

print $result->text;
#print length($result->text), "===\n";
print ((length($result->text) == 3234)?"ok 5\n" : "not ok 5\n");

sub headlines {
    my $result = shift;
    my ($tag, $score, $lines, $length, $headline, $types, $id);

    for ($result->header) {
        ($tag, $score, $lines, $length, $headline, $types, $id) = @{$_};
        printf "%5d %5d %s %s\n", 
        $score, $lines, $headline, join(',', @{$types});
    }
}

@x = $short->split;
print (($x[0] eq 'charly:210')? "ok 6\n" : "not ok 6\n");
