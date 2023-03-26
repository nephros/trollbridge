import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
	SilicaFlickable {
		anchors.fill: parent
		contentHeight: column.height + Theme.paddingLarge

		PullDownMenu {
			id: pullDownMenu
			MenuItem {
				text: qsTr("About Troll Bridge")
				onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
			}
			MenuItem {
				text: qsTr("Connect to WiFi...")
				onClicked: wifi.connect()
			}
			busy: bridge.connected ? false : (!mainWindow.connected)
		}

		PushUpMenu {
			id: pushUpMenu
			enabled: bridge.connected
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
			PageHeader { title: qsTr("Troll Bridge") }
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
				text: bridge.model
				anchors.horizontalCenter: parent.horizontalCenter
				color: mainWindow.palette.highlightColor
				font.pixelSize: Theme.fontSizeLarge
				font.family: Theme.fontFamilyHeading
			}
			
			Label {
				text: "Please connect the camera WiFi"
				visible: !bridge.connected
				anchors.horizontalCenter: parent.horizontalCenter
			}

			Button {
				text: "Images"
				icon.source: "image://theme/icon-m-file-image"
				visible: bridge.connected
				anchors.horizontalCenter: parent.horizontalCenter
				onClicked: {
					bridge.switchMode("play")
					bridge.getFileList()
					pageStack.push(Qt.resolvedUrl("ImageList.qml"))
				}
			}

			SecondaryButton {
				text: "Shutter"
				icon.source: "image://theme/icon-m-cover-camera"
				visible: bridge.connected && !bridge.opc
				anchors.horizontalCenter: parent.horizontalCenter
				onClicked: {
					bridge.switchMode("shutter")
					pageStack.push(Qt.resolvedUrl("Shutter.qml"))
				}
			}

			Button {
				enabled: false
				text: qsTr("Live View")
				icon.source: "image://theme/icon-m-file-image"
				visible: bridge.connected
				anchors.horizontalCenter: parent.horizontalCenter
				onClicked: {
					bridge.switchMode("rec")
					bridge.bindToEvents()
					pageStack.push(Qt.resolvedUrl("ImageList.qml"))
				}
			}
		}
	}
}

