TARGET = trollbridge
CONFIG += sailfishapp sailfishapp_i18n
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

qml.files = qml
qml.path = $$PREFIX/share/$${TARGET}
INSTALLS += qml

OTHER_FILES += $$files(rpm/*)

include(translations/translations.pri)
