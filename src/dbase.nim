import std/os
import std/json
import std/tables
import std/strutils
import utils
import config

type Data* = object
  version*: int

type Item* = ref object
  path*: string
  tags*: seq[string]

type DB* = ref object
  data*: Data
  items*: OrderedTable[string, Item]

var dbo*: DB
var original_jtext: string
var db_ready = false

proc get_db_path(): string =
  if conf.dev:
    getCurrentDir().parentDir().joinPath("db.json")
  else:
    getConfigDir().joinPath("sym/db.json")

proc get_db_backup_path(): string =
  if conf.dev:
    getCurrentDir().parentDir().joinPath("db_backup.json")
  else:
    getConfigDir().joinPath("sym/db_backup.json")

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
  dbo = DB(data:to(db_json["data"], Data), 
    items:to(db_json["items"], OrderedTable[string, Item]))
  db_ready = true

proc db*(): DB =
  if not db_ready:
    get_db()
  return dbo

proc get_db_json*(): string =
  return (% db()[]).pretty()

proc save_db*() = 
  write_to_db_file(get_db_json())

proc save_backup*() = 
  if not conf.force and not confirm("Save backup?"):
    return
  
  write_to_db_backup_file(original_jtext)
  log "Backup saved."

proc restore_backup*() =
  if not conf.force and not confirm("Restore to last backup?"):
    return

  write_to_db_file(read_db_backup_file())
  log "Database restored."
  get_db()