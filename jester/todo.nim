import jester
import json
import options
import sequtils, strutils

proc health(): JsonNode =
  return parseJson("{ \"status\": \"OK\" }")

type
  Todo = object
    id: Option[int]
    description: string
    done: bool

var todos = newSeq[Todo](0)

proc createTodo(payload: JsonNode) =
  var p = to(payload, Todo)
  todos.add(Todo(id: some(todos.len()), description: p.description, done: p.done))

proc patchTodo(i: int, payload: JsonNode) =
  var todo = todos[i]
  if payload.hasKey("description"):
    todo.description = payload["description"].getStr()
  if payload.hasKey("done"):
    todo.done = payload["done"].getBool()
  todos[i] = todo

proc findTodo(id: int): int =
  for todo in todos:
    if todo.id.isSome and (todo.id.get() == id):
      return id
  return -1

routes:
  get "/health":
    resp health()

  get "/echo/@msg":
    resp Http200, @"msg"

  post "/todos":
    createTodo(parseJson(request.body()))
    resp %todos[todos.len() - 1]

  get "/todos":
    resp %todos

  get "/todos/@id":
    let i: int = findTodo(parseInt(@"id"))
    if i >= 0:
      resp %todos[parseInt(@"id")]
    resp Http404

  patch "/todos/@id":
    let id = parseInt(@"id")
    if id < 0 or id >= todos.len():
      raise(newException(ValueError, "ID out of bounds"))
    patchTodo(id, parseJson(request.body()))
    resp %todos[id]

  delete "/todos/@id":
    let id = parseInt(@"id")
    if id < 0 or id >= todos.len():
      raise(newException(ValueError, "ID out of bounds"))
    todos = filter(todos, proc(t: Todo): bool = (t.id.isSome and (t.id.get() != id)))
    resp Http204

  error Http404:
    resp "Page not found!"

  error Exception:
    resp exception.msg
