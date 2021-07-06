import json
import jester
import norm/[model, sqlite]
import options
import strutils

import "../todo"

let healthJson = %* { "status": "OK" }

import os
echo os.getCurrentDir()

let dbConn = open(":memory:", "", "", "")
dbConn.createTables(newTodo())

settings:
  port = Port(5001)

router todoRouter:
  get "":
    let allTodos = dbConn.getAllTodos()
    resp %allTodos

  post "":
    let todo: Todo = dbConn.createTodo(parseJson(request.body()))
    resp %todo

  get "/@id":
    let todo: Option[Todo] = dbConn.findTodo(@"id")
    if todo.isSome:
      resp %todo.get()
    resp Http404

  patch "/@id":
    let todo = dbConn.patchTodo(@"id", parseJson(request.body()))
    if todo.isSome:
      resp %todo.get()
    resp Http404

  delete "/@id":
    let deleted = dbConn.deleteTodo(@"id")
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
