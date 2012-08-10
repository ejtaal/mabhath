#!/usr/bin/env perl

use strict;
my $DEBUG = 1;

if ($DEBUG) {
	my $s = "bl(.*?)oop";
	my $c = qr/$s/;
	my $l = "bin:blah:bloop:bling";
	if ( $l =~ m/$s/){ print "test1 [$1]\n"; }
	if ( $l =~ m/$c/){ print "test2 [$1]\n"; }
	if ( $l =~ /$c/){ print "test3 [$1]\n"; }
	if ( $l =~ /$s/){ print "test4 [$1]\n"; }
	#exit 9
}
