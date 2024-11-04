import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.WebView 1.0
import Sailfish.WebEngine 1.0

WebViewPage { id: wv
    backNavigation: view.loaded

    //onStatusChanged: {
    //}
    //header: PageHeader {
    //    title: (imageList.mode !== "" ? imageList.mode : qsTr("Photos"))
    //}

    WebView { id: view

        anchors.fill: parent

        url: "http://" + nwHelper.ip + "/DCIM"
        //httpUserAgent: "OI.Share v2"
        httpUserAgent: "OlympusCameraKit"
        //Component.onCompleted: {
        //    WebEngineSettings.setPreference()
        //}
    }
}
