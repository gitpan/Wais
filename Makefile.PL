#!/usr/local/ls6/perl/bin/perl
#                              -*- Mode: Perl -*- 
# 
# Makefile.PL -- 
# ITIID           : $ITI$ $Header $__Header$
# Author          : Ulrich Pfeifer
# Created On      : Sun Sep 10 11:00:44 1995
# Last Modified By: Ulrich Pfeifer
# Last Modified On: Tue Apr 30 08:52:44 1996
# Language        : Perl
# Update Count    : 137
# Status          : Unknown, Use with caution!
# 
# (C) Copyright 1995, Universität Dortmund, all rights reserved.
# 
# $Locker: pfeifer $
# $Log: Makefile.PL,v $
# Revision 2.1.1.5  1996/04/30 07:39:59  pfeifer
# patch9: Version in Wais.pm is only overwritten if necessary.
#
# Revision 2.1.1.4  1996/04/09 13:06:30  pfeifer
# patch8: INstallation code for chat. Cleaned rest.
#
# Revision 2.1.1.3  1996/03/07 09:30:13  pfeifer
# patch7: Added registration facility.
#
# Revision 2.1.1.2  1996/03/01 14:35:09  pfeifer
# patch6: Added rule to delete distributed chat2.pl.
#
# Revision 2.1.1.1  1996/02/23 15:44:33  pfeifer
# patch4: Now rewrites Wais.pm to include version number.
#
# Revision 2.1  1995/12/13  14:52:20  pfeifer
# *** empty log message ***
#
# Revision 2.0.1.6  1995/12/13  08:29:52  pfeifer
# patch14: Added -noprototypes.
#
# Revision 2.0.1.5  1995/12/08  19:31:03  pfeifer
# patch12: 2beta1 conformant.
#
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
use Config;

$FW = "/usr/local/ls6/src+data/src/freeWAIS-sf-2.0";
if (-d "$FW/$Config{'archname'}") {
    $FW="$FW/$Config{'archname'}";
}
while (! -d $FW) {
    print STDERR "FreeWAIS-sf source directory? ";
    chomp($FW = <STDIN>);
}

unless (-e "$FW/FIELD-EXAMPLE/test.doc") {
    print "Your tests database \"$FW/FIELD-EXAMPLE/test\" is missing\n";
    print "You must rebuild it before running the tests!\n";
}

open(CONF, "$FW/config.h") || die "Could not open $FW/config.h: $!";
$regexp = '';
while (<CONF>) {
    if (/^#define MYREGEXP/) {
        $regexp = "-lregexp";
    }
}
close(CONF);

$VERSION = getversion('patchlevel.h');
rewrite('lib/Wais.pm', 'Wais', $VERSION);

&WriteMakefile(
	'LIBS'           => "-L$FW/ir -L$FW/regexp -L$FW/lib ".
                            "-lwais $regexp -lftw",
	'INC'            => "-I$FW/ir",
	'NAME'           => 'Wais',
	'VERSION'        => $VERSION,
	'OBJECT'         => "Wais.o HTWAIS.o dictionary.o",
	'DEFINE'         => '-DTRACE=0 -g',
        'XSPROTOARG'     => '-noprototypes', 
        'dist'           => { SUFFIX => 'gz', COMPRESS => 'gzip -f' },
        'clean' 	 => {'FILES' => '*~ chat2.pl'},
        'MAP_TARGET'     => 'waisperl',
        'EXE_FILES'      => [ 'inspect' ],
);

sub getversion {
    my $file = shift;
    my ($version, $revision);

    open(PATCH, $file) || die "Could not open patchlevel.h: $!";
    while (<PATCH>) {
        if (/VERSION ([\d.]+)/) {
            $version = $1;
        }
        if (/PATCHLEVEL (\d+)/) {
            $revision = $1;
        }
    }
    close(PATCH);
    sprintf("%5.3f", $version + $revision/1000);
}

sub moduleversion {
  my ($file, $package) = @_;
  my $version;
  
  open(IN, $file) || die "Could not open $file: $!";
  while (<IN>) {
    if (/^\$($package\:\:)?VERSION\s*=\s*(\d+\.\d+)/) {
      $version = $2;
      last;
    }
  }
  close IN;
  $version;
}

sub rewrite {
    my ($file, $package, $VERSION) = @_;
    my $bak = "$file.bak";

    return if moduleversion($file, $package) eq $VERSION;
    rename $file, $bak or die "Could not rename $file: $!";
    open(IN, $bak) || die "Could not open $bak: $!";
    open(OUT, ">$file") || die "Could not open $file: $!";
    print STDERR "Rewriting $file\n";

    while (<IN>) {
        if (/^\$($package\:\:)?VERSION/) {
            print OUT '$'.$package.'::VERSION = '."$VERSION;\n";
            print STDERR '$'.$package.'::VERSION = '."$VERSION;\n";
        } else {
            print OUT;
        }
    }
    close(IN);
    close(OUT);
    unlink $bak;
}

sub MY::postamble {
    my $self = shift;
    
    q[
install :: chatinstall chatfix register

chatinstall: chat2.pl
	].$self->{NOECHO}.q[rm -f $(SITEARCHEXP)/chat2.pl
	$(UMASK_NULL) && cp chat2.pl $(SITEARCHEXP)/chat2.pl

chatfix ::
	$(RM_F) $(SITELIBEXP)/chat2.pl
	].$self->{NOECHO}.q[$(PERL) -I$(PERL_ARCHLIB) -I$(PERL_LIB) \
-e '    $$newchat = shift;'	\
-e '    for $$oldchat (@ARGV) { next if $$SEEN{$$oldchat}++; ' \
-e '       if (-e "$$oldchat/chat.pl" and $$oldchat ne $$newchat) {'	\
-e '          print "Schould I remove the buggy $$oldchat/chat.pl? ";'	\
-e '          $$answer = <STDIN>;' 	\
-e '          if ($$answer =~ /^y/i) {'	\
-e '             unlink "$$oldchat/chat.pl" || print "Did not work!\n";' \
-e '          } else {'	\
-e '             print "Ok .. dont blame me!\n";'	\
-e '    }}}'	\
    $(SITEARCHEXP) $(PERL_LIB) $(INSTALLPRIVLIB) $(SITELIBEXP)

register ::
	].$self->{NOECHO}.q[$(PERL) -I$(PERL_ARCHLIB) -I$(PERL_LIB) \
-e '    use Wais; ' \
-e '    use Config; ' \
-e '    eval "use Sys::Hostname; \\$$host = q[on ].hostname;";' \
-e '    $$address="wais\@ls6.informatik.uni-dortmund.de";'	\
-e '    print "Send registration mail to $$address (y/n)? ";'	\
-e '    $$answer = <STDIN>;' 	\
-e '    if ($$answer !~ /^n/i) {'	\
-e '        exec "perlbug", "-a", $$address, "-C",'	\
-e '        "-s", "Installed Wais extension $$Wais::VERSION $$host$$Config{mydomain}";'	\
-e '    } else {'	\
-e '        print "Ok ... I will keep your secret!\n";'	\
-e '    }'
] . qq[
TESTDB  = $FW/FIELD-EXAMPLE/test
]
}
