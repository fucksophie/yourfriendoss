import httpclient, strutils

let urls = [
  "https://pbs.twimg.com/media/E6_hPvKVcAQhZKn?format=jpg&name=small",
  "https://pbs.twimg.com/media/E5aanDDVIAYz_pU?format=jpg&name=small",
  "https://pbs.twimg.com/media/E5VfoJTVIAQT63x?format=jpg&name=small",
  "https://pbs.twimg.com/media/E5EHdfMVUAAsEdL?format=jpg&name=small",
  "https://pbs.twimg.com/media/E46jc74WEAAViFr?format=jpg&name=small",
  "https://pbs.twimg.com/media/E3ygeDNVcAA-ND0?format=jpg&name=small"
]

for url in urls:
  let i = find(urls, url)+1
  var client = newHttpClient()

  client.downloadFile(url, i.intToStr() & ".jpg")
  echo "Downloaded image " & i.intToStr()