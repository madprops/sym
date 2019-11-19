import nap

type Config* = object
  tail*: seq[string]

var conf*: Config

proc get_config*() =
  parse_args("tag your directories and files")
  conf = Config(tail:argtail())