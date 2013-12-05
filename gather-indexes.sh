#!/bin/sh

indexes=mr-mh-indexes.js

cat text/*/js-script.js > $indexes
cat text/*/all-roots.txt | sort | uniq | \
	awk 'BEGIN{printf "var all_roots=["}
		{ if ((NR % 10) == 0) printf("\n"); printf "\x27%s\x27,", $0}
		END{printf "];";}' | sed 's/,];/];\n/' >> $indexes
