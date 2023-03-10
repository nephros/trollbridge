import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
	Component.onCompleted: if (!bridge.connected) dbus.connect()
	SilicaFlickable {
		anchors.fill: parent
		contentHeight: column.height + Theme.paddingLarge

		PullDownMenu {
			id: pullDownMenu
			MenuItem {
				text: qsTr("About Troll Bridge")
				onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
			}
		}

		PushUpMenu {
			id: pushUpMenu
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
				visible: bridge.connected
				anchors.horizontalCenter: parent.horizontalCenter
				onClicked: {
					bridge.switchMode("play")
					bridge.getFileList()
					pageStack.push(Qt.resolvedUrl("ImageList.qml"))
				}
			}
			
			Button {
				text: "Shutter"
				visible: bridge.connected && !bridge.opc
				anchors.horizontalCenter: parent.horizontalCenter
				onClicked: {
					bridge.switchMode("shutter")
					pageStack.push(Qt.resolvedUrl("Shutter.qml"))
				}
			}
			
			// Button {
			// 	text: "Live View"
			// 	visible: bridge.connected
			// 	anchors.horizontalCenter: parent.horizontalCenter
			// 	onClicked: {
			// 		bridge.switchMode("rec")
			// 		bridge.bindToEvents()
			// 		pageStack.push(Qt.resolvedUrl("ImageList.qml"))
			// 	}
			// }
		}
	}
}

