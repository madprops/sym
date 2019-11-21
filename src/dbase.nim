import utils
import os
import config
import json
import tables
import rdstdin
import strformat
import strutils

type Data* = object
  version*: int

type Item* = ref object
  path*: string
  tags*: seq[string]

type DB* = object
  data*: Data
  items*: Table[string, Item]

var db*: DB
var original_jtext: string

proc get_db_path(): string =
  if conf.dev:
    getCurrentDir().parentDir().joinPath("db.json")
  else:
    getHomeDir().join(".config/sym/db.json")

proc get_db_backup_path(): string =
  if conf.dev:
    getCurrentDir().parentDir().joinPath("db_backup.json")
  else:
    getHomeDir().join(".config/sym/db_backup.json")

proc read_db_file(): string =
  try:
    return readFile(get_db_path())
  except:
    log "Can't read db file."

proc read_db_backup_file(): string =
  try:
    return readFile(get_db_backup_path())
  except:
    log "Can't read backup db file."

proc write_to_db_file(jtext:string) =
  try:
    writeFile(get_db_path(), jtext)
  except:
    log "Can't write to db file."

proc write_to_db_backup_file(jtext:string) =
  try:
    writeFile(get_db_backup_path(), jtext)
  except:
    log "Can't write to backup db file."

proc get_db*() =
  original_jtext = read_db_file()
  let db_json = parseJson(original_jtext)
  db = DB(data:to(db_json["data"], Data), 
    items:to(db_json["items"], Table[string, Item]))

proc get_db_json*(): string =
  return (% db).pretty()

proc save_db*() = 
  write_to_db_file(get_db_json())

proc save_backup*() = 
  write_to_db_backup_file(original_jtext)

proc restore_backup*() =
  let ans = readLineFromStdin(&"Restore to last backup? (yes/no): ").strip()
  if ans == "yes":
    write_to_db_file(read_db_backup_file())
    get_db()