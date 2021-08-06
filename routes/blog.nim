import httpx
import nre except toSeq
import markdown except toSeq

import std/[os, times, sequtils, strutils] 


proc blog*(req: Request) =
  let posts = toSeq(walkDir("website/posts/", relative=true))

  var postText = ""

  for path in posts:
    let post = readFile("website/posts/" & path.path)

    let title = post.match(nre.re("(?i)(?m)\\|title\\|(.*)$")).get.captures[0]

    func europeTzInfo(time: Time): ZonedTime =
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
    
  req.send(index)