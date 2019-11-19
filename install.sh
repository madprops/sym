sudo cp bin/gat /bin/gat

echo "Binary placed in /bin/gat"

if [[ -d ~/.config/gat ]]
then
    :
else
    mkdir ~/.config/gat
    cp db.json ~/.config/gat/db.json
    cp gato.sh ~/.config/gat/gato.sh
    echo "Files placed in ~/.config/gat"
fi

echo "Done."