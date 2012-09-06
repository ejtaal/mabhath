#!/bin/sh

DIR="$1"
OUT_DIR="$2/$1"

mkdir -p "$OUT_DIR"

BASE=$(dirname $0)
parser=$BASE/../parse-dictionary.pl

time pv "$DIR"/*abiword.txt | \
	perl -C -Mutf8 -pi -e 's/^\@\n/\@/g; s/^\@ الباءُ\:/\@ب\:/' | \
	$parser $BASE/$DIR.ignore.conf $BASE/$DIR.entry.conf $OUT_DIR  > \
		$OUT_DIR/debug.txt

cd $OUT_DIR

grep -v "^e " debug.txt | grep '@' > weird-entries.txt
grep    "^e " debug.txt > entries.txt
grep    "^E " debug.txt > double-entries.txt
grep    "^e ([^01234]" debug.txt > long-entries.txt
grep    "^i " debug.txt > ignored.txt


echo 'register_dictionary( a, "LA", "Lisan ul Arab", "la", "Lisan ul Arab was written by ... etc.");' \
	>> js-script.js


EOF
