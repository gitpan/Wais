#                              -*- Mode: Perl -*- 
# a_preop.t -- index test database, start server
# ITIID           : $ITI$ $Header $__Header$
# Author          : Ulrich Pfeifer
# Created On      : Fri Feb 14 13:28:59 1997
# Last Modified By: Ulrich Pfeifer
# Last Modified On: Fri Feb 14 16:24:58 1997
# Language        : CPerl
# Update Count    : 27
# Status          : Unknown, Use with caution!
# 
# (C) Copyright 1997, Universität Dortmund, all rights reserved.
# 

BEGIN {print "1..3\n"; $|=1}

my $pid = open(INDEX,"waisindex -d test/test -t fields test/TEST 2>&1|")
  or die "Could not run 'waisindex -d test/test -t fields test/TEST': $!\n";

print <INDEX>;

close INDEX;

my $wstatus = $?;
my $estatus = $wstatus >> 8;

print qq{
Subprocess "waisindex -d test/test -t fields test/TEST"
  returned status $estatus (wstat $wstatus)
} if $wstatus;

print "not " if $wstatus;
print "ok 1\n";

$pid = open(INDEX,"waisindex -d test/testg -t fields test/TEST.german 2>&1|")
  or die "Could not run 'waisindex -d test/test -t fields test/TEST': $!\n";

print <INDEX>;

close INDEX;

$wstatus = $?;
$estatus = $wstatus >> 8;

print qq{
Subprocess "waisindex -d test/test -t fields test/TEST"
  returned status $estatus (wstat $wstatus)
} if $wstatus;

print "not " if $wstatus;
print "ok 2\n";

$SIG{CHLD} = sub { print "not "; };


if (!($pid = fork())) {
  open(STDOUT, ">test/waisserver.log")
    or die "Could not write 'test/waisserver.log'\n";
  open(STDERR, '>&STDOUT')
    or die "Could not redirect STDERR: $!\n";
  exec qw(waisserver -d test -p 4171)
    or die "Could not run 'waisserver -d test -p 4171 2>&1': $!\n";
} else {
  open(PID, ">test/waisserver.pid")
    or die "Could not write 'test/waisserver.pid'\n";
  print PID $pid;
  close(PID);
}

sleep 5;

print "ok 3\n";

exit(0);
