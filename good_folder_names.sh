#!/bin/sh

perl -pe '
	sub safe { my $a = $_[0]; $a =~ s/\+/+-/g; return $a }; 
	sub dovecot2utf7_actual { my $a = $_[0]; $a =~ s/&/+/g; $a =~ s/,/\//g; return $a };
	sub dovecot2utf7 { my $a = $_[0]; $a =~ s/&[A-Za-z0-9+,]+-/@{[dovecot2utf7_actual $&]}/g; return $a };
	s/^(\S+\s+)(.*)/\1@{[dovecot2utf7 $2]}/g; 
	s/^\S+/@{[safe $&]}/g
' | iconv -c -f utf-7 -t utf-8
