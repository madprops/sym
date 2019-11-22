sudo cp bin/sym-release-linux /bin/sym
echo "Binary placed in /bin"

sudo cp sym_autocomplete /etc/bash_completion.d/sym_autocomplete
echo "Autocompletion module placed in /etc/bash_completion.d"

if [[ -d ~/.config/sym ]]
then
    :
else
    mkdir ~/.config/sym
    cp db.json ~/.config/sym/db.json
    cp db.json ~/.config/sym/db_backup.json
    echo "Files placed in ~/.config/sym"
fi

echo "Done."