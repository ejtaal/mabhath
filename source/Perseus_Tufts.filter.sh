#!/bin/sh

DIR="$1"
OUT_DIR="$2/$1"

BASE=$(dirname $0)
parser=$BASE/../parse-dictionary.pl


# First deal with Lane's Lexicon

# De-Buckwalter-ize the xml:
time pv "$DIR"/Arabic/Lane/opensource/*xml | \
	perl -pe 's#A\^#>#g' | \
	perl -pe 's#w\^#&#g' | \
	perl -pe 's#y\^#}#g' | \
	perl -pe 's#\^#''#g' | \
	perl -MEncode::Arabic::Buckwalter -pe \
		's#<hi rend="ital" TEIform="hi">(.*?)</hi>#<i>$1</i>#gi' | \
	perl -MEncode::Arabic::Buckwalter -pe \
		's#<orth orig="" extent="full" lang="ar">(.*?)</orth>#{ encode "utf8", decode "buckwalter", $1; }#gei' | \
	perl -MEncode::Arabic::Buckwalter -pe \
		's#<orth orig="" extent="full" lang="ar">(.*?)</orth>#{ encode "utf8", decode "buckwalter", $1; }#gei' | \
	perl -MEncode::Arabic::Buckwalter -pe \
		's#<orth extent="full" lang="ar">(.*?)</orth>#{ encode "utf8", decode "buckwalter", $1; }#gei' | \
	perl -MEncode::Arabic::Buckwalter -pe \
		's#(<div2 n=")([^"]*?)(" type="root" org="uniform" sample="complete" part="N" TEIform="div2">)#{ print $1; print encode "utf8", decode "buckwalter", $2; print $3; }#gei' | \
	perl -MEncode::Arabic::Buckwalter -pe \
		's#(<entryFree id="n\d+" key=")([^"]*?)(" type="main">)#{ print $1; print encode "utf8", decode "buckwalter", $2; print $3; }#gei' | \
	perl -MEncode::Arabic::Buckwalter -pe \
		's#<foreign lang="ar" TEIform="foreign">(.*?)</foreign>#{ encode "utf8", decode "buckwalter", $1; }#gei' | \
	perl -MEncode::Arabic::Buckwalter -pe \
		's#<orth[^>]*? lang="ar">(.*?)</orth>#{ encode "utf8", decode "buckwalter", $1; }#gei' | \
		cat > "$DIR"/perseus-tufts-lane-opensource-debuckwalterized.xml
#	perl -C -pe 's#ا^#أ#gi' | \
#	perl -C -pe 's#و^#ؤ#gi' | \
#	perl -C -pe 's#ي^#ئ#gi' | \
	

#mkdir -p "$OUT_DIR"

#	$parser $BASE/$DIR.ignore.conf $BASE/$DIR.entry.conf $OUT_DIR  > \
#		$OUT_DIR/debug.txt
#
#cd $OUT_DIR
#
#grep -v "^e " debug.txt | grep '@' > weird-entries.txt
#grep    "^e " debug.txt > entries.txt
#grep    "^E " debug.txt > double-entries.txt
#grep    "^e ([^01234]" debug.txt > long-entries.txt
#grep    "^i " debug.txt > ignored.txt
#
#
#echo 'register_dictionary( a, "LA", "Lisan ul Arab", "la", "Lisan ul Arab was written by ... etc.");' \
#	>> js-script.js
#
#
#EOF
