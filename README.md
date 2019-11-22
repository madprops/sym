## Symlink creator and manager

### This has been tested on Linux only.

Example usage to create an item:
```
sym movies ~/media/movies entertainment videos
This creates an item called movies.
Associated with the provided path.
And 2 tags were added to it.
This will create a symlink: ~/sym/movies
It will also create tag symlinks:
~/sym/tags/entertainment/movies
and ~/sym/tags/videos/movies
These 3 symlinks point to the same path.
You can do for instance 'ls ~/sym/movies'
And it will show the contents of
~/media/movies
```

## [Full Documentation Here](https://madprops.github.io/sym/)