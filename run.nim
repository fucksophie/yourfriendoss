import std/strutils, std/sequtils, std/os, std/times, prologue

import prologue/middlewares/staticfile

import nre except toSeq
import markdown except toSeq

proc index*(ctx: Context) {.async.} =
  let file = readFile("README.md")
  let md = markdown(file)

  resp replace(readFile("website/templates/index.html"), "%Markdown%", md)

proc blog*(ctx: Context) {.async.} =
  let posts = toSeq(walkDir("website/posts/", relative=true))

  var postText = ""

  for path in posts:
    let post = readFile("website/posts/" & path.path)

    let title = post.match(nre.re("(?i)(?m)\\|title\\|(.*)$")).get.captures[0]

    proc europeTzInfo(time: Time): ZonedTime =
      ZonedTime(utcOffset: -3, isDst: true, time: time)

    let edited = getLastModificationTime("website/posts/" & path.path)
                .inZone(zone = newTimezone("Europe/Riga", europeTzInfo, europeTzInfo))
                .format("yyyy-MM-dd HH:mm tt")

    let posted = getCreationTime("website/posts/" & path.path)
                  .inZone(zone = newTimezone("Europe/Riga", europeTzInfo, europeTzInfo))
                  .format("yyyy-MM-dd HH:mm tt")
    
    var postTemplate = readFile("website/templates/postListing.md")

    postTemplate = replace(postTemplate, "%title%", title)  
    postTemplate = replace(postTemplate, "%creation%", posted)
    postTemplate = replace(postTemplate, "%edited%", edited)
    postTemplate = replace(postTemplate, "%url%", strutils.replace("/blog/post/" & path.path, " ", "_"))
  
    postText = postText & postTemplate

  var postsTemplate = readFile("website/templates/posts.md")

  postsTemplate = strutils.replace(postsTemplate, "%posts%", postText)
  
  postsTemplate = markdown(postsTemplate)

  var index = readFile("website/templates/index.html")

  index = strutils.replace(index, "%Markdown%", postsTemplate)
  
  resp index

proc posts(ctx: Context) {.async.} =
  let post = readFile("website/posts/" & strutils.replace(ctx.getPathParams("text"), "_", " "))

  var postTemplate = readFile("website/templates/post.md")

  postTemplate = replace(postTemplate, "%title%", post.match(nre.re("(?i)(?m)\\|title\\|(.*)$")).get.captures[0])
  postTemplate = replace(postTemplate, "%content%", replace(post, nre.re("(?i)(?m)\\|title\\|(.*)$"), ""))

  postTemplate = markdown(postTemplate)

  var index = readFile("website/templates/index.html")
  
  index = replace(index, "%Markdown%", postTemplate)
  
  resp index


let settings = newSettings(
  address = "0.0.0.0",
  port = Port(20007),
  debug = false,
  appName = "yourfriend's website"
)

var app = newApp(settings = settings)

app.addRoute("/", index)

app.use(staticFileMiddleware("website/assets"))

app.addRoute("/blog", blog)
app.addRoute("/blog/post/{text}", posts)

echo " Running yourfriend's website! "
app.run()