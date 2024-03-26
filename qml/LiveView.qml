import QtQuick 2.0
import QtMultimedia 5.6
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0

Page {
    id: livePage

    onStatusChanged: {
        if (status == PageStatus.Deactivating && _navigation == PageNavigation.Back) {
             content.source = ""
             bridge.stopLiveView()
             bridge.switchMode(bridge.opc ? "standalone" : "play")
        }
        if (status == PageStatus.Active) {
             bridge.startLiveView()
        }
    }

    Connections {
        target: bridge
        onLiveChanged: {
            console.debug("Live status changed:", bridge.live)
            if (bridge.live) {
                //content.source = bridge.liveUrl
                //content.play()
                delay.restart()
            } else {
                content.pause()
                content.source = ""
                delay.stop()
            }
        }
    }
    Timer { id: delay
        interval: 1000
        running: false
        onTriggered: {
            content.source = bridge.liveUrl
            content.play()
        }
    }
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height + Theme.paddingLarge + header.height

        PageHeader { id: header; title: qsTr("Live View") }

        Video { id: content
            anchors.top: header.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width:  800 + Theme.paddingLarge
            height: 600 + Theme.paddingLarge
            muted: true
            autoPlay: false
            autoLoad: true
            onPlaybackStateChanged: console.info("Now Playing", playbackState)
            onStatusChanged: console.debug(content.status)
            onSourceChanged: console.debug(source)
            onBufferProgressChanged: console.debug(bufferProgress)
        }
        /*
        VideoPoster { id: content
            anchors.top: header.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width:  800 + Theme.paddingLarge
            height: 600 + Theme.paddingLarge
            onLoadedChanged: console.debug(loaded)
            onBusyChanged:   console.debug(busy)
            onStatusChanged: console.debug(content.status)
            onSourceChanged: console.debug(content.source)
            function play() {playing = true}
            function pause() {togglePlay()}
        }
        */
        /*
        Rectangle { id: content
            anchors.top: header.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            color: "gray"
            width:  800 + Theme.paddingLarge
            height: 600 + Theme.paddingLarge


            MediaPlayer { id: player
                muted: true
                onPlaybackStateChanged: console.info("Now Playing", playbackState)
            }

            VideoOutput { id: video
                source: player
                anchors.centerIn: parent
                focus : visible // to receive focus and capture key events when visible
                fillMode: VideoOutput.Stretch
            }
        }
        */
        ButtonLayout {
            anchors.top: content.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            Button { text: qsTr("Play/Pause")
                onClicked: content.play()
            }
            Button { text: qsTr("Take Picture")
                onPressedChanged: { 
                    if (!pressed) {
                        bridge.ow.call("ow.camera.take_picture", [], function(res) { setLive(false) })
                    }
                }
            }
            Button { text: qsTr("Stop LiveView"); onClicked: bridge.stopLiveView() }
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
