#!/usr/bin/env perl

use strict;
use feature 'unicode_strings';
use utf8;
use Encode;
use open qw(:std :utf8);
use Unicode::UCD 'charinfo';
use HTML::Entities;

my $DEBUG = 1;
$DEBUG = 0;
use warnings;
no warnings;

my $ignorefile = $ARGV[0];
my $entryfile = $ARGV[1];
my $output_dir = $ARGV[2];
my $book = $ARGV[3];

if ( $ignorefile eq "" || $entryfile eq "" || $output_dir eq "") {
	print "\nUsage: cat aradocument.txt | $0 <ignorefile> <entryfile> <outputdir>\n";
	print "\n";
	print "\t<ignorefile> : regexps that if matched will be ignored\n";
	print "\t<entryfile>  : contains regexps that if matched will indicate the start of a new entry\n";
	print "\t<output_dir> : the dir in which files will be written to\n";
	print "\n";
	exit 1;
}

if ( ! -f $ignorefile) { print "File not found: $ignorefile\n"; exit 1; }
if ( ! -f $entryfile)  { print "File not found: $entryfile\n"; exit 1; }
if ( ! -d $output_dir)  { print "Dir not found: $output_dir\n"; exit 1; }

open IGNORE, "< $ignorefile";
open ENTRY, "< $entryfile";

my @ignores = grep {/^[^#;].+/} <IGNORE>;
my @entries = grep {/^[^#;].+/} <ENTRY>;
chomp( @ignores); chomp( @entries);

#while (<IGNORE>) { push @ignores, $_; }
## This will be an array of arrays
##while (<ENTRY>) { push @entries, split( $_, "|"); }
#while (<ENTRY>) { push @entries, $_); }

# Now we're ready to parse stdin against the loaded regexes
my $entry_found = 0;
#my @ci = map qr/$_/, @ignores;
my @ce = map qr/$_/, @entries;

my $last_entry = "";
my $entry = "";
my $line_no = 0;
my @entry_length; # = (0,0,0,0,0,0,0,0,0,0,0,0);
my %dict_entries;

LINE: while (<STDIN>) {
	my $line = $_;
	chomp( $line);
	$line_no++;
	my $line_no_fmt = sprintf "%06d", $line_no;
	#foreach my $pat (@ce) { print "BLAH" if /$pat/ };
	foreach my $re ( @ignores ) { 
		#if ($DEBUG) { print "regex: $re | line $line_no_fmt: $line\n"; }; 
		if ( $line =~ m/$re/u) { print "i $line_no_fmt: $line\n"; next LINE; } 
	}
	foreach my $re ( @entries) { 
	#foreach my $re ( @ce) { 
		if ( $line =~ m/$re/u) { 
			if ($DEBUG) { print "MATCH: regex: $re | line $line_no_fmt: $line\n"; }; 
			$entry = $1 . $2 . $3 . $4 . $5;
			$entry =~ s/^\s+(.*?)\s+$/$1/;
			# Remove diacritics (Unicode Mark properties) if any
			# Warn if found? No need I guess
			$entry =~ s/\pM//og;
			$entry =~ s/^\s*(.*?)\s*$/$1/;

			### Do we even want this normalization of hamzas? Will depend on other dictionary's contents
			### # Convert to only one type of hamza, not sure if this is the right one yet?
			$entry =~ s/[ﺁأإاﺍﺍاٰﺀﺀﺁﺃﺅﺇﺉ]/ا/gu;
			### $entry =~ s/[إا]/أ/g;

			my $le = sprintf "%01d", length $entry;

			if ( $entry eq $last_entry) {
				# Same entry encountered again
				print "E ($le)($entry) $line_no_fmt: $line\n";
				# This line should then be appended to the entry
				$dict_entries{$entry}{'text'} .= $line."\n";
				next LINE;
			} 
			else {
				# A genuine new entry
				# TODO: do a check if spaces were encountered
				$entry_length[$le]++;
				print "e ($le)($entry) $line_no_fmt: $line\n";
				$entry_found = 1; 
				$last_entry = $entry;
				$dict_entries{$entry}{'text'} = $line;
				next LINE;
			}
		}
	}
	if ( $entry_found == 1 ) {
		my $le = sprintf "%01d", length $entry;
		print "c ($le)($entry) $line_no_fmt: $line\n";
		$dict_entries{$last_entry}{'text'} .= $line."\n";
	}
	else { print "- $line_no_fmt: $line\n"; }
}

my $total_entries = 0;
print "s No. of entries found vs their lengths\n";
foreach my $l (keys @entry_length) {
	print "s l($l) = " . $entry_length[$l]."\n";
	$total_entries += $entry_length[$l];
}
print "s Total no. of entries: $total_entries\n";

#print "d: Dumping entries to files:\n";
use Term::ProgressBar;
my $pbar = Term::ProgressBar->new({count => scalar keys %dict_entries });
my $i = 0;
my $js_script = "var $book=[";
my $all_entries = "";
foreach my $entry_name ( sort keys %dict_entries) {
	my $output_subdir = $output_dir	. '/' . substr( $entry_name, 0, 1);
	my $output_path   = $output_subdir	. '/' . $entry_name .'.txt';
	mkdir "$output_subdir";
	#print "d: $entry_name -> $output_path\n";
	open ENTRY, "> $output_path";
	# JSONP-ify it:
	my $t = $dict_entries{$entry_name}{'text'};
	my $html = encode_entities( $t, '<>&"\'');
	$html =~ s/\n/<br>\\\n/g;
	my $file_contents = "load_data( { book: '$book', text: '$html' } );";
	print ENTRY $file_contents;
	close ENTRY;
	$js_script .= "\'$entry_name\',";
	if (++$i % 25 == 0) { 
		$pbar->update($i);
		$js_script .= "\n";
	};
	$all_entries .= "$entry_name\n";
}

print "Done.\n";

chop $js_script;
$js_script .= "];\n";
open  JS, "> $output_dir/js-script.js";
print JS $js_script;
close JS;

open  ALL, "> $output_dir/all-roots.txt";
print ALL $all_entries;
close ALL;
### Beware, there may be subroutines below! ###

