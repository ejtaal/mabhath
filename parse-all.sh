#!/bin/bash

pushd $(dirname $0)

# This script requires the mabhath-data repository:
SOURCEDIR="../mabhath-data/"

BOOKSDIR=books/
OUTDIR=$SOURCEDIR/text/

PARSER=./parse-dictionary.pl

if [ -n "$*" ]; then
	books="$BOOKSDIR/$1"
else
	books=$BOOKSDIR/*
fi

for dir in $books; do
	if [ ! -d "$dir" ]; then continue; fi

	echo "==>> Processing '$dir' ..."
	book=$(basename "$dir")

	entryfile=$dir/entry.txt
	filter=$dir/filter.pl
	ignorefile=$dir/ignore.txt
	bookname=$(grep -h -m 1 book: $entryfile | awk '{ print $3 }')
	#outdir="$SOURCEDIR/$book/out"
	outdir="$OUTDIR/$bookname"
	debugdir="/tmp/debug/$book"
	debugdir="$SOURCEDIR/$book/debug"
	debugtxt="$debugdir/debug.txt"

	mkdir -p "$outdir" $debugdir
	
	for i in "$SOURCEDIR/$book/in"/*.doc; do
		if [ ! -f "$i" ]; then continue; fi
		
		converted="${i%%.doc}.abiword.txt"
		echo -en "\t$i -> $converted ... "
		
		### Converting doc -> txt using catdoc 
		#converted="${i%%.doc}.catdoc.txt"
		# Double the indentation since it's unicode
		#catdoc -m 144 "$i" > "$converted" 
		#catdoc -w "$i" > "$converted" 
		
		### Converting doc -> txt using AbiWord
		if [ -f "$converted" ]; then
			echo -n "(abiword cached) "
		else
			abiword --to=txt -o "$converted" "$i"
			echo -n "abiword done. "
		fi

		### Converting doc -> txt using OpenOffice
#		converted="${i%%.doc}.soffice.txt
#		if [ -f "$converted" ]; then
#			echo -n "(soffice cached) "
#		else
#			echo	soffice --headless --convert-to txt:text --outdir "$dir" "$i"
#			soffice_output="${i%%.doc}.txt"
#			mv -vf "$soffice_output" "$converted"
#			echo -n "soffice done. "
#		fi
		echo conversions done.
	done
		
	time pv "$SOURCEDIR/$book/in"/*.txt | \
		perl -Mutf8 -MEncode::Arabic::Buckwalter -p $filter | \
		tee $debugdir/filter-debug.txt | \
		$PARSER $ignorefile	$entryfile $outdir $bookname > $debugtxt

		#perl -C -Mutf8 -MEncode::Arabic::Buckwalter -p $filter | \
	grep    "^e " $debugtxt          > $debugdir/entries.txt
	grep    "^E " $debugtxt          > $debugdir/double-entries.txt
	grep    "^e ([^01234]" $debugtxt > $debugdir/long-entries.txt
	grep    "^i " $debugtxt          > $debugdir/ignored.txt
	grep    "^s " $debugtxt      | tee $debugdir/stats.txt
		
done

./gather-indexes.sh

popd
