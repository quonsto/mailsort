#!/usr/bin/perl -p 

my ( $id ) = ( /^(\S+)/ ); 
$previd = $id and next unless defined $previd; 
$pat = "\Q$previd\E"; 
s/$pat/@{[" " x length( $previd)]}/g; 
$previd = $id
