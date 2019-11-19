import nap

type Config* = object
  tail*: seq[string]
  dev*: bool

var conf*: Config

proc get_config*() =
  let dev = use_arg(name="dev", kind="flag", help="Used for development")
  parse_args("tag your directories and files\nHint: You can use re:string on remove")
  conf = Config(tail:argtail(), dev:dev.used)