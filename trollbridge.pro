TARGET = trollbridge
CONFIG += sailfishapp_qml sailfishapp_i18n
INCLUDEPATH += .

lupdate_only {
	SOURCES += \
		About.qml\
		Cover.qml\
		ImageList.qml\
		JSBridge.qml\
		Shutter.qml\
		TrollBridge.qml\
		main.qml
}


TRANSLATIONS += translations/$${TARGET}-en.ts \
                translations/$${TARGET}-de.ts \

desktop.files = $${TARGET}.desktop
desktop.path = $$PREFIX/share/applications
INSTALLS += desktop

qml.files = $$files(*.qml) $$files(logo/*.png)
qml.path = $$PREFIX/share/harbour-$${TARGET}/qml/
INSTALLS += qml

OTHER_FILES += $$files(rpm/*)

include(translations/translations.pri)
include(icons/icons.pri)
