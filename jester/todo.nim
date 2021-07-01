import jester
import json
import oids
import options
import strutils

proc health(): JsonNode =
  return parseJson("{ \"status\": \"OK\" }")

type
  Todo = object
    id: Option[string]
    description: string
    done: bool

var todos = %* {}

proc createTodo(payload: JsonNode): Todo =
  let p = to(payload, Todo)
  let id = genOid()
  let newTodo = Todo(id: some($id), description: p.description, done: p.done)
  todos[$id] = %newTodo
  return newTodo

proc patchTodo(id: string, payload: JsonNode): Option[Todo] =
  if todos.hasKey(id):
    var todo = to(todos[id], Todo)
    if payload.hasKey("description"):
      todo.description = payload["description"].getStr()
    if payload.hasKey("done"):
      todo.done = payload["done"].getBool()
    todos[id] = %* todo
    return some(todo)

proc findTodo(id: string): Option[Todo] =
  if todos.hasKey(id):
    return some(to(todos[id], Todo))

proc deleteTodo(id: string): Option[string] =
  if todos.hasKey(id):
    todos.delete(id)
    return some(id)

routes:
  get "/health":
    resp health()

  get "/echo/@msg":
    resp Http200, @"msg"

  post "/todos":
    echo parseJson(request.body())
    let todo: Todo = createTodo(parseJson(request.body()))
    resp todos[todo.id.get()]

  get "/todos":
    resp %todos

  get "/todos/@id":
    let todo: Option[Todo] = findTodo(@"id")
    if todo.isSome:
      resp %todos[@"id"]
    resp Http404

  patch "/todos/@id":
    let todo = patchTodo(@"id", parseJson(request.body()))
    if todo.isSome:
      resp %todos[@"id"]
    resp Http404

  delete "/todos/@id":
    let deleted = deleteTodo(@"id")
    if deleted.isSome:
      resp Http204
    resp Http404

  error Http404:
    let errJson = %* { "status": "error", "msg": "Page not found!" }
    resp errJson
