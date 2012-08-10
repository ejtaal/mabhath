#!/bin/bash

SRC=/home/taal/projects/mabhath/source/
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
		converted="${i%%.doc}.soffice.txt"
		if [ -f "$converted" ]; then
			echo -n "(soffice cached) "
		else
			echo	soffice --headless --convert-to txt:text --outdir "$dir" "$i"
			soffice_output="${i%%.doc}.txt"
			mv -vf "$soffice_output" "$converted"
			echo -n "soffice done. "
		fi
		echo conversions done.
	done
		
	if [ -f "$filter" ]; then
		./$filter "$dir" "$OUT"
		echo done.
	fi
done
