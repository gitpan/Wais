#!/app/unido-i06/magic/perl
#                              -*- Mode: Perl -*- 
# z_postop.t -- remove index, kill server
# ITIID           : $ITI$ $Header $__Header$
# Author          : Ulrich Pfeifer
# Created On      : Fri Feb 14 13:51:44 1997
# Last Modified By: Ulrich Pfeifer
# Last Modified On: Fri Feb 14 15:08:11 1997
# Language        : CPerl
# Update Count    : 11
# Status          : Unknown, Use with caution!
# 
# (C) Copyright 1997, Universit�t Dortmund, all rights reserved.
# 
# $Locker:  $
# $Log: z_postop.t,v $
# Revision 2.1  1997/02/14 15:01:19  pfeifer
# Pseudo test to kill the wais server and remove test databases indexes
#
# 

BEGIN {print "1..2\n";}

open(PID, "<test/waisserver.pid")
  or die "Could not read 'test/waisserver.pid'\n";
$pid = <PID>;
close(PID);

unless (kill 1,$pid) {
  print "waisserver process pid=$pid seems gone!\n";
  print "not ";
}
unlink 'test/waisserver.pid';
unlink 'test/waisserver.log';

print "ok 1\n";

opendir(TEST, 'test')
  or die "Could not opendir 'test': $!\n";

while (defined ($_ = readdir(TEST))) {
  next if /^\./;
  next if /^(test.?\.fmt|TEST)/;
  next unless /^(test|INFO)/;
  print "unlink $_\n";
  unlink "test/$_"
    or warn "Could not unlink 'test/$_': $!\n";
}

closedir TEST;

print "ok 2\n";
