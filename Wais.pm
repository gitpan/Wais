#                              -*- Mode: Perl -*- 
# Wais.pm -- 
# ITIID           : $ITI$ $Header $__Header$
# Author          : Ulrich Pfeifer
# Created On      : Tue Dec 12 08:55:26 1995
# Last Modified By: Ulrich Pfeifer
# Last Modified On: Mon Feb  3 16:35:55 1997
# Language        : Perl
# Update Count    : 149
# Status          : Unknown, Use with caution!
# 
# (C) Copyright 1995, Universität Dortmund, all rights reserved.
# 
# $Locker: pfeifer $
# $Log: Wais.pm,v $
# Revision 2.1.1.10  1997/02/03 15:29:51  pfeifer
# patch2: fix from Norbert Goevert to allow for failing connections

package Wais;
require 5.003;

require DynaLoader;

@ISA = qw(DynaLoader);

$timeout  = 120;
$maxnumfd = 10;

# Preloaded methods go here.

$VERSION = '2.202';
bootstrap Wais $VERSION;

use IO::Socket;
use IO::Select;
use vars qw($CHARS_PER_PAGE); # make strict happy
use Carp;

sub Search {
  my(@requests) = @_;
  my $missing = 0;                        # number of answers missing
  my $header  = '';                       # last read message header
  my $message = '';                       # last read message
  my $request;                            # current request
  my $select = IO::Select->new();         # open sockets 
  my $result;                             # references to results
  my ($timeleft) = $Wais::timeout;
  my %known_tags;                         # tags -> 1
  my %local;                              # local requests
  my %pending;                            # requests still to send
  my %fh;                                 # tag -> filehandle
  my %tag;                                # filehandle -> tag
  
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
      my $fh;
      
      # make sure that tag is unique
      $tag++ while defined($known_tags{$tag}); $known_tags{$tag} = 1;
      
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
          # We have a connection already.
          # Postpone sending until answer for first request is arived
          $pending{$fh}->{$tag} = $apdu;
        } else {
          # Open a connection to peer
          $fh = new IO::Socket::INET(PeerAddr => $host,
                                     PeerPort => $port,
                                     Proto    => 'tcp',
                                     Type     => SOCK_STREAM);
          # croak "Could not connect to $host:$port" unless $fh;
          if ($fh) {
            $fh->autoflush(1);
            $fh{$host.':'.$port} = $fh;
            # remember $tag for $fh
            $tag{$fh} = $tag;
            $fh->print($apdu);              # send the request
            $select->add($fh);
            $missing++;
          } else {
            $result->add_diag($tag, '', "Could not connect to $host:$port");
          }
        }
      }
    } else {
      croak "Usage: Wais::Search([query, database, host, port], ....)";
    }
  }

  # Answer local requests to give the remote servers time to process
  # requests.
  for (keys %local) {
    $message = local_answer($local{$_});
    if ($message) {
      $result->add($_, Wais::Search::new($message));
    }
  }

  while ( $missing > 0 and $timeleft > 0 ) {
    my $time = time;
    my @ready = $select->can_read($timeleft);
    my $fh;

    $timeleft -= (time - $time);          # adjust timeleft
    for $fh (@ready) {
      my $tag = $tag{$fh};
      my $header = '';
      
      $fh->read($header, 25);
      my $length = substr($header,0,10);
      $fh->read($message, $length);
      $missing--;
      $result->add($tag, Wais::Search::new($message));

      # check if we have pending requests for this $fh
      if (defined $pending{$fh}) {
        my ($tag) = keys %{$pending{$fh}};
        $fh->print($pending{$fh}->{$tag});
        $tag{$fh} = $tag;
        $missing++;
        delete $pending{$fh}->{$tag};
      } else {
        # we are done with this guy
        $fh->close;
      }
      last unless $missing;
    }
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
    $fh = new IO::Socket::INET(PeerAddr => $host,
                               PeerPort => 210,
                               Proto    => 'tcp',
                               Type     => SOCK_STREAM);
    croak "Could not connect to $host:$port" unless $fh;
    $fh->autoflush(1);
    
    while (1) {
      $apdu = &generate_retrieval_apdu($database, $docid, $type, $chunk++);
      $fh->print($apdu);                  # send the request
      $fh->read($header, 25);
      $length = substr($header,0,10);
      $fh->read($message, $length);
      $presult = &Wais::Search::new($message);
      $result->add('document', $presult);
      last if length($presult->text) != $Wais::CHARS_PER_PAGE;
    }
    $fh->close;
  }
  $result;
}

package Wais::Result;
use vars qw($VERSION);
{
  my $Revision = '';
  
  $VERSION = join '', q$Revision: 2.1.1.10 $ =~ /(\d+\.\d+)\.?(\d+)?\.?(\d+)?/;
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

sub add_diag {
  my $self = shift;
  my($tag, $code, $message) = @_;
  push(@{$self->{'diagnostics'}}, [$tag, $code, $message])
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
