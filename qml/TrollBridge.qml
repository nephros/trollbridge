import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        PullDownMenu {
            id: pullDownMenu
            MenuItem {
                text: qsTr("About %1").arg("Troll Bridge")
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }
            MenuItem {
                text: qsTr("Connect to Wi-Fi...")
                onClicked: wifi.connect()
            }
            MenuItem {
                text: qsTr("Open Webview")
                onClicked: pageStack.push(Qt.resolvedUrl("wv/WVPage.qml"))
            }
            busy: bridge.connected ? false : (!mainWindow.connected)
        }

        PushUpMenu {
            id: pushUpMenu
            enabled: bridge.connected
            visible: enabled
            MenuItem {
                objectName: "cameraSwitch"
                text: qsTr("Power Off")
                enabled: bridge.connected
                onClicked: bridge.switchState(false)
            }
        }

        VerticalScrollDecorator {}
        Column {
            id: column
            spacing: Theme.paddingLarge
            width: parent.width
            PageHeader { title: "Troll Bridge" }
            Image {
                height: Theme.itemSizeMedium
                sourceSize.height: height
                //width: parent.width
                //anchors.centerIn: parent
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                source: (Theme.colorScheme === Theme.LightOnDark ) ?  Qt.resolvedUrl("logo/OlympusLogoWhiteAndGoldRGB.png") : Qt.resolvedUrl("logo/OlympusLogoBlueAndGoldRGB.png")
            }
            Label {
                objectName: "modelLabel"
                text: bridge.connected ? bridge.model : qsTr("not connected")
                anchors.horizontalCenter: parent.horizontalCenter
                color: mainWindow.palette.highlightColor
                font.pixelSize: Theme.fontSizeLarge
                font.family: Theme.fontFamilyHeading
            }
            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                height: Theme.iconSizeLarge
                sourceSize.height: height
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                source: {
                    if (!online) return "" //"image://theme/icon-m-wlan-no-signal"
                    if (/^E-M/.test(bridge.model))  return "devices/olympus-om-d.png"
                    if (/^AIR-/.test(bridge.model)) return "devices/olympus-air.png"
                    if (/PEN/.test(bridge.model))   return "devices/olympus-pen.png"
                    if (/^E-P/.test(bridge.model))  return "devices/olympus-pen.png"
                    if (/^TG/.test(bridge.model))   return "devices/olympus-tg.png"
                    return "image://theme/icon-m-camera"
                }
            }
            Label {
                text: qsTr("Please connect the camera Wi-Fi")
                visible: !bridge.connected
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Button {
                text: qsTr("Photos")
                icon.source: "image://theme/icon-m-file-image"
                visible: bridge.connected
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    bridge.switchMode("play")
                    bridge.getFileList()
                    pageStack.push(Qt.resolvedUrl("ImageList.qml"), { "photoModel": bridge._list })
                }
            }

            SecondaryButton {
                text: qsTr("Shutter")
                icon.source: "image://theme/icon-cover-camera"
                visible: bridge.connected
                enabled: !bridge.opc
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    bridge.switchMode("shutter")
                    pageStack.push(Qt.resolvedUrl("Shutter.qml"))
                }
            }

            Button {
                text: qsTr("Live View")
                icon.source: "image://theme/icon-m-file-image"
                visible: bridge.connected
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    bridge.switchMode("rec")
                    pageStack.push(Qt.resolvedUrl("LiveView.qml"))
                }
            }

            SecondaryButton {
                text: qsTr("Setup")
                icon.source: "image://theme/icon-m-setting"
                visible: bridge.connected
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Setup.qml"))
                }
            }
        }
    }
}

