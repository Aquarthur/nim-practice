import json
import logging; addHandler newConsoleLogger(fmtStr = "")
import norm/[model, sqlite]
import options
import strutils

type
  Todo* = ref object of Model
    description*: string
    done*: bool

func newTodo*(description = "", done = false): Todo =
  Todo(description: description, done: done)

proc getAllTodos*(dbConn: DbConn): seq[Todo] =
  var allTodos = @[newTodo()]
  dbConn.selectAll(allTodos)
  return allTodos

proc createTodo*(dbConn: DbConn, payload: JsonNode): Todo =
  if payload.hasKey("description") and payload.hasKey("done"):
    var newTodo = newTodo(payload["description"].getStr(), payload["done"].getBool())
    dbConn.insert(newTodo)
    return newTodo
  else:
    raise newException(JsonParsingError, "invalid payload")

proc patchTodo*(dbConn: DbConn, id: string, payload: JsonNode): Option[Todo] =
  var todo = newTodo()
  try:
    dbConn.select(todo, "id = $1", id)
    if payload.hasKey("description"):
      todo.description = payload["description"].getStr()
    if payload.hasKey("done"):
      todo.done = payload["done"].getBool()
    dbConn.update(todo)
    return some(todo)
  except NotFoundError:
    return none(Todo)
  except Exception as e:
    raise e

proc findTodo*(dbConn: DbConn, id: string): Option[Todo] =
  var todo = newTodo()
  try:
    dbConn.select(todo, "id = $1", id)
    return some(todo)
  except NotFoundError:
    return none(Todo)
  except Exception as e:
    raise e

proc deleteTodo*(dbConn: DbConn, id: string): Option[string] =
  var todo = newTodo()
  try:
    dbConn.select(todo, "id = $1", id)
    dbConn.delete(todo)
    return some(id)
  except NotFoundError:
    return none(string)
  except Exception as e:
    raise e
