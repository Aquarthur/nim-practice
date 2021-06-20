import asynchttpserver, asyncdispatch

let server = newAsyncHttpServer()

proc cb(req: Request) {.async.} =
    await req.respond(Http200, "Hello there", newHttpHeaders())

waitFor server.serve(Port(8080), cb)

