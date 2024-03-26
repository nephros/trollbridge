import QtQuick 2.0
import Nemo.FileManager 1.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0

Page { id: root

    property ListModel model
    backgroundColor: "#808080"

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: view.height

        PullDownMenu {
            enabled: !view.dragging && !view.flicking
            MenuItem { text: qsTr("Select for download");    onClicked: bridge.setSelection(view.currentIndex, true); visible: !view.currentItem.isSelected }
            MenuItem { text: qsTr("Unselect for download");  onClicked: bridge.setSelection(view.currentIndex, false); visible: view.currentItem.isSelected }
        }

        SlideshowView {
            id: view

            //anchors.fill: parent
            anchors.centerIn: parent
            height: isPortrait ? Screen.height : Screen.width
            itemWidth: width //- Theme.horizontalPageMargin

            model: root.model

            delegate: ImageViewer {
                property bool isSelected: selected
                width:  view.itemWidth
                height: view.height
                property string remote: "image://python/" + path + "/" + file
                property string local: bridge.downloadPath + "/" + bridge.model + "/" + file
                photo.source: trollPath
                largePhoto.source: (downloaded && FileEngine.exists(local)) ? local : remote
            }
        }
    }
}
