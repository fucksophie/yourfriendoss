import strutils, prologue, markdown

proc index*(ctx: Context) {.async.} =
  let file = readFile("README.md")
  let md = markdown(file)

  resp strutils.replace(readFile("website/index.html"), "%File%", md)

  
proc style(ctx: Context) {.async.} =
  await ctx.staticFileResponse("website/assets/style.css", "")


let settings = newSettings(
  address = "0.0.0.0",
  port = Port(20007),
  debug = false,
  appName = "yourfriend's website"
)

var app = newApp(settings = settings)

app.addRoute("/", index)

app.addRoute("style.css", style)

echo " Running yourfriend's website! "
app.run()
