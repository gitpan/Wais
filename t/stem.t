#                              -*- Mode: Perl -*- 
# base.t -- 
# ITIID           : $ITI$ $Header $__Header$
# Author          : Ulrich Pfeifer
# Created On      : Thu Aug 15 18:47:58 1996
# Last Modified By: Ulrich Pfeifer
# Last Modified On: Thu Aug 15 19:29:43 1996
# Language        : CPerl
# Update Count    : 18
# Status          : Unknown, Use with caution!
# 
# (C) Copyright 1996, Universitšt Dortmund, all rights reserved.
# 
# $Locker$
# $Log$
# 

use lib '.';
BEGIN { $| = 1; print "1..19\n"; }
END {print "not ok 1\n" unless $loaded;}
use Wais;
$loaded = 1;
print "ok 1\n";

@inputs = qw(computer computers pfeifer pfeiffer knight night);
@stems  = qw(comput comput pfeifer pfeiffer knight night);
@sounds = qw(C513 C513 P116 P116 K523 N230);
@phonos = qw(K5130000 K5138000 F7000000 F7000000 N3000000 N3000000);


$test = 2;
for (@inputs) {
  print ((Wais::Type::stemmer($_)    eq shift @stems )? "ok $test\n":"not ok $test\n");$test++;
  print ((Wais::Type::soundex($_) eq shift @sounds)? "ok $test\n":"not ok $test\n");$test++;
  print ((Wais::Type::phonix($_)  eq shift @phonos)? "ok $test\n":"not ok $test\n");$test++;
}
