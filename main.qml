import QtQuick 2.0
import Sailfish.Silica 1.0

ApplicationWindow {
	id: mainWindow
	cover: Qt.resolvedUrl("Cover.qml")
	initialPage: Component { TrollBridge { id: tbMain } }
	allowedOrientations: Orientation.All
	_defaultPageOrientations: Orientation.All
	JSBridge{ id: bridge }
	//background.wallpaper: wpImage

	// see: https://olympusamerica.com/sites/default/files/2022-02/Olympus-Logo-Usage-Guidelines_1.pdf
	readonly property color olyblue:   "#08107b"
	readonly property color olyyellow: "#e9b226"
	readonly property color olygray:   "#777777"
	readonly property color olywhite:  "#ffffff"

	//background.color: "black"
	background.color: (Theme.colorScheme === Theme.LightOnDark ) ? Theme.highlightDimmerFromColor(olyblue, Theme.colorScheme) : olywhite
	//background.image: (Theme.colorScheme === Theme.LightOnDark ) ?  Qt.resolvedUrl("logo/OlympusLogoWhiteAndGoldRGB.png") : Qt.resolvedUrl("logo/OlympusLogoBlueAndGoldRGB.png")

	palette.primaryColor: (Theme.colorScheme === Theme.LightOnDark ) ? olywhite : olyblack
	palette.secondaryColor: olygray
	palette.highlightColor: olyyellow
	palette.secondaryHighlightColor: Theme.secondaryHighlightFromColor(olyyellow, Theme.colorScheme)
	palette.highlightBackgroundColor: Theme.highlightBackgroundFromColor(olyyellow, Theme.colorScheme)


}

