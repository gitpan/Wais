#!/usr/local/ls6/perl/bin/perl
#                              -*- Mode: Perl -*- 
# parallel.t -- 
# ITIID           : $ITI$ $Header $__Header$
# Author          : Ulrich Pfeifer
# Created On      : Tue Dec 12 16:55:05 1995
# Last Modified By: Ulrich Pfeifer
# Last Modified On: Wed Dec 13 15:35:36 1995
# Language        : Perl
# Update Count    : 55
# Status          : Unknown, Use with caution!
# 
# (C) Copyright 1995, Universität Dortmund, all rights reserved.
# 
# $Locker: pfeifer $
# $Log: parallel.t,v $
# Revision 2.1  1995/12/13  14:53:27  pfeifer
# *** empty log message ***
#
# Revision 2.0  1995/12/12  17:08:58  pfeifer
# Does not test parallel search yet. (Should be no problem anyway :-)
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

print "1..5\n";

$host = 'ls6-www.informatik.uni-dortmund.de';
$db2   = 'wais-docs';

print "Testing local searches\n";
$result = Wais::Search({
    'query'    => 'pfeifer', 
    'database' => $db,
    });

&headlines($result);
$id = ($result->header)[9]->[6];
@header = $result->header;
print (($#header == 9)?"ok 1\n" : "not ok 1\n");

print "Testing local retrieve\n";
$result = Wais::Retrieve(
                         'database' => $db,
                         'docid'    => $id, 
                         'type'     => 'TEXT',
                         );
print $result->text;
print ((length($result->text) == 406)?"ok 2\n" : "not ok 2\n");

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
print ((length($result->text) == 4453)?"ok 5\n" : "not ok 5\n");

sub headlines {
    my $result = shift;
    my ($tag, $score, $lines, $length, $headline, $types, $id);

    for ($result->header) {
        ($tag, $score, $lines, $length, $headline, $types, $id) = @{$_};
        printf "%5d %5d %s %s\n", 
        $score, $lines, $headline, join(',', @{$types});
    }
}


