import QtQuick 2.0
import Sailfish.Silica 1.0
import MeeGo.Connman 0.2
import Nemo.DBus 2.0

ApplicationWindow {
    id: mainWindow
    cover: Qt.resolvedUrl("Cover.qml")
    initialPage: Component { TrollBridge { id: tbMain } }
    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All

    PyBridge{ id: bridge }

    property alias online: nwHelper.online
    onOnlineChanged: if (online) bridge.connect()

    // see: https://olympusamerica.com/sites/default/files/2022-02/Olympus-Logo-Usage-Guidelines_1.pdf
    readonly property color olyblue:   "#08107b"
    readonly property color olyyellow: "#e9b226"
    readonly property color olygray:   "#777777"
    readonly property color olywhite:  "#ffffff"
    readonly property color olyblack:  "#000000"

    //background.color: "black"
    background.color: (Theme.colorScheme === Theme.LightOnDark ) ? Theme.highlightDimmerFromColor(olyblue, Theme.colorScheme) : olywhite
    //background.image: (Theme.colorScheme === Theme.LightOnDark ) ?  Qt.resolvedUrl("OlympusLogoWhiteAndGoldRGB.png") : Qt.resolvedUrl("OlympusLogoBlueAndGoldRGB.png")

    palette.primaryColor: (Theme.colorScheme === Theme.LightOnDark ) ? olywhite : olyblack
    palette.secondaryColor: olygray
    palette.highlightColor: olyyellow
    palette.secondaryHighlightColor: Theme.secondaryHighlightFromColor(olyyellow, Theme.colorScheme)
    palette.highlightBackgroundColor: Theme.highlightBackgroundFromColor(olyyellow, Theme.colorScheme)
    palette.highlightDimmerColor: Theme.highlightDimmerFromColor(olyyellow, Theme.colorScheme) 

    NetworkManager {
        id: nwHelper
        readonly property bool online: (!!connectedWifi && connectedWifi.connected)
                                    && ( (/^192\.168\.0\./.test(ip)) && (gw === "192.168.0.10") )
        property var ip: (!!connectedWifi) ? connectedWifi.ipv4["Address"] : ""
        property var gw: (!!connectedWifi) ? connectedWifi.ipv4["Gateway"] : ""
        property var id: (!!connectedWifi) ? connectedWifi.identity : ""
        property var bssid: (!!connectedWifi) ? connectedWifi.bssid : ""
        /*
        onIpChanged: console.debug(
                "IP:",JSON.stringify(ip),
                "ID:",JSON.stringify(id),
                "BSSID:",JSON.stringify(bssid),
                "ALL:",JSON.stringify(connectedWifi,null,2)
        )
        */
    }
    DBusInterface { id: wifi
            service: "com.jolla.lipstick.ConnectionSelector"
            path: "/"
            iface: "com.jolla.lipstick.ConnectionSelectorIf"
            function connect() {
                call( "openConnectionNow", ["wifi"],function(){},function(){})
            }
    }
}

