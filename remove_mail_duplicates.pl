#!/usr/bin/perl -wn

use strict;

our ( $PREVMSGID, $PREVFILESIZE, $PREFMESSAGEDATE ) = ( "", -1, "" ); 

my ( $msgid, $filename ) = ( /^(\S+): (.*)/ );
if ( $msgid eq $PREVMSGID ) 
{ 
	my $fsize = -s $filename;
	if ( $fsize ne $PREVFILESIZE ) 
	{ 
		my $date = message_date_from_file_name( $filename);
		if ( $date ne $PREFMESSAGEDATE ) 
		{
			accumulate
}
	process_accumulated_data(); next 
