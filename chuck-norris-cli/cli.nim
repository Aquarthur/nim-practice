import asyncdispatch, httpclient, json

var client = newAsyncHttpClient()

proc getRandomChuckNorrisFact(): Future[string] {.async.} =
  let response = await client.getContent("https://api.chucknorris.io/jokes/random")
  return parseJson(response)["value"].getStr()

echo waitFor getRandomChuckNorrisFact()
