TARGET = harbour-trollbridge
CONFIG += sailfishapp_qml sailfishapp_i18n
INCLUDEPATH += .

lupdate_only {
SOURCES += \
    qml/$$files(qml/*.qml)
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
# must be last
include(icons/icons.pri)
