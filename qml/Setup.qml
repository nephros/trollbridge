import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: setupPage

    onStatusChanged: {
        if (status == PageStatus.Deactivating && _navigation == PageNavigation.Back) {
             bridge.switchMode(bridge.opc ? "standalone" : "play")
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        // PullDownMenu {
        //  id: pullDownMenu
        //  MenuItem {
        //      text: qsTr("")
        //      onClicked: pageStack.push(Qt.resolvedUrl(""))
        //  }
        // }

        VerticalScrollDecorator {}
        Column {
            id: column
            spacing: Theme.horizontalPageMargin
            width: parent.width
            PageHeader { title: qsTr("Camera Setup") }

            Button {
                text: "Set Date/Time"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: bridge.setTime()
            }
        }
    }
}
