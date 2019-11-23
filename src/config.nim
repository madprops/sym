import nap

type Config* = object
  tail*: seq[string]
  dev*: bool
  force*: bool

var conf*: Config

proc get_config*() =

  add_example(title="Create an item", content=
"""
sym add movies ~/media/movies media videos.
#This creates an item called movies.
#Associated with the provided path.
#And 2 tags were added to it.
#This will create a symlink: ~/sym/movies
#It will also create tag symlinks:
#~/sym/tags/entertainment/movies
#and ~/sym/tags/videos/movies
#These 3 symlinks point to the same path.
#You can do for instance 'ls ~/sym/movies'
#And it will show the contents of
#~/media/movies""")
    
  add_example(title="Remove an item", content=
"""
sym remove movies
#or regex...
sym remove re:\\w+""")
    
  add_example(title="Remove an item by path", content=
"""
sym removepath /media/movies
#or regex...
sym removepath re:\\w+""")
    
  add_example(title="Rename an item", content=
"""sym rename movies moviez""")
    
  add_example(title="Add a tag", content=
"""sym tag movies art""")
    
  add_example(title="Remove a tag", content=
"""sym removetag movies art""")
    
  add_example(title="List items", content=
"""sym list""")
    
  add_example(title="List tags", content=
"""sym tags""")
    
  add_example(title="List paths associated with a tag", content=
"""sym tag funny""")
    
  add_example(title="Change the path of an item", content=
"""sym changepath movies /media/movies""")

  add_example(title="Show the path of an item", content=
"""sym path movies""")
    
  add_example(title="Open a path in the file manager", content=
"""sym open movies""")
    
  add_example(title="Remake symlinks based on the database", content=
"""sym remake""")
    
  add_example(title="Make a backup", content=
"""sym backup""")
    
  add_example(title="Restore from backup", content=
"""sym restore""")

  add_example(title="Print a string of item names", content=
"""sym printnames""")

  add_example(title="Scripts", content=
"""
#Scripts can be used for automation.
#Scripts are 1 command per line.

#Example script:
  movies ~/media/movies plot
  tag movies woomy
  backup""")

  add_example(title="Run a script", content=
"""sym runscript /path/to/script""")

  add_example(title="Make a script", content=
"""sym makescript /path/to/save""")

  add_header("Symlink creator and manager")
  
  let dev = use_arg(name="dev", kind="flag", help="Used for development")
  let force = use_arg(name="force", kind="flag", help="Run commands without confirmation")

  parse_args()
  
  conf = Config(tail:argtail(), dev:dev.used, force:force.used)

proc show_info*() =
  print_help()