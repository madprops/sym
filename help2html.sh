script -c 'sym' -q help.tscript
cat help.tscript | aha > docs/index.html
rm help.tscript