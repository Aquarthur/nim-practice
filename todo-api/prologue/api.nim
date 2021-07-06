import json
import norm/[model, sqlite]
import options
import prologue

import "../todo"

let dbConn = open(":memory:", "", "", "")
dbConn.createTables(newTodo())

let app = newApp()

app.get("/health", proc (ctx: Context) {.async.} =
  resp jsonResponse(%* { "status": "OK" })
)

app.get("/echo/{msg}", proc (ctx: Context) {.async.} =
  resp plainTextResponse(ctx.getPathParams("msg"))
)

app.get("/todos", proc (ctx: Context) {.async.} =
  let allTodos = dbConn.getAllTodos()
  resp jsonResponse(%allTodos)
)

app.post("/todos", proc (ctx: Context) {.async, gcsafe.} =
  let body = parseJson(ctx.request.body())
  let todo = dbConn.createTodo(body)
  resp jsonResponse(%todo)
)

app.get("/todos/{id}", proc (ctx: Context) {.async.} =
  let id = ctx.getPathParams("id")
  let todo = dbConn.findTodo(id)
  if todo.isSome:
    resp jsonResponse(%todo.get())
  else:
    resp error404()
)

app.patch("/todos/{id}", proc (ctx: Context) {.async, gcsafe.} =
  let id = ctx.getPathParams("id")
  let body = parseJson(ctx.request.body())
  let todo = dbConn.patchTodo(id, body)
  if todo.isSome:
    resp jsonResponse(%todo.get())
  else:
    resp error404()
)

app.delete("/todos/{id}", proc (ctx: Context) {.async, gcsafe.} =
  let id = ctx.getPathParams("id")
  let deleted = dbConn.deleteTodo(id)
  if deleted.isSome:
    resp plainTextResponse("", Http204)
  else:
    resp error404()
)

app.run()
