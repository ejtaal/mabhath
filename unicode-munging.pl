#!/usr/bin/env perl

use strict;
use warnings;
use feature 'unicode_strings';
use utf8;
use Encode;
use open qw(:std :utf8);
#use Unicode::UCD 'charinfo';

use Unicode::UCD 'charinfo';
#use Encode 'decode_utf8';
binmode STDOUT, "utf8";


my @strings =
	(
		#"آخِرَ شَرْبةً تَشْرَبُها",
		#"اخر شربة تشربها",
		"آخِرَ شَرْبةً تَشْرَبُها ضَياحٌ؛ الضَّيَاحُ والضَّيْحُ",
		"\x{5fcd}ãκς,πμ,πλ+lsctzùïåé}àÀâÂäçéÉèÈêÊëîïôùÙûüÜがぎぐげご½",
		"أَبَدَ الآبِدِينَ, see أَبَدٌ ابر",
		#"",
		#"",
		#"",
		#"",
	);
		#"abcdefghijklmnopqrstuvwxyz"

#use Unicode::Diacritic 'Strip';
#
#foreach my $s (@strings) {
#	explain( "Strip diacritics:", $s, strip_diacritics( $s));
#}

use Unicode::Normalize; 
 
foreach my $s (@strings) {
	#my $s2 = decode('UTF-8', $s);
	my $s2 = $s;
	$s2 = NFD($s2);
	$s2 =~ s/\pM//og;
	explain( "decode NFD:", $s, $s2);
}

foreach my $s (@strings) {
	#my $s2 = decode('UTF-8', $s);
	my $s2 = $s;
	$s2 = NFKD($s2);
	$s2 =~ s/\pM//og;
	explain( "decode NFKD:", $s, $s2);
}

### The next two are utter garbage in the year of writing (2012 C.E.)
#use Text::Unaccent;
#foreach my $s (@strings) {
#	explain( "Unaccent:", $s, unac_string('UTF-8', $s));
#}
#
#foreach my $s (@strings) {
#	explain( "Strip diacritics:", $s, strip_diacritics2( $s));
#}

# Taken from: http://www.perlmonks.org/?node_id=713297
print "== For any UTF8 string, we have four \"lengths\":\n";

foreach my $s (@strings) {
	explain( "1a. the length in codepoints i.e. length():", $s, length( $s));
	$s =~ s/\pM//og;
	explain( "1b. the length in codepoints after stripping Unicode Marks i.e. =~ s/\pM//og; length():", $s, length( $s));
}

foreach my $s (@strings) {
	explain( '2a. the length in graphemes (the "a" is one, the composing "~" is another) i.e. length( NFD $_)', $s, length( NFD($s)));
	my $s2 = NFD($s);
	$s2 =~ s/\pM//og;
	explain( '2b. length of the NFD string stripped of Unicode Mark properties i.e. length( NFD $_ = s/\pM//og)', $s, length( $s2));
	#explain( '2b. length of the NFD string stripped of Unicode Mark properties i.e. length( NFD $_ = s/\pM//og)', $s, length( $s2));
#	explain( '2b. length of the NFD string stripped of Unicode Mark properties i.e. length( NFD $_ = s/\pM//og)', $s, length( $s2) s/\pM//og));
#	explain( '2b. the length in graphemes (the "a" is one, the composing "~" is another) i.e. length( NFKD $_)', $s, length( NFKD($s)));
#	explain( '2c. the length in graphemes (the "a" is one, the composing "~" is another) i.e. length( NFC $_)', $s, length( NFC($s)));
#	explain( '2d. the length in graphemes (the "a" is one, the composing "~" is another) i.e. length( NFKC $_)', $s, length( NFKC($s)));
}

#use Text::CharWidth;
#use Text::CharWidth=mbswidth;
use Text::CharWidth qw(mbwidth mbswidth mblen);

foreach my $s (@strings) {
	explain( "3. the length in columns of text used (the string has one wide character): i.e. Text::CharWidth mbswidth()", $s, mbswidth( $s));
}

foreach my $s (@strings) {
	use bytes;
	explain( "4. the length in bytes of the string i.e. use bytes; length():", $s, length( $s));
}

print "\n\n==== Regular expression properties: ===\n\n";
#my @matches =
#	(
#		'[^\p{Arabic}]',
#		'[^\p{M}]',
#		'[^\p{L}]'
#		#"",
#		#"",
#	);
my @matches =
	(
		'\p{Arabic}',
		'\p{M}',
		'\p{L}'
		#"",
		#"",
	);

foreach my $m (@matches) {
	foreach my $s (@strings) {
		my $r = $s;
		my $e = qr/$m/;
		#$r =~ s/$e//g;
		$r =~ s/($e)/>$1/g;
		print "match: $m, string: $s\nresult: $r\n\n";
	}
}


sub explain {
	my ($a, $b, $c) = @_;
	#print "\n";
	print "==== $a ====\n";
	print "string:\t$b\n";
	print "result:\t$c\n";
}

# -- Next bit taken from http://www.lemoda.net/perl/strip-diacritics/index.html
# Alas, this only works for western/eastern diacritics, not on arabic vowels...

# Remove diacritics from the text.

sub strip_diacritics2
{
    my ($diacritics_text) = @_;
    my @characters = split '', $diacritics_text;
    for my $character (@characters) {
        # Reject non-word characters
        next unless $character =~ /\w/;
        my $decomposed = decompose ($character);
        if ($character ne $decomposed) {
            # If the character has been altered, highlight and add a
            # mouseover showing the original character.
#           $character =
#               "<span title='$character' style='background-color:yellow'>".
#                   "$decomposed</span>";
        }
    }
    my $stripped_text = join '', @characters;
    return $stripped_text;
}

# Decompose one character. This is the core part of the program.

sub decompose
{
    my ($character) = @_;
    # Get the Unicode::UCD decomposition.
    my $charinfo = charinfo (ord $character);
    my $decomposition = $charinfo->{decomposition};
    # Give up if there is no decomposition for $character
    return $character unless $decomposition;
    # Get the first character of the decomposition
    my @decomposition_chars = split /\s+/, $decomposition;
    $character = chr hex $decomposition_chars[0];
    # A character may have multiple decompositions, so repeat this
    # process until there are none left.
    return decompose ($character);
}
