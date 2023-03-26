.pragma library

var maxDownloads = 2;
var curDownloads = 0;

const config = {
  host: "192.168.0.10",
  hostaddr: "http://192.168.0.10/",
  agent: "OlympusCameraKit",
}

WorkerScript.onMessage = function(m){
    if (m.action === "download") {
        //console.debug("received model:", JSON.stringify(m.model))
        downloadList(m.model, m.mode)
    }

    // download all images from a list
    function downloadList(model, mode) {
        //while (model.count > 0) {
        for ( var i = 0; i <= Math.min(m.model.count, maxDownloads) ; i++) {
            const e = model.get(0) // get the first (not i!) item, which we remove from the list later
            const url  = "";
            const name = e["file"];
            const path = e["trollPath"];
            switch (mode) {
                case "thumb":      url = config.hostaddr + "get_thumbnail.cgi?DIR=" + e["path"] + "/" + e["file"]; break;
                case "imagesmall": url = config.hostaddr + "get_resizeimg.cgi?DIR=" + e["path"] + "/" + e["file"] + "&size=2048"; break;
                case "image":      url = config.hostaddr + "file?DIR=" + e["path"] + "/" + e["file"]; break;
            }
            addDownload();
            xhrbin(url, name, path);
            model.remove(0); // remove from queue
        }
        model.sync()
    }

    function addDownload() { curDownloads+=1
        WorkerScript.sendMessage({ event: "queued",count: curDownloads })
    }

    function delDownload() { curDownloads-=1
        WorkerScript.sendMessage({ event: "queued",count: curDownloads })
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
        r.ontimeout = function(event) {
            console.warn("request timed out.")
            WorkerScript.sendMessage({ event: "timeout", query: query, message: r.status + ":" + r.statusText })
        }
        r.onreadystatechange = function(event) {
            if (r.readyState == XMLHttpRequest.DONE) {
                if (r.status === 200) {
                    const mime = r.getResponseHeader("content-type");
                    const size = r.getResponseHeader("content-length"); 
                    const rotation = r.getResponseHeader("x-rotation-info");
                    // buffer to view
                    const response = new Uint8Array(r.response);
                    // view to raw string
                    var raw = "";
                    for (var i = 0; i < response.byteLength; i++) { raw += String.fromCharCode(response[i]); }
                    console.debug(r.status, r.statusText, name, mime, size, response.byteLength);
                    // base64 string
                    const data64 = base64Encode(raw);
                    // image URL
                    //const image = 'data:' + mime + ';base64,' + data64;

                    // send back everything:
                    var eventName;
                    if (/get_thumb/.test(url)) {
                        eventName = "thumbReceived"
                        console.info("Rotation:", rotation);
                    } else if ((/get_resizeimg/.test(url)) || (/file)/.test(url))) {
                        eventName = "imgReceived"
                        console.debug(r.getAllResponseHeaders());
                    };
                    WorkerScript.sendMessage({
                        event: eventName,
                        name: name, path: path,
                        data: { base64: data64 },
                        meta: { type: mime, rot: rotation, size: size }
                    })
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


}

// vim: ft=javascript expandtab ts=4 st=4 sw=4
