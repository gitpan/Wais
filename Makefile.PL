######################### -*- Mode: Perl -*- #########################
##
## File             : Makefile.PL
##
## Description      : 
##
## Author           : Ulrich Pfeifer
## Created On       : Sun Sep 10 11:00:44 1995
##
## Last Modified By : Norbert Goevert
## Last Modified On : Tue Apr  7 14:17:59 1998
##
## $Id: Makefile.PL.sun4-solaris 1.3 Tue, 07 Apr 1998 16:34:24 +0200 goevert $
##
## $ProjectHeader: Wais 23.7 Tue, 07 Apr 1998 16:34:24 +0200 goevert $
######################################################################


use ExtUtils::MakeMaker;
use Config;


foreach (qw(waisserver waisindex)) {
  die "Could not find '$_' in your PATH\n" unless findbin($_);
}

&WriteMakefile
  (
   'PREREQ_PM'    => { IO::Select => 0 },
   'LIBS'         => "-L/app/unido-i06/share/db/wais/default/lib/sun4-solaris -lwais",
   'INC'          => "-DWAIS_USES_STDIO -I/app/unido-i06/share/db/wais/default/include/sun4-solaris",
   'NAME'         => 'Wais',
   'VERSION_FROM' => 'lib/Wais.pm',
   'DEFINE'       => '-DTRACE=0 -g',
   'OBJECT'       => "Wais.o HTWAIS.o dictionary.o",
   'PL_FILES'     => { 'inspect.PL' => 'inspect' },
   'dist'         => { SUFFIX   => 'gz',
                       COMPRESS => 'gzip -9f',
                       PREOP    => 'pod2text lib/Wais.pm > README; pod2text install > INSTALL',
                     },
   'clean' 	  => { FILES => '*~ inspect' },
   'MAP_TARGET'   => 'waisperl',
   'EXE_FILES'    => [ 'inspect' ],
  );


## ###################################################################
## subs
## ###################################################################

sub MY::postamble {
  
  my $self = shift;
  
  qq[
install :: register

register ::
\t] . $self->{NOECHO} . q[$(PERL) -I$(PERL_ARCHLIB) -I$(PERL_LIB) \
-e '    use Wais; ' \
-e '    use Config; ' \
-e '    eval "use Sys::Hostname; \\$$host = q[on ].hostname;";' \
-e '    $$address="wais\@ls6.cs.uni-dortmund.de";'	\
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
  
  foreach (split ':', $ENV{PATH}) {
    return "$_/$prog" if -x "$_/$prog";
  }
  
  return;
}
