#                              -*- Mode: Perl -*- 
# Makefile.PL -- 
# ITIID           : $ITI$ $Header $__Header$
# Author          : Ulrich Pfeifer
# Created On      : Sun Sep 10 11:00:44 1995
# Last Modified By: Ulrich Pfeifer
# Last Modified On: Thu May  1 14:33:27 1997
# Language        : Perl
# Update Count    : 228
# Status          : Unknown, Use with caution!
# 
# (C) Copyright 1995, Universität Dortmund, all rights reserved.
# 

use ExtUtils::MakeMaker;
use Config;

# $Format: "\$VERSION = sprintf '%5.3f', $ProjectMajorVersion: 23 $/10 + $ProjectMinorVersion: 2 $/1000;"
$VERSION = sprintf '%5.3f', 23/10 + 1/1000;

for (qw(waisserver waisindex)) {
  die "Could not find '$_' in your PATH\n"
    unless findbin($_);
}

my $PREOP = qq(
               pod2text INSTALL.pod > INSTALL;
               pod2text Wais.pm     > README;
              );
$PREOP =~ s/\s+/ /g;

&WriteMakefile
  (
   'PREREQ_PM'      => { IO::Select => 0},
   'LIBS'           => "-lwais",
   'INC'            => "-DWAIS_USES_STDIO",
   'NAME'           => 'Wais',
   'VERSION'        => $VERSION,
   'DEFINE'         => '-DTRACE=0 -g',
   'OBJECT'         => "Wais.o HTWAIS.o dictionary.o",
   'PL_FILES'       => {'inspect.PL' => 'inspect'},
   'dist'           => {
                        SUFFIX   => 'gz',
                        COMPRESS => 'gzip -9f',
                        'PREOP'  => $PREOP,
                       },
   'clean' 	    => {'FILES' => '*~ inspect'},
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

sub MY::postamble {
    my $self = shift;
    
    q[
install :: register

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
]
}

sub findbin {
  my $prog = shift;

  for (split ':', $ENV{PATH}) {
    if (-x "$_/$prog") {
      return "$_/$prog";
    }
  }
  return;
}
