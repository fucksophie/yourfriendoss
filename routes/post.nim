import httpx, markdown

import std/[strutils, nre]

proc post*(req: Request, file: string) =
  let post = readFile("website/posts/" & strutils.replace(file, "_", " "))

  var postTemplate = readFile("website/templates/post.md")

  postTemplate = replace(postTemplate, "%title%", post.match(nre.re("(?i)(?m)\\|title\\|(.*)$")).get.captures[0])
  postTemplate = replace(postTemplate, "%content%", replace(post, nre.re("(?i)(?m)\\|title\\|(.*)$"), ""))

  postTemplate = markdown(postTemplate)

  var index = readFile("website/templates/index.html")
    
  index = replace(index, "%Markdown%", postTemplate)
    
  req.send(index)