script -c 'sym' -q help.tscript
cat help.tscript | sed '1d;$d' | aha > docs/index.html
rm help.tscript