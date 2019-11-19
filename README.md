Example usage:

```
gat books /home/me/books
gat books ../story.txt
gat movies ~/movies
gat movies ~/movies/trailers
gat remove movies re:mov
gat list books
gat remove 13
```

And with the provided shell script
```
gato 22
This will cd to whatever path is id:22
```

Ids are incremental, each path gets one automatically.

Removing a path doesn't decrease the id counter.

Using 'clear' to remove all tags resets the id to 0.

![](http://i.imgur.com/h6F5ZVI.jpg)