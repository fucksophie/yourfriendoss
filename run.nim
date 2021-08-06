import httpx

import std/[os, strutils, options, asyncdispatch]
import routes/[index, blog, post]

proc onRequest(req: Request): Future[void]=
  if req.httpMethod == some(HttpGet):
    case req.path.get()
    
    of "/":
      index(req)

    of "/blog":
      blog(req)
    
    else:
      let path = req.path.get()

      if startsWith(path, "/blog/post/"):
        if fileExists("website/posts/" & split(path, "/blog/post/")[1]):
          post(req, split(path, "/blog/post/")[1])

      if fileExists("website/assets" & path):
        req.send(readFile("website/assets" & path))

      req.send(Http404)

echo "Running on port 20007. Binded to all interfaces."
run(onRequest, initSettings(Port(20007), bindAddr = "0.0.0.0", numThreads = 2))