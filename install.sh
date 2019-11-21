sudo cp bin/sym /bin/sym

echo "Binary placed in /bin/sym"

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