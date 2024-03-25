import QtQuick 2.0
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
        //anchors.top: head.bottom
        anchors.fill: parent
        anchors.centerIn: parent
        //anchors.horizontalCenter: parent.horizontalCenter
        height: parent.height - head.height
        itemWidth: width - Theme.horizontalPageMargin

        model: root.model
        /*
        delegate: Image {
            width: view.itemWidth
            height: view.height
            sourceSize.width: 1024
            sourceSize.height: 1024
            property string image: path + "/" + file
            cache: true
            source: "image://python/" + image
            fillMode: Image.PreserveAspectFit
        }
        */
        delegate: ImageViewer {
            width: view.itemWidth
            height: view.height
            property string image: path + "/" + file
            photo.source: trollPath
            largePhoto.source: "image://python/" + image
        }
    }
}
