#                              -*- Mode: Perl -*- 
# Wais.pm -- 
# ITIID           : $ITI$ $Header $__Header$
# Author          : Ulrich Pfeifer
# Created On      : Tue Dec 12 08:55:26 1995
# Last Modified By: Ulrich Pfeifer
# Last Modified On: Mon Aug  5 18:17:12 1996
# Language        : Perl
# Update Count    : 109
# Status          : Unknown, Use with caution!
# 
# (C) Copyright 1995, Universität Dortmund, all rights reserved.
# 
# $Locker: pfeifer $
# $Log: Wais.pm,v $
# Revision 2.1.1.7  1996/08/01 18:11:40  pfeifer
# patch14:
#
# Revision 2.1.1.6  1996/07/22 15:40:36  pfeifer
# patch13:
#
# Revision 2.1.1.5  1996/07/16 16:39:13  pfeifer
# patch10:
#
# Revision 2.1.1.4  1996/04/30 07:45:40  pfeifer
# patch9: Added $VERSION for Wais::Result to make CPAN happy.
#
# Revision 2.1.1.3  1996/03/01 14:36:03  pfeifer
# patch6: 'use vars' form some chat2.pl variables removed.
#
# Revision 2.1.1.2  1996/02/27 18:41:59  pfeifer
# patch5: Sort headlines when merging.
# patch5: Diagnostics are now saved as it should be.
#
# Revision 2.1  1995/12/13  14:52:30  pfeifer
# *** empty log message ***
#
# Revision 2.0.1.9  1995/12/13  08:30:06  pfeifer
# patch14: Added Retrieve().
#
# Revision 2.0.1.8  1995/12/12  11:46:18  pfeifer
# patch13: Parallel search works.
#
# 

package Wais;

require DynaLoader;

@ISA = qw(DynaLoader);

$timeout  = 120;
$maxnumfd = 10;

# Preloaded methods go here.

$Wais::VERSION = 2.115;
bootstrap Wais $VERSION;
require 'chat2.pl';

# make strict happy

@we_know = ($chat::debug, $chat::family,
            $chat::nfound, $chat::thisbuf, $chat::thishost,
            $chat::timeleft, $CHARS_PER_PAGE);
@we_know = ();                  # will be 'use vars' some day :-)

use Carp;

# Preloaded methods go here.
# use strict;

