@echo off
set fconf=ftp.cfg
set get_file=1.test
echo open 10.25.98.66>"%fconf%"
echo ftp>>"%fconf%"
echo ftp>>"%fconf%"
echo bin >>"%fconf%"
echo lcd E:\ >>"%fconf%"
echo get %get_file%>>"%fconf%"
echo bye >>"%fconf%"
ftp -s:"%fconf%"
del -s:"%fconf%"