import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

	Column {
		anchors.centerIn: parent
		width: parent.width
		spacing: Theme.paddingMedium

		Image {
			anchors.horizontalCenter: parent.horizontalCenter
			source: (bridge.connected) ? "image://theme/harbour-trollbridge" : "./cover.png"
			width: Theme.iconSizeLarge
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
