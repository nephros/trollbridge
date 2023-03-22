.pragma library

var maxDownloads = 2;
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
    //while (model.count > 0) {
    for ( var i =0; i<= maxDownloads ; i++) {
        const e = model.get(0)
        console.debug("calling xhrbin for", e, config.hostaddr + "get_thumbnail.cgi?DIR=" + e["path"] + "/" + e["file"], e["file"], e["trollPath"])
        xhrbin(config.hostaddr + "get_thumbnail.cgi?DIR=" + e["path"] + "/" + e["file"], e["file"], e["trollPath"])
        addDownload()
        model.remove(0)
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
    console.debug("called");
    var query = url;
    var r = new XMLHttpRequest();
    r.open('GET', query);
    //r.responseType = 'arraybuffer';
    r.setRequestHeader("User-Agent", config.agent)
    r.setRequestHeader("Host", config.host)
    r.timeout = 500;

    console.debug("sending");
    r.send();
    console.debug("sent");
    r.ontimeout = function(event) { console.debug("xhrbin timed out.") }
    r.onreadystatechange = function(event) {
      if (r.readyState == XMLHttpRequest.DONE) {
        if (r.status === 200 || r.status == 0) {
          //console.debug(r.status, r.statusText, JSON.stringify(r.response));
          console.debug(r.status, r.statusText, name, r.getResponseHeader("mime-type") );
          WorkerScript.sendMessage({ event: "thumbReceived", name: name, type: r.getResponseHeader("mime-type"), data: r.response, path: path } )
        } else {
          console.warn("error in processing request:", r.status, r.statusText, query);
          WorkerScript.sendMessage({ event: "error", query: query, message: r.status + ":" + r.statusText })
        }
        delDownload()
      }
    }
  }
}

// vim: ft=javascript expandtab ts=4 st=2 sw=2
