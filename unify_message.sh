#!/bin/sh

decode_message.pl "$1" |
   perl -pe '
       s/^Subject: \*\*SPAM\*\*/Subject: /g;
       s/^Subject: :SPAM:/Subject: /g
   ' | 
   perl -ne '
       /boundary="(.*)"/ and $boundary = $1;
       $boundary and /^--$boundary--$/ and $tnef_mode = 0;
       print unless $tnef_mode;
       /^\s+filename="winmail.dat"$/ and $tnef_mode = 1;
   ' | 
   perl -ne '
       if ( /^$/ ) {
         $buffer .= $_;
       } else {
         print $buffer;
         $buffer = "";
         print;
       }
   '
