import QtQuick 2.1
import Sailfish.Silica 1.0
import Sailfish.Share 1.0
import Nemo.FileManager 1.0

Item { id: control

    // my properties:
    property var config: {
        "host": "192.168.0.10",
        "hostaddr": "http://192.168.0.10/",
        "agent": "OlympusCameraKit",
    }
    property string cachePath: StandardPaths.cache
    property bool err: false
    property var lastError: ["",]

    /*
     * properties from trollbridge.go:
     */

    property ListModel _list: ListModel {}
    //property string downloadPath: StandardPaths.pictures + "/" + Qt.application.name
    property string downloadPath: StandardPaths.pictures + "/Olympus" // legacy
    property string model: ""
    property string type: ""
    property bool connected: mainWindow.online && (!!model && (model !== ""))
    property bool downloading: false
    property bool opc: (type === "OPC")

    /*
     * helper types and stuff
     */

    WorkerScript { id: worker
        source: "js/worker.js"
        onMessage: function(m) {
            //console.log("WS got msg back:", m.event)
            if (m.event === "thumbReceived") { handleDownloadedFile(m.name, m.type, m.data, m.path) }
            else if (m.event === "error")    { control.lastError += m.message }
            else if (m.event === "queued")   {control.numDownloads +=1 }
            else if (m.event === "dequeued") {control.numDownloads -=1 }
            else { console.warn("Unhandled message from worker:", m.event) }
        }
    }
    // file handling
    property ShareAction sac: ShareAction{}
    property FileInfo fi: FileInfo{}
    Connections {
        target: FileEngine
        onError: function(e,f) { console.warn("error:", e , f)}
    }

    // queue for downloads, passed to worker:
    property ListModel dlq: ListModel {}
    property ListModel dlb: ListModel {}
    property int numDownloads: 0
    property int maxDownloads: 4

    // assert all dl paths are there:
    onModelChanged: checkPaths()
    function checkPaths() {
        if (!model || model === "" ) return
        if (!FileEngine.exists(downloadPath + "/" + model)) {
            mkdirpath(downloadPath + "/" + model)
        }
        if (!FileEngine.exists(cachePath + model)) {
            mkdirpath(cachePath + "/" + model)
        }
    }
    function mkdirpath(p) {
        //console.debug("asserting path exists:", p)
        const dirs = p.split("/");
        const path = "/"
        dirs.forEach(function(dir) {
            if (!FileEngine.exists(path + "/" + dir)) {
                FileEngine.mkdir(path, dir, true)
                console.debug("made:", dir)
            }
            path = path + "/" + dir
        })
    }
    function handleDownloadedFile(name, type, data, path) {
        return
        //console.debug("OK, filehandling:", name, type, data );
        var tmp = sac.writeContentToFile(
            { "name": name, "type": type, "data": data }
        )
        fi.url = tmp
        //console.debug("OK, file written.", tmp, fi.size);
        FileEngine.rename(tmp, path, true);
        fi.url = path
        //console.debug("OK, file copied.", path, fi.size);
    }

    Timer{ id: qTimer
        repeat: false
        running: (numDownloads < maxDownloads)
        interval: 2000
        onTriggered: {
            dlb.clear();
            for (var i=0; i<maxDownloads; ++i){
                dlb.append(dlq.get(i));
                dlq.remove(i);
                worker.sendMessage({ action: "download", parm: { model: dlb } })
            }
        }
    }
    function batchDownload(){
        qTimer.start()
    }
    /*
     * functions from trollbridge.go:
     */

    //function runtimeVersion(){ return "QtQuick 2.1" }
    function version() { return Qt.application.version }

    // SwitchState Switch the camera on or off
    function switchState(on) {
		if (on) {
			cameraExecute("exec_pwon", "")
		} else {
			cameraExecute("exec_pwoff", "")
		}
    }
    // CameraExecute Fire GET request to camera
	function cameraExecute(cmd, path){console.debug("called:", cmd, path)
	    fireQuery("", cmd, [path], function(r){console.debug(r)} )
    }
    // GetImage Get image at list index
    //func (ctrl *BridgeControl) GetImage(index int) *File {
    function getImage(index) {console.debug("called.")
        return _list.get(index)
    }
    // SetSelection Set selection at list index
    //func (ctrl *BridgeControl) SetSelection(index string, value bool) {
    function setSelection(index, value){
        console.debug("called:",index,value)
        _list.setProperty(index, "selected", value)
    }
    // SetSelectionItem Set selection at list index
    //func (ctrl *BridgeControl) SetSelectionItem(idx int, value bool) {
    function setSelectionItem(idx, value){console.debug("called.")
            setSelection(idx, true)
    }
    // ClearAllSelection Clears the file list selection
    //func (ctrl *BridgeControl) ClearAllSelection() {
    function clearAllSelection(){console.debug("called.")
        for (var i = 0; i < _list.length; i++) {
            setSelection(i, false)
        }
    }
    // Download Downloads the file at index
    //func (ctrl *BridgeControl) Download(idx int, quarterSize bool) {
    function download(idx , quarterSize) {
        cameraDownloadFile(_list.get(idx).path, _list.get(idx).file, quarterSize)
    }
    // DownloadSelected Downloads all selected files
    //func (ctrl *BridgeControl) DownloadSelected(quarterSize bool) {
    function downloadSelected(quarterSize) {
        for (var i = 0; i < _list.length; i++) {
            if (o[i].selected) {
                o[i].downloading = true
                download(i, quarterSize)
            }
        }
    }
    // UpdateItem Downloads the file at index
    //func (ctrl *BridgeControl) UpdateItem(idx int) {
    function updateItem(idx) {console.debug("called.")
        // probably unneeded
    }
    // SwitchMode Switch the camera mode to rec/play/shutter
    //func (ctrl *BridgeControl) SwitchMode(mode string) {
    function switchMode(to) { console.debug("called.")
        // "play"
        // "rec"
        // "shutter"
        // "standalone"
        if (opc) {
            if (to === "shutter")
            cameraExecute("switch_cameramode", "mode=" + "rec")
        } else {
            cameraExecute("switch_cammode", "mode=" + to)
        }
    }
    // ShutterToggle Toggle the remote shutter
    //func (ctrl *BridgeControl) ShutterToggle(press bool) {
    function shutterToggle(press) {
        if (press) {
            if (opc) {
                cameraExecute("exec_takemotion", "com=newstarttake")
            } else {
                cameraExecute("exec_shutter", "com=1st2ndpush")
            }
        }
    }
    // HalfWayToggle Toggle remote focusing
    //func (ctrl *BridgeControl) HalfWayToggle(press bool) {
    function halfWayToggle(press) {
		if (press) {
			cameraExecute("exec_shutter", "com=1stpush")
		} else {
			cameraExecute("exec_shutter", "com=1strelease")
		}
	}
    // Connect Connects to the Camera
    //func (ctrl *BridgeControl) Connect() {
    function connect() {
		cameraGetValue("get_caminfo", "/caminfo/model", [], function(m) { setModel(m)} )
		cameraGetValue("get_connectmode", "/connectmode", [], function(t) {setCameraType(t)})
		if (type === "OPC") {
			cameraExecute("switch_commpath", "path=wifi")
			if (connected && !err) { switchMode("standalone") }
			if (model === "") { cameraGetValue("get_caminfo", "/caminfo/model") }
		}
        //connected = true
    }

    // SetModel BridgeControl Model setter 
    //func (ctrl *BridgeControl) SetModel(model string) {
    function setModel(m) {
        const re = /<model>([^<]+)<\/model>/
        model = m.match(re)[1]
        console.log(model)
    }
    function setCameraType(t) {
        const re = /<connectmode>([^<]+)<\/connectmode>/
        type = t.match(re)[1]
        console.log(type)
        //TODO: should change "connected" 
    }
    // GetFileList Check for files
    //func (ctrl *BridgeControl) GetFileList() {
    function getFileList() {
    		cameraGetFolder("/DCIM/100OLYMP")
    }
    // CameraGetValue Get a value from camera
    //func (ctrl *BridgeControl) CameraGetValue(query string, path string, params ...string) (string, error) {
    function cameraGetValue(query , xpath , params, cb ) {
	    fireQuery("", query, params, cb )
    }

    // CameraGetFolder Get file list from camera
    //func (ctrl *BridgeControl) CameraGetFolder(path string) error {
    function cameraGetFolder(path) {
	    fireQuery("", "get_imglist", [ "DIR=" + path, ], function(d) { handleImgList(d) } )

        console.debug("done.")
    }
    // CameraGetFile Gets a file from camera
    //func (ctrl *BridgeControl) CameraGetFile(file string) (image.Image, error) {
    function cameraGetFile(file){
        fireQuery("", "get_thumbnail", [ "DIR=" + file] )
    }
    // CameraDownloadFile Download a file from the camera
    //func (ctrl *BridgeControl) CameraDownloadFile(path string, file string, quarterSize bool) int64 { 
    //	downloadPath := config.DownloadPath + "/" + ctrl.Model
    function cameraDownloadFile(path , file , quarterSize) { 
        const dlPath = Qt.resolvedUrl(downloadPath + "/" + model)
        if (quarterSize) {
           const parms = [ "DIR=" + path + "/" + file, "size=2048"]
           fireQuery("", "get_resizeimg", parms)
        } else {
           const parms = [ path + "/" + file ]
           fireQuery("file", path + "/" + file)
        }
    }

    function fireQuery(requestType , query , params, callback){
       console.debug(requestType, " ", query, " ", params.join(" ") )

        if (!requestType || requestType === "") requestType = "GET"
        const paramString = (params.length > 0) ? "?" + params.join("&") : ""

        const xhr = new  XMLHttpRequest()
        if (requestType === "file") {
            xhr.open("GET", config.hostaddr + query + paramString)
        } else {
            xhr.open(requestType, config.hostaddr + query + ".cgi" + paramString)
        }
        xhr.setRequestHeader("User-Agent", config.agent)
        xhr.setRequestHeader("Host", config.host)
        xhr.send()
        xhr.onreadystatechange = function(event) {
            if (xhr.readyState == XMLHttpRequest.DONE) {
                console.debug("REQ: done,", xhr.status, xhr.statusText)
                if (xhr.status === 206) { // partial
                    var rdata = xhr.response;
                    callback(rdata)
                } else if (xhr.status === 200) {
                //} else if (xhr.status === 200 || xhr.status == 0) {
                    var rdata = xhr.response;
                    //console.debug("got:", rdata)
                    callback(rdata)
                } else {
                    console.debug("error in processing request.", query, xhr.status, xhr.statusText);
                    control.lastError = xhr.statusText;
                }
            }
        }
    }

    function handleImgList(data) {
        const d = data.split("\r\n")
        if (!d[0] === "VER_100") { console.debug("Prefix not correct"); return }
        d.forEach(function(line) {
            if ((line === "") || (line === "VER_100")) return
            // example line: /DCIM/100OLYMP,PA010242.JPG,7051179,0,21825,29424
            //               path          ,filename    ,size   ,?,?????,?????
            const rowData = line.split(",")
            const fileType = rowData[1].split(".")[1]
            const trollDir  = cachePath + "/" + model + rowData[0]
            const trollPath  = trollDir + "/" + rowData[1]
            // TODO: make only once!
            mkdirpath(trollDir)
            const e = {}
            // whats this for and why this value?
            //e["index"]       = rowData[1].substring(4,8) + fileType
            //e["index"]       = _list.count
            e["path"]        = rowData[0]
            e["file"]        = rowData[1]
            e["trollPath"]   = trollPath
            e["type"]        = fileType
            e["size"]        = Number(rowData[2])
            e["downloading"] = false
            e["selected"  ]  = false
            e["downloaded"]  = false
            e["quarter"   ]  = false
            //_list.append(e);

            // download thumbnails
            fi.url = Qt.resolvedUrl(trollPath);
            //fi.refresh();
            if (FileEngine.exists(trollPath) && (fi.size!==0)) {
                //console.debug("file exists:", e["file"], e["size"], fi.size)
                _list.append(e);
                return
            } else {
               dlq.append(e)
            }
        })
        console.debug("found", _list.count + "/" + d.length, "entries, ", dlq.count, "missing thumbs")
        //worker.sendMessage({ action: "download", parm: { model: dlq } })
        control.batchDownload();
    }

    function  handleDownloadedData(name, type, data, path){
        var tmp = sac.writeContentToFile( { "name": name, "type": type, "data": data })
        //console.debug("OK, file written.", tmp);
        FileEngine.rename(tmp, path + "/" + name, true);
        console.debug("OK, file copied.", path + "/"+ name);
    }


}

// vim: ft=javascript nu expandtab ts=4 sw=4 st=4

