#!/bin/sh

#IN=$(cat)
#if [ -z "$1" ] && [ "$1" = '-d' ]; then
	#python3 -c "import sys, urllib.parse as ul; \
    #print(ul.unquote_plus(sys.argv[1]))" "$IN"
#else
	#python3 -c "import sys, urllib.parse as ul; \
    #print (ul.quote_plus(sys.argv[1]))" "$IN"
#fi

od -t d1 | awk '{
      for (i = 2; i <= NF; i++) {
        printf(($i>=48 && $i<=57) || ($i>=65 &&$i<=90) || ($i>=97 && $i<=122) ||
                $i==45 || $i==46 || $i==95 || $i==126 ?
               "%c" : "%%%02x", $i)
      }
    }'
