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

        ButtonLayout { id: buttons
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
            Button { text: qsTr("Setup"); onClicked: pageStack.push(setupPage) }
            Button { text: qsTr("Stop LiveView"); onClicked: bridge.stopLiveView() }
        }

        Page { id: setupPage
            SilicaListView { id: view
                anchors.fill: parent
                onCountChanged: console.debug(count, "controls")
                model: bridge.liveParms
                delegate: ComboBox { id: box
                    width: ListView.view.width
                    property string propName: modelData
                    label: propertyMap[propName] ? propertyMap[propName].label : propName
                    menu: ContextMenu {
                        Repeater { id: menuRep
                            model: bridge.cameraInfo["propertyInfo"][box.propName]
                            delegate: MenuItem { text: modelData }
                        }
                    }
                }
            }
        }
    }
}
