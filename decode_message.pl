#!/usr/bin/env -S perl -pw

use strict;
use MIME::Base64 qw/decode_base64/;

use vars qw/%DECODERS/; BEGIN {

  %DECODERS = (
    "B" => \&decode_base64,
  );

}

sub decode( $ )
{
  my ( $encoded ) = @_;
  ( $encoded =~ /=\?([^?]+)\?(.)\?([^?]+)\?=/ ) or return $encoded;
  my ( $format, $message ) = ( $2, $3 );
  return $encoded unless exists $DECODERS{$format};
  return $DECODERS{$format}->( $message);
}

use vars qw/$HEADERS_MODE/; BEGIN {
  $HEADERS_MODE=1;
}

next unless $HEADERS_MODE;
$HEADERS_MODE = 0 if /^$/;
print "\n" if /^$/;

chomp;

s/=\?([^?]+)\?(.)\?([^?]+)\?=/@{[decode($&)]}/g;

#s/^Subject: \*\*SPAM\*\*/Subject: /g;

$. == 1 or s/^\t// or s/^/\n/;
