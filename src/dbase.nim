import os
import config
import json
import tables

type Data* = object
  version*: int

type Item* = ref object
  path*: string
  tags*: seq[string]

type DB* = object
  data*: Data
  items*: Table[string, Item]

var db*: DB

proc get_db*() =
  let path = if conf.dev: "../db.json"
    else: "~/.config/gat/db.json"
  let db_json = parseJson(readFile(expandTilde(path)))
  db = DB(data:to(db_json["data"], Data), 
    items:to(db_json["items"], Table[string, Item]))

proc save_db*() = 
  var db_json = % db
  let path = if conf.dev: "../db.json"
    else: "~/.config/gat/db.json"
  writeFile(expandTilde(path), db_json.pretty())