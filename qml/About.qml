import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: aboutpage
    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height + Theme.paddingLarge

        VerticalScrollDecorator {}

        Column {
            id: col
            spacing: Theme.paddingLarge
            width: parent.width
            PageHeader { title: qsTr("About %1").arg("Troll Bridge") }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "image://theme/harbour-trollbridge"
                height: Theme.iconSizeLarge
                width: Theme.iconSizeLarge
                sourceSize.height: height
                sourceSize.width: width
                fillMode: Image.PreserveAspectFit
            }

            SectionHeader {
                text: qsTr("Information")
            }
            Label {
                text: qsTr("TRaveller's OLympus Bridge is an Olympus cameras control application")
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                width: (parent ? parent.width : Screen.width) - Theme.paddingLarge * 2
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                x: Theme.paddingLarge
            }
            Label {
                text: qsTr("Troll Bridge supports both OM-D/PEN WiFi cameras and Olympus Air.<br><br>\
                The name of the application was chosen in memory of Terry Pratchett, who died on March 12th, 2015.<br>\
                The original application has been built using GO language and QML bindings.<br>\
                Rewritten to replace GO with Python by nephros.\
                Because of this, the Python version is dedicated to green trolls everywhere.")

                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                width: (parent ? parent.width : Screen.width) - Theme.paddingLarge * 2
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                x: Theme.paddingLarge
            }

            SectionHeader {
                text: qsTr("Copyright")
            }
            Label {
                text: "© 2016 Bundyo"
                x: Theme.paddingLarge
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
            }
            Label {
                text: "© 2023,2024 nephros"
                x: Theme.paddingLarge
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
            }
            Label {
                text: qsTr("Released under the <a href='https://mit-license.org/'>MIT license</a>.")
                x: Theme.paddingLarge
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                linkColor: "lightsteelblue"
            }

            SectionHeader {
                text: qsTr("Additional Copyright")
            }

            Label {
                text: qsTr("<a href='https://github.com/joergmlpts/olympus-wifi/'>olympus-wifi Python module</a> © joergmlpts.")
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                width: (parent ? parent.width : Screen.width) - Theme.paddingLarge * 2
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                linkColor: "lightsteelblue"
                x: Theme.paddingLarge
            }
            Label {
                text: qsTr("<a href='https://together.jolla.com/question/105098/how-to-setup-go-142-15-16-runtime-and-go-qml-pkg-for-mersdk/'>GO-QML port to Sailfish OS</a> © Nekron.")
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                width: (parent ? parent.width : Screen.width) - Theme.paddingLarge * 2
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                linkColor: "lightsteelblue"
                x: Theme.paddingLarge
            }
            Label {
                text: qsTr("<a href='https://github.com/go-qml/qml'>GO-QML package</a> © Gustavo Niemeyer.")
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                width: (parent ? parent.width : Screen.width) - Theme.paddingLarge * 2
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                linkColor: "lightsteelblue"
                x: Theme.paddingLarge
            }
            Label {
                text: qsTr("<a href='https://golang.org/'>GO</a> Copyright © 2012 The Go Authors. All rights reserved.")
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                width: (parent ? parent.width : Screen.width) - Theme.paddingLarge * 2
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                linkColor: "lightsteelblue"
                x: Theme.paddingLarge
            }

            Label {
                text: qsTr("OLYMPUS, Olympus PEN, and Olympus Air are registered trademarks of %1.<br>\
                All other trademarks are property of their respective owners.").arg("OLYMPUS Corporation")
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                width: (parent ? parent.width : Screen.width) - Theme.paddingLarge * 2
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                x: Theme.paddingLarge
            }

            //Label {
            //  text: qsTr("Compiled using GO Runtime %1<br>Application version %2").arg(bridge.runtimeVersion()).arg(bridge.version())
            //  anchors.horizontalCenter: parent.horizontalCenter
            //  wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            //  width: (parent ? parent.width : Screen.width) - Theme.paddingLarge * 2
            //  verticalAlignment: Text.AlignVCenter
            //  horizontalAlignment: Text.AlignLeft
            //  x: Theme.paddingLarge
            //}
        }
    }
}

