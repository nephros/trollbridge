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
  //FROM https://cdnjs.cloudflare.com/ajax/libs/Base64/1.0.1/base64.js
  function base64Encode (input) {
    var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
    var str = String(input);
    for (
      // initialize result and counter
      var block, charCode, idx = 0, map = chars, output = '';
      str.charAt(idx | 0) || (map = '=', idx % 1);
      output += map.charAt(63 & block >> 8 - idx % 1 * 8)
    ) {
      charCode = str.charCodeAt(idx += 3/4);
      if (charCode > 0xFF) {
        throw new Error("Base64 encoding failed: The string to be encoded contains characters outside of the Latin1 range.");
      }
      block = block << 8 | charCode;
    }
    return output;
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
    console.debug("called:", url);
    var query = url;
    var r = new XMLHttpRequest();
    r.open('GET', query);
    r.responseType = 'arraybuffer';
    r.setRequestHeader("User-Agent", config.agent)
    r.setRequestHeader("Host", config.host)
    r.timeout = 500;

    r.send();
    r.ontimeout = function(event) { console.debug("xhrbin timed out.") }
    r.onreadystatechange = function(event) {
      if (r.readyState == XMLHttpRequest.DONE) {
        if (r.status === 200) {
          //console.debug(r.getAllResponseHeaders());
          console.info("Rotation:", r.getResponseHeader("x-rotation-info"));
          const mime = r.getResponseHeader("content-type");
          // buffer to view
          const response = new Uint8Array(r.response);
          // view to raw string
          var raw = "";
          for (var i = 0; i < response.byteLength; i++) { raw += String.fromCharCode(response[i]); }
          console.debug(r.status, r.statusText, name, mime, r.getResponseHeader("content-length"), response.byteLength);
          // base64 string
          const data64 = base64Encode(raw);
          // image URL
          const image = 'data:' + mime + ';base64,' + data64;

          //console.debug("put back:", data.substr(0,16));
          //WorkerScript.sendMessage({ event: "thumbUrl", image: image } )
          // send back raw string:
          //WorkerScript.sendMessage({ event: "thumbReceived", name: name, type: mime, data: raw, path: path } )
          // send back base64 data:
          //WorkerScript.sendMessage({ event: "thumbReceived", name: name, type: mime, data: data64, path: path } )
          // send back image URL:
          //WorkerScript.sendMessage({ event: "thumbReceived", name: name, type: mime, data: image, path: path } )
          // send back everything:
          WorkerScript.sendMessage({ event: "thumbReceived",
                      name: name, type: mime, path: path,
                        data: {
                          raw: raw,
                          base64: data64,
                          url: image
                        }
                    }
          )
        } else if (r.status === 503) {
          WorkerScript.sendMessage({ event: "refused", query: query, message: r.status + ":" + r.statusText })
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
