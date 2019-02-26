#!/bin/sh
# 
# 1. find *.c or *.h file from current directory
# 2. if the file is utf-8 encoded file, then convert it to cp936 encoded.
#
# it will replace the original file.
#
# Author: wangjinle
# Usage: utf8tocp936.sh
#

find ./ -name "*."[ch]  | while read fname                                                                                                                                   
do
    # echo "$fname";
    has_utf8=$(file "$fname" | grep "UTF-8")
    if [ -n "$has_utf8" ];then
        # echo $has_utf8
        iconv -f utf-8 -t cp936 "$fname" -o "$fname"
    fi
done
