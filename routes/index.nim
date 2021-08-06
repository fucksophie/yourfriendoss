import httpx, markdown

import std/[strutils]

proc index*(req: Request) =
  let file = readFile("README.md")
  let md = markdown(file)

  req.send(replace(readFile("website/templates/index.html"), "%Markdown%", md))