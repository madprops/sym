import config
import json
import tables

type Data* = object
  id*: int

type Path* = object
  id*: int
  path*: string

type Tag* = object
  paths*: seq[Path]

type DB* = object
  data*: Data
  tags*: Table[string, Tag]

var db*: DB

proc get_db*() =
  let path = if conf.dev: "../db.json"
    else: "~/.config/tag/db.json"
  let tags_json = parseJson(readFile(path))
  db = DB(data:to(tags_json["data"], Data), 
    tags:to(tags_json["tags"], Table[string, Tag]))

proc save_db*() = 
  var db_json = % db
  let path = if conf.dev: "../db.json"
    else: "~/.config/tag/db.json"
  writeFile(path, db_json.pretty())