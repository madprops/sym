## Symlink creator and manager

Example usage to create an item:
```
  gat movies ~/media/movies entertainment videos.
  This creates an item called movies.
  Associated with the provided path.
  And 2 tags were added to it.
  This will create a symlink: ~/gat/movies
  It will also create tag symlinks:
  ~/gat/tags/entertainment/movies
  and ~/gat/tags/videos/movies
  These 3 symlinks point to the same path.
  You can do for instance 'ls ~/gat/movies'
  And it will show the contents of
  ~/media/movies
```    
Remove an item:
```
  gat remove movies
```    
Remove an item by path:
```
  gat removepath /media/movies
  or regex...
  gat removepath re:\\w+
```    
Rename an item:
```
  gat rename movies moviez
```    
Add a tag:
```
  gat tag movies art
```    
Remove a tag:
```
  gat removetag movies art
  or regex...
  gat remove re:\\d+
```
List items:
```
  gat list
```
List tags:
```
  gat tags
``` 
List paths associated with a tag:
```
  gat tag funny
``` 
Change the path of an item:
```
  gat changepath movies /media/movies
```
Open a path in the file manager:
```
  gat open movies
```