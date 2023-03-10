import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

	Image {
		source: "./cover.png"
		z: -1
		anchors {
			//bottom: parent.bottom
			//horizontalCenter: parent.horizontalCenter
			centerIn: parent
		}
		sourceSize.width: Theme.iconSizeLarge*2
		fillMode: Image.PreserveAspectFit
		opacity: 0.2
	}
	Column {
		anchors.centerIn: parent
		width: parent.width
		spacing: Theme.paddingMedium

		Image {
			anchors.horizontalCenter: parent.horizontalCenter
			source: "image://theme/harbour-trollbridge"
		}

		Label {
			id: coverdata
			objectName: "coverData"
			anchors.horizontalCenter: parent.horizontalCenter
			color: mainWindow.palette.highlightColor
			font.pixelSize: Theme.fontSizeLarge
			text: (bridge.connected ? bridge.model + "<br>" + "connected" : "disconnected")
		}

		CoverActionList {
			enabled: bridge.connected

			CoverAction {
				iconSource: "image://theme/icon-m-reset"
				onTriggered: bridge.switchState(false)
			}
		}
	}
}