sub Search {
    my(@requests) = @_;
    # Strict comlains about the following not initialized
    my $rmask   = '';                     # mask of all filedescriptors
    my $missing = 0;                      # number of answers missing
    my $header  = '';                     # last read message header
    my $message = '';                     # last read message
    my($request,                          # current request
       $length,                           # length of the answer
       @fh,                               # fd -> fh
       %fh,                               # host:port -> filehandles
       $fh,                               # current fh
       @fno,                              # filedescriptors
       $fno,                              # current fd
       $cmask,                            # mask of fds ready for reading
       $nfound,                           # number of fds ready for reading
       @ready,                            # array of fds ready for reading
       $next,
       %pending,                          # requests still to send
       %local,                            # local requests
       @tags,                             # fd -> tags
       %tags,                             # tags -> 1
       $tag,                              # current tag
       $con);
    my $result;      # references to results
    my ($timeleft) = $Wais::timeout;

    if ($#requests > $Wais::maxnumfd-1) {

        # We assume worst case here. We may need less fds since local
        # searches do not count and some databases may be reached with
        # the same fd.
        $result    = Search($requests[$Wais::maxnumfd .. $#requests]);
        $#requests = $Wais::maxnumfd-1;
    } else {
        $result = new Wais::Result;  
    }

    for $request (@requests) {
        if (ref($request)) {
            my $query    = $request->{'query'};
            my $database = $request->{'database'};
            my $host     = $request->{'host'} || 'localhost';
            my $port     = $request->{'port'} || 210;
            my $tag      = $request->{'tag'}  || $request->{'database'};
            my $docids   = $request->{'relevant'};
            my $apdu;
            my ($fh, $fno);

            # make sure that tag is unique
            $tag++ while defined($tags{$tag});
            $tags{$tag} = 1;

            if (ref($docids)) {
                $apdu = generate_search_apdu($query, $database, $docids);
            } else {
                $apdu = generate_search_apdu($query, $database);
            }

            if (($host eq 'localhost') && (-e "$database.src")) {
                # We will handle local searches when as many as possible
                # remote requests have been send.
                $local{$tag} = $apdu;
            } else {
                if ($fh{$host.':'.$port}) { 
                    # We have a connection already
                    $fh   = $fh{$host.':'.$port};
                    $fno  = fileno('chat::'.$fh);
                    # postpone sending until answer for first request is arived
                    $pending{$tag} = $apdu;
                } else {
                    $fh = &chat::open_port($host, $port || 210);
                    $fh{$host.':'.$port} = $fh;
                    croak "chat::open_port failed" unless $fh;
                    &chat::print($fh, $apdu); # send the request
                    $fno  = fileno('chat::'.$fh);
                    $fh[$fno] = $fh;
                    $missing++;               # expect one more answer
                    vec($rmask,$fno,1) = 1;   # set corresponding bit in mask
                }
                # remember that tag is processed on $fno
                push(@{$tags[$fno]}, $tag);   
            }
        } else {
            croak "Usage: Wais::Search([query, database, host, port], ....)";
        }
    }
    for (keys %local) {
        $message = local_answer($local{$_});
        if ($message) {
            $result->add($_, Wais::Search::new($message));
        }
    }
    while ( $missing > 0 and $timeleft > 0 ) {
        ($nfound, $timeleft) = select($cmask = $rmask, undef, undef, $timeleft);
        if ($nfound) {
            @ready = split(//, unpack("b*", $cmask));
            for $fno (0 .. $#ready) {
                if ($ready[$fno]) {         # $fd ready for reading
                    $fh = $fh[$fno];
                    *S = 'chat::'.$fh;            
                    $tag = shift(@{$tags[$fno]});
                    $next = $tags[$fno]->[0];
                    if ($next) {          # more requests for $fd
                        &chat::print($fh, $pending{$next});
                        $missing++;               # expect one more answer
                    }
                    last;
                }
            }
            read(S, $header, 25);               # should use sysread here ...
            $length = substr($header,0,10);
            read(S, $message, $length);          # should use sysread here ...
            $missing--;
            $result->add($tag, Wais::Search::new($message));
            last unless $missing;
        }
    }
    for (@fh) {
      &chat::close($_) if $_;             # will close some con multiple times
    }

    return($result);
}

sub Retrieve {
    my %par = @_;
    my $database = $par{'database'};
    my $host     = $par{'host'} || 'localhost';
    my $port     = $par{'port'} || 210;
    my $chunk    = $par{'chunk'}|| 0;
    my $docid    = $par{'docid'};
    my $type     = $par{'type'} || 'TEXT';
    my $message  = '';
    my $header   = '';
    my ($fh, $length);
    my $apdu; 
    my $result   = new Wais::Result('type' => $type);
    my $presult;

    if (($host eq 'localhost') && (-e "$database.src")) {
        while (1) {
            $apdu = &generate_retrieval_apdu($database, $docid, $type, $chunk++);
            $message = local_answer($apdu);
            last unless $message;
            $presult = &Wais::Search::new($message);
            $result->add('document', $presult);
            last if length($presult->text) != $Wais::CHARS_PER_PAGE;
        }
    } else {
        $fh = &chat::open_port($host, $port || 210);
        croak "chat::open_port failed" unless $fh;
        *S = 'chat::'.$fh;
        while (1) {
            $apdu = &generate_retrieval_apdu($database, $docid, $type, $chunk++);
            &chat::print($fh, $apdu); # send the request
            read(S, $header, 25);
            $length = substr($header,0,10);
            read(S, $message, $length);
            $presult = &Wais::Search::new($message);
            $result->add('document', $presult);
            last if length($presult->text) != $Wais::CHARS_PER_PAGE;
        }
        &chat::close($fh);
    }
    $result;
}

package Wais::Result;
use vars qw($VERSION);
{
  my $Revision = '';
  
  $VERSION = join '', q$Revision: 2.1.1.7 $ =~ /(\d+\.\d+)\.?(\d+)?\.?(\d+)?/;
}
sub new {
    my $type = shift;
    my %par  = @_;
    my $self = {'header' => [], 'diagnostics' => [], 'text' => '', 
                'type'   => $par{'type'}};

    bless $self, $type;
}

sub add {
    my $self = shift;
    my ($tag, $result)  = @_;

    if ($result) {
        if (ref($result)) {
            my @result;
            my @left  = @{$self->{'header'}};
            my @right = $result->header;
            while (($#left >= $[) or ($#right >= $[)) {
                if ($#left < $[) {
                    for (@right) {
                        push @result, [$tag, @{$_}];
                    }
                    last;
                }
                if ($#right < $[) {
                    push @result, @left;
                    last;
                }
                if ($left[0]->[1] > $right[0]->[0]) {
                    push @result, shift @left;
                } else {
                    push @result, [$tag, @{shift @right}];
                }
            }
            $self->{'header'} = \@result;
            my %diag = $result->diagnostics;
            for (keys %diag) {
                push(@{$self->{'diagnostics'}}, [$tag, $_, $diag{$_}]);
            }
            if ($result->text) {
                $self->{'text'} .= $result->text;
            }
        } else {
            push(@{$self->{'diagnostics'}}, [$tag, 'Wais::Result::add No reference']);
        }
    } else {
        push(@{$self->{'diagnostics'}}, [$tag, 'Wais::Result::add No result']);
    }
    $self;
}

sub diagnostics {
    my $self = shift;

    @{$self->{'diagnostics'}};
}

sub header {
    my $self = shift;

    @{$self->{'header'}};
}

sub text {
    my $self = shift;

    $self->{'text'};
}

1;
