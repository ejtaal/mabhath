#!/bin/bash

# This script requires the mabhath-data repository:
SOURCEDIR="../mabhath-data/"

BOOKSDIR=books/
OUTDIR=roots/

PARSER=./parse-dictionary.pl

for dir in $BOOKSDIR/*; do
	if [ ! -d "$dir" ]; then continue; fi
	echo "==>> Processing '$dir' ..."
	book=$(basename "$dir")

	entryfile=$dir/entry.txt
	filter=$dir/filter.pl
	ignorefile=$dir/ignore.txt
	outdir="$SOURCEDIR/$book/out"
	filterdebugtxt="$outdir/filter-debug.txt"
	debugdir="/tmp/debug/$book"
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
		perl -C -Mutf8 -MEncode::Arabic::Buckwalter -p $filter | \
		tee $filterdebugtxt | \
		$PARSER $ignorefile	$entryfile $outdir > $debugtxt

	grep    "^e " $debugtxt          > $debugdir/entries.txt
	grep    "^E " $debugtxt          > $debugdir/double-entries.txt
	grep    "^e ([^01234]" $debugtxt > $debugdir/long-entries.txt
	grep    "^i " $debugtxt          > $debugdir/ignored.txt
		
done

exit 0


SRC="$(dirname $0)/source/"
OUT=/mnt/ramfs/mabhath/
cd $SRC || exit 1

for dir in `find * -type d`; do
	if [ ! -d "$dir" ]; then continue; fi
	# Now we're dealing with directories only

	echo "==>> Processing '$dir' ..."
	filter="$dir.filter.sh"
	
	for i in "$dir"/*.doc; do
		if [ ! -f "$i" ]; then continue; fi

		converted="${i%%.doc}.abiword.txt"
		echo -en "\t$i -> $converted ... "
		#converted="${i%%.doc}.catdoc.txt"
		# Double the indentation since it's unicode
		#catdoc -m 144 "$i" > "$converted" 
		#catdoc -w "$i" > "$converted" 
		if [ -f "$converted" ]; then
			echo -n "(abiword cached) "
		else
			abiword --to=txt -o "$converted" "$i"
			echo -n "abiword done. "
		fi
#		converted="${i%%.doc}.soffice.txt"
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
		
	if [ -f "$filter" ]; then
		./$filter "$dir" "$OUT"
		echo done.
	fi
done
