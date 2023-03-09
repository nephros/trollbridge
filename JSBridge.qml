import QtQuick 2.1

QtObject {
    property var config: {
        downloadPath: "" 
    }

    property string model: "unknown"
    property bool connected: true
    property bool downloading: false
    property bool opc
    readonly property string version: Qt.application.version
    function switchState(b_what){}

    // worker functions:
	//function CameraGetValue("get_caminfo", "/caminfo/model")
	function cameraGetValue(cmd, path){}
	//ctrl.CameraExecute("exec_pwon", "")
	//ctrl.CameraExecute("exec_pwoff", "")
	function cameraExecute(cmd, path){}
   
    // GetImage Get image at list index
    //func (ctrl *BridgeControl) GetImage(index int) *File {
    function getImage(index)  {}
    // SetSelection Set selection at list index
    //func (ctrl *BridgeControl) SetSelection(index string, value bool) {
    function setSelection(index, value) {}
    // SetSelectionItem Set selection at list index
    //func (ctrl *BridgeControl) SetSelectionItem(idx int, value bool) {
    function setSelectionItem(idx, value) {}
    // ClearAllSelection Clears the file list selection
    //func (ctrl *BridgeControl) ClearAllSelection() {
    function clearAllSelection() {}
    // Download Downloads the file at index
    //func (ctrl *BridgeControl) Download(idx int, quarterSize bool) {
    function download(idx , quarterSize) {}
    // DownloadSelected Downloads all selected files
    //func (ctrl *BridgeControl) DownloadSelected(quarterSize bool) {
    function downloadSelected(quarterSize) {}
    // UpdateItem Downloads the file at index
    //func (ctrl *BridgeControl) UpdateItem(idx int) {
    function updateItem(idx) {}
    // SwitchMode Switch the camera mode to rec/play/shutter
    //func (ctrl *BridgeControl) SwitchMode(mode string) {
    function switchMode(mode) {
        // "play"
        // "rec"
        // "shutter"
        // "standalone"
        if (opc) {
            if (mode === "shutter") mode = "rec"
            cameraExecute("switch_cameramode", "mode=" + mode)
        } else {
            cameraExecute("switch_cammode", "mode=" + mode)
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

    // SetModel BridgeControl Model setter 
    //func (ctrl *BridgeControl) SetModel(model string) {
    function setModel(m) {
        model = m
        console.log("changed: " + model)
        //TODO: should change "connected" 
    }
    // GetFileList Check for files
    //func (ctrl *BridgeControl) GetFileList() {
    function getFileList() {
    		cameraGetFolder("/DCIM/100OLYMP")
    }
    // CameraGetValue Get a value from camera
    //func (ctrl *BridgeControl) CameraGetValue(query string, path string, params ...string) (string, error) {
    function cameraGetValue(query , path , params) {}

    // CameraGetFolder Get file list from camera
    //func (ctrl *BridgeControl) CameraGetFolder(path string) error {
    function cameraGetFolder(path) {}
    // CameraGetFile Gets a file from camera
    //func (ctrl *BridgeControl) CameraGetFile(file string) (image.Image, error) {
    function cameraGetFile(file ){
        fireQuery("", "get_thumbnail", ["DIR=" + file] )
    }
    // CameraDownloadFile Download a file from the camera
    //func (ctrl *BridgeControl) CameraDownloadFile(path string, file string, quarterSize bool) int64 { 
    //	downloadPath := config.DownloadPath + "/" + ctrl.Model
    function cameraDownloadFile(path , file , quarterSize) { 
        const	downloadPath = config.DownloadPath + "/" + model
        if (quarterSize) {
           fireQuery("", "get_resizeimg", [ "DIR=" + path + "/" + file, "size=2048"]) {
        } else {
           fireQuery("file", path + "/" + file)
        }
    }

    function fireQuery(requestType , query , params){

        const addr = "http://192.168.0.10/" 
        const paramString = ""
        if (params.length > 0) {
            paramString = "?" + params.join("&")
        }

        // TODO
        // Shorten the delay for camera detection
        //if query == "get_caminfo" {
        //	client = &http.Client{
        //		Timeout: time.Duration(2 * time.Second),
        //	}
        //} else {
        //	client = &http.Client{}
        //}

        if (!requestType || requestType === "") requestType = "GET"

        const xhr
        if (requestType === "file") {
            xhr =new  XMLHttpRequest()
            xhr.open("GET", "http://192.168.0.10/" + query + paramString)
        } else {
            xhr = new XMLHttpRequest()
            xhr.open(requestType, "http://192.168.0.10/" + query + ".cgi" + paramString)
        }
        req.setRequestHeader("User-Agent", "OlympusCameraKit")
        req.setRequestHeader("Host", "192.168.0.10")
        req.send()
        r.onreadystatechange = function(event) {
            if (r.readyState == XMLHttpRequest.DONE) {
                if (partial && r.status === 206) {
                    var rdata = JSON.parse(r.response);
                    callback(rdata)
                } else if (r.status === 200 || r.status == 0) {
                    var rdata = JSON.parse(r.response);
                    callback(rdata)
                } else {
                    console.debug("error in processing request.", query, r.status, r.statusText);
                    obj.lastError = r.statusText;
                }
            busy = false;
            }
        }

        return res
    }

}

// vim: ft=javascript nu expandtab ts=4 sw=4 st=4
