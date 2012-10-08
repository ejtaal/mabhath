#!/bin/sh

DIR="$1"
OUT_DIR="$2/$1"

BASE=$(dirname $0)
parser=$BASE/../parse-dictionary.pl

mkdir -p "$OUT_DIR"

# First deal with Lane's Lexicon
# echo test123456789test | perl -pi -e 's|(test)(.*?)(test)|{ $a = $2; $a =~ tr/368/KLM/; print "<<< $1$a$3 >>>"; }|gie; exit 0;'

# De-Buckwalter-ize the xml:
time pv "$DIR"/Arabic/Lane/opensource/*xml | \
	perl -MEncode::Arabic::Buckwalter -pe \
'
	# s#A\^#آ#g;
	# s#w\^#آ#g;
	# s#y\^#آ#g;
	# s#\^#''#g;
	s#\^##g;
	s#@#o#g;
	s#<hi rend="ital" TEIform="hi">(.*?)</hi>#<i>$1</i>#gi;
	s#<orth orig="" extent="full" lang="ar">(.*?)</orth>#{ encode "utf8", decode "buckwalter", $1; }#gei;
	s#<orth orig="" extent="full" lang="ar">(.*?)</orth>#{ encode "utf8", decode "buckwalter", $1; }#gei;
	s#<orth extent="full" lang="ar">(.*?)</orth>#{ encode "utf8", decode "buckwalter", $1; }#gei;
	s#(<div2 n=")([^"]*?)(" type="root" org="uniform" sample="complete" part="N" TEIform="div2">)#{ print $1; print encode "utf8", decode "buckwalter", $2; print $3; }#gei;
	s#(<div2 type="root" part="N" n=")([^"]*?)(" org="uniform")#{ print $1; print encode "utf8", decode "buckwalter", $2; print $3; }#gei;
	s#(<entryFree id="n\d+" key=")([^"]*?)(" type="main">)#{ print $1; print encode "utf8", decode "buckwalter", $2; print $3; }#gei;
	s#(<div1 part="N" n=")([^"]*?)(")#{ print $1; print encode "utf8", decode "buckwalter", $2; print $3; }#gei;
	s#<foreign lang="ar" TEIform="foreign">(.*?)</foreign>#{ encode "utf8", decode "buckwalter", $1; }#gei;
	s#<orth[^>]*? lang="ar">(.*?)</orth>#{ encode "utf8", decode "buckwalter", $1; }#gei;
	# s#=#آ#g;
		' | \
		tee "$DIR"/perseus-tufts-lane-opensource-debuckwalterized.xml \
		| $parser $BASE/$DIR.ignore.conf $BASE/$DIR.entry.conf $OUT_DIR  > \
			$OUT_DIR/debug.txt

cd $OUT_DIR

#grep -v "^e " debug.txt | grep '@' > weird-entries.txt
grep    "^e " debug.txt > entries.txt
grep    "^E " debug.txt > double-entries.txt
grep    "^e ([^01234]" debug.txt > long-entries.txt
grep    "^i " debug.txt > ignored.txt
echo 'register_dictionary( a, "LL", "Lane''s Lexicon", "ll", "Text provided by Perseus Digital Library, with funding from The U.S. Department of Education and The Max Planck Society.");' \
	>> js-script.js
