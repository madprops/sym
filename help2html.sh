script -c 'sym' -q help.tscript
cat help.tscript | sed '1d;$d' | aha --title sym > docs/index.html
rm help.tscript