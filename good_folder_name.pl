#!/usr/bin/perl -wl

use strict;

open my $iconv, "| iconv -f utf-7 -t utf-8" or die "Cannot start iconv: $!";
select $iconv;

sub safe { 
  my $a = $_[0];
  $a =~ s/\+/+-/g;
  $a =~ s/~/&AH4-/g; # to be fully compatible with utf-7
  return $a 
}; 
sub dovecot2utf7_actual { my $a = $_[0]; $a =~ s/&/+/g; $a =~ s/,/\//g; return $a };
sub dovecot2utf7 { 
  my $a = $_[0]; 
  $a =~ s/-([^&]*)&/-@{[safe $1]}&/g; 
  $a =~ s/^([^&]*)&/@{[safe $1]}&/g; 
  $a =~ s/-([^&]*)$/-@{[safe $1]}/g; 
  $a =~ s/^([^&]*)$/@{[safe $1]}/g; 
  $a =~ s/&[A-Za-z0-9+,]+-/@{[dovecot2utf7_actual $&]}/g; 
  return $a 
};

foreach my $folder_name (@ARGV) {
  $folder_name =~ s/(.*)/@{[dovecot2utf7 $1]}/g; 
  print $folder_name;
}

END { 
  close $iconv;
}
