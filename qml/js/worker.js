.pragma library

var maxDownloads = 4;
var curDownloads = 0;

const config = {
  host: "192.168.0.10",
  hostaddr: "http://192.168.0.10/",
  agent: "OlympusCameraKit",
}

WorkerScript.onMessage = function(m){
    //console.log("message:",JSON.stringify(m));

    if (m.action === "download") {
      console.debug("received model:", JSON.stringify(m.parm.model))
      download(m.parm.model)
    }

  function download(model) {
    while (model.count > 0) { 
      if ( curDownloads < maxDownloads) { // TODO: fix busy looping while queue is full
        const e = model.get(0)
        console.debug("calling xhrbin for", e, config.hostaddr + "get_thumbnail.cgi?DIR=" + e["path"] + "/" + e["file"], e["file"], e["trollPath"])
        xhrbin(config.hostaddr + "get_thumbnail.cgi?DIR=" + e["path"] + "/" + e["file"], e["file"], e["trollPath"])
        addDownload()
        model.remove(0)
      } else {
        // we don't have sleep, so make a sync request to nowhere, hoping for a
        // timeout to halt execution: 
        var r = new XMLHttpRequest();
        r.open('GET', 'http://no-host.' + Math.floor(Math.random()*1000) + '.void', true);
        r.send(null);
        r.onreadystatechange = function(event) {
          if (r.readyState == XMLHttpRequest.DONE) {
            console.log("sleeprequest done")
          }
        }
      }
    }
    model.sync()
  }
    function addDownload() { curDownloads+=1
        WorkerScript.sendMessage({ event: "queued" })
    }
    function delDownload() { curDownloads-=1
                WorkerScript.sendMessage({ event: "dequeued" })
    }

    function xhrbin(url, name, path) {
        console.log("called.")
        var query = url;
        var r = new XMLHttpRequest();
        r.open('GET', query);
        r.responseType = 'arraybuffer';
        r.setRequestHeader("User-Agent", config.agent)
        r.setRequestHeader("Host", config.host)


        r.send();
        r.onreadystatechange = function(event) {
            if (r.readyState == XMLHttpRequest.DONE) {
                if (r.status === 200 || r.status == 0) {
                    console.log(r.status, r.statusText, JSON.stringify(r.response));
                    WorkerScript.sendMessage({ event: "thumbReceived", name: name, type: r.getResponseHeader("mime-type"), data: r.response, path: path } )
                } else {
                    console.log("error in processing request:", r.status, r.statusText, query);
                    WorkerScript.sendMessage({ event: "error", query: query, message: r.status + ":" + r.statusText })
                }
                delDownload()
            }
        }
    }
}

// vim: ft=javascript expandtab ts=4 st=2 sw=2
