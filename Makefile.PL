#!/usr/local/ls6/perl/bin/perl
#                              -*- Mode: Perl -*- 
# 
# Makefile.PL -- 
# ITIID           : $ITI$ $Header $__Header$
# Author          : Ulrich Pfeifer
# Created On      : Sun Sep 10 11:00:44 1995
# Last Modified By: Ulrich Pfeifer
# Last Modified On: Wed Nov  8 12:15:52 1995
# Language        : Perl
# Update Count    : 18
# Status          : Unknown, Use with caution!
# 
# (C) Copyright 1995, Universität Dortmund, all rights reserved.
# 
# $Locker: pfeifer $
# $Log: Makefile.PL,v $
# Revision 2.0.1.4  1995/11/08  15:12:58  pfeifer
# patch6: Added TESTDB for tests.
#
# Revision 2.0.1.3  1995/11/08  08:19:49  pfeifer
# patch5: More standard Makefile.PL.
#
# Revision 2.0.1.2  1995/09/29  12:01:11  pfeifer
# patch4: Interactive search for the freeWAIS-sf includes and
# patch4: libraries. Also removed .../ctype/ctype.o. Make sure to
# patch4: include it in libwais.a. This is done with freeWAIS-sf-2.0.19
# patch4: automatically.
#
# Revision 2.0.1.1  1995/09/10  09:35:45  pfeifer
# patch1: Test if the given freeWAIS-sf source directory exists and
# patch1: query user if not.
#
# 

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile being created.

# Change the path to the freeWAIS-sf source directory according to
# your local setting.

$FW = "/usr/local/ls6/src+data/src/freeWAIS-sf-2.0";

while (! -d $FW) {
    print STDERR "FreeWAIS-sf source directory? ";
    chomp($FW = <STDIN>);
}

open(CONF, "$FW/config.h") || die "Could not open $FW/config.h: $!";
$regexp = '';
while (<CONF>) {
    if (/^#define MYREGEXP/) {
        $regexp = "-lregexp";
    }
}
close(CONF);
open(PATCH, "./patchlevel.h") || die "Could not open patchlevel.h: $!";
while (<PATCH>) {
    if (/VERSION ([\d.]+)/) {
        $version = $1;
    }
    if (/PATCHLEVEL (\d+)/) {
        $revision = $1;
    }                       # 
}
close(PATCH);

&WriteMakefile(
	'potential_libs' => "-L$FW/ir -L$FW/regexp -L$FW/lib -lwais $regexp -lftw",
	'INC'            => "-I$FW/ir",
	'NAME'           => 'Wais',
        'TESTDB'         => "$FW/FIELD-EXAMPLE/test",
	'VERSION'        => "$version.$revision",
	'OBJECT'         => "Wais.o HTWAIS.o dictionary.o",
	'DEFINE'         => '-DTRACE=0',
        'dist'           => { SUFFIX => 'gz', COMPRESS => 'gzip -f' },
        'clean' 	 => {'FILES' => '*~'},
);
