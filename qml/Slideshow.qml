import QtQuick 2.0
import Nemo.FileManager 1.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0

Page { id: root

    property ListModel model
    backgroundColor: olygray

    PageHeader { id: head
        title: qsTr("Slideshow")
    }

    SlideshowView {
        id: view

        onCurrentIndexChanged: {
            if (currentIndex >= 0) {
            var o = model.get(currentIndex)
            head.description = o["file"]
            }
        }
        anchors.fill: parent
        anchors.centerIn: parent
        height: parent.height - head.height
        itemWidth: width //- Theme.horizontalPageMargin

        model: root.model

        delegate: ImageViewer {
            width: view.itemWidth
            height: view.height
            property string remote: "image://python/" + path + "/" + file
            property string local: bridge.downloadPath + "/" + bridge.model + "/" + file
            photo.source: trollPath
            largePhoto.source: (downloaded && FileEngine.exists(local)) ? local : remote
        }
    }
}
