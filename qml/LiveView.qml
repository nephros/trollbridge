import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: livePage

    onStatusChanged: {
        if (status == PageStatus.Deactivating && _navigation == PageNavigation.Back) {
             bridge.switchMode(bridge.opc ? "standalone" : "play")
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height + Theme.paddingLarge

        PageHeader { title: qsTr("Live View") }

        Rectangle { content
            width: parent.width - Theme.paddingLarge
            height: parent.width - Theme.paddingLarge

            MediaPlayer { id: player
                autoPlay: true
                muted: true
                source: bridge.live ? "udp://" + bridge.liveAddr + ":" + bridge.livePort : ""
            }

            VideoOutput { id: video
                source: player
                anchors.centerIn: parent
                focus : visible // to receive focus and capture key events when visible
                fillMode: VideoOutput.Stretch
            }
        }

        //ValueButton { label: qsTr("Take Mode")            ; value: ""; onClicked: {} }
        //ValueButton { label: qsTr("Drive Mode")           ; value: ""; onClicked: {} }
        //ValueButton { label: qsTr("Focal Value")          ; value: ""; onClicked: {} }
        //ValueButton { label: qsTr("Exposure Compensation"); value: ""; onClicked: {} }
        //ValueButton { label: qsTr("Shutter Speed")        ; value: ""; onClicked: {} }
        //ValueButton { label: qsTr("ISO Speed")            ; value: ""; onClicked: {} }
        //ValueButton { label: qsTr("White Balance")        ; value: ""; onClicked: {} }
        //ValueButton { label: qsTr("Art Filter")           ; value: ""; onClicked: {} }
        //ValueButton { label: qsTr("Color Tone")           ; value: ""; onClicked: {} }
        //ValueButton { label: qsTr("Color Phase")          ; value: ""; onClicked: {} }
        //ValueButton { label: qsTr("Movie Exposure")       ; value: ""; onClicked: {} }
    }
}
