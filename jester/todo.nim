import logging; addHandler newConsoleLogger(fmtStr = "")
import jester
import json
import norm/[model, sqlite]
import options
import strutils

let healthJson = %* { "status": "OK" }

type
  Todo = ref object of Model
    description: string
    done: bool

func newTodo(description = "", done = false): Todo =
  Todo(description: description, done: done)

let dbConn = open(":memory:", "", "", "")
dbConn.createTables(newTodo())

proc getAllTodos(): seq[Todo] =
  var allTodos = @[newTodo()]
  dbConn.selectAll(allTodos)
  return allTodos

proc createTodo(payload: JsonNode): Todo =
  if payload.hasKey("description") and payload.hasKey("done"):
    var newTodo = newTodo(payload["description"].getStr(), payload["done"].getBool())
    dbConn.insert(newTodo)
    return newTodo
  else:
    raise newException(JsonParsingError, "invalid payload")

proc patchTodo(id: string, payload: JsonNode): Option[Todo] =
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

proc findTodo(id: string): Option[Todo] =
  var todo = newTodo()
  try:
    dbConn.select(todo, "id = $1", id)
    return some(todo)
  except NotFoundError:
    return none(Todo)
  except Exception as e:
    raise e

proc deleteTodo(id: string): Option[string] =
  var todo = newTodo()
  try:
    dbConn.select(todo, "id = $1", id)
    dbConn.delete(todo)
    return some(id)
  except NotFoundError:
    return none(string)
  except Exception as e:
    raise e

settings:
  port = Port(5001)

router todoRouter:
  get "":
    let allTodos = getAllTodos()
    resp %allTodos

  post "":
    let todo: Todo = createTodo(parseJson(request.body()))
    resp %todo

  get "/@id":
    let todo: Option[Todo] = findTodo(@"id")
    if todo.isSome:
      resp %todo.get()
    resp Http404

  patch "/@id":
    let todo = patchTodo(@"id", parseJson(request.body()))
    if todo.isSome:
      resp %todo.get()
    resp Http404

  delete "/@id":
    let deleted = deleteTodo(@"id")
    if deleted.isSome:
      resp Http204
    resp Http404

routes:
  extend todoRouter, "/todos"

  get "/health":
    resp healthJson

  get "/echo/@msg":
    resp Http200, @"msg"

  error Http404:
    let errJson = %* { "status": "error", "msg": "Page not found!" }
    resp errJson

  error Exception:
    let errJson = %* { "status": "error", "msg": "an error occurred" }
    resp(Http500, [("Content-Type", "application/json")],  $errJson)
