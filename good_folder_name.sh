#!/bin/sh

perl -le '
	sub safe { my $a = $_[0]; $a =~ s/\+/+-/g; return $a }; 
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
	$folder_name = qq/'"$1"'/;
	#$folder_name =~ s/.*/@{[safe $&]}/g;
	$folder_name =~ s/(.*)/@{[dovecot2utf7 $1]}/g; 
	print $folder_name;
' | iconv -f utf-7 -t utf-8 #| iconv -f utf-7 -t utf-8
