import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: setupPage

    // TODO:
    //   'set_camprop': OlympusCamera.CmdDescr(method='post', args={'com': {'set': {'propname': {'takemode': None, 'drivemode': None, 'focalvalue': None, 'expcomp': None, 'shutspeedvalue': None, 'isospeedvalue': None, 'wbvalue': None, 'artfilter': None, 'colortone': None, 'exposemovie': None, 'colorphase': None}}}}),
    //   'set_utctimediff': OlympusCamera.CmdDescr(method='get', args={'utctime': {'*': {'diff': {'*': None}}}}),
    //
    onStatusChanged: {
        if (status == PageStatus.Deactivating && _navigation == PageNavigation.Back) {
             bridge.switchMode(bridge.opc ? "standalone" : "play")
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            spacing: Theme.horizontalPageMargin
            width: parent.width
            PageHeader { title: qsTr("Camera Setup") }

            DetailItem { label: qsTr("UTC Time Difference"); value: bridge.utcdiff }

            Button {
                text: "Set Date/Time"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: bridge.setTime()
            }

            Separator{}

            ValueButton { label: qsTr("Take Mode")            ; value: ""; onClicked: {} }
            ValueButton { label: qsTr("Drive Mode")           ; value: ""; onClicked: {} }
            ValueButton { label: qsTr("Focal Value")          ; value: ""; onClicked: {} }
            ValueButton { label: qsTr("Exposure Compensation"); value: ""; onClicked: {} }
            ValueButton { label: qsTr("Shutter Speed")        ; value: ""; onClicked: {} }
            ValueButton { label: qsTr("ISO Speed")            ; value: ""; onClicked: {} }
            ValueButton { label: qsTr("White Balance")        ; value: ""; onClicked: {} }
            ValueButton { label: qsTr("Art Filter")           ; value: ""; onClicked: {} }
            ValueButton { label: qsTr("Color Tone")           ; value: ""; onClicked: {} }
            ValueButton { label: qsTr("Color Phase")          ; value: ""; onClicked: {} }
            ValueButton { label: qsTr("Movie Exposure")       ; value: ""; onClicked: {} }
        }
        VerticalScrollDecorator {}
    }
}
