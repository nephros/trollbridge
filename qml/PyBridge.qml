import QtQuick 2.1
import Sailfish.Silica 1.0
import Nemo.FileManager 1.0
import io.thp.pyotherside 1.5

Item { id: control

    // my properties:
    property string cachePath: StandardPaths.cache
    property bool err: false
    property var lastError: ["",]

    property var cameraInfo: ({})

    /*
     * properties from trollbridge.go:
     */

    property ListModel _list: ListModel {}
    //property string downloadPath: StandardPaths.pictures + "/" + Qt.application.name
    property string downloadPath: StandardPaths.pictures + "/Olympus" // legacy
    property string model: ""
    property int free
    property string type: ""
    property bool connected: mainWindow.online && (!!model && (model !== ""))
    property bool downloading: false
    property bool opc: (type === "OPC")

    property bool live: false
    property var liveParms: []
    property string liveAddr: "192.168.0.10"
    property int livePort: 40000
    //property string liveUrl: "udp://" + liveAddr + ":" + livePort + "/"
    property string liveUrl: "rtp://" + liveAddr + ":" + livePort + "/"

    property int utcdiff

    /*
     * helper types and stuff
     */

    Python { id: ow
        property bool initialized: false

        signal error
        onError:   function(message)     {control.lastError += m.message }

        // message handlers
        function dlDone(index, quarter){
            console.info("Downloaded", index)
            _list.setProperty(index, "selected", false)
            _list.setProperty(index, "downloaded", true)
            _list.setProperty(index, "quarter", quarter)
        }
        // whatever information we received, create an object from that:
        function updateCameraInfo(info) {
            console.debug("Got Camera info", info)
            try {
                var props = JSON.parse(info)
                control.cameraInfo = props
                console.debug("Created cameraInfo object", JSON.stringify(control.cameraInfo,null,2))
            } catch(e) {
                console.warn("Could not parse cameraInfo", e)
            }
        }

        Component.onCompleted: {
            setHandler('error', error);
            setHandler('thumbdownloaded', dlDone);
            setHandler('downloaded', dlDone);
            setHandler('camerainfo', updateCameraInfo);
            addImportPath(Qt.resolvedUrl('../py'));
        }
        // functions
        function connect() {
            importModule("ow", [ ], function() {
                call('ow.info', [ ], function() {})
            })
        }
    }

    // file handling
    //property FileInfo fi: FileInfo{}

    Connections { target: mainWindow
        onWillQuit: cleanupOnExit()
    }
    function cleanupOnExit() {
        if (live)
            stopLiveView()
    }

    /*
     * functions from trollbridge.go:
     */

    //function runtimeVersion(){ return "QtQuick 2.1" }
    function version() { return Qt.application.version }

    // SwitchState Switch the camera on or off
    function switchState(on) {
        if (on) {
            ow.call("ow.sendCommand",  [ "exec_pwon"] )
        } else {
            ow.call("ow.sendCommand",  [ "exec_pwoff"] )
        }
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
        //cameraDownloadFile(_list.get(idx).path, _list.get(idx).file, quarterSize)
        ow.call('ow.downloadImage', [ _list.get(idx).path, _list.get(idx).file, idx, quarterSize ])
    }
    // DownloadSelected Downloads all selected files
    //func (ctrl *BridgeControl) DownloadSelected(quarterSize bool) {
    function downloadSelected(quarterSize) { console.debug("called.")
        for (var i = 0; i < _list.count; i++) {
            var o = _list.get(i);
            if (o.selected) {
                _list.setProperty(i, "downloading" , true)
                const path = o["path"] + "/" + o["file"]
                const out = downloadPath + "/" + control.model + "/" + o["file"]
                ow.call('ow.downloadImage', [ path, out, i, quarterSize])
            }
        }
    }
    // UpdateItem Downloads the file at index
    //func (ctrl *BridgeControl) UpdateItem(idx int) {
    function updateItem(idx) {console.debug("called.")
        // probably unneeded
        var o = _list.get(i);
        _list.setProperty(i, "downloading" , true)
        const path = o["path"] + "/" + o["file"]
        const out = downloadPath + "/" + control.model + "/" + o["file"]
        ow.call('ow.downloadImage', [ path, out, i, false])
    }
    // SwitchMode Switch the camera mode to rec/play/shutter
    //func (ctrl *BridgeControl) SwitchMode(mode string) {
    function switchMode(to) {
        console.info("Switching Camera into '%1' mode.".arg(to))
        // "play"
        // "rec"
        // "shutter"
        // "standalone"
        if (opc) {
            if (to === "shutter")
            ow.call('ow.sendCommand', [ "switch_cameramode", { "mode": to } ])
        } else {
            ow.call('ow.sendCommand', [ "switch_cammode", { "mode": to } ])
        }
    }
    // ShutterToggle Toggle the remote shutter
    //func (ctrl *BridgeControl) ShutterToggle(press bool) {
    function shutterToggle(press) {
        if (press) {
            if (opc) {
                ow.call('ow.sendCommand', [ "exec_takemotion", { "com": "newstarttake" } ])
            } else {
                ow.call('ow.sendCommand', [ "exec_shutter", { "com": "1st2ndpush" } ])
            }
        }
    }
    // HalfWayToggle Toggle remote focusing
    //func (ctrl *BridgeControl) HalfWayToggle(press bool) {
    function halfWayToggle(press) {
        if (press) {
            ow.call('ow.sendCommand', [ "exec_shutter", { "com": "1stpush" } ])
        } else {
            ow.call('ow.sendCommand', [ "exec_shutter", { "com": "1strelease" } ])
        }
    }
    // Connect Connects to the Camera
    //func (ctrl *BridgeControl) Connect() {
    function connect() {
        ow.connect()
        ow.call("ow.getCameraModel", [], function(m) { setModel(m["model"])} )
        ow.call("ow.getFreeSpace", [], function(s) { setSpace(s["unused"]) })
        //ow.call('ow.sendCommand', [ "get_connectmode", {} ], function(t) {setCameraType(t)})
        ow.call("ow.getConnectMode", [], function(t) {setCameraType(t["connectmode"])})
        ow.call('ow.info', [ ], function() {})

        connected = true
    }

    // SetModel BridgeControl Model setter 
    //func (ctrl *BridgeControl) SetModel(model string) {
    function setModel(m) { model = m; console.info("Model:", model) }
    function setSpace(s) { free = s }
    function setCameraType(t) { type = t; console.info("Connection Type:", t)}

    function setLive(l, parms) { live = l; liveParms = parms; console.info("LiveView parameters:", parms ) }

    // GetFileList Check for files
    //func (ctrl *BridgeControl) GetFileList() {
    function getFileList() {
        cameraGetFolder("/DCIM/100OLYMP")
    }

    function setTime() {
        ow.call("ow.setClock")
    }
    function startLiveView() {
        // fixme: don't use fixed quality
        console.debug("Starting LiveView")
        //ow.call("ow.camera.start_liveview", [ control.livePort , "0800x0600" ], function(res) { setLive(true); console.debug(JSON.stringify(res)) })
        ow.call("ow.camera.start_liveview", [ control.livePort , "0640x0480" ], function(res) { setLive(true, res) })
    }
    function stopLiveView() {
        ow.call("ow.camera.stop_liveview", [], function(res) { setLive(false) })
    }

    // CameraGetFolder Get file list from camera
    //func (ctrl *BridgeControl) CameraGetFolder(path string) error {
    function cameraGetFolder(path) {
        ow.call('ow.listImages', [ path ], function(l) {
            _list.clear()
            var d = JSON.parse(l)
            for (var i=0; i<d.length; i++) {
                const e = {}
                // what was this used for in original TrollBridge and why this value?
                //e["index"]       = rowData[1].substring(4,8) + fileType
                //e["index"]       = _list.count
                var spl = d[i]["file_name"].split("/")
                const fileName  = spl.pop()
                const filePath  = spl.join("/")
                const trollDir  = cachePath + "/" + model + filePath
                const trollPath  = trollDir + "/" + fileName

                e["file"]        = fileName
                e["path"]        = filePath
                e["trollPath"]   = trollPath
                e["type"]        = FileEngine.extensionForFileName(fileName)
                e["size"]        = d["file_size"]
                e["downloading"] = false
                e["selected"  ]  = false
                e["downloaded"]  = false
                e["quarter"   ]  = false

                const wanted = downloadPath + "/" + control.model + "/" + e["file"]
                if (FileEngine.exists(wanted)) {
                    console.log("exists:", wanted)
                    e["downloaded"]  = true
                }
                if (!FileEngine.exists(trollPath)) {
                    console.debug("Does not exist:" , trollPath)
                    ow.call('ow.getThumbnail', [d[i]["file_name"],trollPath] )
                }
                //console.debug("model element:", JSON.stringify(e))
                _list.append(e)
            }
        })
        console.debug("done.")
    }

}
// vim: ft=javascript nu expandtab ts=4 sw=4 st=4
