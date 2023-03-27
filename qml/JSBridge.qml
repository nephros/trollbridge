import QtQuick 2.1
import Sailfish.Silica 1.0
import Nemo.FileManager 1.0
import io.thp.pyotherside 1.5
//import Sailfish.Share 1.0
//import "js/db.js" as DB
//import "js/base64.js" as Base64

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
    property int numDownloads: 0 // rate limit, overwhelming the camera will lead to 503 errors

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

    // Simple script to store replace JS worker script:
    Python { id: worker
        signal queued
        signal timeout
        signal refused
        signal error
        signal dlModelChanged // necessary?
        signal thumbReceived // necessary?
        signal imgReceived   // necessary?
        onQueued:  function(count)       {control.numDownloads = count }
        onError:   function(message)     {control.lastError += m.message }
        onRefused: function()            {dlqueue.stop()}
        onDlModelChanged: function(model) {
            control.qModel.clear()
            model.forEatch(function(e) { control.qModel.append(e) })
        }
        // init
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../py'));
            importModule("dl", [ ], function() {} )
            setHandler('queued',  queued);
            setHandler('timeout', timeout);
            setHandler('refused', refused);
            setHandler('error',   error);
            //setHandler('thumbReceived', queued);
            //setHandler('imgReceived'  , queued);
        }
        // calls
        function setDownloadPath(path) {
            call("dl.setDownloadPath", [path], null)
        }
        function download(mode, model) {
            // FIXME: how to get a true listmodel in py?
            var dllist = []
            for (var i=0;i<model.count;i++){
                dllist[dllist.length] = model.get(i)
            }
            call("dl.downloadList", [ mode, dllist ], function(){})
        }
        function mkpath(path)          { call("dl.assertPathExists", [ path ], function(){}) }
    }


    // Simple script to store files because passing data from WScript to QML never works.
    Python { id: py
        Component.onCompleted: {
            //addImportPath(Qt.resolvedUrl('./'));
            //addImportPath(Qt.resolvedUrl('../lib'));
            addImportPath(Qt.resolvedUrl('../py'));
            importModule("writer", [ ], function() {} ) }
            function writeImage(data, path) {
                call("writer.writeImage", [ data, path ], function(){})
            }
    }

    // WS for mass downloads, and queued requests
    /*
    WorkerScript { id: worker
        source: "js/worker.js"
        onMessage: function(m) {
            if (m.event === "thumbReceived") {
                handleDownloadedImage(m.name, m.meta.type, m.data.base64, m.path) }
            else if (m.event === "imgReceived") {
                handleDownloadedImage(m.name, m.meta.type, m.data.base64, control.downloadPath + "/" + m.name) }
            else if (m.event === "error")    {control.lastError += m.message }
            else if (m.event === "refused")  {dlqueue.stop()}
            else if (m.event === "queued")   {control.numDownloads = m.count }
            else { console.warn("Unhandled message from worker:", m.event) }
        }
    }
    */
    // file handling
    property FileInfo fi: FileInfo{}

    // queue for downloads, passed to worker:
    ListModel { id: qModel
        property string mode: "thumb"; // switched to image mode later
    }
    Timer{ id: dlqueue
        repeat: (qModel.count > 0 )
        interval: 1200
        onRunningChanged: {
            if (running) console.info("Starting download for %1 images (%2).".arg(qModel.count).arg(qModel.mode))
        }
        onTriggered: {
            if (qModel.count <= 0){ stop(); console.info("queue empty"); return }
            //worker.sendMessage({ action: "download", mode: qModel.mode, model: qModel })
            worker.download(qModel.mode, qModel)
        }
    }

    // assert all dl paths are there:
    onDownloadPathChanged: {
        worker.setDownloadPath(downloadPath)
        worker.mkpath(downloadPath)
    }
    onModelChanged: checkPaths()
    function checkPaths() {
        worker.mkpath(downloadPath + "/" + model)
        worker.mkpath(cachePath    + "/" + model)
    }
    function mkdirpath(p) {
        worker.mkpath(p);
    }
    /*
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
    */

    /*
    function handleDownloadedImage(name, type, data, path) {
        //const url = 'data:' + type + ';base64,' + data;
        py.writeImage(data, path )
    }
    */

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
    function setSelection(index, value){ console.debug("called:",index,value)
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
    function downloadSelected(quarterSize) { console.debug("called.")
        qModel.clear();
        qModel.mode = (!!quarterSize) ? "imagesmall" : "image"
        for (var i = 0; i < _list.count; i++) {
            var o = _list.get(i);
            if (o.selected) {
                //o.downloading = true
                _list.setProperty(i, "downloading" , true)
                qModel.append(o);
            }
        }
        dlqueue.start();
    }
    // UpdateItem Downloads the file at index
    //func (ctrl *BridgeControl) UpdateItem(idx int) {
    function updateItem(idx) {console.debug("called.")
        // probably unneeded
    }
    // SwitchMode Switch the camera mode to rec/play/shutter
    //func (ctrl *BridgeControl) SwitchMode(mode string) {
    function switchMode(to) { console.info("Switching Camera into '%1' mode.".arg(to))
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

    /* ----- Unused functions ----- */
    // CameraGetFile Gets a file from camera
    //func (ctrl *BridgeControl) CameraGetFile(file string) (image.Image, error) {
    function cameraGetFile(file){
        fireQuery("", "get_thumbnail", [ "DIR=" + file] )
    }
    /* ^^^^^ Unused functions ^^^^^ */

    // CameraDownloadFile Download a file from the camera
    //func (ctrl *BridgeControl) CameraDownloadFile(path string, file string, quarterSize bool) int64 { 
    //	downloadPath := config.DownloadPath + "/" + ctrl.Model
    function cameraDownloadFile(path , file , quarterSize) { 
        const dlPath = Qt.resolvedUrl(downloadPath + "/" + model)
        if (quarterSize) {
           fireQuery("", "get_resizeimg", [ "DIR=" + path + "/" + file, "size=2048"])
        } else {
           fireQuery("file", [ path + "/" + file ])
        }
    }

    // send a web request to the camera - all except image downloads:
    function fireQuery(requestType , query , params, callback){
       //console.debug(requestType, " ", query, " ", params.join(" ") )
       if (typeof(callback) == undefined) {
           console.debug("WARNING: no callback defined!")
           callback = function() {};
       }

        if (!requestType || requestType === "") requestType = "GET"
        const paramString = (params.length > 0) ? "?" + params.join("&") : ""

        const xhr = new XMLHttpRequest()
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
                //console.debug("fireQuery: done,", xhr.status, xhr.statusText)
                if (xhr.status === 200) {
                    var rdata = xhr.response;
                    callback(rdata)
                } else {
                    console.warn("error in processing request.", query, xhr.status, xhr.statusText);
                    control.lastError = xhr.statusText;
                }
            }
        }
    }

    // populate the model with metadata, check for thumbnail existence, download if missing
    function handleImgList(data) {
        const d = data.split("\r\n")
        if (!d[0] === "VER_100") { console.debug("Prefix not correct"); return }
        qModel.mode = "thumb";
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
            // what was this used for in original TrollBridge and why this value?
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

            _list.append(e);
            fi.url = Qt.resolvedUrl(trollPath);
            if (FileEngine.exists(trollPath)
                && (fi.size!==0)
                && (
                    (fi.mimeType === "image/jpeg") ||
                    (fi.mimeType === "image/png")  ||
                    (fi.mimeType === "image/gif")
                )
            ) { // exists and doesn't look corrupt
                return
            } else { // does not exist or looks corrupt:
               if (FileEngine.exists(trollPath)) FileEngine.deleteFiles(trollPath);
               qModel.append(e)
            }
        })
        console.debug("found %1/%2 entries, %3 missing thumbs.".arg(_list.count).arg(d.length).arg(qModel.count));
        if (qModel.count > 0) dlqueue.start();
    }
}

// vim: ft=javascript nu expandtab ts=4 sw=4 st=4
