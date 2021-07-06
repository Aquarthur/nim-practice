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

app.post("/todos", proc (ctx: Context) {.async.} =
  let body = parseJson(ctx.request.body())
  let todo = dbConn.createTodo(body)
  resp "hi"
)

app.run()
